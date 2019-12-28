//
//  SCView.m
//  Singer Song Reader
//
//  Created by Developer on 13/10/08.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SCView.h"

const CGFloat LargeNumberForText = 1.0e7;

@implementation SCView



- (id)initWithTextStorage:(NSTextStorage *)textStorage {
    self = [super init];
    if (self) {
		layoutManager = [self layoutManagerForTextStorage:textStorage];
	}
    return self;
}

- (void)dealloc {
	[layoutManager release];
    [super dealloc];
}

- (NSLayoutManager *)layoutManager {
	return layoutManager;
}

- (NSLayoutManager *)layoutManagerForTextStorage:(NSTextStorage *)givenStorage {
    NSLayoutManager *lm = [[NSLayoutManager alloc] init];
    [givenStorage addLayoutManager:lm];
    return [lm autorelease];
}

- (NSTextContainer *)textContainerForLayoutManager:(NSLayoutManager *)givenManager {
	
	NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(LargeNumberForText, LargeNumberForText)];
	
	//[textContainer setLineFragmentPadding:100];
	
	if (givenManager != nil) {
		[givenManager addTextContainer:textContainer];
	}
	
    return [textContainer autorelease];
}

- (SVContentsTextView *)textViewForTextContainer:(NSTextContainer *)textContainer {

    SVContentsTextView *view = [[SVContentsTextView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100) textContainer:textContainer];
    [view setMaxSize:NSMakeSize(LargeNumberForText, LargeNumberForText)];
    [view setSelectable:YES];
    [view setEditable:NO];
    [view setRichText:YES];
    [view setImportsGraphics:NO];
    [view setUsesFontPanel:YES];
    [view setUsesRuler:NO];
    [view setAllowsUndo:YES];
	[view setAlignment:NSCenterTextAlignment];
    [view setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
	[view setTextContainerInset:NSMakeSize(5, 20)];
    	
	// Transparent test
	[view setDrawsBackground:NO];
    
    // 検索バーテスト
    //[view setUsesFindBar:YES];
	
    return [view autorelease];
}

- (void) replaceTextStorage:(NSTextStorage *)newStorage {
    
	[layoutManager replaceTextStorage:newStorage];
}

@end
