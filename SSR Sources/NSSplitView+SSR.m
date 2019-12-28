//
//  NSSplitView+SSR.m
//  Singer Song Reader
//
//  Created by Developer on 5/8/14.
//
//

#import "NSSplitView+SSR.h"

@implementation NSSplitView (SSR)

- (void) refresh {
    
    NSView *superview = self.superview;
    
    [self removeFromSuperview];
    [superview addSubview:self];
}

@end
