//
//  SCLyrics.m
//  Singer Song Reader
//
//  Created by Developer on 13/10/20.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SCLyrics.h"
#import "SMSite.h"
//#import "SMKanji.h"

@implementation SCLyrics

@synthesize lyricsLED;
@synthesize matchRatio;
@synthesize tagCurrentButtonEnabled;
@synthesize texCurrentButtonEnabled;
@synthesize editButtonHidden;
@synthesize cancelButtonHidden;
@synthesize looseMatchText;

@synthesize mediaType;
@synthesize trackIdentifier;
@synthesize srchType;

@synthesize localLyrics;

@synthesize errorCode;

@synthesize arrowsLeftRight;

- (id)init {
    self = [super init];
    if (self) {

        // UI バインディング
        [self showLyricsStatus:SC_STATE_OFF];
        [self setMatchRatio:@""];
        [self setTagCurrentButtonEnabled:NO];
        [self setTexCurrentButtonEnabled:NO];
        [self setEditButtonHidden:YES];
        [self setCancelButtonHidden:YES];
        [self setLooseMatchText:nil];

		siteList        = [[NSMutableArray alloc] initWithCapacity:0];

        mediaType       = SC_MEDIA_NONE;
        trackIdentifier = nil;
        srchType        = SC_AT_SEARCH;

        // Local モード関連
		localLyrics     = nil;

        // Site モード関連
		track           = [[SMTrack alloc] init];
        prefs           = [[SMPrefs alloc] init];
        matchThreshold  = 0;
 		errorCode       = 0;
        hitNum          = 0;
        finishNum       = 0;
        
        japaneseLyricsRomaji = YES;
        japaneseLyricsKanji  = YES;
        
        arrowsLeftRight = NSOffState;
	}
    return self;
}

- (void)dealloc {
	[siteList release];
	[track release];
    [super dealloc];
}

- (void) setDelegate:(id)aDelegate {
	delegate = aDelegate;
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
	
    // メニュー、ボタン制御
	[self buttonControl:SC_MODE_NONE];
    
	// サイトリスト更新
	[self updateSiteList];
    
	// HTTP キャッシュメモリ指定： 4MB
	[[NSURLCache sharedURLCache] setMemoryCapacity:4194304];
}

#pragma mark - Clear

// 初期表示、設定変更のサイトリスト更新
- (void) updateSiteList {
    
    //NSLog(@"## updateSiteList");
	
	NSDictionary *siteDict = [super siteDict];

	[siteList removeAllObjects];
	
	// ユーザ設定の検索サイトリストを取得
	NSArray *enabledSiteKeys = [super userEnabledSites];
	
	//-------------------------
    // siteList 生成
	//-------------------------
	for (NSString *key in enabledSiteKeys) {
		
		// [0] name: 正式名称
        // [1] site: サイトオブジェクト
		NSArray *name_site = [siteDict objectForKey:key];
		
		if (name_site) {
			
            id site = [name_site objectAtIndex:1];
            
            // site オブジェクトにサイトキーをセット
            [site setSiteKey:key];
            
            NSString *fullName = [name_site objectAtIndex:0];
            
            // 正式名称もセット
            [site setSiteFullName:fullName];
            
			// 検索サイト追加
			[siteList addObject:site];
		}
	}
		
	//-------------------------
	// siteList 情報付加
	//-------------------------
	int i = 0;
	for (id site in siteList) {
		
		// サイトインデックス割り当て
		[site setSiteIndex:i];
        // サイト優先順位セット
        [site setSitePriority:i];
		// トラック情報のポインタセット
		[site setTrack:track];
        // 検索設定情報のポインタセット
        [site setPrefs:prefs];
		// デリゲートセット
		[(SMSite *)site setDelegate:self];
		
		i++;
	}
    
	//-------------------------
    // サイトタブクリア
	//-------------------------
    [siteTabs clearAllWith:siteList];
}

// 表示 Lyrics クリア (Track Information Unavailable 時用)
- (void) clear {
	
    // local モード関連
	[self setLocalLyrics:nil];
	
	// Site  モード関連
	[track clear];
    matchThreshold = 0;
	errorCode       = 0;
    hitNum         = 0;
    finishNum      = 0;
	
	for (id site in siteList) {
		
		// 検索結果クリア
		[(SMSite *)site clearResult];
	}

	// マッチ率表示クリア
    [self setMatchRatio:@""];
	
	// 歌詞表示クリア
	[contents changeText:@"" refresh:YES];
    
    // サイトタブクリア
    [siteTabs clearAllWith:siteList];

    // メニュー、ボタン制御
	[self buttonControl:SC_MODE_NONE];
    
	// Lyrics インジケータ: OFF
	[self showLyricsStatus:SC_STATE_OFF];
    
    // fadeoutMessage2: 非表示
    [fadeoutMessage2 hide];
    
    // Loose Match メッセージ: 非表示
    [self setLooseMatchText:nil];
}

