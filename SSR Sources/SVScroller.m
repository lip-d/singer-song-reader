//
//  SVScroller.m
//  Singer Song Reader
//
//  Created by Developer on 13/11/17.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SVScroller.h"
#import "SSCommon.h"

@implementation SVScroller

@synthesize backgroundColor;
@synthesize knobColor;
@synthesize allowKnob;

// 自分で alloc & init したときに呼ばれる
- (id)init {

    allowKnob = NO;
    
    self = [super init];
    if (self) {

        [self initControl];
	}
    return self;
}

// IB 上のオブジェクトが読み込まれたときに呼ばれる
- (void)awakeFromNib {
    
    allowKnob = NO;

    [super awakeFromNib];
    
    [self initControl];
}

- (void)dealloc {
    [super dealloc];
}


- (void) drawRect: (NSRect) dirtyRect
{
	if (backgroundColor) {

		[backgroundColor set];
	}
	
	NSRectFill(dirtyRect);

    if (allowKnob) {
    
        [self drawKnob];
    }
}

- (void) drawKnob {
    
	if (knobColor) {
        
		[knobColor set];
	}

    NSRect rect = [super rectForPart:NSScrollerKnob];
    
    NSRectFill(rect);
}

- (void) initControl {
    
    // スクロールバーのサイズを Small に設定 (Mini は機能しない - Regular と同じ表示になる)
    [super setControlSize:NSSmallControlSize];

    // ノブの色
    //[super setControlTint:NSClearControlTint];
    
    // スクローラの通り道の背景色
    [self setBackgroundColor:[NSColor colorWithCalibratedWhite:SSPanelWhite
                                                         alpha:SSPanelAlpha]];
    
    // スクローラのノブの色
    [self setKnobColor:[NSColor colorWithCalibratedWhite:SSPanelWhite
                                                         alpha:SSPanelAlpha+0.1]];
}

@end
