//
//  SMSelectors.m
//  Singer Song Reader
//
//  Created by Developer on 13/10/11.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMSelectors.h"
#import "SMWebViewAccessControl.h"
#import "SMHTTPAccessControl.h"


@implementation SMSelectors


@synthesize frameName;

- (id)init {
    self = [super init];
    if (self) {

		frameName = nil;
		
		accessDate  = nil;
		analyzeDate = nil;
        endDate     = nil;
	}
	
	return self;
}

- (NSString *) url {
	
	//---------------------
	// url 生成」
	//---------------------
	NSString *url = (NSString *)urlFunction(child, urlSelector);
	
	return url;
}

- (void) access {
	
	accessDate = [[NSDate date] retain];
	
	//---------------------
	// HTTP 通信
	//---------------------
	[srchObject access];
}

- (NSInteger) analyze:(id)aDom {
	
	analyzeDate = [[NSDate date] retain];

	//---------------------
	// ページ解析処理
	//---------------------
	NSNumber *rCode = (NSNumber *)analyzeFunction(child, analyzeSelector, aDom);
	
	endDate = [[NSDate date] retain];

	NSInteger code = [rCode integerValue];
	
	return code;
}	

- (id) element:(id)aDomDocument {

	//---------------------
	// HTML 要素取得
	//---------------------
	id elm = elementFunction(child, elementSelector, aDomDocument);
	
	return elm;
}

- (void) setUrlSelector:(id)aChild selectorName:(NSString*)aSelectorName {

	urlSelector = NSSelectorFromString(aSelectorName);
	urlFunction = [aChild methodForSelector:urlSelector];
}

- (void) setAnalyzeSelector:(id)aChild selectorName:(NSString*)aSelectorName {
	
	analyzeSelector = NSSelectorFromString(aSelectorName);
	analyzeFunction = [aChild methodForSelector:analyzeSelector];
}

- (void) setElementSelector:(id)aChild selectorName:(NSString*)aSelectorName {
	
	elementSelector = NSSelectorFromString(aSelectorName);
	elementFunction = [aChild methodForSelector:elementSelector];
}

- (void) setChild:(id)aChild {
	child = aChild;
}

- (void) setSrchObject:(id)aSrchObject {
	srchObject = aSrchObject;
}

- (BOOL) isHTTP {

	if ([srchObject isKindOfClass:[SMHTTPAccessControl class]]) {
		return YES;
	} else {
		return NO;
	}
}

- (BOOL) isWebView {
	
	if ([srchObject isKindOfClass:[SMWebViewAccessControl class]]) {
		return YES;
	} else {
		return NO;
	}	
}

- (void) reset {
	[accessDate  release]; accessDate  = nil;
	[analyzeDate release]; analyzeDate = nil;
    [endDate     release]; endDate     = nil;
}

- (NSTimeInterval) accessTime {
	NSTimeInterval interval = [analyzeDate timeIntervalSinceDate:accessDate];
	return interval;
}

- (NSTimeInterval) analyzeTime {
	NSTimeInterval interval = [endDate timeIntervalSinceDate:analyzeDate];
	return interval;
}

- (NSInteger) httpStatusCode {

    return [srchObject statusCode];
}

@end
