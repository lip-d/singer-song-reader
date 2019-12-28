//
//  SCDelegate.m
//  Singer Song Reader
//
//  Created by Developer on 13/10/23.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SCDelegate.h"

@implementation SCDelegate

@synthesize window;

@synthesize searchTitle;
@synthesize searchArtist;

SVFieldEditorTextView *titleFieldEditor = nil;
SVFieldEditorTextView *artistFieldEditor = nil;

- (id)init {
    self = [super init];
    if (self) {

        // UI バインディング
        arrowsLeftRight = [super userArrowsLeftRight];
        arrowsUpDown    = [super userArrowsUpDown];
        
		siteListChanged = NO;
		
        [self setSearchTitle:@""];
        [self setSearchArtist:@""];
        
        lyricsDone = YES;
        storeDone  = YES;
	}
    return self;
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark    -   NSApplicationDelegate

- (void) applicationWillFinishLaunching:(NSNotification *)aNotification {
    
	// For Debug: ユーザ設定すべて初期設定に戻す
	//[super clearAllUserDefaults];

    // KeyUp イベントを受け付けるための設定
    //[mainWindow setDelegate:self];
    
    // nextResponder セット
    [songInformationPanel setNextResponder:mainWindow];
    [biographyPanel       setNextResponder:mainWindow];
    
	// メインウィンドウ マウス IN/OUT 判定範囲設定
	[self updateTrackingRect];

    // View 識別タグ (V3.4)
    [mainWindow                                       setDebugTag:  0];
    [mainWindow.contentsForegroundView                setDebugTag: 10];
    [songTitle                                        setDebugTag:101];
    [artistNames                                      setDebugTag:102];

    // Accessibility Window Title 付与 (保留)
//    [mainWindow accessibilitySetOverrideValue:@"Main" forAttribute:NSAccessibilityTitleAttribute];
    
    //--------------------------------------
    // SC クラス初期化処理
    //--------------------------------------

    // 1) Contents: 歌詞 View 取り付け　(一番目に変更 V3.4)
    [contents    setDelegate:self];
	[contents    applicationWillFinishLaunching:aNotification];
    
	// 2) Appearance: 前回のモードを再現
	[appearance  setDelegate:self];
	[appearance  applicationWillFinishLaunching:aNotification];

	// Preference の init 内でソースと UD のサイトリストが同期される
	[preferences setDelegate:self];
	[preferences applicationWillFinishLaunching:aNotification];
	
    // Lyrics
	[lyrics      setDelegate:self];
	[lyrics      applicationWillFinishLaunching:aNotification];
	
    // Font Panel
	[fontPanel   applicationWillFinishLaunching:aNotification];
	
    // Store
	[store       setDelegate:self];
	[store       applicationWillFinishLaunching:aNotification];
	
    // SongInfo
    [songInformation setDelegate:self];
	[songInformation applicationWillFinishLaunching:aNotification];
    
    // Batch
    [batch           setDelegate:self];
    
    // Open File
	[openFile        applicationWillFinishLaunching:aNotification];
    
    [[searchButton cell] setBackgroundStyle:NSBackgroundStyleRaised];
    
    [self setArrowsSetting];
    
    //--------------------------------------------------------------------------------------
    // V3.4
    // 初期フォーカスは TextView に合わせる
    // 理由1: 初期表示の空 Lyrics 状態から Local Lyrics File を開いたときに、"Scroll Area" になるのを
    //       防げるため。
    // 理由2: Local Lyrics File を開いたときに、すぐ VoiceOver に読み上げさせるため
    //--------------------------------------------------------------------------------------
    [mainWindow makeFirstResponderToContentsFirstTextView];

    //--------------------------------------
    // メインウィンドウ表示
    //--------------------------------------
    [mainWindow makeKeyAndOrderFront:self];
	
    //--------------------------------------
	// iTunes チェックループ開始 (最後に呼び出す)
    //--------------------------------------
	[iTunes      setDelegate:self];
	[iTunes      applicationWillFinishLaunching:aNotification];
    
    //--------------------------------------
    // iTunes チェックループ開始 (最後に呼び出す)
    //--------------------------------------
    if ([super userOpeniTunesAtLaunch])
        [iTunes launch:self];

    //--------------------------------------
    // AppNap 対応 (OS 10.9以降) (v3.8)
    //--------------------------------------
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(beginActivityWithOptions:reason:)]) {
        
        // NSActivityBackground: Flag to indicate the app has initiated some kind of work, but not as the direct result of user request.
        
        self.activity = [[NSProcessInfo processInfo] beginActivityWithOptions:NSActivityBackground reason:@"Receiving iTunes state"];
    }
}

