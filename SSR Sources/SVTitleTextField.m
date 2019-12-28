//
//  SVTitleTextField.m
//  Singer Song Reader
//
//  Created by Developer on 5/4/14.
//
//

#import "SVTitleTextField.h"
#import "NSView+SSR.h"

@implementation SVTitleTextField

- (NSView *) nextKeyView {

    NSView *retView = self.svwindow.artistTextField;
    
    return retView;
}

- (NSView *) previousKeyView {

    NSView *retView = self.svwindow.contentsForegroundView.firstTextView;
    
    return retView;
}

@end
