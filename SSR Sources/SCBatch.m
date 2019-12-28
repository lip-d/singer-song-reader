//
//  SCBatch.m
//  Singer Song Reader
//
//  Created by Developer on 2014/03/05.
//
//

#import "SCBatch.h"
#import "SCiTunes.h"
#import "iTunes.h"

@interface SCBatch ()
@property (retain) NSDate *pausedDate;
@end

@implementation SCBatch

@synthesize valAutosaved;
@synthesize valNoHit;
@synthesize valSkipped;
@synthesize valLooseMatch;

@synthesize interval;
@synthesize overwrite;
@synthesize paused;

@synthesize iTunesError;
@synthesize iTunesTracks;

@synthesize pausedDate;

- (id)init {
    self = [super init];
    if (self) {
        
        // UI バインディング
        [self setValAutosaved :0];
        [self setValNoHit     :0];
        [self setValSkipped   :0];
        [self setValLooseMatch:0];
        
        [self setInterval:[super userBatchInterval]];
        [self setOverwrite:NSOffState];
        [self setPaused:YES];
        
        // iTunes アクセス/データ格納
		iTunesApp = (iTunesApplication *)[[SBApplication alloc] initWithBundleIdentifier:@"com.apple.iTunes"];
        [iTunesApp setLaunchFlags:kLSLaunchDontSwitch];
		[iTunesApp setDelegate:self];

        //---------------------
        // 選択 Tracks (From)
        //---------------------
        iTunesTracks    = nil;
        iTunesTracksTotal = 0;

        //---------------------
        // 格納先 Tracks (To)
        //---------------------
        aryAutosaved    = [[NSMutableArray alloc] initWithCapacity:0];
        aryNoHit        = [[NSMutableArray alloc] initWithCapacity:0];
        aryExisting     = [[NSMutableArray alloc] initWithCapacity:0];
        aryNonMusicFile = [[NSMutableArray alloc] initWithCapacity:0];
        aryNonMusicZero = [[NSMutableArray alloc] initWithCapacity:0];
        aryError        = [[NSMutableArray alloc] initWithCapacity:0];
        aryLooseMatch   = [[NSMutableArray alloc] initWithCapacity:0];
        
        iTunesErrorFlag = NO;
        iTunesError     = nil;
    }
    
    return self;
}

- (void)dealloc {
    
    [iTunesApp release];
    
    [aryAutosaved    release];
    [aryNoHit        release];
    [aryExisting     release];
    [aryNonMusicFile release];
    [aryNonMusicZero release];
    [aryError        release];
    [aryLooseMatch   release];
    
    [super dealloc];
}

- (void) setDelegate:(id)aDelegate {
	delegate = aDelegate;
}

- (void) applicationShouldTerminate {
    
    // 設定保存
    [userDefault setInteger:interval forKey:UDBatchInterval];
}

#pragma mark - Window open/close

