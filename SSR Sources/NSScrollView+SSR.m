//
//  NSScrollView+SSR.m
//  Singer Song Reader
//
//  Created by Developer on 5/8/14.
//
//

#import "NSScrollView+SSR.h"

@implementation NSScrollView (SSR)

- (void) refresh {
    
    NSTextView *savedView = self.documentView;
    
    // Document View 一旦剥がして、付け直し
    [self setDocumentView:nil];
    [self setDocumentView:savedView];
}

@end
