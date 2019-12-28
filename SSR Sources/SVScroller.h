//
//  SVScroller.h
//  Singer Song Reader
//
//  Created by Developer on 13/11/17.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SVScroller : NSScroller {

	NSColor *backgroundColor;
	NSColor *knobColor;
    BOOL     allowKnob;
}

@property (retain) NSColor *backgroundColor;
@property (retain) NSColor *knobColor;
@property          BOOL     allowKnob;

//- (void) drawBackgroundColor:(NSColor *)color;

@end
