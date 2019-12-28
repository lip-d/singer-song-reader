//
//  SMSelectors.h
//  Singer Song Reader
//
//  Created by Developer on 13/10/11.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@interface SMSelectors : NSObject {

@private
	id srchObject;
	
	id child;

	SEL urlSelector;
	IMP urlFunction;

	SEL analyzeSelector;
	IMP analyzeFunction;
	
	SEL elementSelector;
	IMP elementFunction;

	NSString *frameName;
	
	// 性能測定用
	NSDate *accessDate;
	NSDate *analyzeDate;
    NSDate *endDate;
}

@property (retain) NSString *frameName;

- (NSString *) url;
- (void) access;
- (NSInteger) analyze:(id)aDom;
- (id) element:(id)aDomDocument;

- (void) setUrlSelector:(id)aChild selectorName:(NSString*)aSelectorName;
- (void) setAnalyzeSelector:(id)aChild selectorName:(NSString*)aSelectorName;
- (void) setElementSelector:(id)aChild selectorName:(NSString*)aSelectorName;

- (void) setChild:(id)aChild;
- (void) setSrchObject:(id)aSrchObject;

- (BOOL) isHTTP;
- (BOOL) isWebView;

- (void) reset;

- (NSTimeInterval) accessTime;
- (NSTimeInterval) analyzeTime;

- (NSInteger) httpStatusCode;

@end
