//
//  SCSongInformation.m
//  Singer Song Reader
//
//  Created by Developer on 13/10/25.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SCSongInformation.h"
#import "SMCountries.h"
#import "NSScrollView+SSR.h"

NSString * const SCWebFrame1 = @"webFrame1";
NSString * const SCWebFrame2 = @"webFrame2";

typedef enum {
	SC_LINK_SONG       = 0,
	SC_LINK_ARTIST     = 1
} SCITunesLink;

@implementation SCSongInformation

@synthesize artistName;

@synthesize songIcon;
@synthesize artistIcon;

@synthesize songUrl;
@synthesize artistUrl;

- (id)init {
    self = [super init];
    if (self) {
        
        // UI バインディング
        [self setArtistName:@""];
        
        [self setSongIcon  :[[super SC_SONG_IMAGE]   objectAtIndex:SC_IMAGE_OFF]];
        [self setArtistIcon:[[super SC_ARTIST_IMAGE] objectAtIndex:SC_IMAGE_OFF]];

        [self setSongUrl  :nil];
        [self setArtistUrl:nil];
        
        iTunesStore = nil;
		
        //-------------------------------
        // Affiliate リンク作成
        //-------------------------------
		linkMaker = [[SMLinkMaker alloc] init];
        
        // Top Songs 情報 TableView のデータソースを管理するクラス
        topSongsDataSource = [[SMTopSongsDataSource alloc] init];
        
        // アーティスト情報 TableView のデータソースを管理するクラス
        bioStatsDataSource = [[SMBioStatsDataSource alloc] init];
        
        //------------------------------------------------------------
		// WebView 設定: 画像読込み無効化 (読み込まれるのは,html, js, css)
        //------------------------------------------------------------
		WebPreferences *webPref = [[[WebPreferences alloc]
                                    initWithIdentifier:@"SCStoreWebPreferences"] autorelease];
		
		[webPref setAllowsAnimatedImageLooping:NO];
		[webPref setAllowsAnimatedImages:NO];
		[webPref setJavaScriptCanOpenWindowsAutomatically:NO];
		[webPref setLoadsImagesAutomatically:NO];
		[webPref setUsesPageCache:NO];
		[webPref setCacheModel:WebCacheModelDocumentViewer];
        
        //-------------------------------
        // Song URL 用
        //-------------------------------
		webView1 = [[WebView alloc]
                    initWithFrame:NSMakeRect(0.0, 0.0, 640.0, 480.0)
                    frameName:SCWebFrame1
                    groupName:nil
                    ];
		
		[webView1 setPreferences:webPref];
		[webView1 setFrameLoadDelegate:self];
		[webView1 setResourceLoadDelegate:self];
		
        //-------------------------------
        // Artist URL 用
        //-------------------------------
		webView2 = [[WebView alloc]
                    initWithFrame:NSMakeRect(0.0, 0.0, 640.0, 480.0)
                    frameName:SCWebFrame2
                    groupName:nil
                    ];
		
		[webView2 setPreferences:webPref];
		[webView2 setFrameLoadDelegate:self];
		[webView2 setResourceLoadDelegate:self];
}
	
	return self;
}

- (void)dealloc {
    [webView1 release];
    [webView2 release];
	[linkMaker release];
    [super dealloc];
}

