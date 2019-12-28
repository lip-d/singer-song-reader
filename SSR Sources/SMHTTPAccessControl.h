//
//  SMHTTPAccessControl.h
//  Singer Song Reader
//
//  Created by Developer on 13/09/29.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SMHTTPCommon.h"


@interface SMHTTPAccessControl : SMHTTPCommon {

	NSURLConnection *urlConnection;
	NSMutableData   *httpData;
	NSString        *encoding;
}

@property (retain) NSString *encoding;

- (id) init;

- (void) access;
- (void) cancel;

- (void) clearTemp;

@end
