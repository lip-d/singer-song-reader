//
//  SMSrchSelector.m
//  Singer Song Reader
//
//  Created by Developer on 13/10/11.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMSrchSelector.h"
#import "SMSelectors.h"


@implementation SMSrchSelector

@synthesize selectorsIndex;

- (id)init {
    self = [super init];
    if (self) {
		
		selectorsArray = [[NSMutableArray alloc] initWithCapacity:0];
		current = nil;
		selectorsIndex = 0;
		
		HTTPAccessControl = nil;
		WebViewAccessControl = nil;
	}
    return self;
}

- (void)dealloc {
	[selectorsArray release];
	if (HTTPAccessControl) {
		[HTTPAccessControl release];
	}
	if (WebViewAccessControl) {
		[WebViewAccessControl release];
	}
    [super dealloc];
}

- (void) setDelegate:(id)aDelegate {
	if (HTTPAccessControl) {
		[HTTPAccessControl setDelegate:aDelegate];
	}
	if (WebViewAccessControl) {
		[WebViewAccessControl setDelegate:aDelegate];
	}
}

- (void) addSelectors:(SMSrchType)aSearchType childObject:(id)aChild urlMethod:(NSString *)aUrlMethod analyzeMethod:(NSString *)aAnalyzeMethod  frameName:(NSString *)aFrameName elementMethod:(NSString *)aElementMethod {
	
	SMSelectors *selectors = [[SMSelectors alloc] init];
	
	[selectors setChild:aChild];
	
	if (aSearchType == SMHTTP) {

		if (HTTPAccessControl == nil) {
			HTTPAccessControl = [[SMHTTPAccessControl alloc] init];
		}
		[selectors setSrchObject:HTTPAccessControl];
	} else if (aSearchType == SMWebView) {

		if (WebViewAccessControl == nil) {
			WebViewAccessControl = [[SMWebViewAccessControl alloc] init];	
		}
		[selectors setSrchObject:WebViewAccessControl];
	} else {

		[selectors setSrchObject:nil];
	}
	
	[selectors setUrlSelector:aChild selectorName:aUrlMethod];

	[selectors setAnalyzeSelector:aChild selectorName:aAnalyzeMethod];
	
	if (aFrameName != nil) {
		[selectors setFrameName:aFrameName];
	} else {
		[selectors setFrameName:SMWebViewMainFrameName];
	}
	
	if (aElementMethod != nil) {
		[selectors setElementSelector:aChild selectorName:aElementMethod];
	}
	
	[selectorsArray addObject:selectors];
}

- (NSString *)url {
	NSString *url = [current url];
	
	return url;
}

- (void) access {

	[current access];
}

- (void) cancel {
	if (HTTPAccessControl) {
		[HTTPAccessControl cancel];
	}
	
	if (WebViewAccessControl) {
		[WebViewAccessControl cancel];
	}
}

- (NSInteger) analyze:(id)aDom {

	NSInteger code = [current analyze:aDom];
	
	return code;
}

- (id) element:(id)aDomDocument {
	id elm = [current element:aDomDocument];
	
	return elm;
}

- (NSString *) frameName {
	NSString *nam = [current frameName];
	
	return nam;
}

- (void) next {
	selectorsIndex = selectorsIndex + 1;
	
	if (selectorsIndex >= [selectorsArray count]) {
		current = nil;
	} else {
		current = [selectorsArray objectAtIndex:selectorsIndex];
	}
}

- (void) reset {
	selectorsIndex = 0;
	
	NSInteger selectorsCount = [selectorsArray count];
	
	if (selectorsCount > 0) {
		current = [selectorsArray objectAtIndex:0];
		
		for (int i=0; i<selectorsCount; i++) {
			[[selectorsArray objectAtIndex:i] reset];
		}
	} else {
		current = nil;
	}
}

- (void) clearTemp {
	[HTTPAccessControl clearTemp];
}

- (BOOL) isEnd {
	if (selectorsIndex == [selectorsArray count]) {
		return YES;
	} else {
		return NO;
	}
}

- (BOOL) useWebView {
	if (WebViewAccessControl != nil) {
		return YES;
	} else {
		return NO;
	}
}
		
- (NSInteger) webViewLoopCount {
	return [WebViewAccessControl loopCount];
}

- (NSTimeInterval) accessTime {
	
	NSTimeInterval totalAccessTime = 0;
	NSTimeInterval accessTime = 0;
	
	NSInteger selectorsCount = [selectorsArray count];

	for (int i=0; i<selectorsCount; i++) {
		
		accessTime = [[selectorsArray objectAtIndex:i] accessTime];

		totalAccessTime = totalAccessTime + accessTime;
	}

	return totalAccessTime;
}

- (NSTimeInterval) accessTimeForIndex:(NSInteger)selectorIndex {
    
    NSTimeInterval accessTime = 0;
    
    accessTime = [[selectorsArray objectAtIndex:selectorIndex] accessTime];
    
    return accessTime;
}

- (NSTimeInterval) accessTimeForCuttent {
    
    return [current accessTime];
}

- (NSTimeInterval) analyzeTimeForCuttent {
    
    return [current analyzeTime];
}

- (NSInteger) httpStatusCodeForCurrent {
    
    return [current httpStatusCode];
}

@end
