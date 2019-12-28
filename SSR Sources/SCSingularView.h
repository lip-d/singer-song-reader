//
//  SCSingularView.h
//  Singer Song Reader
//
//  Created by Developer on 13/10/08.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SCView.h"
#import "SVScroller.h"

@interface SCSingularView : SCView {
	SVScroller *customScroller;
	NSScroller *normalScroller;

@private
	NSScrollView *scrollView;
}

@property (readonly) SVScroller *customScroller;

- (NSTextContainer *) textContainerForLayoutManager:(NSLayoutManager *)givenManager;
- (SVContentsTextView *) textViewForTextContainer:(NSTextContainer *)givenContainer;

- (void) setAlignment:(NSTextAlignment)mode;
- (void) setHasVerticalScroller:(BOOL)flag;
- (void) setEditable:(BOOL)flag;
- (void) setArrowsLeftRight:(NSInteger)flag;
- (void) setArrowsUpDown:(NSInteger)flag;

- (NSTextView *)    firstTextView;
- (NSScrollView *)  view;
- (NSTextAlignment) alignment;

- (void) useCustomScroller;
- (void) useNormalScroller;

@end