#pragma mark    -   Search

// 検索実行命令を各サイトに一斉送信
- (void) searchWithTitle:(NSString *)aTitle withArtist:(NSString *)aArtist matchThreshold:(NSInteger)threshold {
    
    japaneseLyricsRomaji = (BOOL)[super userJapaneseLyricsRomaji];
    japaneseLyricsKanji  = (BOOL)[super userJapaneseLyricsKanji];
    
    // 自動検索
    if (srchType == SC_AT_SEARCH) {
        
        //-----------------------
        // Site モードへ移行
        //-----------------------
        [self setLocalLyrics:nil];
    }
    // 手動検索変更なし、手動検索変更あり
    else if (srchType == SC_MA_SEARCH_SAME || srchType == SC_MA_SEARCH_EDIT){
        
        ; // 検索ヒットが確認できるまで LocalLyrics を確保
    }

    // Lyrics 埋込み/テキスト保存: 無効化
    [self setTagCurrentButtonEnabled:NO];
    [self setTexCurrentButtonEnabled:NO];
    
    // fadeoutMessage2: 非表示
    [fadeoutMessage2 hide];
    
    // Loose Match メッセージ: 非表示
    [self setLooseMatchText:nil];
   
    // マッチ率表示クリア
    [self setMatchRatio:@""];
    
    // サイトタブクリア
    [siteTabs clearAllWith:siteList];

    // 検索条件セット
	[track setTitle:aTitle artist:aArtist];
    
    // 日本語設定セット
    [prefs setRomaji:japaneseLyricsRomaji kanji:japaneseLyricsKanji];

    matchThreshold = threshold;
	errorCode       = -9999;
    hitNum         = 0;
    finishNum      = 0;
    
	[self showLyricsStatus:SC_STATE_GREEN_OFF_BLINK];
    
    // FadeoutMessage 領域表示
    [fadeoutMessage show];
    NSString *mes = [NSString stringWithFormat:@"0/%d", (int)[siteList count]];
    [fadeoutMessage setText:mes];

    
#ifdef SS_DEBUG_MATCH_RATIO
    NSLog(@"DEBUG --Threshold(%ld)------------------\n", matchThreshold);
#endif

#ifdef SS_DEBUG_SEARCH_KEYWORD
    NSLog(@"-* DEBUG ttl:%@ art:%@", track.title.original, track.artist.original);
#endif

    for (id site in siteList) {
		
		[site resetTimer];
		[site startTimer];
		
		// 検索実行
		[(SMSite *)site search];
	}
    
	[self performSelector:@selector(waitAll)];
}

- (void) useLocalLyrics:(NSString *)lyrics {
    
    //-----------------------
    // Local モードへ移行
    //-----------------------
    [self setLocalLyrics:lyrics];
    
    // fadeoutMessage2: 非表示
    [fadeoutMessage2 hide];
    
    // Loose Match メッセージ: 非表示
    [self setLooseMatchText:nil];
    
    // Site タブクリア
    [siteTabs clearAllWith:siteList];
    
    [self _useLocalLyrics];
    
	// delegate に検索完了通知
	[delegate performSelector:@selector(lyricsDidFinishSearching:)
				   withObject:self];
}

- (void) useFileLyrics:(NSString *)lyrics {
    
    //-----------------------
    // XXX モードへ移行
    //-----------------------
    [self setLocalLyrics:nil];
    
    // fadeoutMessage2: 非表示
    [fadeoutMessage2 hide];
    
    // Loose Match メッセージ: 非表示
    [self setLooseMatchText:nil];
    
    // Site タブクリア
    [siteTabs clearAllWith:siteList];
    
    [self _useFileLyrics:lyrics];
    
	// delegate に検索完了通知
	[delegate performSelector:@selector(lyricsDidFinishSearching:)
				   withObject:self];
}

- (void) cancel {
	
	for (id site in siteList) {
		
		// 各サイトにキャンセル通知
		[site performSelector:@selector(cancel)];
	}
}

- (void) timeout {

	for (id site in siteList) {
		
		// 各サイトにタイムアウト通知
		[site performSelector:@selector(timeout)];
	}	
}

