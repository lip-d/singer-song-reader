//
//  SMWebViewAccessControl.h
//  Singer Song Reader
//
//  Created by Developer on 13/09/29.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "SMHTTPCommon.h"


NSString * const SMWebViewMainFrameName;
NSString * const SMResourceIdentifierIgnore;
NSString * const SMResourceIdentifierUse;

@interface SMWebViewAccessControl : SMHTTPCommon {
	
@private

	WebView *webView;

	NSInteger loopCount;
	NSInteger resourceCount;

	SEL SEGetDom;	
}

@property NSInteger loopCount;

- (id) init;

- (void) access;
- (void) cancel;

- (void) getDOMDocument:(WebFrame *)frame;

- (NSString *) resourceIdentifier:(NSURLRequest *)request;

@end
