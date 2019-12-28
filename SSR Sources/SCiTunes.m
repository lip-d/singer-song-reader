//
//  SCiTunes.m
//  Singer Song Reader
//
//  Created by Developer on 13/10/23.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SCiTunes.h"
#import "iTunes.h"
#import "Deezer.h"


const NSTimeInterval SC_LOOP_INTERVAL    = 0.2;
const NSInteger      SC_LOOP_COUNT       = 2;  // 一定カウントごとに iTunes にアクセスする
const long           SC_iTUNES_TIMEOUT   = 10; // およそ 1 秒に相当 (The time in ticks)
NSString * const noInfoMessage = @"Track information unavailable";

@implementation SCiTunes

@synthesize autosave;
@synthesize autosaveTx;

@synthesize iTunesError;
@synthesize savedTrack;
@synthesize iTunesLED;

@synthesize iTunesData;

@synthesize srchType;
@synthesize perSearchEdited;

@synthesize selectedTracks;

@synthesize arrowsUpDown;

- (id)init {
    self = [super init];
    if (self) {
        
        // UI バインディング
        [self showStatus:SC_STATE_OFF];
        autosave   = [super userAutosave];
        autosaveTx = [super userAutosaveTx];

        // iTunes/Deezer アクセス/データ格納
		iTunesApp = (iTunesApplication *)[[SBApplication alloc] initWithBundleIdentifier:@"com.apple.iTunes"];
        [iTunesApp setDelegate:self];

        // v4.0
        DeezerApp = (DeezerApplication *)[[SBApplication alloc] initWithBundleIdentifier:@"com.deezer.Deezer"];
        if (DeezerApp) {
            [DeezerApp setDelegate:self];
        }
        
        // v4.0
        currentApp      = nil;
        notification    = SC_NTF_NONE;
        
        iTunesData      = [[SMiTunesData alloc] init];
        iTunesNotif     = [[SMiTunesNotif alloc] init];
        savedTrack      = nil;
		iTunesErrorFlag = NO;
        iTunesError     = nil;
		
        // mainLoop 割込みフラグ
		srchType  = SC_AT_SEARCH;
        doTagging         = NO;
        goEditing         = NO;
        goBatchProcessing = NO;
        goOpenFile        = NO;
        
        // batchLoop フラグ
        intervalLock   = NO;
        forcedAutosave = NO;
        
        // 内部使用
		thread          = nil;
		textFieldEdited = NO;
        perSearchEdited = NO;
        
        arrowsUpDown    = NSOffState;
        
        // Lyrics 保存フォルダ取得
        NSString *lyricsFolder = [super userLyricsFolder];
        
        // 存在チェック
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:lyricsFolder];
        
        // 存在しなかったら
        if (!exist) {
            
            // 作成
            [[NSFileManager defaultManager] createDirectoryAtPath:lyricsFolder withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        // Notification 受信設定
        dNtfCenter = [NSDistributedNotificationCenter defaultCenter];
        
        if (DeezerApp) {
            [dNtfCenter addObserver:self
                           selector:@selector(onDeezerNotification:)
                               name:@"DZRPlayerDidStartPlayingNotification"
                             object:@"com.deezer.Deezer"];
        }

        [dNtfCenter addObserver:self
                       selector:@selector(onITunesNotification:)
                           name:@"com.apple.iTunes.playerInfo"
                         object:@"com.apple.iTunes.player"];

        /* Test
        [dNtfCenter addObserver:self
                       selector:@selector(onAnyNotification:)
                           name:nil
                         object:nil];
         */
    }

    return self;
}

- (void)dealloc {
	[iTunesData release];
	[iTunesApp  release];
    [super dealloc];
}

- (void) setDelegate:(id)aDelegate {
	delegate = aDelegate;
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
    
    [[lyricsTextField cell] setBackgroundStyle:NSBackgroundStyleRaised];
    [[iTunesTextField cell] setBackgroundStyle:NSBackgroundStyleRaised];
    
    [[batchButton cell] setBackgroundStyle:NSBackgroundStyleRaised];
    
    // Deezer が既に再生中かチェックする (v4.0)
    if (DeezerApp)
        if ([DeezerApp isRunning]) notification = SC_NTF_DEEZER;
    
	[self performSelector:@selector(startLoop)];
}

- (void) applicationShouldTerminate {

    // 設定保存
    [userDefault setObject:[super dataFromInteger:autosave]   forKey:UDAutosave];
    [userDefault setObject:[super dataFromInteger:autosaveTx] forKey:UDAutosaveTx];
    
    // 即反映
    // Delegate で synchronize 実行
    //[userDefault synchronize];
}

#pragma  mark - Main Loop

//--------------------------
// メイン処理ループ
//--------------------------
- (void) mainLoop {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	static int cnt = 0;

    if (goOpenFile) {

        goOpenFile = NO;
        
        // iTunes LED を OFF にして Loop を抜ける
        [self showStatus:SC_STATE_OFF];
        
        // Open File ダイアログを開く
        [openFile performSelectorOnMainThread:@selector(openDialog)
                                   withObject:nil
                                waitUntilDone:NO]; // モーダルダイアログのため非同期実行

		[pool release];

		// ループを停止
		return;
    }
    
    if (goBatchProcessing) {
        
        // Batch ウィンドウを開く
        [batch performSelectorOnMainThread:@selector(showBatchWindow:)
                               withObject:self
                            waitUntilDone:YES]; // 同期実行
        
        goBatchProcessing = NO;
        
        // iTunes LED を OFF にして Loop を抜ける
        [self showStatus:SC_STATE_OFF];
        
		[pool release];
		
		// ループを停止
		return;
    }
    
	//NSLog(@"## mainLoop %3d", cnt);
    
    //-------------------------
	// Tagging ボタンが押されたら
    //-------------------------
    if (doTagging) {
        
        // Tagging 実行
        [self performSelectorOnMainThread:@selector(tagCurrent:)
                               withObject:[NSNumber numberWithInteger:SC_MA_ACTION]
                            waitUntilDone:YES]; // 同期実行
        if (iTunesErrorFlag) iTunesErrorFlag = NO;
        
        doTagging = NO;
    }
    
    //-------------------------
    // Edit ボタンが押されたら
    //-------------------------
    if (goEditing) {
        
        // iTunes LED を OFF にする
        [self showStatus:SC_STATE_OFF];
        
        // Edit モードへ切替
        [LyricsCtrl performSelectorOnMainThread:@selector(beginEditMode)
                                     withObject:nil
                                  waitUntilDone:YES]; // 同期実行
        
        goEditing = NO;
        
        // タイトルバーに "Editing..." を表示 (Minimum/Panel)
        [self displayWindowTitle];
        
		[pool release];
		
		// ループを抜けて再開待ち
		return;
    }
    
    //----------------------------
    // iTunes 再生トラック情報取得
    //----------------------------
   	BOOL isChanged = NO;

    // 例) SC_LOOP_COUNT: 2
    //     4 回に 1 回 check が実行される。0, 1, 2, 3 (実行), 0, 1, 2, ...
    if (cnt > SC_LOOP_COUNT) {
        isChanged = [self check];
        cnt = 0;
        //NSLog(@"## check");
    } else {
        cnt++;
    }
	
    BOOL goToSearch = NO;
    
    // 曲変更あり
    if (isChanged) {
        
//        NSLog(@"## Song changed.");
        
        // 検索タイプを自動検索に無条件設定 (優先順位: 自動検索 > 手動系検索)
        srchType = SC_AT_SEARCH;
        
        // テキスト編集フラグをリセット
        textFieldEdited = NO;
        
        [songTitle   setStringValue:[iTunesData title]];
		[artistNames setStringValue:[iTunesData artist]];
        
        if ([iTunesData isNotValid]) {
            
            [noInfoAvailable setStringValue:noInfoMessage];
            [noInfoAvailable setHidden:NO];
        } else {
            [noInfoAvailable setHidden:YES];
        }
        
        goToSearch = YES;
    }
    // 曲変更なし
    else {
        
        // 手動系検索の場合
        if (srchType == SC_MA_SEARCH_SAME || srchType == SC_MA_SEARCH_EDIT) {
        
            goToSearch = YES;
        }
    }
    
	// 曲変更あり、検索タイプが手動の場合
	if (goToSearch) {
        
        // Window タイトル表示
        [self displayWindowTitle];
        
		// 検索実行
		[delegate performSelectorOnMainThread:@selector(startSearching:)
								   withObject:self
                                waitUntilDone:NO];
		
		[pool release];
		
		// ループを抜けて再開待ち
		return;
	}

    // 一定時間待機
	[NSThread sleepForTimeInterval:SC_LOOP_INTERVAL];
    
	[pool release];
    
	// ループ
	[self mainLoop];
}

//----------------------------------
// iTunes 再生中トラック情報取得
//----------------------------------
- (BOOL) check {
    
    // 停止後はじめての更新チェック
	static BOOL isFirstTime = YES;
    
    static id targetApp = nil; // 更新チェック対象アプリ
    static id lastApp   = nil; // 前回チェック時の対象アプリ

    // デフォルトのチェック対象は iTunes
    if (!targetApp) targetApp = iTunesApp;
    
    // 通知が来た場合のみ、チェック対象を Deezer に切り替える
    if (notification == SC_NTF_DEEZER) {
        
        targetApp = DeezerApp;
    }
    notification = SC_NTF_NONE;
    
    if (targetApp != lastApp) {
    
        lastApp = targetApp;
        isFirstTime = YES;
    }
    
	// iTunes/Deezer が既に起動されているか
	if ([targetApp isRunning] == NO) {
        
        targetApp = iTunesApp;
        
		[self showStatus:SC_STATE_OFF];
		isFirstTime = YES;
		return NO;
	}
    
	@try {
        
		iTunesErrorFlag = NO;

        int  plyState  = [targetApp playerState];
        
		// 接続中
		if (iTunesErrorFlag) {
			
			// インジケータ GREEN 点滅
			// 点滅アニメーションが止まらないように Main thread 側で実行
			[self performSelectorOnMainThread:@selector(showStatusBlink)
								   withObject:nil
                                waitUntilDone:YES]; // showStatus 実行がダブらないように必ず YES を指定する
			iTunesErrorFlag = NO;
			return NO;
		}
        
        BOOL isPlaying = NO;
        
        if (targetApp == DeezerApp) {
            if (plyState == DeezerEPlSPlaying) isPlaying = YES;
        }else{
            if (plyState == iTunesEPlSPlaying) isPlaying = YES;
        }
        
        // 停止中
		if (!isPlaying) {
            
            targetApp = iTunesApp;

			[self showStatus:SC_STATE_OFF];
			isFirstTime = YES;
			return NO;
        }
	}
	@catch (NSException * e) {
		
		[self showStatus:SC_STATE_RED];
		isFirstTime = YES;
		return NO;
	}
    
	if (isFirstTime) {
		isFirstTime = NO;
		
		// 停止後はじめて更新チェックする直前にクリアする。
		[iTunesData clear];
		
		//NSLog(@"## iTunesData clear");
	}
    
    BOOL     updated = NO;
    NSString *label  = nil;
    
    // 更新チェック
    if (targetApp == DeezerApp) {
        
        updated = [iTunesData updateWith:DeezerApp.loadedTrack];
        label   = @"Deezer";
    }else{
        
        updated = [iTunesData updateWith:iTunesApp.currentStreamTitle
                            currentTrack:iTunesApp.currentTrack
                             iTunesNotif:iTunesNotif];
        label   = @"iTunes";
    }
    
	if ([iTunesData isValid]) [self showStatus:SC_STATE_GREEN];
	else                      [self showStatus:SC_STATE_YELLOW];
    
    // 更新あり
	if (updated) {
        
        // プレーヤーラベル切替
        [iTunesTextField setStringValue:label];
        
        // 現在使用中のプレーヤーをセット
        currentApp = targetApp;
        
        return YES;
	}
	
	return NO;
}

// メイン処理ループ 開始
- (void) startLoop {
    
    // タイムアウトを読取り用 (約 1 秒)に設定
    [iTunesApp setTimeout:SC_iTUNES_TIMEOUT];
	
	if (thread) [thread release];
	
    // mainLoop を別スレッドで実行
    thread = [[NSThread alloc] initWithTarget:self
                                     selector:@selector(mainLoop)
                                       object:nil];
	
	[thread start];
}

// メイン処理ループ 一時停止 (検索時)
- (void) pauseLoop:(NSInteger)aEvent {
    
    // SC_EV_SEARCH_BUTTON    : 検索ボタンが押された
	switch (aEvent) {
		case SC_EV_SEARCH_BUTTON:
            
			// テキストフィールドが変更されている場合
			if (textFieldEdited) {
				
				// 手動検索変更あり
				srchType = SC_MA_SEARCH_EDIT;
			} else {
				
				// 手動検索変更なし
				srchType = SC_MA_SEARCH_SAME;
			}
			
			break;
	}
}

// メイン処理ループ 再開 (検索後)
- (void) resumeLoop {
    
    if (srchType == SC_MA_OPEN_FILE) {

        [openFile closeDialog];
  
        // コンテンツ領域に強制フォーカス移動 (V3.4)
        [mainWindow forceMakeFirstResponderToContentsFirstTextView];
    }
    
    //-------------------------
    // Current Track を保存
    //-------------------------
    [self setSavedTrack:[iTunesData currentTrack]];

    //-------------------------
    // Autosave 実行条件チェック
    //-------------------------
    BOOL doAutosaving = NO;
    
    // Normal モードの場合
    if (share.batchMode == NSOffState) {
        
        doAutosaving = YES;
    }
    // Batch モードの場合
    else {

        // Cancel されたサイトがない場合
        if ([LyricsCtrl isSearchCanceled] == NO) {
            
            doAutosaving = YES;
        }
    }
    
    //-----------------------
    // Autosave
    //-----------------------
    if (doAutosaving) {
        
        if (autosave)   [self autoTagCurrent];
        if (autosaveTx) [self autoTexCurrent];
    }

    // フラグリセット
    // 手動検索で Autosave が走ってしまう現象を修正。フラグリセットを Autosave の後に移動 (V3.4)
    srchType        = SC_AT_SEARCH;
    perSearchEdited = NO;

    //-----------------------
    // Loop 再開
    //-----------------------
    if (share.batchMode == NSOffState) [self performSelector:@selector(startLoop)];
    else                               [self performSelector:@selector(startBatchLoop)];
}

#pragma mark    -   Button Event

// Edit ボタンクリック受付
- (IBAction) editButtonClicked:(id)sender {
    
    // mainLoop 停止依頼
    goEditing = YES;
}

// Edit ボタンクリック受付
- (IBAction) cancelButtonClicked:(id)sender {
    
    // Edit モード解除
    [LyricsCtrl endEditMode];
    
    // タイトルバーの "Editing..." を解除 (Minimum/Panel)
    [self displayWindowTitle];

    // mainLoop 再開
    [self performSelector:@selector(startLoop)];
}

//--------------------------
// Tagging
//--------------------------

// Tag Current ボタンクリック受付
- (IBAction) tagCurrentButtonClicked:(id)sender {
    
    // Local モード
    if ([LyricsCtrl localLyrics]) {
    
        // Tagging 実行
        [self tagCurrent:[NSNumber numberWithInteger:SC_MA_ACTION]];
        if (iTunesErrorFlag) iTunesErrorFlag = NO;

        // Edit モード解除
        [LyricsCtrl endEditMode];
        
        // タイトルバーの "Editing..." を解除 (Minimum/Panel)
        [self displayWindowTitle];
        
        // mainLoop 再開
        [self performSelector:@selector(startLoop)];
    }
    // Site モード
    else {
        doTagging = YES;
    }
}

- (IBAction) texCurrentButtonClicked:(id)sender {
    
    [self texCurrent:[NSNumber numberWithInteger:SC_MA_ACTION]];
}

#pragma mark    -   Save

// 自動 Tagging (Auto-Tag 有効時/Batch モード時)
- (void) autoTagCurrent {
    
    BOOL chkEmpty    = NO;
    BOOL chkPerfect  = NO;
    BOOL chkMedia    = NO;
    BOOL chkSrchType = NO;
    
    BOOL chkAllOk = NO;
    
    // Lyrics nil 確認
    if ([LyricsCtrl localLyrics] == nil) {
        
        chkEmpty = YES;
        
    }
    // nil でない場合
    else {
        // 空確認
        if ([[LyricsCtrl localLyrics] length] == 0) {
            
            chkEmpty = YES;
        }
    }
    
    // 100% マッチ確認
    if ([[[LyricsCtrl selectedSite] resultScore] totalScore] == 100)
        chkPerfect = YES;

    
    // メディア種別確認: ミュージック/ミュージックビデオ
    if (iTunesData.mediaType == SC_MEDIA_MUSIC)
        chkMedia = YES;

    // 検索種別確認: 自動検索/手動検索変更なし (手動検索変更ありを除外する)
    if (srchType == SC_AT_SEARCH || srchType == SC_MA_SEARCH_SAME)
        chkSrchType = YES;
    
    BOOL tagged = NO;


    // Batch モードで、Overwrite オンの場合
    if (share.batchMode && batch.overwrite) {
        
        if (            chkPerfect && chkMedia && chkSrchType) {
            chkAllOk = YES;
        }
    }
    else{
        
        if (chkEmpty && chkPerfect && chkMedia && chkSrchType) {
            chkAllOk = YES;
        }
    }
    
    // 全チェックをクリアしたら
    if (chkAllOk) {
        
        // Autosave 実行
        [self tagCurrent:[NSNumber numberWithInteger:SC_AT_ACTION]];

        if (!iTunesErrorFlag) {
            tagged = YES;
        }
    }
    
    // Batch モードの場合
    if (share.batchMode) {
        
        NSInteger errorCode = LyricsCtrl.errorCode;
        
        if (tagged) {
            
            [batch addTrack:savedTrack type:SC_TRK_AUTOSAVED  errorCode:errorCode];
        }
        else {
            
            if (iTunesErrorFlag) {
                
                [batch addTrack:savedTrack type:SC_TRK_ERROR  errorCode:errorCode];
            }
            else {
                
                if ([[[LyricsCtrl selectedSite] resultScore] totalScore] >= SSLooseMatchThreshold) {
                    
                    [batch addTrack:savedTrack type:SC_TRK_LOOSE_MATCH errorCode:errorCode];
                }
                // No Hit
                else {
                    
                    [batch addTrack:savedTrack type:SC_TRK_NO_HIT errorCode:errorCode];
                }
            }
        }
    }

    // エラーフラグを戻しておく
    iTunesErrorFlag = NO;
}

// 手動 Tagging (エラーの場合は iTunesErrorFlag に YES がセットされる)
- (void) tagCurrent:(NSNumber *)aTaggingAction {
    //                          SC_AT_ACTION: Auto-Tag モードによるもの
    //                          SC_MA_ACTION: Tag Current ボタンによるもの
    doTagging       = NO;
    
    NSInteger taggingAction = [aTaggingAction integerValue];

    // タイムアウトを書込み用 (約 1 分)に設定
    [iTunesApp setTimeout:kAEDefaultTimeout];

    //---------------------------------------------------
    // iTunes 起動チェック処理消去 (v3.1)
    // 起動されていなければ、以後の呼び出しで自動的に起動される
    //---------------------------------------------------
    
    // トラック存在チェック
    if ([savedTrack exists] != YES) {
        
        // アラート表示
        [self showFadeoutAlert:@"Error - No current track."];
        iTunesErrorFlag = YES;
        return;
    }
    
    // トラック一致チェック
    if ([[LyricsCtrl trackIdentifier] isEqualToString:savedTrack.persistentID] == NO) {
        
        // アラート表示
        [self showFadeoutAlert:@"Error - Current track changed."];
        iTunesErrorFlag = YES;
        return;
    }
    
    // 前後空白類を削除しておく (全半角スペース、タブ、改行)
    NSString *lyrTrim = [savedTrack.lyrics stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    // 既存 Lyrics の存在チェック
    if ([lyrTrim length] > 0) {
        
        // Auto tag の場合
        if (taggingAction == SC_AT_ACTION) {
         
            // Batch モードで、Overwrite オンの場合
            if (share.batchMode && batch.overwrite) {
                ;
            }
            else{

                return;
            }
        }
    }

    // 書込み用 Lyrics
    NSString *lyr       = nil;
    SMSite   *site      = [LyricsCtrl selectedSite];
    
    // Local モード
    if ([LyricsCtrl localLyrics]) {

        // 画面に表示されているコンテンツがそのまま書込み用になる
        lyr = [LyricsCtrl displayedLyrics];
    }
    // Site モード
    else {

        // 画面に表示されているのとは別に、Header, Footer も考慮して、
        // 書込み用 Lyrics を組み立てる
        lyr = [self makeLyrics:site];
    }
    
    iTunesErrorFlag = NO;

    //---------------------
    // Save 実行
    //---------------------
    [savedTrack setLyrics:lyr];
    
    if (iTunesErrorFlag) {
        
        // Timeout
        if ([iTunesError code] == -1712) {
            
            // アラート表示
            [self showFadeoutAlert:@"Timeout - Please try again."];

        } else {
            
            NSString *mes = [NSString stringWithFormat:@"Error - Cannot save into iTunes (code:%d)",
                             (int)[iTunesError code]];

            // アラート表示
            [self showFadeoutAlert:mes];
        }
        return;
    }
    // エラーが返らない場合でも・・・ (v4.0)
    else {
        
        // iCloud の場合は・・・
        if ([iTunesData isCloudStored]) {
            
            // 書き込めているか確認する
            // (iCloud Music Library であれば書込可。単に iCloud の場合は書込不可。
            // 実際書込んでみないとどちらかわからない)
            
            // 読み込めなかったら・・・
            if (savedTrack.lyrics.length == 0) {
                
                [self showFadeoutAlert:@"Cannot save into cloud-stored item."];
                iTunesErrorFlag = YES;
                return;
            }
            
        }
    }
    
    // Local モード
    if ([LyricsCtrl localLyrics]) {
        
        // 書込んだ Lyrics を localLyrics に反映する
        [LyricsCtrl setLocalLyrics:lyr];
    }
    // Site モード
    else {
        
        // 書込んだ Lyrics を Site 内に記憶しておく
        [LyricsCtrl setTaggedLyrics:lyr forSite:site];
        
    }
    
    // Tag Current ボタン、Edit ボタン、Lyrics インジケータ制御
    [LyricsCtrl buttonControl:SC_MODE_SITE];

    if (taggingAction == SC_AT_ACTION) {
        
        [fadeoutMessage setText:@"Autosaved" afterDelay:SSFadeoutMessageDuration/2.5];
    } else {
        
        [fadeoutMessage show];
        [fadeoutMessage setText:@"Saved"];
        [fadeoutMessage fadeoutAfterDelay:SSFadeoutMessageDuration];
    }
}

- (void) autoTexCurrent {
    
    BOOL chkPerfect  = NO;
    BOOL chkSrchType = NO;

    // 100% マッチ確認
    if ([[[LyricsCtrl selectedSite] resultScore] totalScore] == 100)
        chkPerfect = YES;

    // 検索種別確認: 自動検索/手動検索変更あり・なし (ファイルオープンを除外する)
    if (srchType == SC_AT_SEARCH || srchType == SC_MA_SEARCH_SAME ||
        srchType == SC_MA_SEARCH_EDIT)
        chkSrchType = YES;
    
    // チェックをクリアしたら
    if (chkPerfect && chkSrchType) {
        
        // Autosave 実行
        [self texCurrent:[NSNumber numberWithInteger:SC_AT_ACTION]];
    }
}

- (void) texCurrent:(NSNumber *)aAction {
    
    SMSite       *site = [LyricsCtrl selectedSite];
    SMSrchResult *res  = [site srchResult];

    // 書込み用 Lyrics
    NSString     *lyr   = [self makeLyrics:site];
    
    if (lyr == nil) {
        return;
    }
    
    NSString     *dir   = nil;
    NSString     *fname = nil;
    BOOL          exist;
    NSError      *err   = nil;
        
    // Artist
    NSString *art = [res.artist stringByReplacingOccurrencesOfString:@"/" withString:@":"];
    
    // Title
    NSString *ttl = [res.title  stringByReplacingOccurrencesOfString:@"/" withString:@":"];
    
    // Artist 名でサブフォルダ作成
    if ([super userSubFolderByArtist]) {
        
        dir = [[super userLyricsFolder] stringByAppendingPathComponent:art];
        
        // 存在チェック
        exist = [[NSFileManager defaultManager] fileExistsAtPath:dir];
        
        // 存在しなかったら
        if (!exist) {
            
            //-------------------------------
            // フォルダ作成
            //-------------------------------
            BOOL ret = [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&err];
            
            if (!ret) {
                
                NSString *mes = [NSString stringWithFormat:@"Error - Cannot create folder (code:%d)", (int)[err code]];
                
                // アラート表示
                [self showFadeoutAlert:mes];
                
                return;
            }
        }

        fname = [NSString stringWithFormat:@"%@.txt", ttl];

    } else {
        
        dir   = [super userLyricsFolder];
        fname = [NSString stringWithFormat:@"%@ - %@.txt", art, ttl];
    }
    
    // フルパス生成
    NSString *path = [dir stringByAppendingPathComponent:fname];
    
    // 既存ファイル存在チェック
    exist = [[NSFileManager defaultManager] fileExistsAtPath:path];
    
    BOOL doSaving = YES;
    
    // 存在する場合
    if (exist) {
        
        // 手動保存の場合
        if ([aAction integerValue] == SC_MA_ACTION) {
            
            NSString *mes = @"The file already exists. Do you want to overwrite it?";
       
            // 上書き確認ダイアログ表示
            NSInteger result = [SSCommon yesOrNoAlertWithMessage:mes info:@""];
            
            // 上書きしない場合
            if (result != NSAlertDefaultReturn) {
                doSaving = NO;
            }
        }
        // 自動保存の場合
        else {
            
            // Batch モードで、Overwrite オンの場合
            if (share.batchMode && batch.overwrite) {
                ;
            }
            else{
                
                doSaving = NO;
            }
        }
    }
    
    if (doSaving) {
        
        //-------------------------------
        // ファイル出力
        //-------------------------------
        BOOL ret = [lyr writeToFile:path
                         atomically:YES encoding:NSUTF8StringEncoding error:&err];

        if (!ret) {
            
            NSString *mes = [NSString stringWithFormat:@"Error - Cannot write file (code:%d)",
                             (int)[err code]];
            
            // アラート表示
            [self showFadeoutAlert:mes];
            
            return;
        }
    }
}

// ヘッダー/フッター設定によって書込み歌詞の内容を組み立てる
- (NSString *) makeLyrics:(SMSite *)aSite {
    
    SMSrchResult *res = [aSite srchResult];
    
    NSString *header = @"";
    
    if ([super userIncludeLyricHeader] == NSOnState) {
        
        header = [aSite lyricHeader];
    }
    
    NSString *footer = @"";
    
    if ([super userIncludeLyricFooter] == NSOnState) {
        
        footer = [aSite lyricFooter:!((BOOL)[super userHideLyricFooterURL])];
    }
    
    NSString *lyr = nil;
    
    // 念のため空チェック (検索中はクリアされて空になっている可能性があるため)
    if (res.lyrics != nil)
        if (res.lyrics.length > 0)
            lyr = [NSString stringWithFormat:@"%@%@%@", header, res.lyrics, footer];
    
    return lyr;
}

#pragma mark - Batch

- (void) startBatchLoop {
    
    // iTunesData 初期化
    [iTunesData clear];
    
    [noInfoAvailable setHidden:YES];

    // タイムアウトを書込み用 (約 1 分)に設定
    [iTunesApp setTimeout:kAEDefaultTimeout];

    if (thread) [thread release];
	
    // batchLoop を別スレッドで実行
    thread = [[NSThread alloc] initWithTarget:self
                                     selector:@selector(batchLoop)
                                       object:nil];
	
	[thread start];
}

- (void) unlockInterval {
    
    // キャンセル
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timer) object:nil];
    
    [batch stopIntervalAnimation];
    
    // 即実行
    [self timer];
}