- (void) showLooseMatches {
    
    // マッチ率しきい値を Loose Match 用に設定
    matchThreshold = SSLooseMatchThreshold;
    errorCode       = -9999;
    hitNum         = 0;
    finishNum      = 0;
    
    // fadeoutMessage2: 非表示
    [fadeoutMessage2 hide];
    
    // Loose Match メッセージ: 非表示
    [self setLooseMatchText:nil];
    
    // マッチ率表示クリア
    [self setMatchRatio:@""];
    
    // サイトタブクリア (V3.3)
    [siteTabs clearAllWith:siteList];
    
    for (id site in siteList) {
     
        // マッチ率が 0 でなかったら
        if ([[site resultScore] totalScore] > 0) {
            
            // resultCode を 1 に戻す
            [site markAsHit];
        }
        
        // 検索終了後の処理を再度通す -> サイトタブが更新される
        [self receiveData:site];
    }
    
    [self performSelector:@selector(waitAll)];
}


// 検索終了受付ハンドラ
- (void) siteDidFinishSearching:(id)sender {
	[sender stopTimer];
	[self performSelector:@selector(receiveData:) withObject:sender];
}

// 検索結果のスコア格納〜サイトタブ切替 -> 検索終了
- (void) receiveData:(id)sender {
	
    //--------------------------------
    // 検索結果フィルタリング
    //--------------------------------
	NSInteger sco = [self resultFilter:sender];
    
    if (sco > 0) hitNum++;
    finishNum++;
	
    //--------------------------------
	// Site タブのインジケータにシンクロ
    //--------------------------------
    [siteTabs syncStatusWith:sender andEnable:YES];
    
    //--------------------------------
	// 検索状況表示
    //--------------------------------
    // Normal Search の場合
    if (matchThreshold > SSLooseMatchThreshold) {

        // FadeoutMassage表示: Site 検索終了状況
        NSString *mes = [NSString stringWithFormat:@"%d/%d", (int)finishNum, (int)[siteList count]];
        [fadeoutMessage setText:mes];
    }
    
	NSInteger code = [sender resultCode];

	// 総合エラーコード決定: 一番いいコードを使う
	if (code > errorCode) {
		
		errorCode = code;
	}
}

// 検索結果フィルタ (全サイト共通)
- (NSInteger) resultFilter:(id)sender {
    
    
    NSInteger sco = [[sender resultScore] totalScore];
    NSString *lyr = [[sender srchResult] lyrics];

    if (sco > 0) {
        
        NSInteger lyrLength = lyr.length;
        
        BOOL ngFlag = NO;
        
        //-----------------------------------------------
        // Lyrics 最低文字数チェック (空の場合もここではじく)
        //-----------------------------------------------
        if (lyrLength < SSLyricsLengthMin) {
            
#ifdef SS_DEBUG_FILTER
            NSLog(@"## DEBUG %@ !!Too short (%ld bytes)", [sender siteName], lyrLength);
#endif
            ngFlag = YES;
        }
        
        //-----------------------------------------------
        // Lyrics 改行有無チェック
        //-----------------------------------------------
        if (ngFlag == NO) {

            if (lyrLength > SSLyricsSentenceMax) {
                
                NSRange max = NSMakeRange(0, SSLyricsSentenceMax);
                
                NSRange range = [lyr rangeOfString:@"\n"
                                           options:NSLiteralSearch
                                             range:max];

                // 先頭から一定範囲内に改行が存在しない場合
                if (range.location == NSNotFound) {

#ifdef SS_DEBUG_FILTER
                    NSLog(@"## DEBUG %@ !!No linefeed", [sender siteName]);
#endif
                    ngFlag = YES;
                }
            }
        }

        //-----------------------------------------------
        // 簡易文字化けチェック (V3.4)
        //-----------------------------------------------
        if (ngFlag == NO) {
            
            NSRange range = [lyr rangeOfString:@"??????????"];
            
            if (range.location != NSNotFound) {
                
#ifdef SS_DEBUG_FILTER
                NSLog(@"## DEBUG %@ !!Garbage characters", [sender siteName]);
#endif
                ngFlag = YES;
            }
        }
        
        //-----------------------------------------------
        // タグ削除漏れチェック (V3.7)
        //-----------------------------------------------
        if (ngFlag == NO) {
            
            NSRange range = [lyr rangeOfString:@"</"];
            
            if (range.location != NSNotFound) {
                
#ifdef SS_DEBUG_FILTER
                NSLog(@"## DEBUG %@ !!Tag left", [sender siteName]);
#endif
                ngFlag = YES;
            }
        }
        
        if (ngFlag) {

            // result code を 0 で上書き
            [sender markAsNoHit];
            
            // result score を 0 で上書き
            [[sender resultScore] clear];
            
            // スコアを 0 にする
            sco = 0;
        }
    }
    
    if (sco > 0) {
        
        BOOL ngFlag = NO;
        
        BOOL containsKana   = NO;
        BOOL containsRomaji = NO;
        
        //------------------------------
        // 日本語判定
        //------------------------------
        if ([lyr containsJapaneseKana])
            containsKana = YES;
        
        //------------------------------
        // ローマ字判定
        //------------------------------
        if ([lyr containsRomaji])
            containsRomaji = YES;
        
        // 日本語とローマ字混在の場合
        if (containsKana && containsRomaji) {

            // ノーヒット扱いとする
            ngFlag = YES;
        }
        // 日本語を含む場合
        else if (containsKana) {

            if (!japaneseLyricsKanji)
                ngFlag = YES;
        }
        // ローマ字を含む場合
        else if (containsRomaji) {

            if (!japaneseLyricsRomaji)
                ngFlag = YES;
        }

#ifdef SS_DEBUG_JAPANESE_TYPE
        
        NSString *type;
        
        if (containsKana && containsRomaji) type = @"Kanji & Romaji";
        else if (containsKana)              type = @"Kanji";
        else if (containsRomaji)            type = @"Romaji";
        else                                type = nil;

        if (type)
            NSLog(@"## DEBUG [Japanese: %@] %@", type, [sender siteName]);

#endif

        if (ngFlag) {
            
            // result code を 0 で上書き
            [sender markAsNoHit];
            
            // result score を 0 で上書き
            [[sender resultScore] clear];
            
            // スコアを 0 にする
            sco = 0;
        }
    }

    if (sco > 0) {
        
        //------------------------------
        // しきい値チェック
        //------------------------------
        
        // しきい値未満の場合
        if (sco < matchThreshold) {
            
            // result code を 0 で上書き
            [sender markAsNoHit];

            // スコアを 0 とみなす
            sco = 0;
        }
        // しきい値に達している場合
        else {
            
            // Normal 検索の場合
            if (matchThreshold > SSLooseMatchThreshold) {
                
                // 100% 扱いとする => Sites Priority 順に表示される
                [[sender resultScore] setTotalScore:100];
            }
            // Loose Match 表示の場合
            else {
                // 何も手を加えない => スコア順に表示される
                ;
            }
        }
    }

    return sco;
}

