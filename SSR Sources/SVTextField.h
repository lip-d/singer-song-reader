//
//  SVTextField.h
//  Singer Song Reader
//
//  Created by Developer on 13/11/08.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SVTextField : NSTextField {

	BOOL isFirstResponder;
}

@property (readonly) BOOL isFirstResponder;

@end
