//
//  SCColumnarView.h
//  Singer Song Reader
//
//  Created by Developer on 13/09/09.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SCView.h"


@interface SCColumnarView : SCView {
    
@private
	NSSplitView    *splitView;
	NSMutableArray *textContainerArray;
}

- (id) initWithTextStorage:(NSTextStorage *)textStorage;

- (NSTextContainer *) textContainerForLayoutManager:(NSLayoutManager *)givenManager;
- (SVContentsTextView *) textViewForTextContainer:(NSTextContainer *)givenContainer;

- (NSArray *) viewsOfTextViews:(NSInteger)newViewNum;

- (void) setAlignment:(NSTextAlignment)mode;
- (void) setEditable:(BOOL)flag;
- (void) setArrowsLeftRight:(NSInteger)flag;
- (void) setArrowsUpDown:(NSInteger)flag;

- (NSTextView *)  firstTextView;
- (NSSplitView *) view;
- (NSSplitView *) viewOf:(NSInteger)newNum;
- (NSTextAlignment) alignment;

@end