- (void) batchLoop {
    
    // Interval Lock 解除待ち
    while (intervalLock) {
        
     	[NSThread sleepForTimeInterval:0.5];
    }
    
    // 選択リストの中から順次 Track を取得する
    // 歌詞のない Track のみが返る
    iTunesTrack *track = [batch getTrack];
    
    // リストの最後に到達、または一時停止
    if (track == nil) {
        
        // Batch 画面に完了メッセージ表示
        
        // "Not Found" Playlist ボタン表示
        
        // Close ボタン表示
        
        
        return;
    }

    // iTunesData にデータをセット
    [iTunesData updateWithMusicTrack:track];
    
    // 検索タイプ
    srchType = SC_AT_SEARCH;
    
    // テキスト編集フラグをリセット
    textFieldEdited = NO;
    perSearchEdited = NO;
    
    // タイトル、アーティスト名をディスプレイに表示
    [songTitle   setStringValue:[iTunesData title ]];
    [artistNames setStringValue:[iTunesData artist]];
        
    // Window タイトル表示
    [self displayWindowTitle];
    
    // 検索実行
    [delegate performSelectorOnMainThread:@selector(startSearching:)
                               withObject:self
                            waitUntilDone:NO];
    
    // Interval Lock: ON
    intervalLock = YES;

    // Timer スタート
    [self performSelectorOnMainThread:@selector(startTimer)
                               withObject:nil
                            waitUntilDone:NO];
}

