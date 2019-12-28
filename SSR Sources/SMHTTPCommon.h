//
//  SMHTTPCommon.h
//  Singer Song Reader
//
//  Created by Developer on 13/10/14.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern const NSTimeInterval SMHTTPTimeOut;
extern const NSInteger SMGetDocumentTryLimit;

@interface SMHTTPCommon : NSObject {
	
	id lyricsSite;
	
	SEL SEDidFinish;
	SEL SEDidFail;

	NSInteger       statusCode;
}

@property (readonly) NSInteger statusCode;

- (void) setDelegate:(id)aDelegate;

- (NSMutableURLRequest *) accessRequest;

- (NSMutableURLRequest *) urlRequestFromUrl:(NSURL *)aURL;

@end