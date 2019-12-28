//
//  SVButton.m
//  Singer Song Reader
//
//  Created by Developer on 2014/03/10.
//
//

#import "SVButton.h"

@implementation SVButton

- (void)keyDown:(NSEvent *)event {
    
    //NSLog(@"SVButton KeyDown: %@ (%hu)", [event characters], [event keyCode]);
    
        switch ([event keyCode]) {
            case 36: // Enter キー
                [super performClick:self];
                break;
            default:
                [super keyDown:event];
                break;
        }
}

@end
