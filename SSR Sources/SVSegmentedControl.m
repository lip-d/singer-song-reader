//
//  SVSegmentedControl.m
//  Singer Song Reader
//
//  Created by Developer on 2014/02/16.
//
//

#import "SVSegmentedControl.h"

@implementation SVSegmentedControl

/*
- (void)keyUp:(NSEvent *)event {
    
    //unsigned short keyCode = [event keyCode];
    
    //NSLog(@"SegCtrl Characters: %@", [event characters]);
    //NSLog(@"SegCtrl KeyCode: %hu", [event keyCode]);
    
    switch ([event keyCode]) {
        case 124:
        case 123:
            [super performClick:self];
            break;
            
        default:
            [super keyUp:event];
            break;
    }
}
*/

// <-, -> キーでセグメントが
- (BOOL)acceptsFirstResponder {

    return NO;
}

- (BOOL)becomeFirstResponder {
    
    return NO;
}


@end
