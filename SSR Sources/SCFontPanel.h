//
//  SCFontPanel.h
//  Singer Song Reader
//
//  Created by Developer on 13/10/25.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SCContents.h"
#import "SVFontAccessoryView.h"
#import "SSCommon.h"

@interface SCFontPanel : SSCommon <NSWindowDelegate> {

	NSFontPanel *fontPanel;

	// Accessory View
	IBOutlet SVFontAccessoryView *fontAccessoryView;
	IBOutlet NSColorWell *textColorWell;
	IBOutlet NSColorWell *backgroundColorWell;	
	IBOutlet NSTextField *textTextField;
	IBOutlet NSTextField *backgroundTextField;
	
	// Lyrics コンテンツ
	IBOutlet SCContents *contents;
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification;

- (void) changeTextStorageFont:(id)sender;
- (IBAction) changeTextColor:(id)sender;
- (IBAction) changeBackgroundColor:(id)sender;

- (IBAction) showFontPanel:(id)sender;

- (void) controlColorButtons;

- (NSUInteger)validModesForFontPanel:(NSFontPanel *)fPanel;

@end