- (void) startTimer {
    
    [self performSelector:@selector(timer) withObject:nil afterDelay:batch.interval];
    
    [batch startIntervalAnimation];
}

- (void) timer {
    
    intervalLock = NO;
}

// Batch モードへ移行
- (IBAction) beginBatchMode:(id)sender {
    
    goBatchProcessing = YES;
    
    // 検索中であれば、中断する
    [delegate performSelector:@selector(cancel:)
                   withObject:self];
    
    // 2) Autosave: ON
    if (autosave == NO) {
        
        // Autosave を強制的に ON
        [self setAutosave:NSOnState];
        
        // 強制 Autosave フラグ: ON
        forcedAutosave = YES;
    }
}

// Batch モード終了 〜 Normal モードへ移行
- (IBAction) endBatchMode:(id)sender {
    
    // Batch ウィンドウを閉じる
    [batch closeBatchWindow];
    
    // Autosave: 元に戻す
    if (forcedAutosave) {
        
        // 強制 Autosave フラグを元に戻す
        forcedAutosave = NO;
        
        // Autosave を OFF に戻す
        [self setAutosave:NSOffState];
    }
    
    // mainLoop 再開
    [self performSelector:@selector(startLoop)];
}

#pragma mark - Open File

// Open File モーダルへ移行
- (IBAction) beginOpenFileModal:(id)sender {
    
    goOpenFile = YES;
    
    // 検索中であれば、中断する
    [delegate performSelector:@selector(cancel:)
                   withObject:self];
}