- (NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *)sender {

    // Auto-Tagging  設定保存
    [iTunes applicationShouldTerminate];
    
    // BatchInterval 設定保存
    [batch applicationShouldTerminate];
    
    // カラム数 設定保存
    [contents applicationShouldTerminate];
    
    // Show Date Modified 設定保存
    [openFile applicationShouldTerminate];

    // Arrows Shortcuts 設定保存
    [userDefault setObject:[super dataFromInteger:arrowsLeftRight] forKey:UDArrowsLeftRight];
    [userDefault setObject:[super dataFromInteger:arrowsUpDown   ] forKey:UDArrowsUpDown   ];
    
    
    //------------------
	// For Debug
    //------------------
	//[super clearAllUserDefaults];
    

    
    
    // 即反映
    [userDefault synchronize];
	
	return NSTerminateNow;
}

// メインウィンドウクローズ時に、アプリを終了する
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	
	return YES;
}

// アプリケーション切替: アクティブ
- (void)applicationDidBecomeActive:(NSNotification *)aNotification {

    [self setAllWindowLevelFloatingIfVisible];
}

// アプリケーション切替: 非アクティブ
- (void)applicationDidResignActive:(NSNotification *)aNotification {

    [self setAllWindowLevelNormalIfVisible];
}

#pragma mark    -   Search

- (void) startSearching:(id)sender {

#ifdef SS_DEBUG_START_SEARCHING_SEPARATOR
    NSLog(@"## DEBUG -*-*-*-*-*-*-*-*-*-*-*-*-*-*");
#endif
    // Lyrics 検索
    [self lyricsSearch:sender];

    // Batch モードでない場合
    if (share.batchMode == NSOffState) {

#ifndef SS_DEBUG_STORE_OFF
        // Store 検索
        [self storeSearch];
#endif
    }
}

- (void) lyricsSearch:(id)sender {
    
    SMiTunesData *iTunesData = [sender iTunesData];
    
    // サイトタブ更新
    if (siteListChanged) {
        
        [lyrics updateSiteList];
        siteListChanged = NO;
    }
    
    // 検索タイプセット (V3.4)
    [lyrics setSrchType:[sender srchType]];

    // 自動検索の場合
    if ([sender srchType] == SC_AT_SEARCH) {
        
        // メディアタイプ、トラック ID セット
        [lyrics setMediaType      :iTunesData.mediaType];
        [lyrics setTrackIdentifier:iTunesData.persistentId];
    }
    
    // 検索条件保存 (Store 検索用 および Lyrics 検索用)
    // UTF8-Mac -> UTF8 変換 (V3.4)
    // 濁点、半濁点がファイル名に使われていると、検索ヒットしない問題を解消
    [self setSearchTitle :  songTitle.stringValue.convertedStringFromUTF8Mac];
    [self setSearchArtist:artistNames.stringValue.convertedStringFromUTF8Mac];
    
    // 検索条件チェック
	if ([self isValid:searchTitle artist:searchArtist] == NO ||
        [lyrics siteCount] == 0) {
		
		[lyrics clear];       // Lyrics 画面クリア
        [searchButton setState:NSOffState]; // 検索ボタンを戻す
		[iTunes resumeLoop];  // iTunes チェックループ再開
		return;
	}
    
    lyricsDone = NO;
    
    // 検索ボタン制御
    [self searchButtonControl:SCSrchStart];
    
    // 動作モード
    SCMode mode = SC_MODE_NONE;

    // File Lyrics
    NSString *fileLyrics = nil;
    
    //----------------
    // モード切り分け
    //----------------
    // 自動検索
    if ([sender srchType] == SC_AT_SEARCH) {
        
        // Lyrics あり
        if ([iTunesData.lyrics length]) {
            
            // バッチ (上書きモード)
            if (share.batchMode && batch.overwrite) {
                
                mode = SC_MODE_SITE;
            }else{
                
                mode = SC_MODE_LOCAL;
            }
        }
        // Lyrics なし
        else {
            
            // ラジオの場合　(v4.0)
            if (iTunesData.mediaType == SC_MEDIA_RADIO) {
                
                // キャッシュチェック - File Lyrics 取得 (存在しなければ nil)
                fileLyrics = [self fileLyricsWithTitle:searchTitle withArtist:searchArtist];
                
                if (fileLyrics)                 mode = SC_MODE_FILE;
                else                            mode = SC_MODE_SITE;
            }
            // ラジオ以外
            else {
                
                mode = SC_MODE_SITE;
            }
        }
    }
    // 手入力
    else if ([sender srchType] == SC_MA_SEARCH_EDIT) {
        
        // 前回の検索から変更があった場合
        if ([sender perSearchEdited]) {
            
            // キャッシュチェック - File Lyrics 取得 (存在しなければ nil)
            fileLyrics = [self fileLyricsWithTitle:searchTitle withArtist:searchArtist];
            
            if (fileLyrics)                 mode = SC_MODE_FILE;
            else                            mode = SC_MODE_SITE;
        }
        else {
            
            mode = SC_MODE_SITE;
        }
    }
    // 更新 (Refresh)
    else if ([sender srchType] == SC_MA_SEARCH_SAME) {
        
        mode = SC_MODE_SITE;
    }
    // オープンファイル
    else if ([sender srchType] == SC_MA_OPEN_FILE) {
        
        NSString *path = [openFile selectedFile].path;
        NSError  *err  = nil;
        
        fileLyrics = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
        
        mode = SC_MODE_FILE;
    }

    //----------------
    // 検索/表示実行
    //----------------
    if      (mode == SC_MODE_LOCAL) {
        
        // Local lyrics 使用
        [lyrics useLocalLyrics:iTunesData.lyrics];
    }
    else if (mode == SC_MODE_FILE ) {
        
        // File Lyrics 使用
        [lyrics useFileLyrics:fileLyrics];
    }
    else if (mode == SC_MODE_SITE ) {
        
        // Lyrics 検索
        [lyrics searchWithTitle:searchTitle withArtist:searchArtist
                 matchThreshold:SSNormalMatchThreshold];
    }
    
    // Timer スタート
    [self startTimer:SCTypeLyrics srchType:[sender srchType]];
}