- (void) setDelegate:(id)aDelegate {
	delegate = aDelegate;
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {

    [bioStatsTableView setDataSource:bioStatsDataSource];
    [topSongsTableView setDataSource:topSongsDataSource];
    
    //-----------------------------------
    // Biography TextView 設定
    //-----------------------------------
    // 背景色：透明
    [biographyTextView setDrawsBackground:NO];
    
    [biographyTextView setTextColor:[NSColor colorWithCalibratedWhite:0.8 alpha:1.0]];
    [biographyTextView setFont:[NSFont fontWithName:@"Lucida Grande" size:11]];
    
    // スクローラのノブ表示設定
    [biographyScroller setAllowKnob:YES];
    
    if ([topSongScrollView respondsToSelector:@selector(setVerticalScrollElasticity:)]) {
        
        [topSongScrollView   setVerticalScrollElasticity:NSScrollElasticityNone];
        [biographyScrollView setVerticalScrollElasticity:NSScrollElasticityNone];
        [bioStatsScrollView  setVerticalScrollElasticity:NSScrollElasticityNone];
    }
}

- (void) setStore:(SMiTunesStore *)store {

	iTunesStore = store;
}

#pragma mark - Clear

- (void) clear {

    //----------------------------------
    // Panel Title
    //----------------------------------
	[songInformationPanel       setTitle:@""];
    [biographyPanel             setTitle:@""];
    
    // Shared
    [self setArtistName:@""];

    //----------------------------------
    // Song
    //----------------------------------
	[songTextField              setStringValue:@""];
	[albumTextField             setStringValue:@""];
    [trackTextField             setStringValue:@""];
    [timeTextField              setStringValue:@""];
	[artworkLargeImageView      setHidden:YES];
	[changeCountryButton        setEnabled:NO];
	[changeCountryTextField     setHidden:YES];
	
    // Top Songs
    [topSongsDataSource         clearDataArray];
    [topSongsTableView          reloadData];
    
    //----------------------------------
    // Biography
    //----------------------------------

    // Summary
    [bioStatsDataSource         clearDataArray];
    [bioStatsTableView          reloadData];

    // Biography
    [biographyTextView          setString:@""];
        
    //----------------------------------
    // Song, Artist ボタン画像
    //----------------------------------
    [self setSongIcon  :[[super SC_SONG_IMAGE]   objectAtIndex:SC_IMAGE_OFF]];
    [self setArtistIcon:[[super SC_ARTIST_IMAGE] objectAtIndex:SC_IMAGE_OFF]];

    // Download ボタン用 未加工 iTunes URL
    [self setSongUrl  :nil];
    [self setArtistUrl:nil];
}

#pragma mark - Display

- (void) display {

	// 国コード設定読み出し・画面反映
	// (検索で使用したものと国コードを使用する)
	NSString *countryCode = [iTunesStore countryCode];
	
	[countryTextField setStringValue:[SMCountries nameOfCode:countryCode]];
	

	// iTunes Store 検索結果取り出し・画面反映
	BOOL availableInStore = NO;
	NSString *panelTitle = nil;

	NSInteger code = [iTunesStore resultCode];
	
	switch (code) {
		case 1:
            
			panelTitle = @"";
			availableInStore  = YES;
			break;
		case 0:
			panelTitle = @"";
			break;
		case -1:
			panelTitle = @"Connection Error";
			break;
		case -2:
			panelTitle = @"Service Unavailable";
			break;
		case -5:
			panelTitle = @"iTunes Store Unavailable";
			[changeCountryButton    setEnabled:YES];
			[changeCountryTextField setHidden:NO];
			break;
		case -10:
			panelTitle = @"Search Timeout. Please try again";
			break;
		case -1000:
			panelTitle = @"Search Canceled";
			break;
		default:
			// 内部エラー
			panelTitle = [NSString stringWithFormat:@"Error (%ld)", code];
			break;
	}
	
	[songInformationPanel setTitle:panelTitle];
    [biographyPanel       setTitle:@""];
    

	if (availableInStore == NO) {
		return;
	}

    // Song, Artist ヒット判定
    BOOL songHit   = [[iTunesStore resultScore] totalScore] > 0 ? YES : NO;
    BOOL artistHit = [[iTunesStore artistScore] totalScore] > 0 ? YES : NO;
    
    // 曲のタイトル、アーティスト名
    NSString *song   = [[iTunesStore srchResult] title];
    NSString *artist = [[iTunesStore srchResult] artist];
    
    // Song, Artist の iTunes URL
    NSString *sUrl   = [[iTunesStore srchResult] url];
    NSString *aUrl   = [[iTunesStore srchResult] artistUrl];

    // Song または Artist のいずれかがヒットした場合
    if (songHit || artistHit) {

        // アーティスト名画面反映 (Shared in 2 Panels)
        [self setArtistName:artist];
    }
    
    //-------------------------------------
    // Song Info
    //-------------------------------------
    
    // Song がヒットした場合
    if (songHit) {
        
        // Song 情報あり: Icon ON
        [self setSongIcon  :[[super SC_SONG_IMAGE]     objectAtIndex:SC_IMAGE_ON]];
        
        // Song URL あり: Download ON
        [self setSongUrl:sUrl];

        //-------------------
        // 情報取得
        //-------------------
        NSInteger trackNumber = [[iTunesStore srchResult] trackNumber];
        //NSInteger matchRate   = [[iTunesStore resultScore] totalScore];
        
        NSDictionary *others  = [[iTunesStore srchResult] others];
        
        NSString *artworkUrl100    = [others valueForKey:@"artworkUrl100"];
        NSString *trackTimeMillis  = [others valueForKey:@"trackTimeMillis"];
        NSString *album            = [others valueForKey:@"collectionName"];
        
        double msec = [trackTimeMillis doubleValue];
        int    sec  = msec / 1000;
        int    mm   = sec  / 60;
        int    ss   = sec  % 60;
        
        //-------------------
        // 画面反映
        //-------------------

        // アルバムカバーイメージ
        if (artworkUrl100) {
            
            // メインスレッドを待機させないよう別スレッドで実行
            [self performSelectorInBackground:@selector(loadArtworkImageOfURL:)
                                   withObject:artworkUrl100];
        }
        
        [songTextField       setStringValue:song];
        [albumTextField      setStringValue:album];
        
        [trackTextField  setStringValue:[NSString stringWithFormat:@"Track: %d", (int)trackNumber]];
        [timeTextField   setStringValue:[NSString stringWithFormat:@"Time : %d:%02d", mm, ss]];
        
        //[songInformationPanel setTitle:[NSString stringWithFormat:@"%d %% match", (int)matchRate]];
    }
    
    //-------------------------------------
    // Top Songs
    //-------------------------------------
    NSArray *topSongs = [[iTunesStore srchResult] topSongs];

    if (artistHit && [topSongs count]) {

        // Top Songs データソースをセット
        [topSongsDataSource setDataArray:topSongs];
        
        // Song 情報あり: Icon ON
        [self setSongIcon  :[[super SC_SONG_IMAGE]     objectAtIndex:SC_IMAGE_ON]];
        
        // 再生中の曲に一致するものがあるかチェック
        NSInteger sameTrackIndex = [[iTunesStore srchResult] topSongsIndex];
        
        // 一致するものがあったら文字色を変える
        if (sameTrackIndex != -1) {
            
            [topSongsDataSource setHighlightItemOfIndex:sameTrackIndex];
        }        
                
        // 画面反映
        [topSongsTableView  reloadData];
        
        // V3.4
        if (topSongsTableView.numberOfRows)
            [topSongsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    }
    
    //-------------------------------------
    // Biography
    //-------------------------------------

    // Artist がヒットした場合
    if (artistHit) {

        // Artist URL あり: Download ON
        [self setArtistUrl:aUrl];
        
        //---------------------------
        // Biography
        //---------------------------

        // Biography データソースをセット
        [bioStatsDataSource setDataArray:[[iTunesStore srchResult] bioStats]];
        
        // 表示
        [bioStatsTableView  reloadData];
        
        // V3.4
        if (bioStatsTableView.numberOfRows)
            [bioStatsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
        
        // Biography テキスト表示
        NSString *bio = [[iTunesStore srchResult] biography];
        [biographyTextView setString:bio];
        
        // VO 対策 (V3.4)
        if ([biographyPanel firstResponder] == biographyTextView) {
            
            [biographyScrollView refresh];
            [biographyPanel makeFirstResponder:biographyTextView];
        }
        
        // Biography が空でなかった場合
        if ([bio length]) {
            
            // Artist 情報あり: Icon ON
            [self setArtistIcon:[[super SC_ARTIST_IMAGE] objectAtIndex:SC_IMAGE_ON]];
        }
    }
}

// アルバムカバー画像を HTTP で取得し、画面に反映させる
- (void) loadArtworkImageOfURL:(NSString *)aUrl {
	
	// 別スレッドで実行される
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSURL *artworkUrl = [NSURL URLWithString:aUrl];
	
	if (artworkUrl) {
		
		// HTTP で GET (取得に失敗した場合は nil が返る)
		NSImage *artworkImage = [[NSImage alloc] initWithContentsOfURL:artworkUrl];
		
		if (artworkImage) {
			
			[artworkLargeImageView setImage:artworkImage];
			[artworkLargeImageView setHidden:NO];
			//NSLog(@"## %@", artworkUrl100);

			[artworkImage release];
		}
	}
	
	[pool release];
}

#pragma mark - Panel Open/Close

// Panel Open/Close
- (IBAction) showPanel:(id)sender {
	
	if ([songInformationPanel isVisible]) {
		
		[songInformationPanel close];
    } else {
		
        // Main にも Key ウィンドウにもしない
        [songInformationPanel setLevel:NSFloatingWindowLevel];
        [songInformationPanel makeFirstResponder:topSongsTableView];
		[songInformationPanel orderFront:self];
	}
}

// Biography パネル表示/非表示
- (IBAction) showBiography:(id)sender {
	
	if ([biographyPanel isVisible]) {
		
		[biographyPanel close];
	} else {
		
        // Main にも Key ウィンドウにもしない
        [biographyPanel setLevel:NSFloatingWindowLevel];
        [biographyPanel makeFirstResponder:biographyTextView];
		[biographyPanel orderFront:self];
    }
}

#pragma mark    -   Button Actions

// Song ボタンクリック
- (IBAction) loadSongPage:(NSButton *)sender {
	
	[self loadPage:SC_LINK_SONG];
}

// Artist ボタンクリック
- (IBAction) loadArtistPage:(NSButton *)sender {

	[self loadPage:SC_LINK_ARTIST];
}

// WebView ロード -> iTunes 内表示
- (void) loadPage:(NSInteger)linkType {
    
    NSString            *url;
    WebView             *webView;
    NSProgressIndicator *spinningIcon;
    
    if (linkType == SC_LINK_SONG) {
        
        url          = songUrl;
        webView      = webView1;
        spinningIcon = spinningIcon1;
    }
    // SC_LINK_ARTIST
    else {
        
        url          = artistUrl;
        webView      = webView2;
        spinningIcon = spinningIcon2;
    }

    // 国コード取得 (検索で使用したものと国コードを使用する)
    NSString *countryCode = [iTunesStore countryCode];
    
    //-------------------------------------
    // Affiliate リンク生成 (国コード対応)
    //-------------------------------------
    NSString *urlAff = [linkMaker urlWithAffiliateParameter:url
                                         countryCode:countryCode
                                         withWebView:webView];

    // v4.0
    urlAff = [NSString stringWithFormat:@"%@&app=itunes", urlAff];
    
//    NSLog(@"## Aff link:\n%@", urlAff);
    
    //-------------------------------------
    // リンクオープン
    //-------------------------------------
    [webView setMainFrameURL:urlAff];
    
    [spinningIcon startAnimation:self];
}

- (void) finishingForFrame:(WebFrame *)frame {
    
	if ([frame.name isEqualToString:SCWebFrame1]) {
        
        [spinningIcon1  stopAnimation:self];
    } else {
        
        [spinningIcon2  stopAnimation:self];
    }
}


#pragma mark    -   Delegate

//-------------------------------
// Frame Delegate
//-------------------------------

// frame: finish loading
- (void) webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    
    [self finishingForFrame:frame];
}

// frame: fail loading
- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
	
    [self finishingForFrame:frame];
    
	//NSInteger code = [error code];
	//NSString *desc = [error localizedDescription];
	//NSString *reason = [error localizedFailureReason];
	
	//NSLog(@"########### Frame failed: %d (%@)", code, desc);	
}

//-------------------------------
// Resource Delegate
//-------------------------------

// resource: fail loading
- (void)webView:(WebView *)sender resource:(id)identifier didFailLoadingWithError:(NSError *)error fromDataSource:(WebDataSource *)dataSource {
	
	//NSInteger code = [error code];
	//NSString *desc = [error localizedDescription];
	//NSString *reason = [error localizedFailureReason];
	
	//NSLog(@"########### Resource Failed: %d (%@)", code, desc);
	
	// ↑
	// 例: ネットに接続されていない場合
	// code: -1009
	// desc: (This computer’s Internet connection appears to be offline.)
	
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    
    //[topSongsTableView deselectAll:self];
    //[bioStatsTableView deselectAll:self];
}

- (void) setArrowsLeftRight:(NSInteger)flag {
 
    [biographyTextView setArrowsleftRight:flag];
}

- (void) setArrowsUpDown:(NSInteger)flag {
    
    [biographyTextView setArrowsUpDown:flag];
}

#pragma mark - NSMenuDelegate

// メモ: このメソッドが呼ばれるには、NSMenu の Attribute 設定で、
//      Auto Enables Items をオンにしておく必要がある。
- (BOOL) validateMenuItem:(NSMenuItem *)menuItem {
    
    if (menuItem.action == @selector(showPanel:)) {
        
        if (songInformationPanel.isVisible) [menuItem setTitle:@"Hide Top Songs"];
        else                                [menuItem setTitle:@"Show Top Songs"];
    }
    else if (menuItem.action == @selector(showBiography:)) {
        
        if (biographyPanel.isVisible)       [menuItem setTitle:@"Hide Biography"];
        else                                [menuItem setTitle:@"Show Biography"];
    }
    
    return YES;
}

@end

