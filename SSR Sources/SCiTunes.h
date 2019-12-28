//
//  SCiTunes.h
//  Singer Song Reader
//
//  Created by Developer on 13/10/23.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSCommon.h"
#import "SMiTunesData.h"
#import "SMiTunesNotif.h"
#import "SVTextField.h"
#import "SCAppearance.h"
#import "SCLyrics.h"
#import "SCFadeoutMessage.h"
#import "SCBatch.h"
#import "SCOpenFile.h"
#import "SSShare.h"

extern const long           SC_iTUNES_TIMEOUT;

enum SCiTunesEPlS {
	SCiTunesEPlSNil            = 'kPSN',
	SCiTunesEPlSNotRunning     = 'kPSn',
	SCiTunesEPlSStopped        = 'kPSS',
	SCiTunesEPlSPlaying        = 'kPSP',
	SCiTunesEPlSPaused         = 'kPSp',
	SCiTunesEPlSFastForwarding = 'kPSF',
	SCiTunesEPlSRewinding      = 'kPSR',
	SCiTunesEPlSConnecting     = 'kPSC',
	SCiTunesEPlSError          = 'kPSE'
};
typedef enum SCiTunesEPlS SCiTunesEPlS;

enum SCAction {
    SC_AT_ACTION = 0,
    SC_MA_ACTION = 1
};

@interface SCiTunes : SSCommon <SBApplicationDelegate, NSTextFieldDelegate> {

	id delegate;

    // UI コネクション
	IBOutlet SVWindow    *mainWindow;
	IBOutlet SVTextField *songTitle;
	IBOutlet SVTextField *artistNames;
	IBOutlet NSTextField *noInfoAvailable;
    IBOutlet NSTextField *lyricsTextField; // "Lyrics" Label
    IBOutlet NSTextField *iTunesTextField; // "iTunes" Label
    IBOutlet NSButton    *batchButton;
    IBOutlet NSTextField *titleBarTextField;
	
    // UI バインディング
    NSImage  *iTunesLED;
    NSInteger autosave;
    NSInteger autosaveTx;

    // アクセスクラス
    IBOutlet SCLyrics          *LyricsCtrl;
    IBOutlet SCSiteTabs        *siteTabs;
	IBOutlet SCAppearance      *appearance;
    IBOutlet SCFadeoutMessage  *fadeoutMessage;
    IBOutlet SCFadeoutMessage  *fadeoutAlert;
    IBOutlet SCBatch           *batch;
    IBOutlet SCOpenFile        *openFile;
    IBOutlet SSShare           *share;

    id                currentApp;    // コントロール対象アプリ
    SCNotification    notification;  // 通知フラグ
    
	// iTunes/Deezer アクセス/データ格納
	iTunesApplication *iTunesApp;
    DeezerApplication *DeezerApp; // (v4.0)
	SMiTunesData      *iTunesData;
    SMiTunesNotif     *iTunesNotif;
    iTunesTrack       *savedTrack;
	BOOL               iTunesErrorFlag;
    NSError           *iTunesError;

    // Loop 割込みフラグ
	NSInteger srchType;
    BOOL      doTagging;
    BOOL      goEditing;
    BOOL      goBatchProcessing;
    BOOL      goOpenFile;
    
    // Batch Loop
    BOOL      intervalLock;
    BOOL      forcedAutosave;
    
    // 内部使用
	NSThread *thread;
	BOOL textFieldEdited;
	BOOL perSearchEdited;
    
    NSInteger arrowsUpDown;
    
    // Deezer notification 受信で使用
    NSDistributedNotificationCenter *dNtfCenter;
}

@property          NSInteger    autosave;
@property          NSInteger    autosaveTx;

@property (retain) NSError     *iTunesError;
@property (retain) iTunesTrack *savedTrack;
@property (retain) NSImage     *iTunesLED;

@property (readonly) SMiTunesData *iTunesData;

@property (readonly) NSInteger srchType;

@property (readonly) BOOL      perSearchEdited;

@property (retain) NSArray     *selectedTracks;

@property            NSInteger arrowsUpDown;

- (void) setDelegate:(id)aDelegate;

- (void) applicationWillFinishLaunching:(NSNotification *)aNotification;
- (void) applicationShouldTerminate;

// メイン処理ループ関連
- (void) mainLoop;
- (BOOL) check;

- (void) startLoop;
- (void) pauseLoop:(NSInteger)aEvent;
- (void) resumeLoop;

// Save
- (IBAction) tagCurrentButtonClicked:(id)sender;
- (void)     autoTagCurrent;
- (void)     tagCurrent:(NSNumber *)aTaggingAction;

- (IBAction) texCurrentButtonClicked:(id)sender;
- (void)     autoTexCurrent;
- (void)     texCurrent:(NSNumber *)aAction;

// Edit
- (IBAction) editButtonClicked:(id)sender;
- (IBAction) cancelButtonClicked:(id)sender;

// Batch
- (void)     startBatchLoop;
- (void)     unlockInterval;
- (IBAction) beginBatchMode:(id)sender;
- (IBAction) endBatchMode:(id)sender;

// Open File
- (IBAction) beginOpenFileModal:(id)sender;
- (IBAction) openFile:(id)sender;
- (IBAction) endOpenFileModal:(id)sender;

// Control iTunes
- (IBAction) nextTrack:(id)sender;
- (IBAction) prevTrack:(id)sender;
- (IBAction) launch:(id)sender;

// 内部使用
- (void) displayWindowTitle;
- (void) showStatus:(NSInteger)sts;
- (void) showStatusBlink;

#pragma mark    -   Key Up Event from SCDelegate

- (void) keyUpEvent:(NSEvent *)event;

NSInteger SCDetectMedia(iTunesTrack *track);

@end