- (void) storeSearch {
    
    if ([self isValid:searchTitle artist:searchArtist] == NO) {

        [store clear]; // Store  画面クリア
        return;
    }
    
    storeDone = NO;
    
    // Store 画面クリア
    [store clear];
    
    // Store 検索実行 (しきい値固定: 80%)
    [store searchWithTitle:searchTitle withArtist:searchArtist
            matchThreshold:SSNormalMatchThreshold];
    
    // Store 検索は Timeout なし
}

- (void) startTimer:(NSInteger)srchTarget srchType:(NSInteger)srchType {
    
    [self cancelTimer:srchTarget];

	NSInteger tim = 0;
    
    // 通常モード
    if (share.batchMode == NSOffState) {
    
        if (srchType == SC_AT_SEARCH) {
            
            // 自動実行の場合
            tim = [super userAutoSrchTimeout];
            
        } else {
            
            // 手動実行の場合
            tim = [super userManuSrchTimeout];
        }
    }
    // Batch モード
    else {

        // 基本的には自動検索のタイムアウト時間を使用
        tim = [super userAutoSrchTimeout];
        
        // Batch Interval の方が短かったら
        if (batch.interval < tim) {
            
            // Batch Interval を使用する
            tim = batch.interval;
        }
    }
    
    NSNumber *aSrchTarget = [NSNumber numberWithInteger:srchTarget];
    
    // Timer スタート
    [self performSelector:@selector(timer:) withObject:aSrchTarget afterDelay:tim];
}

- (void) cancelTimer:(NSInteger)srchTarget {
    
    //NSLog(@"## cancel timer");

    NSNumber *aSrchTarget = [NSNumber numberWithInteger:srchTarget];

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timer:) object:aSrchTarget];
}

// 検索タイマー
- (void) timer:(NSNumber *)aSrchTarget {
    
    NSInteger srchTarget = [aSrchTarget integerValue];
    
    //NSLog(@"## timer fire");
    
    // 検索ボタン制御
	[self searchButtonControl:SCSrchCancel];

    if (srchTarget == SCTypeLyrics) {

        if (!lyricsDone) [lyrics timeout];
    } else {
        
        if (!storeDone)  [store  timeout];
    }
}

// 検索キャンセル
- (IBAction) cancel:(id)sender {
    
    // 検索ボタン制御
	[self searchButtonControl:SCSrchCancel];
    
    if (!lyricsDone) [lyrics cancel];
    if (!storeDone)  [store  cancel];
}

