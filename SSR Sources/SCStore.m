//
//  SCStore.m
//  Singer Song Reader
//
//  Created by Developer on 13/11/01.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SCStore.h"


@implementation SCStore

@synthesize titlePool;
@synthesize artistPool;

- (id)init {
    self = [super init];
    if (self) {

		iTunesStore = [[SMiTunesStore alloc] init];
		track       = [[SMTrack alloc] init];
        
        searching   = NO;
        selfCancel  = NO;
        
        titlePool   = nil;
        artistPool  = nil;
        matchThresholdPool = 0;
        
        matchThreshold = 0;
	}
	
    return self;
}

- (void)dealloc {
	[iTunesStore release];
	[track release];
    [super dealloc];
}

- (void) setDelegate:(id)aDelegate {
	delegate = aDelegate;
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {

	// トラック情報のポインタセット
	[iTunesStore setTrack:track];
	// デリゲートセット
	[iTunesStore setDelegate:self];
	
	[songInformation setStore:iTunesStore];	
}

#pragma mark - Clear

// Panel 表示クリア
- (void) clear {
    
    [songInformation clear];
}

#pragma mark - Search

// iTunes Store 検索実行
- (void) searchWithTitle:(NSString *)aTitle withArtist:(NSString *)aArtist matchThreshold:(NSInteger)threshold {
		
    // 二重検索防止
    if (searching) {
        
        // 検索条件保存
        [self setTitlePool :aTitle];
        [self setArtistPool:aArtist];
        matchThresholdPool = threshold;
        
        // 二重キャンセル防止
        if (!selfCancel) {
            
            selfCancel = YES;
            
            // セルフキャンセル
            [self cancel];
            
            [self waitForSelfCancel];
        }
        
        return;
    }
    
    searching = YES;
    
    // 検索開始表示
    [songInformationPanel setTitle:@"Searching iTunes Store..."];
    [biographyPanel       setTitle:@"Searching..."];
    
    // マッチ率しきい値
    matchThreshold = threshold;
    
	// 国コード取得
	NSString *code = [super userCountryCode];
	
	// 国コード設定
	[iTunesStore setCountryCode:code];
    
    // マッチ率しきい値設定
    [iTunesStore setMatchThreshold:matchThreshold];
	
	// 検索条件をセット
	[track setTitle:aTitle artist:aArtist];

	// 検索実行
	[iTunesStore search];
}

// 検索キャンセル
- (void) cancel {
	//NSLog(@"## cancel");
	[iTunesStore performSelector:@selector(cancel)];
}

// 検索タイムアウト
- (void) timeout {
	//NSLog(@"## timeout");
	[iTunesStore performSelector:@selector(timeout)];
}

// 検索終了受付ハンドラ
- (void) siteDidFinishSearching:(id)sender {
    
    searching = NO;

    if (selfCancel) return;
    
	//NSLog(@"## finish");

	NSInteger songSco = [[sender resultScore] totalScore];
	NSInteger artSco  = [[sender artistScore] totalScore];
    
    BOOL songNoHit = NO;
    BOOL artNoHit  = NO;

	// 最低スコアに達しない場合、Not Found 扱いとする
    if (songSco > 0 && songSco < matchThreshold) {

        [sender markSongAsNoHit];
        songNoHit = YES;
	}

    if (artSco > 0 && artSco < matchThreshold) {

        [sender markArtistAsNoHit];
        artNoHit = YES;
    }
    
    if (songNoHit && artNoHit) {
        
        [sender markAsNoHit];
    }
    
    // Song Information パネル情報表示
	[songInformation display];
	
	// delegate に検索完了通知
	[delegate performSelector:@selector(storeDidFinishSearching:)
				   withObject:self];	
}

// セルフキャンセル待ち
- (void) waitForSelfCancel {
    
    if (!searching) {
        
        selfCancel = NO;
        
        [self searchWithTitle:titlePool withArtist:artistPool matchThreshold:matchThresholdPool];

        return;
    }
    
    [self performSelector:@selector(waitForSelfCancel) withObject:nil afterDelay:0.5];
}

- (SMStoreResult *) srchResult {
	
	return (SMStoreResult *)[iTunesStore srchResult];
}
@end
