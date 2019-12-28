//
//  SVTextView.m
//  Singer Song Reader
//
//  Created by Developer on 2014/02/22.
//
//

#import "SSCommon.h"
#import "SVTextView.h"

@implementation SVTextView

@synthesize arrowsleftRight;
@synthesize arrowsUpDown;

- (id)init {
    self = [super init];
    if (self) {
        
        arrowsLeftRight = NSOffState;
        arrowsUpDown    = NSOffState;
    }
    
    return self;
}

- (void)keyDown:(NSEvent *)event {
    
    BOOL accept             = YES;
    
    //NSLog(@"SVTextView KeyDown: %@ (%hu)", [event characters], [event keyCode]);
    
    if ([super isEditable]) {
        
        ;
    }
    else {
        
        // Shift キーが ON の場合
        if ([NSEvent modifierFlags] & NSShiftKeyMask) {
            
            ;
        }
        else {
            
            switch ([event keyCode]) {
                case 123: // ←
                case 124: // →
                    
                    if (arrowsLeftRight) accept = NO;
                    break;
                    
                case 125: // ↓
                case 126: // ↑
                    
                    if (arrowsUpDown)   accept = NO;
                    break;
            }
        }
    }
    
    if (accept) {
        
        [super keyDown:event];
    }
}

- (void)keyUp:(NSEvent *)event {
    
    BOOL pass             = YES;
    
    //NSLog(@"SVTextView KeyUp: %@ (%hu)", [event characters], [event keyCode]);
    
    if ([super isEditable]) {
        
        switch ([event keyCode]) {
            case 123: // ←
            case 124: // →
            case 125: // ↓
            case 126: // ↑
                
                // ここでブロック
                pass = NO;
        }
    }
    
    if (pass) {
        
        [super keyUp:event];
    }
}

@end
