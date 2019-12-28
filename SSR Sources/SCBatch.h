//
//  SCBatch.h
//  Singer Song Reader
//
//  Created by Developer on 2014/03/05.
//
//

#import <Foundation/Foundation.h>
#import "iTunes.h"
#import "SSCommon.h"
#import "SSShare.h"

enum SCTrackResultType {
    SC_TRK_AUTOSAVED   = 0,
    SC_TRK_NO_HIT      = 1,
    SC_TRK_EXISTING    = 2,
    SC_TRK_NON_MS_FILE = 3,
    SC_TRK_NON_MS_ZERO = 4,
    SC_TRK_ERROR       = 5,
    SC_TRK_LOOSE_MATCH = 6
};

@interface SCBatch : SSCommon <SBApplicationDelegate> {
    
    id delegate;
    
    IBOutlet NSWindow    *batchWindow;
    IBOutlet NSWindow    *mainWindow;
    // メッセージ
    IBOutlet NSTextField *mainMessageTextField;
    IBOutlet NSTextField *subMessageTextField;

    // プログレスバー
    IBOutlet NSProgressIndicator *mainProgressBar;

    // 数値
    IBOutlet NSView      *valLayer;
    IBOutlet NSTextField *valProcessedTextField;
    IBOutlet NSTextField *valPercengageTextField;
    
    // アイコン
    IBOutlet NSImageView *blueCheckImageView;
    IBOutlet NSImageView *squareLedImageView;
    IBOutlet NSImageView *greenCheckImageView;
    
    // 結果レイヤー
    IBOutlet NSView      *resLayer;
    IBOutlet NSButton    *resAutosaved;
    IBOutlet NSButton    *resNoHit;
    IBOutlet NSButton    *resSkipped;
    IBOutlet NSButton    *resLooseMatch;
    
    // Help レイヤー
    IBOutlet NSView      *helpLayer;

    // ボタン
    IBOutlet NSButton    *startButton;
    IBOutlet NSButton    *pauseButton;
    IBOutlet NSButton    *closeButton;
    IBOutlet NSButton    *checkButton;
    IBOutlet NSButton    *backButton;
    IBOutlet NSButton    *overwriteCheckbox;
    
    IBOutlet NSBox       *intervalBar;
    
    IBOutlet NSPanel     *songInfoPanel;
    IBOutlet NSPanel     *biographyPanel;
    
    // UI バインディング
    NSInteger valAutosaved;
    NSInteger valNoHit;
    NSInteger valSkipped;
    NSInteger valLooseMatch;
    
    NSInteger interval;
    NSInteger overwrite;
    BOOL      paused;
    

    // アクセスクラス
    IBOutlet SSShare     *share;
    
    // iTunes Tracks (Autosaved, No Hit)
    NSMutableArray       *aryAutosaved;
    NSMutableArray       *aryNoHit;
    
    // iTunes Tracks (Skipped)
    NSMutableArray       *aryExisting;
    NSMutableArray       *aryNonMusicFile;
    NSMutableArray       *aryNonMusicZero;
    NSMutableArray       *aryError;
    
    // iTunes Tracks (Loose Match)
    NSMutableArray       *aryLooseMatch;

    // iTunes アクセス
    iTunesApplication    *iTunesApp;
    BOOL                  iTunesErrorFlag;
    NSError              *iTunesError;

    // iTunes 全 Track
    NSArray              *iTunesTracks;
    NSInteger             iTunesTracksTotal;
    
    // 一時停止フラグ
    NSDate               *pausedDate;
}

@property          NSInteger    interval;
@property          NSInteger    overwrite;

@property          NSInteger    valAutosaved;
@property          NSInteger    valNoHit;
@property          NSInteger    valSkipped;
@property          NSInteger    valLooseMatch;

@property          BOOL         paused;

@property (retain) NSError     *iTunesError;
@property (retain) NSArray     *iTunesTracks;

- (void) setDelegate:(id)aDelegate;
- (void) applicationShouldTerminate;

- (IBAction) showBatchWindow:(id)sender;
- (void) closeBatchWindow;

- (iTunesTrack *) getTrack;

- (void) addTrack:(iTunesTrack *)track type:(NSInteger)type errorCode:(NSInteger)errorCode;

- (void) startIntervalAnimation;
- (void) stopIntervalAnimation;

- (IBAction) checkButtonClicked:(id)sender;
- (IBAction) startButtonClicked:(id)sender;
- (IBAction) pauseButtonClicked:(id)sender;
- (IBAction) resultIconClicked :(id)sender;
- (IBAction) helpIconClicked :(id)sender;

- (IBAction) deleteButtonClicked:(id)sender;


@end