- (IBAction) showBatchWindow:(id)sender {
    
    //------------------------------
    // 選択 Tracks 初期化 (From)
    //------------------------------
    [self setITunesTracks:nil];
    iTunesTracksTotal = 0;
    
    //------------------------------
    // 格納先 Tracks 初期化 (To)
    //------------------------------
    [aryAutosaved    removeAllObjects];
    [aryNoHit        removeAllObjects];
    [aryExisting     removeAllObjects];
    [aryNonMusicFile removeAllObjects];
    [aryNonMusicZero removeAllObjects];
    [aryError        removeAllObjects];
    [aryLooseMatch   removeAllObjects];
	
    // 合わせてカウンタも初期化
    [self setValAutosaved :0];
    [self setValNoHit     :0];
    [self setValSkipped   :0];
    [self setValLooseMatch:0];
    
    // メッセージ初期化
    [mainMessageTextField setStringValue:@"Select iTunes tracks, then press \"Add Lyrics\"."];
    
    [subMessageTextField  setStringValue:@" "];
    
    // プログレスバー初期化
    [mainProgressBar      setDoubleValue:0];
    [intervalBar          setHidden:YES];
    
    // 数値: 非表示
    [valLayer             setHidden:YES];
    
    // 各数値: 表示リセット
    [valProcessedTextField  setStringValue:@""];
    [valPercengageTextField setStringValue:@""];
    
    [blueCheckImageView     setAlphaValue:0];
    [squareLedImageView     setAlphaValue:0];
    [greenCheckImageView    setHidden:YES];
    
    // 結果レイヤー: 非表示
    [resAutosaved           setHidden:YES];
    [resNoHit               setHidden:YES];
    [resSkipped             setHidden:YES];
    [resLooseMatch          setHidden:YES];
    [resLayer               setAlphaValue:0];
    
    // Help レイヤー: 非表示
    [helpLayer              setHidden:YES];
    [mainProgressBar        setHidden:NO];
    
    
    // Start ボタンのタイトルを Add Lyrics に設定する
    [startButton setTitle:@"Add Lyrics"];
    
    // ボタン
    [startButton          setHidden:NO];
    [pauseButton          setHidden:YES];
    [closeButton          setHidden:NO];
    [backButton           setHidden:YES];
    
    [checkButton          setHidden:NO];
    
    [overwriteCheckbox    setHidden:NO];
    
    // Batch モードへ切替
    [share setBatchMode:NSOnState];
    
    // Song Info クローズ
    if ([songInfoPanel isVisible]) {
        [songInfoPanel close];
    }
    
    // Biography クローズ
    if ([biographyPanel isVisible]) {
        [biographyPanel close];
    }

    // Batch ウィンドウオープン
    [batchWindow setLevel:NSFloatingWindowLevel];
    [batchWindow makeKeyAndOrderFront:self];
    
    // Start ボタンにフォーカス
    //[batchWindow makeFirstResponder:startButton];
    [batchWindow makeFirstResponder:mainMessageTextField];
}

- (void) closeBatchWindow {
    
    // Batch モード終了
    [share setBatchMode:NSOffState];
    
    [batchWindow close];
}

#pragma mark - Processing

- (IBAction) checkButtonClicked:(id)sender {
    
    NSArray *selection = [self getITunesSelection];

    int count = selection.count;
    
    NSString *mes = nil;
    
    if (count == 1) {
        
        mes = @"1 track selected.";
    }
    else if (count > 0) {
        
        mes = [NSString stringWithFormat:@"%d tracks selected.", count];
    } else {
        
        mes = @"0 track selected.";
    }
    
    [subMessageTextField setStringValue:mes];
}

// Start/Resume ボタンクリック時
- (IBAction) startButtonClicked:(id)sender {
    
    [self setPaused:NO];
    
    // 画面表示後の初回 Start の場合
    if (iTunesTracks == nil) {
        
        //-----------------------------------
        // 選択 iTunes トラック取得
        //-----------------------------------
        NSArray *selectedTracks = [self getITunesSelection];
        
        NSInteger selectedTracksCount = selectedTracks.count;
        
        // Track 数チェック
        if (selectedTracksCount == 0) {
            
            [subMessageTextField setStringValue:@"No selection. Please select one or more tracks."];
            return;
        }
        
        //------------------------------
        // 選択 Tracks セット
        //------------------------------
        [self setITunesTracks:selectedTracks];
        iTunesTracksTotal   = selectedTracksCount;
        
        // メッセージ: 非表示
        [mainMessageTextField   setStringValue:@""];
        [subMessageTextField    setStringValue:@""];
        
        // 進捗率初期表示
        NSString *mes = [NSString stringWithFormat:@"Complete: 0 of %d", (int)iTunesTracksTotal];
        
        [valProcessedTextField  setStringValue:mes];
        [valPercengageTextField setStringValue:@"0 %"];

        // 各種数値表示
        [valLayer               setHidden:NO];
    }

    //--------------------------
    // 画面に各種数値を表示
    //--------------------------
    
    // ボタン
    [startButton setHidden:YES];
    [pauseButton setHidden:NO];
    [closeButton setHidden:YES];
    [checkButton setHidden:YES];
    [backButton  setHidden:YES];
    [overwriteCheckbox setHidden:YES];
    
    // Pause ボタンにフォーカス
    [batchWindow makeFirstResponder:pauseButton];
    
    [intervalBar setHidden:YES];
    
    // 結果レイヤー: 非表示
    [resAutosaved  setEnabled:NO];
    [resNoHit      setEnabled:NO];
    [resSkipped    setEnabled:NO];
    [resLooseMatch setEnabled:NO];
    [self startFadeoutView:resLayer];

    // Help レイヤー: 非表示
    //[helpLayer              setHidden:YES];
    //[mainProgressBar        setHidden:NO];
    
    // Batch 開始通知
    [delegate performSelector:@selector(batchDidStarted:)
                   withObject:self];
}

