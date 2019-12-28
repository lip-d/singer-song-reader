//
//  SCSingularView.m
//  Singer Song Reader
//
//  Created by Developer on 13/10/08.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SCSingularView.h"
#import "SVScroller.h"
#import "SSCommon.h"

@implementation SCSingularView

@synthesize customScroller;

- (id)initWithTextStorage:(NSTextStorage *)textStorage {
    self = [super initWithTextStorage:textStorage];
    if (self) {
		NSTextContainer *textContainer = [self textContainerForLayoutManager:layoutManager];
		SVContentsTextView *textView = [self textViewForTextContainer:textContainer];
        
        // V3.4
        [textView setDebugTag:100];
		
		// 100 x 100 は仮の値
		scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
		
        [scrollView setBorderType:NSNoBorder];
        [scrollView setHasVerticalScroller:YES];
        [scrollView setHasHorizontalScroller:NO];
        [scrollView setAutohidesScrollers:YES];
        [scrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
		[scrollView setDrawsBackground:NO];
		
		[scrollView setDocumentView:textView];
		
        // v3.6 No Elasticity
        if ([scrollView respondsToSelector:@selector(setVerticalScrollElasticity:)]) {
            [scrollView setHorizontalScrollElasticity:NSScrollElasticityNone];
            [scrollView setVerticalScrollElasticity:  NSScrollElasticityNone];
        }
        
		// 背景を透過したカスタムスクローラ
		customScroller = [[SVScroller alloc] init];
        
        // V3.0: 以下の処理を SVScroller の init に移動
		[customScroller setControlTint:NSClearControlTint];
		//[customScroller setBackgroundColor:[NSColor colorWithCalibratedWhite:SSPanelWhite alpha:SSPanelAlpha]];
		
		// 元のスクローラ
		normalScroller = [[scrollView verticalScroller] retain];
	}
    return self;
}

- (void)dealloc {
	[normalScroller release];
	[customScroller release];
	[scrollView release];
    [super dealloc];
}

- (NSTextContainer *)textContainerForLayoutManager:(NSLayoutManager *)givenManager {
	NSTextContainer *textContainer = [super textContainerForLayoutManager:givenManager];
	
	[textContainer setWidthTracksTextView:YES];
    [textContainer setHeightTracksTextView:NO];

    return textContainer;
}

- (SVContentsTextView *)textViewForTextContainer:(NSTextContainer *)textContainer {
    SVContentsTextView *view = [super textViewForTextContainer:textContainer];

	[view setHorizontallyResizable:NO];
    [view setVerticallyResizable:YES];

    return view;
}

- (void) setAlignment:(NSTextAlignment)mode {
	
	[[scrollView documentView] setAlignment:mode];
}

- (void) setHasVerticalScroller:(BOOL)flag {
	
	[scrollView setHasVerticalScroller:flag];
}

- (void) setEditable:(BOOL)flag {
    
    [[scrollView documentView] setEditable:flag];
    
    // スペルチェッキング テスト
    //[[scrollView documentView] checkSpelling:self];
}

- (void) setArrowsLeftRight:(NSInteger)flag {
    
    [[scrollView documentView] setArrowsleftRight:flag];
}

- (void) setArrowsUpDown:(NSInteger)flag {
    
    [[scrollView documentView] setArrowsUpDown:flag];
}

- (void) useCustomScroller {
	
	[scrollView setVerticalScroller:customScroller];
}

- (void) useNormalScroller {

	[scrollView setVerticalScroller:nil];
	[scrollView setVerticalScroller:normalScroller];
    [scrollView tile];
}

- (NSTextView *)  firstTextView {

    return scrollView.documentView;
}

- (NSScrollView *)view {
	return scrollView;
}

- (NSTextAlignment) alignment {
	
	return [[scrollView documentView] alignment];
}

@end