// スコア第一位サイトを決定
- (NSInteger) bestSite {
    
    NSInteger idx = -1;
    
	if (finishNum > 0) {
        
        //-----------------------------------------
        // スコアリスト作成
        //-----------------------------------------
        NSMutableArray *scoreList = [NSMutableArray arrayWithCapacity:0];
        NSInteger siteNum = [siteList count];
        
        for (id site in siteList) {
            
            NSInteger priorityPoint = siteNum - [site sitePriority];
            
            NSInteger sco = [[site resultScore] totalScore];
            
            NSInteger sco_pp = (sco * 100) + priorityPoint;
            
            // 検索結果スコアを保存：{スコア, インデックス}
            NSArray *scoAndIdx = [NSArray arrayWithObjects:
                                  [NSNumber numberWithInt:sco_pp],
                                  [NSNumber numberWithInt:[site siteIndex]], nil];
            
            [scoreList addObject:scoAndIdx];
            
        }
		
		// スコアリストを降順でソート
		[scoreList sortUsingFunction:numberSort context:nil];
		      
        // 新しい siteList
        NSMutableArray *newSiteList = [NSMutableArray arrayWithCapacity:0];
        
        int i = 0;
        for (NSArray *item in scoreList) {
            
            NSInteger siteIndex = [[item objectAtIndex:1] integerValue];
            
            id site = [siteList objectAtIndex:siteIndex];
            
            // サイトインデックス再割当て
            [site setSiteIndex:i];
            
            // 新しいサイトリストに追加
            [newSiteList addObject:site];
            
            i++;
        }
        
        //-----------------------------------------
        // siteList の順番を入れ替える
        //-----------------------------------------
        [siteList setArray:newSiteList];
        
        //----------------------------
        // サイトタブにシンクロ
        //----------------------------
        [siteTabs syncAllWith:siteList];
        
        // 修正 (V3.4)
//        if ([[siteList objectAtIndex:0] isHit])
        if ([siteTabs count] > 0)
            idx = 0;
    }
    
    return idx;
}