- (IBAction) pauseButtonClicked:(id)sender {
    
    [self setPaused:YES];
    
    // Batch 中断通知
    [delegate performSelector:@selector(batchDidPaused:)
                   withObject:self];
}

- (IBAction) resultIconClicked:(id)sender {
    
    iTunesPlaylist *newPlayList;
    
    NSMutableArray *jointTracks = [NSMutableArray arrayWithCapacity:0];
    
    switch ([sender tag]) {
        // Autosaved
        case 0:
            newPlayList = [self createPlaylistFrom:aryAutosaved
                                              name:@"Autosaved"];
            break;
            
        // No Hit
        case 1:
            newPlayList = [self createPlaylistFrom:aryNoHit
                                              name:@"No Hit"];
            break;
            
        // Skipped
        case 2:
            
            // 結合順: Existing + NonMusicFile + Error
            [jointTracks addObjectsFromArray:aryExisting];
            [jointTracks addObjectsFromArray:aryNonMusicFile];
            [jointTracks addObjectsFromArray:aryError];
            
            // + NonMusicZero
            newPlayList = [self createPlaylistFrom:jointTracks
                                       radioTracks:aryNonMusicZero
                                              name:@"Skipped"];
            
            break;
        
        // Loose Match
        case 3:
            newPlayList = [self createPlaylistFrom:aryLooseMatch
                                              name:@"Loose Match"];
            break;
    }
    
    // Playlist 画面表示
    [newPlayList reveal];
}

- (IBAction) helpIconClicked :(id)sender {
    
    [helpLayer setHidden:!(helpLayer.isHidden)];
    
    [mainProgressBar setHidden:!(helpLayer.isHidden)];
}

- (void) startIntervalAnimation {
    
    [intervalBar setFrameSize:NSMakeSize(0, 2)];
    
    [intervalBar setHidden:NO];

    NSTimeInterval duration = interval;
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:duration];
    [[intervalBar animator] setFrameSize:NSMakeSize(300, 2)];
    [NSAnimationContext endGrouping];
}

- (void) stopIntervalAnimation {
 
    [intervalBar setHidden:YES];
}

#pragma mark - Get Track (Public)

