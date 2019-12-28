//
//  NSWindow+AccessoryView.m
//  NSWindowButtons
//
//  Created by Randall Brown on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSWindow+AccessoryView.h"

@implementation NSWindow (NSWindow_AccessoryView)

// Top バー (中央)
-(void) addTopBar:(NSView *)view {
	
	view.frame = NSMakeRect(-1,
                            [[self contentView] frame].size.height,
                            [[self contentView] frame].size.width+1,
                            view.frame.size.height);
    
	[[[self contentView] superview] addSubview:view];
}

// カスタム タイトルバー ボタン (左端)
-(void) addTitleBarButtons:(NSView *)view {
    
    // X 軸: プラスで右方向   Y 軸: プラスで上方向
	view.frame = NSMakeRect(5,
                            [[self contentView] frame].size.height -2,
                            view.frame.size.width,
                            [self heightOfTitleBar]);
    
	[view setAutoresizingMask:NSViewMaxXMargin | NSViewMinYMargin];
    
	[[[self contentView] superview] addSubview:view];
}

// カスタム タイトルバー テキスト (中央)
-(void) addTitleBarText:(NSView *)view {
    
    // 3つボタン横幅
    const CGFloat btnWidth = 66;
    
    view.frame = NSMakeRect(btnWidth,
                            [[self contentView] frame].size.height -2,
                            [[self contentView] frame].size.width - (btnWidth*2),
                            [self heightOfTitleBar]);
    
	[[[self contentView] superview] addSubview:view];
}

// 左端スクエアインジケータ (Lyrics)
/*
 -(void) addTitleBarLyricsIndicator:(NSView *)view {
 // 左端
 view.frame = NSMakeRect(5,
 [[self contentView] frame].size.height + 19,
 view.frame.size.width,
 [self heightOfTitleBar]);
 
 [view setAutoresizingMask:NSViewMaxXMargin | NSViewMinYMargin];
 
 [[[self contentView] superview] addSubview:view];
 }
 */

// 右端 Autosave LED ボタン
/*
-(void) addTitleBarAutosaveButton:(NSView *)view {
    
	view.frame = NSMakeRect(self.frame.size.width - view.frame.size.width,
								 [[self contentView] frame].size.height + 21,
								 view.frame.size.width,
								 [self heightOfTitleBar]);
	
	[view setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin];
    
	[[[self contentView] superview] addSubview:view];
}
*/

// 右端スクエアインジケータ用 (iTunes)
/*
-(void) addTitleBarITunesIndicator:(NSView *)view {

	view.frame = NSMakeRect(self.frame.size.width - view.frame.size.width - 7,
								 [[self contentView] frame].size.height + 19,
								 view.frame.size.width,
								 [self heightOfTitleBar]);

	[view setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin];

	[[[self contentView] superview] addSubview:view];
}
*/

/*
-(void) addTitleBarInfoButton:(NSView *)view {
    
	view.frame = NSMakeRect(self.frame.size.width - view.frame.size.width -24,
								 [[self contentView] frame].size.height + 21,
								 view.frame.size.width,
								 [self heightOfTitleBar]);
	
	[view setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin];
    
	[[[self contentView] superview] addSubview:view];    
}
*/
/*
-(void) addTitleBarMatchRatioTextField:(NSView *)view {
    
	view.frame = NSMakeRect(5,
								 [[self contentView] frame].size.height -2,
								 view.frame.size.width,
								 [self heightOfTitleBar]);
	
	[view setAutoresizingMask:NSViewMaxXMargin | NSViewMinYMargin];
    
	[[[self contentView] superview] addSubview:view];
}
*/
/*
-(void) addResizeBox:(NSView *)view {
	
	view.frame = NSMakeRect(self.frame.size.width - view.frame.size.width - 4,
								 [[self contentView] frame].origin.y,
								 view.frame.size.width,
								 view.frame.size.height);
	
	[view setAutoresizingMask:NSViewMinXMargin | NSViewMaxYMargin];
	
	[[[self contentView] superview] addSubview:view];
}
*/

-(CGFloat)heightOfTitleBar
{
   NSRect outerFrame = [[[self contentView] superview] frame];
   NSRect innerFrame = [[self contentView] frame];
   
   return outerFrame.size.height - innerFrame.size.height;
}

/*
 -(void)addViewToTitleBar:(NSView*)view atXPosition:(CGFloat)x
 {
 view.frame = NSMakeRect(x, [[self contentView] frame].size.height, view.frame.size.width, [self heightOfTitleBar]);
 
 NSUInteger mask = 0;
 if( x > self.frame.size.width / 2.0 )
 {
 mask |= NSViewMinXMargin;
 }
 else
 {
 mask |= NSViewMaxXMargin;
 }
 [view setAutoresizingMask:mask | NSViewMinYMargin];
 
 [[[self contentView] superview] addSubview:view];
 }
 */


@end