// すべてのサイトの検索が終了するまで待機
- (void) waitAll {
    
	if (finishNum == [siteList count]) {
        
        if (localLyrics && hitNum == 0) {
            
            //---------------------------------
            // Local モードを継続
            //---------------------------------
            
            // Lyrics コンテンツ更新不要
            
            // サイトタブ無効化
            [siteTabs disableAll];
            
             //errorCode = 0;
            
            [self _useLocalLyrics];
            
        } else {
            
            //---------------------------------
            // Site モードへ移行
            //---------------------------------
            [self setLocalLyrics:nil];

            // スコア第一位サイトを決定＋タブ並び替え
            NSInteger idx = [self bestSite];
            
            // タブ選択
            if (idx != -1)
                [siteTabs selectTabAtIndex:idx];
            
            [self _useSiteLyrics:nil];
        }
        
        // Normal Search の場合
        if (matchThreshold > SSLooseMatchThreshold) {
            
            if (hitNum == 0) {
                
                // Not Hit を Fadeout メッセージ表示
                [fadeoutMessage setText:@"0 Hit"];

                
                // Loose Match 件数をカウント
                int looseMatchNum = 0;
                for (id site in siteList) {
                    
                    if ([[site resultScore] totalScore] >= SSLooseMatchThreshold) {
                        
                        looseMatchNum++;
                    }
                }
                
                if (looseMatchNum) {
                    
                    NSString *fmt;

                    // 通常モード
                    if (share.batchMode == NSOffState) {
                        
                        if (looseMatchNum == 1) fmt = @"%d Loose Match. Press 'Enter' to show it.";
                        else                    fmt = @"%d Loose Matches. Press 'Enter' to show them.";
                    }
                    // Batch モード
                    else {
                        
                        if (looseMatchNum == 1) fmt = @"%d Loose Match.";
                        else                    fmt = @"%d Loose Matches.";
                    }
                    
                    NSString *text = [NSString stringWithFormat:fmt, looseMatchNum];
                    
                    // Show Loose Matches メッセージ表示
                    [self setLooseMatchText:text];
                    
                    // 通常モード
                    if (share.batchMode == NSOffState) {
                        [mainWindow makeFirstResponder:looseMatchTextField];
                    }
                }
            } else {
                
                NSString *fmt;
                
                if (hitNum == 1) fmt = @"%d Hit";
                else             fmt = @"%d Hits";
                
                [fadeoutMessage setText:[NSString stringWithFormat:fmt, (int)hitNum]];
            }
            
            [fadeoutMessage fadeoutAfterDelay:SSFadeoutMessageDuration];

            // delegate に検索完了通知
            [delegate performSelector:@selector(lyricsDidFinishSearching:)
                           withObject:self];
        }

		return;
	}
	
	[self performSelector:@selector(waitAll) withObject:nil afterDelay:0.5];
}

#pragma mark    -   Display

// 選択 Site の Lyrics を表示
- (IBAction) _useSiteLyrics:(id)sender {

	if (track.title.original == nil) {
		return;
	}
    
    id site = [self selectedSite];
    
    if (site) {
        
        //-----------------------------
        // マッチ率をディスプレイ領域に表示
        // デバッグ用にとっておく
        //-----------------------------
        NSString *hitRate = @"";
        
        if ([site isHit]) {
            
            NSInteger score = [[site resultScore] totalScore];
            
            hitRate = [NSString stringWithFormat:@"%d %%", (int)score];
        }
        
        [self setMatchRatio:hitRate];
        
        
        BOOL showFadeoutMessage2 = NO;
        
        // 検索ヒットしている場合
        if ([site isHit]) {
            
            // Loose Search の場合
            if (matchThreshold == SSLooseMatchThreshold) {
                
                showFadeoutMessage2 = YES;
            }
        }
        
        //-----------------------------
        // マッチ率は常に非表示にしておく
        //-----------------------------
        showFadeoutMessage2 = NO;
        
#ifdef SS_DEBUG_MATCH_RATIO_DISP
        showFadeoutMessage2 = YES;
#endif
        
        //
        if (showFadeoutMessage2) {
            
            // fadeoutMessage2 にマッチ率を表示
            NSInteger score = [[site resultScore] totalScore];
            
            NSString *hitRate = [NSString stringWithFormat:@"%d %%", (int)score];
            
            [fadeoutMessage2 show];
            [fadeoutMessage2 setText:hitRate];
        } else {
            
            [fadeoutMessage2 hide];
        }
        
        // 歌詞コンテンツ表示
        [self displayContents:[site contents:!((BOOL)[super userHideLyricFooterURL])]];
    }
    //
    else {
        
        [self displayContents:@""];
    }
    
    // メニュー、ボタン制御
    [self buttonControl:SC_MODE_SITE];
}