- (IBAction) openFile:(id)sender {
    
    // まずモーダル終了
    [openFile stopModal];
    
    // 検索タイプ: Local File 表示
    srchType = SC_MA_OPEN_FILE;

    // ダイアログで選択されている歌詞ファイル情報を取得
    SMLocalFile *localFile = [openFile selectedFile];
    
    // タイトル、アーティスト名をディスプレイに表示
    [songTitle   setStringValue:localFile.title];
    [artistNames setStringValue:localFile.artist];


    [noInfoAvailable setHidden:YES];
    
    [self displayWindowTitle];
    
    // 表示実行
    [delegate performSelector:@selector(startSearching:) withObject:self];
}

- (IBAction) endOpenFileModal:(id)sender {

    // まずモーダル終了
    [openFile stopModal];
    
    // 次にダイアログ クローズ
    [openFile closeDialog];

    // mainLoop 再開
    [self performSelector:@selector(startLoop)];
}

#pragma mark - Others

// Appearance に応じた Window タイトルを表示する
- (void) displayWindowTitle {
    
	
	NSString *windowTitle   = @"";
    
    if ([appearance currentMode] == SC_APPEARANCE_FULL) {
        
        if (![iTunesData isEmpty]) {
            
            NSString *source   = [iTunesData source];
            NSString *category = [iTunesData category];
            
            windowTitle = source;
            
            if ([category length]) {
                windowTitle = [NSString stringWithFormat:@"%@ - %@", source, category];
            }
        }
    } else {
        
        NSString *title  = songTitle.stringValue;
        NSString *artist = artistNames.stringValue;

        if (title.length || artist.length) {
            
            windowTitle = title;
            
            if ([artist length]) {
                windowTitle = [NSString stringWithFormat:@"%@ : %@", title, artist];
            }
            
            // Edit モード時
            if ([LyricsCtrl cancelButtonHidden] == NO) {
                
                windowTitle = [NSString stringWithFormat:@"Editing... %@", windowTitle];
            }
            
        } else {
            if (![iTunesData isEmpty])
                windowTitle = noInfoMessage;
        }
    }
    
    // Change (V3.2)
    //[mainWindow  setTitle:windowTitle];
    [titleBarTextField setStringValue:windowTitle];
}