// Track 取得 + Index インクリメント
- (iTunesTrack *) getTrack {
    
    iTunesTrack *track = nil;
    
    while ([self completeCount]  < iTunesTracksTotal) {
        
        // 中断フラグが立ったら
        if (paused) {
            
            // nil を返して batchLoop を止める
            track = nil;
            break;
        }
        
        iTunesTrack *trk = [iTunesTracks objectAtIndex:[self completeCount]];

        
        // メディアの種類判別
        NSInteger media = SCDetectMedia(trk);
        
        // ミュージックの場合
        if (media == SC_MEDIA_MUSIC) {
            
            NSString *lyr = [trk.lyrics stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            // 既存の歌詞がない場合
            if (lyr.length == 0) {
                
                track = trk;
                break;
            }
            // 歌詞がある場合
            else {
                
                if (overwrite) {
                    track = trk;
                    break;
                }
                else {
                    [self addTrack:trk type:SC_TRK_EXISTING errorCode:0];
                }
            }
        }
        // ミュージック以外の場合
        else {
            
            if (trk.size) {
                [self addTrack:trk type:SC_TRK_NON_MS_FILE errorCode:0];
            }
            else {
                [self addTrack:trk type:SC_TRK_NON_MS_ZERO errorCode:0];
            }
        }
    }
    
    if (track == nil) {
        
        [self setPausedDate:[NSDate date]];
        
        // 完了した場合
        if ([self completeCount] == iTunesTracksTotal) {
            
            // ボタン
            [startButton  setHidden:YES];
            [pauseButton  setHidden:YES];
            [closeButton  setHidden:NO];
            [backButton   setHidden:NO];


        }
        // 中断された場合
        else {
            
            // Start ボタンのタイトルを Resume に変更する
            [startButton setTitle:@"Resume"];
            
            // ボタン
            [startButton  setHidden:NO];
            [pauseButton  setHidden:YES];
            [closeButton  setHidden:NO];
            [backButton   setHidden:NO];
            
            // Resume ボタンにフォーカス
            [batchWindow makeFirstResponder:startButton];
        }

        // 結果レイヤー: 表示
        if (valAutosaved  > 0) {[resAutosaved  setHidden:NO]; [resAutosaved  setEnabled:YES];}
        if (valNoHit      > 0) {[resNoHit      setHidden:NO]; [resNoHit      setEnabled:YES];}
        if (valSkipped    > 0) {[resSkipped    setHidden:NO]; [resSkipped    setEnabled:YES];}
        if (valLooseMatch > 0) {[resLooseMatch setHidden:NO]; [resLooseMatch setEnabled:YES];}
        //[self startFadeinView:resLayer]; // OS X 10.6.8 で動作しない
        [resLayer               setAlphaValue:1.0];

        // Interval Bar を隠す
        [intervalBar setHidden:YES];
    }
    
    return track;
}

#pragma mark - Add Track (Public)

- (void) addTrack:(iTunesTrack *)track type:(NSInteger)type errorCode:(NSInteger)errorCode {
    
    switch (type) {
        case SC_TRK_AUTOSAVED:
            [self addAutosaved:track];
            break;
        case SC_TRK_NO_HIT:
            [self addNoHit:track      errorCode:errorCode];
            break;
        case SC_TRK_LOOSE_MATCH:
            [self addLooseMatch:track errorCode:errorCode];
            break;
        case SC_TRK_EXISTING:
            [self addExisting:track];
            break;
        case SC_TRK_NON_MS_FILE:
            [self addNonMusicFile:track];
            break;
        case SC_TRK_NON_MS_ZERO:
            [self addNonMusicZero:track];
            break;
        case SC_TRK_ERROR:
            [self addError:track];
            break;
    }
    
    // 進捗率を更新
    [self updateProgress];
}

#pragma mark - Add Track (Private)

// 1) Autosaved トラック
- (void) addAutosaved:(iTunesTrack *)track {
    
    [aryAutosaved addObject:track];
    
    //----------------------------
    // Autosaved カウント更新
    //----------------------------
    [self setValAutosaved:valAutosaved+1];
    
    // ブルーチェック 表示時間調整
    NSTimeInterval deduction = 0;
    if (interval < 10) deduction = (10 - interval) * 0.1;
    
    // ブルーチェック表示〜フェイドアウト
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startFadeoutView:) object:blueCheckImageView];
    [blueCheckImageView setAlphaValue:1.0];
    [self performSelector:@selector(startFadeoutView:) withObject:blueCheckImageView afterDelay:SSFadeoutImageDuration-deduction];
}

// 2) No Hit トラック
- (void) addNoHit:(iTunesTrack *)track errorCode:(NSInteger)errorCode {
    
    [aryNoHit addObject:track];
    
    //------------------
    // No Hit カウント更新
    //------------------
    [self setValNoHit:valNoHit+1];
    
    // LED 表示〜フェイドアウト
    [self showSquareLED:errorCode];
}