// Local Lyrics を表示
- (void) _useLocalLyrics {
    
	if (localLyrics == nil) {
		return;
	}
    
    // 検索していないものとみなす
    errorCode = 0;
    
    [self setMatchRatio:@""];
    
	// 歌詞コンテンツ表示
	[self displayContents:localLyrics];
    
    // メニュー、ボタン制御
	[self buttonControl:SC_MODE_LOCAL];
}

// File Lyrics を表示
- (void) _useFileLyrics:(NSString *)lyrics {
    
    // 検索していないものとみなす
    errorCode = 0;
    
    [self setMatchRatio:@""];
    
	// 歌詞コンテンツ表示
	[self displayContents:lyrics];
    
    // メニュー、ボタン制御
	[self buttonControl:SC_MODE_FILE];
}

- (void) displayContents:(NSString *)lyrics {
    
    NSString *newLyrics = lyrics;
    
    // Appearance 変更時は nil が渡される
    if (lyrics == nil) {

        // 画面に表示されているコンテンツを使用
        // length チェック (V3.4)
        if ([[self displayedLyrics] length] > 0)
            newLyrics = [self displayedLyrics];
        else
            newLyrics = @"";
    }
	
	//--------------------------------
    // Alignment 指定
	//--------------------------------
    NSInteger alignment = NSCenterTextAlignment;
    
    // Local モード
	if (localLyrics) {
        
        if (mediaType == SC_MEDIA_PODCAST || mediaType == SC_MEDIA_ITUNESU || mediaType == SC_MEDIA_VIDEO) {
            
            // Podcast、iTunesU、ビデオ の場合のみ左寄せ
            alignment = NSLeftTextAlignment;
        }
	}
    // v3.6
    if (IS_OS10_10_LATER) {

        // Single View
        if ([contents.currentView isKindOfClass:[NSScrollView class]]) {
            [[contents firstTextView] setHidden:YES];
        }
    }else{
        [contents setAlignment:alignment];
    }
	
	//--------------------------------
    // 文字色指定
	//--------------------------------
    // V3.4
    BOOL refreshFlag = YES;
    
    // File Lyrics を開く場合
    if (srchType == SC_MA_OPEN_FILE) {
        // TextView の refresh (貼り直し) をしない
        refreshFlag = NO;
    }
    
	if ([appearance currentMode] == SC_APPEARANCE_PANEL) {
		
		// 文字色： White 固定
		[contents changeText:newLyrics color:[NSColor whiteColor] refresh:refreshFlag];
	} else {
		
		// 文字色：ユーザ設定
		[contents changeText:newLyrics refresh:refreshFlag];
	}
    
    // v3.6
    // Yosemite or later
    if (IS_OS10_10_LATER) {

        [contents setAlignment:alignment];
        
        // Single View
        if ([contents.currentView isKindOfClass:[NSScrollView class]]) {
            
            // スクロールバー位置再調整
            [[(NSScrollView *)contents.currentView verticalScroller] setFloatValue:0];
            [(NSScrollView *)contents.currentView display];

            [[contents firstTextView] display];
            [[contents firstTextView] setHidden:NO];
        }
    }

    // Kanji to Romaji Conversion Test
//
//    if (lyrics) {
//        
//        NSMutableArray *lines = [NSMutableArray array];
//        [newLyrics enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
//            [lines addObject:line];
//        }];
//        
//        SMKanji *kanji = [[[SMKanji alloc] init] autorelease];
//        
//        if (!kanji) {
//            NSLog(@"## SMKanji init failed.");
//        }
//        
//        for (NSString *line in lines) {
//            
//            NSString *romaji = [kanji romajiByConvertingFrom:line];
//            //[kanji mecabTest:line];
//            
//            NSLog(@"## IN : %@", line);
//            NSLog(@"## OUT: %@", romaji);
//        }
//    }
}

#pragma mark    -   Button Control