//---------------------------
// 内部使用
//---------------------------

- (void) showStatus:(NSInteger)sts {
	
	static NSInteger ois = -1;
	
	if (sts != ois) {
		ois = sts;
		NSImage *img = [[super SC_STATE] objectAtIndex:sts];
        
        [self setITunesLED:img];
	}
}

- (void) showStatusBlink {

	[self showStatus:SC_STATE_GREEN_OFF_BLINK];
}

- (void) showFadeoutAlert:(NSString *)mes {
    
    // アラート表示
    [fadeoutAlert show];

    [fadeoutAlert setText:mes];
    
    // メッセージにフォーカスセット
    [mainWindow makeFirstResponder:fadeoutAlert.textField];
    
    [fadeoutAlert fadeoutAfterDelay:SSFadeoutAlertDuration];
}

#pragma mark - Controlling iTunes

- (IBAction) nextTrack:(id)sender {
    
    if (currentApp) [currentApp nextTrack];
}

- (IBAction) prevTrack:(id)sender {
    
    if (currentApp) [currentApp previousTrack];
}

- (IBAction) launch:(id)sender {
    
    // まだ起動されていなかったら
    if ([iTunesApp isRunning] == NO) {

        [iTunesApp activate];
    }
}

#pragma mark - Delegate

//---------------------------------------------------
// iTunes アクセスエラー検知 (SBApplicationDelegate)
//---------------------------------------------------
- (id)eventDidFail:(const AppleEvent *)event withError:(NSError *)error {

	iTunesErrorFlag = YES;
    [self setITunesError:error];
	
	//NSLog(@"## error: %@", [[error userInfo] description]);
    //if ([error code] != -1712)
    //    NSLog(@"## error: %d", (int)[error code]);
    
	// Main Thread でなく別スレッドで実行のため AutoreleasePool から外れてしまう
	// 自分で release する。これでメモリリークしない。
    // -> 変更: release により crash する場合があるため、leak はするが、
    //          決して release しない (V3.0)
	//[error release];
	
	return nil;
}

