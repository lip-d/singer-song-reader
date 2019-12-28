//
//  SCAppearance.h
//  Singer Song Reader
//
//  Created by Developer on 13/11/16.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSCommon.h"
#import "SCContents.h"
#import "SVWindow.h"

@interface SCAppearance : SSCommon <NSTabViewDelegate> {
	id delegate;
	
	IBOutlet SVWindow *mainWindow;
	IBOutlet NSToolbar *toolbar;
    IBOutlet NSSegmentedControl *siteTab;

	IBOutlet SCContents *contents;
	
	IBOutlet NSView *topView;
	IBOutlet NSView *contentsView;
	IBOutlet NSView *bottomView;
		
//	IBOutlet NSImageView *titleBarLyricsIndicator;
    IBOutlet NSView      *titleBarButtons;
    IBOutlet NSTextField *titleBarTextField;
//	IBOutlet NSImageView *titleBarITunesIndicator;
//	IBOutlet NSButton    *titleBarAutosaveButton;
//	IBOutlet NSButton    *titleBarInfoButton;
//  IBOutlet NSTextField *titleBarMatchRatio;

	IBOutlet NSMenu *appearanceMenu;
	
	NSInteger currentMode;
	
	NSButton *closeButton;
	NSButton *miniaturizeButton;
	NSButton *zoomButton;
}

@property (readonly) NSInteger currentMode;

- (void) setDelegate:(id)aDelegate;

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification;

- (IBAction) changeAppearance:(id)sender;
- (void)     changeAppearanceWithTag:(NSInteger)aTag;

- (void) barsSetHidden:(BOOL)aFlag;
- (void) contentsSetWide:(BOOL)aFlag;
- (void) windowSetOpaque:(BOOL)aFlag;
- (void) buttonsSetHidden:(BOOL)aFlag;
- (void) menuControl;

- (void) contentsSetWideFor:(NSView *)newView;
@end