- (IBAction) manualSearch:(id)sender {
    
    NSString *ttl = [songTitle   stringValue];
    NSString *art = [artistNames stringValue];
    
    if ([lyrics isEditMode]) {
        
        // 検索ボタンを元に戻す
        [searchButton setState:NSOffState];
        
        return;
    }
    
    if ([self isValid:ttl artist:art]) {
		
        // フォーカス移動
        // (テキストフィールド空で検索ボタンを押してもフォーカスが移動するように)
        // コメントアウト (V3.4)
        //        [mainWindow makeFirstResponder:nil];
        
        if ([searchButton state] == NSOffState) {
            
            [searchButton setState:NSOnState]; // 「×」アイコン
        }
        
        // iTunes mainLoop を一時停止して検索
        // メモ：検索中は mainLoop が停止しているので、何度 pauseLoop を呼んでも
        //      何も起こらない (=>二重検索は発生しない)
        [iTunes pauseLoop:SC_EV_SEARCH_BUTTON];
    } else {
		
        [mainWindow makeFirstResponder:songTitle];
        
        // 検索ボタンを元に戻す
        [searchButton setState:NSOffState];
    }
}

#pragma mark    -   Search Results

// Lyrics 検索終了通知
- (void) lyricsDidFinishSearching:(id)sender {
    
    // Timer キャンセル
    [self cancelTimer:SCTypeLyrics];
    
    lyricsDone = YES;
	
    // 検索ボタン制御
	[self searchButtonControl:SCSrchDone];

    // iTunes チェックループ再開
    [iTunes resumeLoop];
}

// Store 検索終了通知
- (void) storeDidFinishSearching:(id)sender {
	
    // Timeout なし -> Timer キャンセル不要
    
    storeDone = YES;
}

#pragma mark - Event

// 検索/キャンセルボタンクリック
- (IBAction) searchButtonClicked:(NSButton *)sender {
	
	NSInteger state = [sender state];
	
    // 検索
	if (state == NSOnState) {
        
        [self manualSearch:self];
	}
    // キャンセル
    else {
		
        [self cancel:self];
	}
}

// Appearance 変更通知
- (void) appearanceDidChange:(id)sender {
    
	// Window タイトル切替
    [iTunes    displayWindowTitle];
    
    // Lyrics コンテンツ文字色切替 (nil 指定: 画面に表示されている Lyrics を使用する)
    [lyrics    displayContents:nil];
    
    // フォントパネル 文字色変更有効/無効切替
	[fontPanel controlColorButtons];
}

// Contents View 切替え通知
- (void) contentsViewDidSwitched:(id)sender {

    [appearance contentsSetWideFor:[sender currentView]];
}

// Preferences 国コード変更通知
- (void) preferencesCountryChanged:(id)sender {
	
    [self storeSearch];
}

// Preferences サイトリスト変更通知
- (void) preferencesSiteListChanged:(id)sender {
    
    siteListChanged = YES;
}

// Preferences Always on top 変更通知
- (void) preferencesAlwaysOnTopChanged:(id)sender {
    
    if ([super userAlwaysOnTop] == NSOnState) {
        
        [self setAllWindowLevelFloatingIfVisible];
    }
    else {
        
        [self setAllWindowLevelNormalIfVisible];
    }
}

- (void) batchDidStarted:(id)sender {
    
    // Store 画面クリア
    [store clear];
    
    // Batch 開始
    [iTunes startBatchLoop];
}

- (void) batchDidPaused:(id)sender {
    
    if (!lyricsDone) [lyrics cancel];

    [iTunes unlockInterval];
}

