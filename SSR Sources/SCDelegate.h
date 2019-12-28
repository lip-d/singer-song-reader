//
//  SCDelegate.h
//  Singer Song Reader
//
//  Created by Developer on 13/10/23.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSCommon.h"
#import "SCiTunes.h"
#import "SCLyrics.h"
#import "SCContents.h"
#import "SCFontPanel.h"
#import "SCPreferences.h"
#import "SCStore.h"
#import "SCSongInformation.h"
#import "SCAppearance.h"
#import "SVWindow.h"
#import "SCBatch.h"
#import "SSShare.h"
#import "SCOpenFile.h"
#import "SVFieldEditorTextView.h"

enum SCSrchTarget {
	SCTypeLyrics = 0,
	SCTypeStore  = 1
};

enum SCSrchEvent {
	SCSrchStart   = 0,
	SCSrchCancel  = 1,
    SCSrchDone    = 2
};

extern SVFieldEditorTextView *titleFieldEditor;
extern SVFieldEditorTextView *artistFieldEditor;

@interface SCDelegate : SSCommon <NSApplicationDelegate> {
	
	NSWindow *window;
	
	IBOutlet SVWindow *mainWindow;
    IBOutlet NSPanel  *songInformationPanel;
    IBOutlet NSPanel  *biographyPanel;
    IBOutlet NSWindow *batchWindow;
    IBOutlet NSWindow *preferencesWindow;

	IBOutlet SVTextField *songTitle;
	IBOutlet SVTextField *artistNames;
	IBOutlet NSTextField *lyricsTextField;
	IBOutlet NSButton    *searchButton;
	
	IBOutlet SCiTunes          *iTunes;
	IBOutlet SCLyrics          *lyrics;
	IBOutlet SCContents        *contents;
	IBOutlet SCFontPanel       *fontPanel;
	IBOutlet SCPreferences     *preferences;
	IBOutlet SCStore           *store;
	IBOutlet SCSongInformation *songInformation;
	IBOutlet SCAppearance      *appearance;
    IBOutlet SCBatch           *batch;
    IBOutlet SCOpenFile        *openFile;
    IBOutlet SSShare           *share;

	
	IBOutlet NSImageView *songInfoWindowC;
	IBOutlet NSImageView *songInfoWindowL;
	IBOutlet NSImageView *songInfoWindowR;
    
    // UI バインディング
    NSInteger arrowsLeftRight;
    NSInteger arrowsUpDown;
	
@private
	BOOL     siteListChanged;
	
    // Song Info パネル用に保存しておく検索条件
	NSString *searchTitle;
	NSString *searchArtist;
    
    BOOL     lyricsDone;
    BOOL     storeDone;
}

@property (assign) IBOutlet NSWindow *window;

@property (retain) NSString *searchTitle;
@property (retain) NSString *searchArtist;

// (v3.8)
@property (strong) id activity;

- (void) applicationWillFinishLaunching:(NSNotification *)aNotification;
- (NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *)sender;


// 検索系 (入口)↘︎
- (void) startSearching:(id)sender;
- (void) lyricsSearch:(id)sender;
- (void) storeSearch;

// 中断・割込系↘︎
- (void)     startTimer:(NSInteger)srchTarget srchType:(NSInteger)srchType;
- (void)     cancelTimer:(NSInteger)srchTarget;
- (void)     timer:(NSNumber *)aSrchTarget;
- (IBAction) cancel:(id)sender;
- (IBAction) manualSearch:(id)sender;

// 検索終了受付
- (void) lyricsDidFinishSearching:(id)sender; // 復帰↗︎
- (void) storeDidFinishSearching:(id)sender;

// イベント受付系
- (IBAction) searchButtonClicked:(NSButton *)sender;
- (void)     appearanceDidChange:(id)sender;
- (void)     contentsViewDidSwitched:(id)sender;
- (void)     preferencesCountryChanged:(id)sender;
- (void)     preferencesSiteListChanged:(id)sender;
- (void)     preferencesAlwaysOnTopChanged:(id)sender;
- (void)     batchDidStarted:(id)sender;
- (void)     batchDidPaused:(id)sender;
- (IBAction) arrowsMenuChanged:(id)sender;
- (IBAction) copyArtistAndTitle:(id)sender;
- (IBAction) showHomepage:(id)sender;
- (IBAction) showFAQs:(id)sender;
- (IBAction) showDonationPage:(id)sender;
- (IBAction) makeTitleFirstResponder:(id)sender;

// UI パーツ制御系
- (void) searchButtonControl:(NSInteger)srchEvent;

// ウィンドウ関連イベント受付
- (void)windowDidBecomeMain:(NSNotification *)notification;
- (void)windowDidResignMain:(NSNotification *)notification;
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication;

// 内部用
- (void)      updateTrackingRect;
- (NSString *)getArtistAndTitle;
- (BOOL)      isValid:(NSString *)title artist:(NSString *)artist;
- (void)     setArrowsSetting;

#pragma mark    -   Key Up Event

// キー入力受付
- (void) keyUpEvent:(NSEvent *)event;

@end
