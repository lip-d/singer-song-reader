//
//  SVContentsTextView.m
//  Singer Song Reader
//
//  Created by Developer on 5/5/14.
//
//

#import "SVContentsTextView.h"
#import "NSView+SSR.h"

@implementation SVContentsTextView

- (NSView *) nextValidKeyView {
    
    [self.svwindow.contentsForegroundView refresh];
    
    return [super nextValidKeyView];
}

- (NSView *) previousValidKeyView {
    
    [self.svwindow.contentsForegroundView refresh];
    
    return [super previousValidKeyView];
}

- (NSView *) nextKeyView {
    
    return self.svwindow.titleTextField;
}

- (NSView *) previousKeyView {
    
    return self.svwindow.artistTextField;
}

@end
