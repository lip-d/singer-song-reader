//
//  NSWindow+AccessoryView.h
//  NSWindowButtons
//
//  Created by Randall Brown on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NSWindow (NSWindow_AccessoryView)

-(void) addTopBar:(NSView *)viewToAdd;
-(void) addTitleBarButtons:(NSView *)viewToAdd;
-(void) addTitleBarText:(NSView *)viewToAdd;

//-(void) addTitleBarLyricsIndicator:(NSView *)viewToAdd;
//-(void) addTitleBarAutosaveButton:(NSView *)viewToAdd;
//-(void) addTitleBarITunesIndicator:(NSView *)viewToAdd;
//-(void) addTitleBarInfoButton:(NSView *)viewToAdd;
//-(void) addTitleBarMatchRatioTextField:(NSView *)viewToAdd;

//-(void) addResizeBox:(NSView *)viewToAdd;

-(CGFloat)heightOfTitleBar;

//-(void)addViewToTitleBar:(NSView*)viewToAdd atXPosition:(CGFloat)x;

@end
