//
//  SCContents.h
//  Singer Song Reader
//
//  Created by Developer on 13/10/08.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SCColumnarView.h"
#import "SCSingularView.h"
#import "SVFontAccessoryView.h"
#import "SSCommon.h"


@interface SCContents : SSCommon {
    
    id delegate;
		
    // UI コネクション
	IBOutlet SVWindow    *mainWindow;
    
    IBOutlet NSTextField *titleTextField;
    IBOutlet NSTextField *artistTextField;
    
	IBOutlet NSMenuItem *addColumn;
	IBOutlet NSMenuItem *reduceColumn;
	IBOutlet NSMenu     *columnsMenu;
	
	IBOutlet NSBox      *contentsBackground;
	IBOutlet NSView     *contentsForeground;
    
	NSTextStorage *textStorage;
	
	SCColumnarView *columnarView;
	SCSingularView *singularView;
    
    NSInteger columnCount;
}

@property (readonly) NSView *currentView;
@property (readonly) NSInteger columnCount;

@property (readonly) NSTextStorage *textStorage;

@property (readonly) SCColumnarView *columnarView;
@property (readonly) SCSingularView *singularView;


- (void) setDelegate:(id)aDelegate;

- (void) applicationWillFinishLaunching:(NSNotification *)aNotification;
- (void) applicationShouldTerminate;

- (void) changeText:(NSString *)str refresh:(BOOL)refreshFlag;
- (void) changeText:(NSString *)str color:(NSColor *)color refresh:(BOOL)refreshFlag;
- (void) changeColumns:(NSInteger)num;

- (void) changeTextColor:(NSColor *)color;
- (void) changeBackgroundColor:(NSColor *)color;
- (void) setOpaque:(BOOL)aFlag;
- (void) setAlignment:(NSTextAlignment)mode;
- (void) setEditable:(BOOL)flag;
- (void) deselectText;
- (void) setArrowsLeftRight:(NSInteger)flag;
- (void) setArrowsUpDown:(NSInteger)flag;

- (IBAction) setColumns:(id)sender;
- (IBAction) addColumn:(id)sender;
- (IBAction) reduceColumn:(id)sender;

- (NSString *)    text;
- (NSTextView *)  firstTextView;
- (NSView *)      currentView;

- (void) setAccessibilityDescription:(NSString *)descriotion;

@end