//-----------------------------------
// Title/Artist フィールド イベント検知
//-----------------------------------

// Title/Artist フィールド フォーカス検知
- (void) controlDidBecomeFirstResponder:(id)sender {

	[noInfoAvailable setHidden:YES];
}

// Title/Artist フィールド 編集検知
- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor {
	
	textFieldEdited = YES;
    perSearchEdited = YES;
	
	return YES;
}

// Title/Artist フィールド Enter キー検知
- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command {

    BOOL retVal = NO;
    
    // 改行(Enter)キーが押された場合
    if (command == @selector(insertNewline:)) {
        
        retVal = YES; // デフォルトのアクションでなく、自分でアクションを定義する
        
        // Enter キーがタイプされたことを通知する
        [delegate performSelector:@selector(manualSearch:)
                       withObject:self];

    }
    
    //NSLog(@"Selector = %@", NSStringFromSelector(command));
    
    return retVal;
}

#pragma mark    -   Key Up Event from SCDelegate

- (void) keyUpEvent:(NSEvent *)event {
    
    if (arrowsUpDown == NSOffState) return;
    
    //NSLog(@"SCiTunes KeyUp: %@ [%hu]", [event characters], [event keyCode]);
    
    switch ([event keyCode]) {

        case 125: // ↓
            
            [iTunesApp nextTrack];
            break;
            
        case 126: // ↑

            [iTunesApp previousTrack];
            break;
    }
}