// 3) Loose Match トラック
- (void) addLooseMatch:(iTunesTrack *)track errorCode:(NSInteger)errorCode {
    
    [aryNoHit      addObject:track];
    [aryLooseMatch addObject:track];
    
    //------------------
    // No Hit カウント更新
    //------------------
    [self setValNoHit:valNoHit+1];
    
    //------------------------
    // Loose Match カウント更新
    //------------------------
    [self setValLooseMatch:valLooseMatch+1];
    
    // LED 表示〜フェイドアウト
    [self showSquareLED:errorCode];
}

// 4) 既存歌詞あり トラック
- (void) addExisting:(iTunesTrack *)track {
    
    [aryExisting addObject:track];
    
    //-------------------
    // Skipped カウント更新
    //-------------------
    [self setValSkipped:valSkipped+1];
}

// 5) Music 以外のトラック
- (void) addNonMusicFile:(iTunesTrack *)track {
    
    [aryNonMusicFile addObject:track];
    
    //-------------------
    // Skipped カウント更新
    //-------------------
    [self setValSkipped:valSkipped+1];
}

// 6) Radio トラック (size: 0)
- (void) addNonMusicZero:(iTunesTrack *)track {
    
    [aryNonMusicZero addObject:track];
    
    //-------------------
    // Skipped カウント更新
    //-------------------
    [self setValSkipped:valSkipped+1];
}

// 7) Error トラック
- (void) addError:(iTunesTrack *)track {
    
    [aryError addObject:track];
    
    //-------------------
    // Skipped カウント更新
    //-------------------
    [self setValSkipped:valSkipped+1];
}

#pragma mark - Private

- (NSInteger) completeCount {
    
    return valAutosaved + valNoHit + valSkipped;
}

// 進捗率計算〜表示
- (void) updateProgress {
    
    // 完了トラック数
    NSInteger completed = [self completeCount];
    
    // 進捗率(%) 算出
    float percentage = ((float)completed / (float)iTunesTracksTotal) * 100;
    
    //----------------------------
    // メインプログレスバーを進める
    //----------------------------
    [mainProgressBar setDoubleValue:percentage];
    
    //---------------------
    // Complete 数更新
    //---------------------
    NSString *mes = [NSString stringWithFormat:@"Complete: %d of %d", (int)completed, (int)iTunesTracksTotal];
    
    [valProcessedTextField setStringValue:mes];

    //----------------------------
    // 進捗率(%)更新
    //----------------------------
    if (percentage < 100) {
        
        [valPercengageTextField setStringValue:[NSString stringWithFormat:@"%.2f %%", percentage]];

    } else {
        
        [valPercengageTextField setStringValue:@"100 %"];
        [greenCheckImageView    setHidden:NO];
        
        // 残りのインターバルをアンロックして完了させる
        [self pauseButtonClicked:self];
    }
}

- (NSArray *) getITunesSelection {
    
    // 選択されている iTunes track を読み込む
    NSArray  *selectedTracks = nil; // iTunesTrack オブジェクトのリスト
    NSInteger itemCount = 0;
    
    SBObject *obj = [iTunesApp selection];
    
    // 念のため nil 判定してから選択されているアイテムリストを取得する
    if (obj != nil) {
        
        selectedTracks = [obj get];
        
        if (selectedTracks != nil) {
            
            itemCount = [selectedTracks count];
        }
    }
    
    if (itemCount == 0) {
        
        return nil;
    }
    
    return selectedTracks;
}

// No Hit の Square LED 表示
- (void) showSquareLED:(NSInteger)errorCode {
    
    // LED セット
    NSInteger sts = statusForCode(errorCode);
    NSImage  *img = [[super SC_STATE] objectAtIndex:sts];
    [squareLedImageView setImage:img];
    
    // LED 表示時間調整
    NSTimeInterval deduction = 0;
    if (interval < 10) deduction = (10 - interval) * 0.1;
    
    // LED 表示〜フェイドアウト
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startFadeoutView:) object:squareLedImageView];
    [squareLedImageView setAlphaValue:1.0];
    [self performSelector:@selector(startFadeoutView:) withObject:squareLedImageView afterDelay:SSFadeoutImageDuration-deduction];
}