// Tag Current、Edit、Cancel ボタン制御
// Show Original メニュー項目制御
- (void) buttonControl:(SCMode)mode {

    // 初期表示時の設定
    BOOL tagCurrentEnb   = NO;
    BOOL texCurrentEnb   = NO;
    BOOL editButtonHid   = YES;
    BOOL cancelButtonHid = YES;
    BOOL showOriginalEnb = NO;
    BOOL blueCheck       = NO;
    
    // Text view 用 Accessibility Description (V3.4)
    NSString *textViewDescription;

    
    // Local モード
    if (mode == SC_MODE_LOCAL) {
        
        editButtonHid = NO;
        
        // Lyrics の中身が空でなかったら
        if ([localLyrics length]) {
            
            blueCheck = YES;
        }
        
//        textViewDescription = @"Embeded";
        textViewDescription = @"";
    }
    // File モード
    else if (mode == SC_MODE_FILE) {

//        textViewDescription = @"Local";
        textViewDescription = @"";
    }
    // Site モード
    else if (mode == SC_MODE_SITE) {
        
        id site = [self selectedSite];
        
        // Hit 件数 > 0
        if (site) {
            if ([site isHit]) {
                
                // "Show Original" メニュー項目有効
                showOriginalEnb = YES;
                
                // Text 保存有効
                texCurrentEnb = YES;
                
                if (mediaType == SC_MEDIA_MUSIC) {
                    
                    // Tag Current ボタン有効
                    tagCurrentEnb = YES;
                    
                    // lyrics が保存済だった場合
                    if ([site taggedLyrics]) {
                        
                        // Edit ボタン表示
                        editButtonHid = NO;
                        
                        // Blue Check 表示
                        blueCheck     = YES;
                    }
                }
                
            }
            // 検索ノーヒット、エラー
            else {
                
                // URL が取得できていたら
                if([[[site srchResult] url] length]) {
                    
                    // - Copyright 保護で表示できない場合
                    // - エラーの場合
                    
                    // 上記の場合にも、原因が表示できるよう
                    // "Show Original" メニュー項目有効
                    showOriginalEnb = YES;
                }
            }
            
            textViewDescription = [NSString stringWithFormat:@"%d of %d", (int)[siteTabs selectedIndex]+1, (int)[siteTabs count]];
        }
        // 0 Hit
        else {
        
            textViewDescription = @"";
        }
        
    }
    // SC_MODE_NONE
    else {

        textViewDescription = @"";
    }
	   
    // Tag Current ボタン有効/無効化
    [self setTagCurrentButtonEnabled:tagCurrentEnb];
    
    // Text 保存有効/無効化
    [self setTexCurrentButtonEnabled:texCurrentEnb];
    
    // Edit ボタン表示/非表示
    [self setEditButtonHidden:editButtonHid];

    // Cancel ボタン表示/非表示
    [self setCancelButtonHidden:cancelButtonHid];
    
    // Show Original メニュー有効/無効化
    [showOriginalMenuItem setEnabled:showOriginalEnb];
    
    // Blue Check/Search Status 切替
    NSInteger              sts;
    if (blueCheck)         sts = SC_STATE_CHECK;
    else                   sts = statusForCode(errorCode);
    [self showLyricsStatus:sts];
    
    //-------------------------------------------------------
    // Text view: Accessibility Description 書き換え (V3.4)
    //-------------------------------------------------------
    [contents setAccessibilityDescription:textViewDescription];
    
    // Lyrics コンテンツにフォーカス (上下スクロールやコピーができるようにするため)
    [mainWindow makeFirstResponderToContentsFirstTextView];
}

// Lyrics インジケータ表示
- (void) showLyricsStatus:(SCStateIndex)sts {
    
    NSImage *img = [[super SC_STATE] objectAtIndex:sts];
    
    [self setLyricsLED:img];
}

- (SMSite *) selectedSite {

    SMSite* site = nil;
    
    NSInteger idx = [siteTabs selectedIndex];
    
    if (idx != -1) {

        site = [siteList objectAtIndex:idx];
    }

    return site;
}

// Lyrics 保存済サイトを記録する
- (void) setTaggedLyrics:(NSString *)taggedLyrics forSite:(SMSite *)aSite {
    
    NSInteger siteIndex = [aSite siteIndex];
    
    int i = 0;
    for (id site in siteList) {
        
        if (i == siteIndex) {
         
            [site setTaggedLyrics:taggedLyrics];
        } else {
            
            [site setTaggedLyrics:nil];
        }
        
        i++;
    }
    
	// Site タブにシンクロ
    [siteTabs syncStatusAllWith:siteList];
}

- (SMSrchResult *) srchResult {

	return [[self selectedSite] srchResult];
}

- (NSString *) displayedLyrics {
    
    return [contents text];
}

- (NSInteger) siteCount {
    
    return [siteList count];
}

- (BOOL) isEditMode {
    
    return !cancelButtonHidden;
}

- (BOOL) isSearchCanceled {
    
    BOOL canceled = NO;
    
    for (id site in siteList) {
        
        if ([site resultCode] == -1000) {
            
            canceled = YES;
            break;
        }
    }
    
    return canceled;
}

