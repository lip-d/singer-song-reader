//
//  SCView.h
//  Singer Song Reader
//
//  Created by Developer on 13/10/08.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SVContentsTextView.h"
#import "NSView+SSR.h"

extern const CGFloat LargeNumberForText;

@interface SCView : NSObject {

	NSLayoutManager *layoutManager;
	
}

- (id)initWithTextStorage:(NSTextStorage *)textStorage;

- (NSTextContainer *)textContainerForLayoutManager:(NSLayoutManager *)givenManager;
- (SVContentsTextView *)textViewForTextContainer:(NSTextContainer *)givenContainer;

- (NSLayoutManager *)layoutManager;

- (NSLayoutManager *)layoutManagerForTextStorage:(NSTextStorage *)givenStorage;

- (void) replaceTextStorage:(NSTextStorage *)newStorage;

@end
