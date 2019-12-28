//
//  SCLyrics.h
//  Singer Song Reader
//
//  Created by Developer on 13/10/20.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSCommon.h"
#import "SMTrack.h"
#import "SCContents.h"
#import "SCAppearance.h"
#import "SMSrchResult.h"
#import "SMSite.h"
#import "SCFadeoutMessage.h"
#import "SCSiteTabs.h"
#import "SSShare.h"

@interface SCLyrics : SSCommon {
	id delegate;
	
    // UI コネクション
	IBOutlet SVWindow           *mainWindow;
	IBOutlet NSMenuItem         *showOriginalMenuItem;
	IBOutlet NSImageView        *lyricsIndicator;
    IBOutlet NSTextField        *looseMatchTextField;

    // UI バインディング
    NSImage        *lyricsLED;
    NSString       *matchRatio;
    BOOL            tagCurrentButtonEnabled;
    BOOL            texCurrentButtonEnabled;
    BOOL            editButtonHidden;
    BOOL            cancelButtonHidden;
    NSString       *looseMatchText;
    
	// アクセスクラス
	IBOutlet SCContents         *contents;
	IBOutlet SCAppearance       *appearance;
    IBOutlet SCFadeoutMessage   *fadeoutMessage2;
    IBOutlet SCFadeoutMessage   *fadeoutMessage;
    IBOutlet SCSiteTabs         *siteTabs;
    IBOutlet SSShare            *share;

    // 検索サイトリスト
	NSMutableArray *siteList;

    // 再生中トラック情報 (自動検索ごとに書き変わる)
    NSInteger       mediaType;
    NSString       *trackIdentifier;
    NSInteger       srchType;
    
    //-----------------------------------
    // Local モード
    //-----------------------------------
    NSString       *localLyrics;

    //-----------------------------------
    // Site モード
    //             localLyrics == nil
    //-----------------------------------
	SMTrack        *track;
    SMPrefs        *prefs;
    NSInteger       matchThreshold; // マッチ率しきい値 (検索時に渡される)
	NSInteger       errorCode;
	NSInteger       hitNum;
    NSInteger       finishNum;
    
    BOOL            japaneseLyricsRomaji;
    BOOL            japaneseLyricsKanji;
    
    NSInteger       arrowsLeftRight;
}

@property (retain)    NSImage  *lyricsLED;
@property (retain)    NSString *matchRatio;
@property             BOOL      tagCurrentButtonEnabled;
@property             BOOL      texCurrentButtonEnabled;
@property             BOOL      editButtonHidden;
@property             BOOL      cancelButtonHidden;
@property (retain)    NSString *looseMatchText;

@property             NSInteger mediaType;
@property (retain)    NSString *trackIdentifier;
@property             NSInteger srchType;

@property (retain)    NSString *localLyrics;

@property (readonly)  NSInteger errorCode;

@property             NSInteger arrowsLeftRight;

- (void) setDelegate:(id)aDelegate;

- (void) applicationWillFinishLaunching:(NSNotification *)aNotification;

// 検索
- (void) updateSiteList;
- (void) clear;
- (void) searchWithTitle:(NSString *)aTitle withArtist:(NSString *)aArtist matchThreshold:(NSInteger)threshold;
- (void) useLocalLyrics:(NSString *)lyrics;
- (void) useFileLyrics:(NSString *)lyrics;
- (void) cancel;
- (void) timeout;

- (void) showLooseMatches;

// 検索結果受付〜サイトタブ更新
- (void)      siteDidFinishSearching:(id)sender;
- (void)      receiveData:(id)sender;
- (NSInteger) bestSite;
- (void)      waitAll;

// Lyrics コンテンツ表示
- (IBAction) _useSiteLyrics:(id)sender;
- (void)     _useLocalLyrics;
- (void)     _useFileLyrics:(NSString *)lyrics;
- (void)     displayContents:(NSString *)lyrics;
- (void)     buttonControl:(SCMode)mode;
- (void)     showLyricsStatus:(SCStateIndex)sts;

// 外部からのアクセス用
- (SMSite *)   selectedSite;
- (void)       setTaggedLyrics:(NSString *)taggedLyrics forSite:(SMSite *)aSite;
- (SMSrchResult *) srchResult;
- (NSString *) displayedLyrics;
- (NSInteger)  siteCount;
- (BOOL)       isEditMode;
- (BOOL)       isSearchCanceled;

// イベント受付
- (IBAction) showOriginal:(id)sender;

// Edit モード
- (void) beginEditMode;
- (void) endEditMode;

- (IBAction) nextSite:(id)sender;
- (IBAction) prevSite:(id)sender;

NSInteger numberSort(id num1, id num2, void *context);

#pragma mark    -   Key Up Event

// キー入力受付
- (void)     keyUpEvent:(NSEvent *)event;
//- (void)     keyDownEvent:(NSEvent *)event;

@end
