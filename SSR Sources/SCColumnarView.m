//
//  SCColumnarView.m
//  Singer Song Reader
//
//  Created by Developer on 13/09/09.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SCColumnarView.h"


@implementation SCColumnarView

/* Sets up a standard Cocoa text system, made up of a layout manager, text container, and text view, as well as the text storage given as an initialization parameter.
 */
- (id)initWithTextStorage:(NSTextStorage *)textStorage {
    self = [super initWithTextStorage:textStorage];
    if (self) {

		textContainerArray = [[NSMutableArray alloc] initWithCapacity:0];
		
		for (int i=0; i<10; i++) {
			NSTextContainer *textContainer = [self textContainerWithTextView];
            
            // V3.4
            [(SVContentsTextView *)(textContainer.textView) setDebugTag:(200+i)];
            
			[textContainerArray addObject:textContainer];
		}

		// 100 x 100 は仮の値
		splitView = [[NSSplitView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
		
        [splitView setVertical:YES];
        [splitView setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];
		[splitView setDividerStyle:NSSplitViewDividerStyleThin];
	}
    return self;
}

// TextContainer+TextView のセットを作成する (※LayoutManager とはリンクしない)
// initWithTextStorage: のみで使用
- (NSTextContainer *)textContainerWithTextView {
    
    NSTextContainer *textContainer = [self textContainerForLayoutManager:nil];
    
    // V4.2
    SVContentsTextView *textView = [self textViewForTextContainer:textContainer];
    
    // 100 x 100 は仮の値
    NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
    
    // TextView を View でラッピングしておく。
    [view addSubview:textView];
    
    return textContainer;
}

- (void)dealloc {
	[textContainerArray release];
	[splitView release];
    [super dealloc];
}

- (NSTextContainer *)textContainerForLayoutManager:(NSLayoutManager *)givenManager {
	NSTextContainer *textContainer = [super textContainerForLayoutManager:givenManager];
		
	[textContainer setWidthTracksTextView:YES];
    [textContainer setHeightTracksTextView:YES];
	
    return textContainer;
}

- (SVContentsTextView *)textViewForTextContainer:(NSTextContainer *)textContainer {
    SVContentsTextView *view = [super textViewForTextContainer:textContainer];
	
	[view setHorizontallyResizable:NO];
    [view setVerticallyResizable:NO];

    return view;
}

// 予め用意しておいた TextContainer リストから指定数分の TextView を取得し親Viewのリストを返す (V4.2)
- (NSArray *) viewsOfTextViews:(NSInteger)newViewNum {
	
	NSArray *oldTextContainerArray = [layoutManager textContainers];
	NSInteger oldViewNum = [oldTextContainerArray count];
	
	// 一旦 LayoutManager の TextContainer をすべてリンク解除する
	for (int i=0; i<oldViewNum; i++) {
		[layoutManager removeTextContainerAtIndex:0];
	}
	
	// 返却用 View リスト
	NSMutableArray *viewArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
	
	for (int i=0; i<newViewNum; i++) {
		NSTextContainer *textContainer = [textContainerArray objectAtIndex:i];
		
		// LayoutManager に再リンク
		[layoutManager addTextContainer:textContainer];
		
		NSTextView *textView = [textContainer textView];
		
		// サイズを均等に再度割り当てる
//		[textView setFrame:NSMakeRect(0, 0, 100, 100)];

        // (V4.2) サイズ再割当てはsuperviewのみでOK
        [textView.superview setFrame:NSMakeRect(0, 0, 100, 100)];
        
		// textView リストに追加
		[viewArray addObject:textView.superview];
	}
	
	return viewArray;
}

/*
- (NSArray *) textViews  {
    
	NSMutableArray *textViewArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];

    for (NSTextContainer *textContainer in layoutManager.textContainers) {
        
        [textViewArray addObject:textContainer.textView];
    }
    
    return textViewArray;
}
*/

- (void) setAlignment:(NSTextAlignment)mode {

	for (NSTextContainer *textContainer in textContainerArray) {
		
		NSTextView *textView = [textContainer textView];
		[textView setAlignment:mode];
	}
}

- (void) setEditable:(BOOL)flag {

	for (NSTextContainer *textContainer in textContainerArray) {
		
		NSTextView *textView = [textContainer textView];
		[textView setEditable:flag];
	}
}

- (void) setArrowsLeftRight:(NSInteger)flag {
    
	for (NSTextContainer *textContainer in textContainerArray) {
		
		SVContentsTextView *textView = (SVContentsTextView *)[textContainer textView];
		[textView setArrowsleftRight:flag];
	}
}

- (void) setArrowsUpDown:(NSInteger)flag {
    
	for (NSTextContainer *textContainer in textContainerArray) {
		
		SVContentsTextView *textView = (SVContentsTextView *)[textContainer textView];
		[textView setArrowsUpDown:flag];
	}
}

- (NSTextView *) firstTextView {
    
	NSTextContainer *textContainer = [textContainerArray objectAtIndex:0];
	
    return [textContainer textView];
}

- (NSSplitView *) view {
	return splitView;
}

// 指定数分の subview を割り当てた splitView を返す
- (NSSplitView *) viewOf:(NSInteger)newNum {

    NSArray *newViews = [self viewsOfTextViews:newNum];
    
    [splitView setSubviews:newViews];
    
    return splitView;
}

- (NSTextAlignment) alignment {

	return [[self firstTextView] alignment];
}

@end