- (IBAction) showOriginal:(id)sender {

	id site = [self selectedSite];
		
	NSString *url = [[site srchResult] url];
	
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

#pragma mark - Edit Mode

- (void) beginEditMode {

    // Local モードの場合
    if (localLyrics) {
        ;
    }
    // Site モードの場合
    else {

        // iTunes に保存済の Lyrics を取得
        NSString *taggedLyrics = [[self selectedSite] taggedLyrics];
        
        //---------------------------
        // Local モードへ移行
        //---------------------------
        [self setLocalLyrics:taggedLyrics];
        
        // サイトタブクリア
        [siteTabs clearAllWith:siteList];
        
        [self _useLocalLyrics];
    }

    // 0) フォーカスを一番目の TextView に移動
    [mainWindow makeFirstResponderToContentsFirstTextView];

    // 1) Edit ボタン非表示
    [self setEditButtonHidden:YES];

    // 2) Tag Current ボタン有効
    [self setTagCurrentButtonEnabled:YES];
    
    // 3) Cancel ボタン表示
    [self setCancelButtonHidden:NO];
    
    // 4) TextView を編集可
    [contents setEditable:YES];
    
    // fadeoutMessage2: 非表示
    [fadeoutMessage2 hide];
    
    // Loose Match メッセージ: 非表示
    [self setLooseMatchText:nil];
}

- (void) endEditMode {
    
    
    // TextView を編集不可
    [contents setEditable:NO];

    // 通常の表示に戻る
    [self _useLocalLyrics];
}

#pragma mark - Site Tab

- (IBAction) nextSite:(id)sender {
    
    [siteTabs clickNextTab];
}

- (IBAction) prevSite:(id)sender {

    [siteTabs clickPrevTab];
}


// スコア降順ソート用関数
NSInteger numberSort(id num1, id num2, void *context){
	NSInteger ret = [[num2 objectAtIndex:0] compare:[num1 objectAtIndex:0]]; //昇順
	return ret;
}

#pragma mark    -   Key Up Event from SCDelegate

- (void) keyUpEvent:(NSEvent *)event {

    //NSLog(@"SCLyrics KeyUp: %@ [%hu]", [event characters], [event keyCode]);
    
    switch ([event keyCode]) {
            
        case 124: // ->
            
            if (arrowsLeftRight) [self nextSite:self];
            break;
            
        case 123: // <-
            
            if (arrowsLeftRight) [self prevSite:self];
            break;
        case 36:  // Return
        case 76:  // Enter (v3.8)
            
            if (looseMatchText) [self showLooseMatches];
            break;
    }
}

#pragma mark - NSMenuDelegate

// メモ: このメソッドが呼ばれるには、NSMenu の Attribute 設定で、
//      Auto Enables Items をオンにしておく必要がある。

//------------------------------------------------------------------
// "N of N" 表示を TextView の Accessibility Description へ移行 (V3.4)
//------------------------------------------------------------------
/*
- (BOOL) validateMenuItem:(NSMenuItem *)menuItem {
    
    BOOL enabled = YES;
    
    if (menuItem.action          == @selector(nextSite:) ||
        menuItem.action          == @selector(prevSite:)) {
        
        NSString *title      = nil;
        NSString *additional = nil;
        int       index      = -1;
        
        if (menuItem.action      == @selector(nextSite:)) {
            
            title = @"Next Tab";
            index = [siteTabs nextTabIndex];
        }
        else {
            
            title = @"Previous Tab";
            index = [siteTabs prevTabIndex];
        }

        int tabNum = [siteTabs count];
        
        // サイトタブあり
        if (tabNum) {
            
            // 検索中 (disabled)
            if (index != -1) {
                
                additional = [NSString stringWithFormat:@" (%d of %d)", index+1, tabNum];
            }
            else {
                
                additional = @"";
                
                // NO をセットすると、Control + Shift + Tab でバックして先頭に達した時、
                // VO カーソルがタブの先頭で止まらずに曲名テキストフィールドに移動してしまう。
                //enabled = NO;
            }
        }
        // サイトタブが空 (ノーヒット)
        else {
            
            additional = @" (0 of 0)";
        }
        
        [menuItem setTitle:[title stringByAppendingString:additional]];
    }
    
    return enabled;
}
*/

/*
- (void) keyDownEvent:(NSEvent *)event {
 
    //NSLog(@"SCLyrics KeyDown: %@ [%hu]", [event characters], [event keyCode]);

    switch ([event keyCode]) {
            
        case 124: // ->
            
            if (cancelButtonHidden) [self nextSite:self];
            break;
            
        case 123: // <-
            
            if (cancelButtonHidden) [self prevSite:self];
            break;
        case 36:  // Enter
            
            if (looseMatchText) [self showLooseMatches];
            break;
    }

}
*/

@end
