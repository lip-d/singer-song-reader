//
//  SMSrchSelector.h
//  Singer Song Reader
//
//  Created by Developer on 13/10/11.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SMHTTPAccessControl.h"
#import "SMWebViewAccessControl.h"
#import "SMSelectors.h"

typedef enum {
	SMHTTP = 0,
	SMWebView = 1
} SMSrchType;


@interface SMSrchSelector : NSObject {

@private	
	NSMutableArray *selectorsArray;

	NSInteger selectorsIndex;
	SMSelectors *current;
	
	SMHTTPAccessControl *HTTPAccessControl;
	SMWebViewAccessControl *WebViewAccessControl;
}

@property (readonly) NSInteger selectorsIndex;

- (id) init;

- (void) setDelegate:(id)aDelegate;
	
//------------------------------------
// SMSelectors 追加
//------------------------------------
- (void) addSelectors:(SMSrchType)aSearchType childObject:(id)aChild urlMethod:(NSString *)aUrlMethod analyzeMethod:(NSString *)aAnalyzeMethod  frameName:(NSString *)aFrameName elementMethod:(NSString *)aElementMethod;

//------------------------------------
// current の SMSelectors に対して実行
//------------------------------------
- (NSString *)url;
- (void) access;
- (void) cancel;
- (NSInteger) analyze:(id)aDom;
- (id) element:(id)aDomDocument;
- (NSString *) frameName;


//------------------------------------
// SMSelectors 配列内の現在位置管理
//------------------------------------
- (void) next;
- (BOOL) isEnd;
- (void) reset;
- (void) clearTemp;

- (BOOL) useWebView;
- (NSInteger) webViewLoopCount;

- (NSTimeInterval) accessTime;
- (NSTimeInterval) accessTimeForIndex:(NSInteger)selectorIndex;
- (NSTimeInterval) accessTimeForCuttent;
- (NSTimeInterval) analyzeTimeForCuttent;

- (NSInteger) httpStatusCodeForCurrent;

@end
