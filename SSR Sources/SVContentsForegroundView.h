//
//  SVContentsForegroundView.h
//  Singer Song Reader
//
//  Created by Developer on 5/4/14.
//
//

#import <Cocoa/Cocoa.h>

@interface SVContentsForegroundView : NSView

- (NSTextView *) firstTextView;

- (void) refresh;

@property (readonly) NSTextView *firstTextView;

@end
