//
//  SMHTTPCommon.m
//  Singer Song Reader
//
//  Created by Developer on 13/10/14.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMHTTPCommon.h"
#import "SMSite.h"


const NSTimeInterval SMHTTPTimeOut = 60; // cocoa のデフォルト値は 60 秒
const NSInteger SMGetDocumentTryLimit = 5;

@implementation SMHTTPCommon

@synthesize statusCode;

- (id) init {
    self = [super init];
    if (self) {

		SEDidFinish = @selector(didFinishSearching:encoding:);
		SEDidFail   = @selector(didFailSearching:);

		statusCode    = 0;
	}
	
	return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void) setDelegate:(id)aDelegate {
	lyricsSite = aDelegate;
}

- (NSMutableURLRequest *) accessRequest {
	
	NSString* url = [[lyricsSite srchSelector] url];
	
	NSURL *aURL = [NSURL URLWithString:url];
	
	NSMutableURLRequest *aURLRequest = [self urlRequestFromUrl:aURL];
	
	return aURLRequest;
}

- (NSMutableURLRequest *) urlRequestFromUrl:(NSURL *)aURL {

	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:aURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:SMHTTPTimeOut];
    
    // User-Agent 追加
    [urlRequest setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.74.9 (KHTML, like Gecko) Version/7.0.2 Safari/537.74.9"
      forHTTPHeaderField:@"User-Agent"];

    // Accept 追加
    [urlRequest setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
	
	return urlRequest;
}

@end