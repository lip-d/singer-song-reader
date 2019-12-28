//
//  NSResponder+SSR.m
//  Singer Song Reader
//
//  Created by Developer on 4/30/14.
//
//

#import "NSResponder+SSR.h"
#import <objc/runtime.h> // Needed for method swizzling

@implementation NSResponder (SSR)

static NSMutableDictionary *debugTagDictionary;

- (NSInteger) debugTag {
    
    NSString *key = [NSString stringWithFormat:@"%p", self];
    
//    NSLog(@"## key: %@", key);
    
    NSNumber *numberTag = [debugTagDictionary valueForKey:key];
    
    if (numberTag) return numberTag.integerValue;
    else           return -1;
}

- (void) setDebugTag:(NSInteger)tag {
    
    NSString *key = [NSString stringWithFormat:@"%p", self];
    
    [debugTagDictionary setValue:[NSNumber numberWithInteger:tag]
                          forKey:key];
}
/*
- (BOOL) swizzled_acceptsFirstResponder {
    
	BOOL acceptsFirstResponder = [self swizzled_acceptsFirstResponder];
    
//    NSLog(@"## %d: acceptsFirstResponder (%d)", (int)[self debugTag], acceptsFirstResponder);
    
	return acceptsFirstResponder;
}

- (BOOL) swizzled_becomeFirstResponder {
    
	BOOL didBecomeFirstResponder = [self swizzled_becomeFirstResponder];
    
    NSString *unknown;
    
    if ([self debugTag] == -1) unknown = [[[self description] componentsSeparatedByString:@":"] objectAtIndex:0];
    else                       unknown = @"";
    
//    NSLog(@"## %d %@: becomeFirstResponder (%d)", (int)[self debugTag], unknown, didBecomeFirstResponder);
    
	return didBecomeFirstResponder;
}

- (BOOL) swizzled_resignFirstResponder {
	
	BOOL didResignFirstResponder = [self swizzled_resignFirstResponder];
    
    // test
//    NSLog(@"## %d: resignFirstResponder (%d)", (int)[self debugTag], didResignFirstResponder);
	
	return didResignFirstResponder;
}
*/

+ (void)load {

    debugTagDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
/*
    Method original, swizzled;
    
    original = class_getInstanceMethod(self, @selector(becomeFirstResponder));
    swizzled = class_getInstanceMethod(self, @selector(swizzled_becomeFirstResponder));
    method_exchangeImplementations(original, swizzled);
    
    original = class_getInstanceMethod(self, @selector(resignFirstResponder));
    swizzled = class_getInstanceMethod(self, @selector(swizzled_resignFirstResponder));
    method_exchangeImplementations(original, swizzled);

    original = class_getInstanceMethod(self, @selector(acceptsFirstResponder));
    swizzled = class_getInstanceMethod(self, @selector(swizzled_acceptsFirstResponder));
    method_exchangeImplementations(original, swizzled);
 */
}
@end
