//
//  SVTextField.m
//  Singer Song Reader
//
//  Created by Developer on 13/11/08.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SVTextField.h"
#import "NSView+SSR.h"
#import "SCDelegate.h"

@implementation SVTextField

@synthesize isFirstResponder;

- (void)awakeFromNib {
    
    isFirstResponder = NO;
}

- (BOOL) acceptsFirstResponder {
    
	BOOL acceptsFirstResponder = [super acceptsFirstResponder];
    
//    NSLog(@"## %d: acceptsFirstResponder (%d)", (int)[self debugTag], acceptsFirstResponder);
    
	return acceptsFirstResponder;
}

- (BOOL) becomeFirstResponder {
    
	BOOL didBecomeFirstResponder = [super becomeFirstResponder];

	isFirstResponder = YES;
	
	[[super delegate] performSelector:@selector(controlDidBecomeFirstResponder:) withObject:self];
	
	return didBecomeFirstResponder;
}

- (BOOL) resignFirstResponder {
	
	BOOL didResignFirstResponder = [super resignFirstResponder];

	isFirstResponder = NO;
	
	return didResignFirstResponder;
}

// test
/*
- (BOOL)accessibilityIsIgnored {
    
//    BOOL retValue = [super accessibilityIsIgnored];
    
//    NSLog(@"## %d: accessibilityIsIgnored (%d)", (int)[self debugTag], retValue);
    
    return NO;
}
*/

// test
/*
- (id)accessibilityAttributeValue:(NSString *)attribute
{
    
    if ( [attribute isEqualToString:NSAccessibilityChildrenAttribute] ) {

        if (self.tag == 1)
            if (titleFieldEditor) {
                
                return [NSArray arrayWithObject:titleFieldEditor];
            }
            else {
                return [super accessibilityAttributeValue:attribute];
            }
        else
            return [super accessibilityAttributeValue:attribute];
    }

    else if ( [attribute isEqualToString:NSAccessibilityParentAttribute] ) {
        

//        id unignoredAncestor = NSAccessibilityUnignoredAncestor(self.superview);

//        return unignoredAncestor;
        return [super accessibilityAttributeValue:attribute];
    }

    else
        return [super accessibilityAttributeValue:attribute];
}
*/ 
/*
- (NSView *)nextValidKeyView {
 
//    NSLog(@"## %@", self.stringValue);
    
    return [super nextValidKeyView];
}
*/
#pragma mark    -   NSResponder

- (void)     keyUp:(NSEvent *)event {
    
    //NSLog(@"MainWindow Characters: %@", [event characters]);
    //NSLog(@"SVTextField KeyCode: %hu", [event keyCode]);

    switch ([event keyCode]) {
        case 123: // ←
        case 124: // →
        case 125: // ↓
        case 126: // ↑
            //NSLog(@"## block 124/123");
            break;
            
        default:
            [super keyUp:event];
            break;
    }
}

@end