- (IBAction) copyArtistAndTitle:(id)sender {
	
	NSString *str = [self getArtistAndTitle];
	
	if ([str length] == 0) {
		return;
	}
	
	// クリップボードへ保存
	NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
	[pasteBoard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    
	[pasteBoard setString:str forType:NSStringPboardType];
}

// ヘルプ SSR WebSite 表示
- (IBAction) showHomepage:(id)sender {
	
	NSString *url = SSHomepageURL;
	
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

// ヘルプ オンライン FAQ 表示
- (IBAction) showFAQs:(id)sender {
	
	NSString *url = SSFAQsURL;
	
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

// ヘルプ コメントページ表示
- (IBAction) showBBS:(id)sender {
	
	NSString *url = SSBBSURL;
	
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

// ヘルプ Donation ページ 表示
- (IBAction) showDonationPage:(id)sender {
	
	NSString *url = SSDonationPageURL;
	
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

- (IBAction) makeTitleFirstResponder:(id)sender {
  
    // Add (V3.2)
    [mainWindow makeKeyAndOrderFront:self];
    
    // Add (V3.4)
    [mainWindow.contentsForegroundView refresh];

    [mainWindow makeFirstResponder:songTitle];
}

- (IBAction) arrowsMenuChanged:(id)sender {
    
    [self performSelector:@selector(setArrowsSetting) withObject:nil afterDelay:0];
}

// 検索ボタン制御
- (void) searchButtonControl:(NSInteger)srchEvent {
    
    // 検索開始
    if (srchEvent == SCSrchStart) {
        
        // Lyrics 検索中
        if (!lyricsDone) {

            // コメントアウト (V3.4)
//            [mainWindow makeFirstResponder:nil];
            
            if ([searchButton state] == NSOffState) {
                
                [searchButton setState:NSOnState]; // 「×」アイコン
            }
        }
    }
    // 検索キャンセル/タイムアウト
    else if (srchEvent == SCSrchCancel) {
        
	}
    // 検索終了
    else {
        
        // Lyrics 検索終了済
        if (lyricsDone) {
            
            [searchButton setState:NSOffState];
        }
    }
}

#pragma mark    -   NSWindowDelegate

// メインウインドウがアクティブになった
- (void)windowDidBecomeMain:(NSNotification *)notification {
    
	[songInfoWindowC setEnabled:YES];
	[songInfoWindowL setEnabled:YES];
	[songInfoWindowR setEnabled:YES];
//    NSLog(@"## MainWindow Became Main");
}

// メインウインドウが非アクティブになった
- (void)windowDidResignMain:(NSNotification *)notification {
    
	[songInfoWindowC setEnabled:NO];
	[songInfoWindowL setEnabled:NO];
	[songInfoWindowR setEnabled:NO];
    //NSLog(@"## MainWindow Resigned Main");
}

// V3.4
- (id)windowWillReturnFieldEditor:(NSWindow *)sender toObject:(id)anObject
{
    if ([anObject isKindOfClass:[SVTextField class]])
    {
        NSInteger tag = [anObject tag];
        
        // Title TextField
        if (tag == 1) {
            
            if (!titleFieldEditor) {
                titleFieldEditor = [[SVFieldEditorTextView alloc] init];
                [titleFieldEditor setFieldEditor:YES];
                
                [titleFieldEditor setDebugTag:105];
            }
            return titleFieldEditor;
        }
        else if (tag == 2) {
            
            if (!artistFieldEditor) {
                artistFieldEditor = [[SVFieldEditorTextView alloc] init];
                [artistFieldEditor setFieldEditor:YES];
                
                [artistFieldEditor setDebugTag:106];
            }
            return artistFieldEditor;
        }
        
    }
    return nil;
}

/* For Debug
- (void)windowDidBecomeKey:(NSNotification *)notification {
    
   //NSLog(@"## %ld", mainWindow.firstResponder.debugTag);

}

- (void)windowDidResignKey:(NSNotification *)notification {
    
    //NSLog(@"## MainWindow Resigned Key");
}
*/

// メインウインドウのリサイズ
- (void)windowDidResize:(NSNotification *)notification {
    
	// マウス IN/OUT 判定範囲設定
	[self updateTrackingRect];
}

// マウス IN/OUT 判定範囲設定
- (void) updateTrackingRect {
    
	static NSView *superview = nil;
	
	static NSTrackingRectTag tag = 0;
	
	if (superview == nil) {
        
		superview = [[mainWindow contentView] superview];
	} else {
        
		// 古い範囲設定を削除
		[superview removeTrackingRect:tag];
	}
	
	// 新たな範囲を設定
	tag = [superview addTrackingRect:[superview bounds] owner:appearance userData:NULL assumeInside:NO];
	
	//NSLog(NSStringFromRect([[[mainWindow contentView] superview] bounds]));
}

#pragma mark    -   Private

- (NSString *)getArtistAndTitle {
	
	NSString *str;
	
	NSString *art = [artistNames stringValue];
	NSString *ttl = [songTitle stringValue];

	str = art;
	
	if ([art length] != 0) {
		if ([ttl length] != 0) {
			
			str = [NSString stringWithFormat:@"%@ - %@", art, ttl];
		}
	} else {
		
		str = ttl;
	}
	
	return str;
}


// 検索条件チェック
- (BOOL) isValid:(NSString *)title artist:(NSString *)artist {
	
	if ([title length] || [artist length]) {
		return YES;
	}
	return NO;
}

- (void) setArrowsSetting {
    
    //NSLog(@"## left/right: %d", (int)arrowsLeftRight);
    //NSLog(@"## up/down   : %d", (int)arrowsUpDown);
    
    [iTunes setArrowsUpDown            :arrowsUpDown];
    
    [lyrics setArrowsLeftRight         :arrowsLeftRight];
    
    [contents setArrowsLeftRight       :arrowsLeftRight];
    [contents setArrowsUpDown          :arrowsUpDown];
    
    [songInformation setArrowsLeftRight:arrowsLeftRight];
    [songInformation setArrowsUpDown   :arrowsUpDown];
}

- (void) setWindowLevelFloatingIfVisible:(NSWindow *)aWindow {
    
    if (aWindow.isVisible) {
        
        [aWindow setLevel:NSFloatingWindowLevel];
    }
}

- (void) setAllWindowLevelFloatingIfVisible {

    if ([super userAlwaysOnTop] == NSOnState) {
        [self setWindowLevelFloatingIfVisible:mainWindow         ];
        [self setWindowLevelFloatingIfVisible:preferencesWindow  ];
    }
    
    [self setWindowLevelFloatingIfVisible:batchWindow         ];
    [self setWindowLevelFloatingIfVisible:songInformationPanel];
    [self setWindowLevelFloatingIfVisible:biographyPanel      ];
}

- (void) setWindowLevelNormalIfVisible:(NSWindow *)aWindow {
    
    if (aWindow.isVisible) {
        
        [aWindow setLevel:NSNormalWindowLevel];
        [aWindow orderWindow:NSWindowAbove relativeTo:mainWindow.windowNumber];
    }
}

- (void) setAllWindowLevelNormalIfVisible {

    if ([super userAlwaysOnTop] == NSOnState) {
        ;
    }
    else {
        
        [self setWindowLevelNormalIfVisible:mainWindow          ];
        [self setWindowLevelNormalIfVisible:preferencesWindow   ];
        [self setWindowLevelNormalIfVisible:batchWindow         ];
        [self setWindowLevelNormalIfVisible:songInformationPanel];
        [self setWindowLevelNormalIfVisible:biographyPanel      ];
    }
}

// File Lyrics 取得 (存在しなければ nil 返却)
- (NSString *) fileLyricsWithTitle:(NSString *)aTitle withArtist:(NSString *)aArtist {
    
    NSString     *dir   = nil;
    NSString     *fname = nil;
    BOOL          exist;
    NSError      *err   = nil;
    
    // Artist
    NSString *art = [aArtist stringByReplacingOccurrencesOfString:@"/" withString:@":"];
    
    // Title
    NSString *ttl = [aTitle  stringByReplacingOccurrencesOfString:@"/" withString:@":"];
    
    // Artist 別フォルダ構造
    if ([super userSubFolderByArtist]) {
        
        dir = [[super userLyricsFolder] stringByAppendingPathComponent:art];
        
        fname = [NSString stringWithFormat:@"%@.txt", ttl];
    }
    // フラットフォルダ構造
    else {
        
        dir   = [super userLyricsFolder];
        fname = [NSString stringWithFormat:@"%@ - %@.txt", art, ttl];
    }
    
    // フルパス生成
    NSString *path = [dir stringByAppendingPathComponent:fname];
    
    // 既存ファイル存在チェック
    exist = [[NSFileManager defaultManager] fileExistsAtPath:path];
    
    // 存在する場合
    if (exist) {
        
        NSString *fileLyrics = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];

        return fileLyrics;
    }
    else {
        
        return nil;
    }
}

#pragma mark    -   NSResponder
/*
- (void)cancelOperation:(id)sender
{
    [iTunes cancelButtonClicked:self];
}
*/

#pragma mark    -   Key Up Event from SVWindow

- (void) keyUpEvent:(NSEvent *)event {
    
    //NSLog(@"SCDelegate KeyUp: %@ [%hu]", [event characters], [event keyCode]);
    
    // Batch モードでない場合
    if (share.batchMode == NSOffState) {

        [iTunes keyUpEvent:event];
        [lyrics keyUpEvent:event];
    }
}

@end
