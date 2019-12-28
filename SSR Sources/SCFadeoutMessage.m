//
//  SCFadeoutMessage.m
//  Singer Song Reader
//
//  Created by Developer on 2014/02/06.
//
//

#import "SCFadeoutMessage.h"

@implementation SCFadeoutMessage

@synthesize textField;

@synthesize textPool;

- (id) init {
    self = [super init];
    if (self) {

        [self setTextPool:@""];
	}
	
	return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void) show {

    // 連続表示対応
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startFadeout) object:nil];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setText:) object:nil];
    
    [textField setStringValue:@""];
    [textField setAlphaValue:1.0];
    [textField setHidden:NO];
    
    //[self setTextPool:@""];
}

- (void) setText:(NSString *)aText {
    
    if (aText) {
        
        [textField setStringValue:aText];
    } else {
        
        [textField setStringValue:textPool];
    }
}

- (void) setText:(NSString *)aText afterDelay:(NSTimeInterval)aDelay {
    
    [self setTextPool:aText];
    
    [self performSelector:@selector(setText:) withObject:nil afterDelay:aDelay];
}

- (void) fadeoutAfterDelay:(NSTimeInterval)aDelay {
    
    [self performSelector:@selector(startFadeout) withObject:nil afterDelay:aDelay];

}

- (void) hide {
    
    [textField setHidden:YES];
}

// 内部用
- (void) startFadeout {
    
    //NSLog(@"## startFadeout");
    
    NSTimeInterval duration = 1.0;
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:duration];
    [[textField animator] setAlphaValue:0.0];
    [NSAnimationContext endGrouping];
    
    [self performSelector:@selector(hide) withObject:nil afterDelay:duration];
}


@end
