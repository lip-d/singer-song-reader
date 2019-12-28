//
//  SCOpenFile.m
//  Singer Song Reader
//
//  Created by Developer on 4/25/14.
//
//

#include <sys/types.h>
#include <sys/stat.h>
#include <fts.h>

#import "SCOpenFile.h"

@implementation SCOpenFile

- (id)init {
    self = [super init];
    if (self) {
        
        // UI バインディング
        showDateModified   = [super userShowDateModified];
    }
    
    return self;
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {

    // Show Date Modified Checkbox ON/OFF 設定
    [self showDateModified:showDateModified];

    // 初期表示時のソート順指定: ファイル作成日付
    NSSortDescriptor *mdateSort = [[[NSSortDescriptor alloc]initWithKey:@"mdate" ascending:NO] autorelease];
    
    [localFilesArrayController setSortDescriptors:[NSArray arrayWithObject:mdateSort]];
    
    if ([localFilesScrollView respondsToSelector:@selector(setVerticalScrollElasticity:)]) {
        
        [localFilesScrollView   setVerticalScrollElasticity:NSScrollElasticityNone];
    }
    
    // Modified Date - Relative date 設定
    if ([mDateFormatter respondsToSelector:@selector(setDoesRelativeDateFormatting:)]) {

        [mDateFormatter setDoesRelativeDateFormatting:YES];
    }
 }

- (void) applicationShouldTerminate {
    
    // 設定保存
    [userDefault setObject:[super dataFromInteger:showDateModified] forKey:UDShowDateModified];
}

- (void) openDialog {
    
//    NSDate *startDate, *endDate;
//    NSTimeInterval interval;
    
    // Lyrics フォルダ自体、または配下の Artist フォルダの最新更新日時
    NSDate *lastDate = nil;
    
//    startDate = [NSDate date];
    
    // Lyrics フォルダ配下のファイルを取得し、配列化する。
    NSArray *localFilesArray = [self getLocalFiles:&lastDate];

//    endDate = [NSDate date];
    
//    interval = [endDate timeIntervalSinceDate:startDate];

//    NSLog(@"## Get local files: %.3fs", interval);
    
    static NSDate *cmpDate = nil;
    
    BOOL updateNeeded = NO;
    
    if (cmpDate == nil) {
        
        updateNeeded = YES;
    } else {
        
        if ([cmpDate compare:lastDate] != NSOrderedSame) {
            
            updateNeeded = YES;
        }
    }
    
    // フォルダ配下に更新があった場合のみ、画面のリストを更新する
    if (updateNeeded) {
        
//        startDate = [NSDate date];
        
        // ArrayController にセットする。
        [localFilesArrayController setContent:localFilesArray];
        
//        endDate = [NSDate date];
    
//        interval = [endDate timeIntervalSinceDate:startDate];
        
//        NSLog(@"## File list updated %.3fs", interval);

        if (cmpDate != nil) [cmpDate release];
        cmpDate = [lastDate retain];
    }

    // メインメッセージ更新
    NSString *mainMes;
    NSString *fnumMes;
    
    int fileCount = localFilesArray.count;
    
    if      (fileCount == 0) fnumMes = @"0 item in total.";
    else if (fileCount == 1) fnumMes = @"1 item in total.";
    else
        fnumMes = [NSString stringWithFormat:@"%d items in total.", fileCount];
    
    mainMes = [NSString stringWithFormat:@"Type the keywords to filter the files below. %@", fnumMes];
    
    [mainMessageTextField setStringValue:mainMes];
    
    // Search フィールドにフォーカスセット
    [openFileWindow makeFirstResponder:searchField];
    
    // モーダルモードでウィンドウオープン
    [NSApp runModalForWindow:openFileWindow];
}

- (void) stopModal {
    
    [NSApp stopModal];
}

- (void) closeDialog {

    [openFileWindow close];
}

- (SMLocalFile *) selectedFile {
 
    SMLocalFile *localFile = nil;
    
    NSArray *selectedObjects = [localFilesArrayController selectedObjects];
    
    if (selectedObjects.count > 0) {
        
        localFile = [selectedObjects objectAtIndex:0];
    }
    
    return localFile;
}

- (NSArray *) getLocalFiles:(NSDate **)aLastDate {
 
    NSMutableArray *localFilesArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];

    time_t last_time = 0;

    char *ssrDir = (char *)[[super userLyricsFolder] cStringUsingEncoding:NSUTF8StringEncoding];
    
    char *paths[] = {ssrDir, NULL};

    FTS *fts = fts_open(paths, 0, NULL);
    
    FTSENT *entry;
    while ((entry = fts_read(fts))) {
        
        short dirLevel = entry->fts_level;
        
        if (dirLevel > 2) continue;
        
        // ディレクトリ (SSR ディレクトリと、その配下のアーティストディレクトリ)
        if (entry->fts_info & FTS_D) {
            
            if (entry->fts_statp->st_mtime > last_time) {
                
                last_time = entry->fts_statp->st_mtime;
            }
        }
        // ファイル
        else if (entry->fts_info & FTS_F) {
            
            // ファイル名のみを取得
            NSString *file = [NSString stringWithUTF8String:entry->fts_name];
            
            if (![[file pathExtension] isEqualToString:@"txt"]) continue;
            
            NSString *name = file.stringByDeletingPathExtension;
            
            NSArray *components;
            
            // Artist - Title.txt の場合
            if (dirLevel == 1) {
                
                components = [name componentsSeparatedByString:@" - "];
            }
            // Artist/Title.txt   の場合
            else {
                
                NSString *parent = [NSString stringWithUTF8String:entry->fts_parent->fts_name];
                
                components = @[parent, name];
            }

            // Local Lyrics オブジェクト作成
            if (components.count == 2) {
                
                SMLocalFile *localFile = [[[SMLocalFile alloc] init] autorelease];
                
                localFile.artist = [components objectAtIndex:0];
                localFile.title  = [components objectAtIndex:1];
                localFile.path   = [NSString stringWithUTF8String:entry->fts_path];
                localFile.mdate  = [NSDate dateWithTimeIntervalSince1970:entry->fts_statp->st_mtime];
                
                [localFilesArray addObject:localFile];
            }
        }
    }
    
    fts_close(fts);
    
    *aLastDate = [NSDate dateWithTimeIntervalSince1970:last_time];
    
    return localFilesArray;
}


- (IBAction) showDateModifiedCheckboxClicked:(id)sender {

    [self showDateModified:[sender state]];
}

- (void) showDateModified:(NSInteger)flag {
    
    if (flag) {
        
        [[localFilesTableView tableColumnWithIdentifier:@"DTM"] setHidden:NO];
    }
    else {
        
        [[localFilesTableView tableColumnWithIdentifier:@"DTM"] setHidden:YES];
    }
}

#pragma mark - NSTextFieldDelegate

// Search フィールド Enter キー検知
- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command {
    
    BOOL retVal = NO;
    
    // 改行(Enter)キーが押された場合
    if (command == @selector(insertNewline:)) {
        
        retVal = YES; // デフォルトのアクションでなく、自分でアクションを定義する
    
        // TableView の第一行を選択
        [localFilesArrayController setSelectionIndexes:[NSIndexSet indexSetWithIndex:0]];
        
        // TableView にフォーカス移動
        [openFileWindow makeFirstResponder:localFilesTableView];
    }
    
    //NSLog(@"Selector = %@", NSStringFromSelector(command));
    
    return retVal;
}

@end
