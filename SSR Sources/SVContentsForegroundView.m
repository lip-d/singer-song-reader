//
//  SVContentsForegroundView.m
//  Singer Song Reader
//
//  Created by Developer on 5/4/14.
//
//

#import "SSCommon.h"
#import "SVContentsForegroundView.h"
#import "NSScrollView+SSR.h"
#import "NSSplitView+SSR.h"

@implementation SVContentsForegroundView

- (NSTextView *) firstTextView {
    
    NSTextView *retView = nil;
    
    NSArray *subviews = self.subviews;
    
    if (subviews.count > 0) {
        
        NSView *subview = [subviews objectAtIndex:0];
        
        if ([subview isKindOfClass:[NSScrollView class]]) {
            
            retView = [(NSScrollView *)subview documentView];
        }
        else if ([subview isKindOfClass:[NSSplitView class]]) {
            
//            retView = [[(NSSplitView *)subview subviews] objectAtIndex:0];
            // V4.2
            retView = [[[[(NSSplitView *)subview subviews] objectAtIndex:0] subviews] objectAtIndex:0];
        }
    }
    
    return retView;
}

- (void) refresh {
    
#ifdef SS_DEBUG_MAKE_FIRST_RESPONDER
    NSLog(@"DEBUG ===========================[%3d]", ++contentsRefreshCount);
#endif
    
    NSArray *subviews = self.subviews;
    
    if (subviews.count > 0) {
        
        NSView *subview = [subviews objectAtIndex:0];
        
        if ([subview isKindOfClass:[NSScrollView class]]) {

            // DocumentView を付け直し
            [(NSScrollView *)subview refresh];
        }
        else if ([subview isKindOfClass:[NSSplitView class]]) {

            // SplitView ごと付け直し
            [(NSSplitView *)subview  refresh];
        }
    }
}

@end