- (void) startFadeoutView:(NSView *)view {
    
    NSTimeInterval duration = 1.0;
    
    // フェイドアウト時間調整
    if (interval < 10) {
        
        NSTimeInterval deduction = (10 - interval) * 0.1;
        
        duration -= deduction;
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:duration];
    [[view animator] setAlphaValue:0.0];
    [NSAnimationContext endGrouping];
}

- (void) startFadeinView:(NSView *)view {
    
    NSTimeInterval duration = 1.0;
    
    // フェイドイン時間調整
    if (interval < 10) {
        
        NSTimeInterval deduction = (10 - interval) * 0.1;
        
        duration -= deduction;
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:duration];
    [[view animator] setAlphaValue:1.0];
    [NSAnimationContext endGrouping];
}

- (iTunesPlaylist *) createPlaylistFrom:(NSArray *)tracks radioTracks:(NSArray *)radios name:(NSString *)name {

    iTunesPlaylist *newPlaylist = [self createPlaylistFrom:tracks name:name];
    
    for (iTunesTrack *trk in radios) {

        [trk duplicateTo:newPlaylist];
    }
    
    return newPlaylist;
}

- (iTunesPlaylist *) createPlaylistFrom:(NSArray *)tracks name:(NSString *)name {
    
    iTunesPlaylist *newPlayList = nil;
    
    SBElementArray *iSources = [iTunesApp sources];
    
//    NSLog(@"sources: %ld", iSources.count);
    
    for (iTunesSource *src in iSources) {
        
        if (src.kind == iTunesESrcLibrary) {
            
            // Playlist 新規作成
            newPlayList = [[[[iTunesApp classForScriptingClass:@"playlist"] alloc] init] autorelease];
            
            // ユーザプレイリストに追加
            [[src userPlaylists] addObject:newPlayList];
            
            // 日付から名前を生成
            NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
            //            [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
            [formatter setDateFormat:@"MM/dd HH:mm:ss"];
            NSString *dateStr = [formatter stringFromDate:pausedDate];
            
            NSString *playlistName = [NSString stringWithFormat:@"SSR %@ %@", dateStr, name];
            
            // 名前を付ける
            [newPlayList setName:playlistName];
            
            // v4.0
            for (iTunesTrack *trk in tracks) {
                
                if ([trk.className isEqualToString:@"ITunesFileTrack"]) {
                    
                    [iTunesApp add:[NSArray arrayWithObject:((iTunesFileTrack *)trk).location] to:newPlayList];
                    //NSLog(@"## File  : %@", trk.name);
                }
                else if ([trk.className isEqualToString:@"ITunesAudioCDTrack"]) {
                    
                    [iTunesApp add:[NSArray arrayWithObject:((iTunesAudioCDTrack *)trk).location] to:newPlayList];
                    //NSLog(@"## CD    : %@", trk.name);
                }
                else {

                    [trk duplicateTo:newPlayList];
                    //NSLog(@"## Shared: %@", trk.name);
                }
            }

            // Track リストをセット
            //[iTunesApp add:[tracks valueForKey:@"location"] to:newPlayList];
            
            break;
        }
    }
    
    return newPlayList;
}

#pragma mark - Test

- (IBAction) deleteButtonClicked:(id)sender {
    
    NSArray *selectedTracks = [self getITunesSelection];
    
    for (iTunesTrack *trk in selectedTracks) {
        
        [trk setLyrics:@""];
    }
}

#pragma mark - Delegate

//---------------------------------------------------
// iTunes アクセスエラー検知 (SBApplicationDelegate)
//---------------------------------------------------
- (id)eventDidFail:(const AppleEvent *)event withError:(NSError *)error {
    
	iTunesErrorFlag = YES;
    [self setITunesError:error];
		
	return nil;
}

@end
