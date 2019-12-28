//
//  NSView+SSR.m
//  Singer Song Reader
//
//  Created by Developer on 4/30/14.
//
//

#import "NSView+SSR.h"
#import <objc/runtime.h> // Needed for method swizzling


@implementation NSView (SSR)

- (SVWindow *) svwindow {
    
    return (SVWindow *)[self window];
}

/*
- (NSView *) swizzled_nextValidKeyView {
    
    NSView *next = [self swizzled_nextValidKeyView];
    
    if ([[NSApp keyWindow] firstResponder] == self) {
        
        NSInteger selfDebugTag, nextDebugTag;
        NSString *selfUnknown, *nextUnknown;
        
        selfDebugTag = [self debugTag];
        nextDebugTag = [next debugTag];
    
        if (selfDebugTag == -1)
            selfUnknown = [[self.description componentsSeparatedByString:@":"] objectAtIndex:0];
        else
            selfUnknown = @"";
        
        if (next == nil)
            nextUnknown = @"nil";
        else
            nextUnknown = @"";
        
        
//        NSLog(@"## %d %@-> %d %@ ---------------------", (int)selfDebugTag, selfUnknown, (int)nextDebugTag, nextUnknown);
        
    }
    
    return next;
}

+ (void)load {

    Method original, swizzled;

    original = class_getInstanceMethod(self, @selector(nextValidKeyView));
    swizzled = class_getInstanceMethod(self, @selector(swizzled_nextValidKeyView));
    method_exchangeImplementations(original, swizzled);
}
*/

@end