NSInteger SCDetectMedia(iTunesTrack *track) {
    
    NSInteger media;

    //---------------------------------
    // iTunesU 利用可能判定 (v3.8)
    //---------------------------------
    static NSNumber *isITunesUAvailable = nil;
    
    if (isITunesUAvailable == nil) {
        
        if ([track respondsToSelector:@selector(iTunesU)]) {
            
            isITunesUAvailable = [[NSNumber alloc] initWithBool:YES];
        }else{
            
            isITunesUAvailable = [[NSNumber alloc] initWithBool:NO];
        }
    }
    
    BOOL  track_iTunesU = NO;
    
    // iTunesU 利用可の場合
    if (isITunesUAvailable.boolValue) {
        if (track.iTunesU) track_iTunesU = YES;
    }
    
    //---------------------------------
    // podcast 利用可能判定 (v4.3)
    //---------------------------------
    static NSNumber *isPodcastAvailable = nil;
    
    if (isPodcastAvailable == nil) {
        
        if ([track respondsToSelector:@selector(podcast)]) {
            
            isPodcastAvailable = [[NSNumber alloc] initWithBool:YES];
        }else{
            
            isPodcastAvailable = [[NSNumber alloc] initWithBool:NO];
        }
    }
    
    BOOL  track_podcast = NO;
    
    // podcast 利用可の場合
    if (isPodcastAvailable.boolValue) {
        if (track.podcast) track_podcast = YES;
    }
    
    
    if      (track.size == 0)                         media = SC_MEDIA_RADIO;
    else if (track_podcast)                           media = SC_MEDIA_PODCAST;
    else if (track_iTunesU)                           media = SC_MEDIA_ITUNESU;
    else if (track.videoKind == iTunesEVdKMusicVideo) media = SC_MEDIA_MUSIC;
    else if (track.videoKind != iTunesEVdKNone)       media = SC_MEDIA_VIDEO;
    else if (track.duration == 0)                     media = SC_MEDIA_NONE;
    else                                              media = SC_MEDIA_MUSIC;
    
    //NSLog(@"## %d", (int)media);
    
    return media;
}

