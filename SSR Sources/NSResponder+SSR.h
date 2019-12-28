//
//  NSResponder+SSR.h
//  Singer Song Reader
//
//  Created by Developer on 4/30/14.
//
//

#import <Cocoa/Cocoa.h>

@interface NSResponder (SSR)

- (NSInteger) debugTag;
- (void) setDebugTag:(NSInteger)tag;

@end