// Deezer notification 受信用
- (void) onDeezerNotification:(NSNotification *)notif {
    
    //NSLog(@"<-- %@ title=%@", notif.name, [[notif.userInfo valueForKey:@"track"] valueForKey:@"title"]);
    
    notification = SC_NTF_DEEZER;
}

// iTunes notification 受信用
- (void) onITunesNotification:(NSNotification *)notif {
    
    if ([[notif.userInfo valueForKey:@"Player State"] isEqualToString:@"Playing"]) {
        if ([notif.userInfo valueForKey:@"Artist"]) {
            
            iTunesNotif.title        = [notif.userInfo valueForKey:@"Name"];
            iTunesNotif.artist       = [notif.userInfo valueForKey:@"Artist"];
            iTunesNotif.album        = [notif.userInfo valueForKey:@"Album"];
            iTunesNotif.genre        = [notif.userInfo valueForKey:@"Genre"];
            
            // NSCFNumber -> NSString
            iTunesNotif.persistentID = [[notif.userInfo valueForKey:@"PersistentID"] stringValue];
            
            //NSLog(@"## Notif set: %@", iTunesNotif.title);
        }
        else if ([[notif.userInfo valueForKey:@"Name"] isEqualToString:@"Beats 1"]) {
            
            [iTunesNotif clear];
            //NSLog(@"## Notif cleared.");
        }
/*
        else {
            [iTunesNotif clear];
            NSLog(@"## Notif cleared.");
            NSLog(@"## %@", notif.userInfo);
        }
 */
    }
}

// Test
- (void) onAnyNotification:(NSNotification *)notif {

    NSLog(@"## Notification: %@", notif.name);
}
@end
