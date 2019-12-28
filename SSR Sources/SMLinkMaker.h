//
//  SMLinkMaker.h
//  Singer Song Reader
//
//  Created by Developer on 13/11/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>


@interface SMLinkMaker : NSObject {

	// JS 版 LinkMaker 本体 (サーバから取得してこの変数に格納する)
	NSString *linkMakerJSText;
	
	// JS 版 LinkMaker を置いておくサーバ
	NSArray  *linkMakerJSServers;
	NSInteger serverIndex;
}

/*
- (void) accessServerForLinkMakerJSText;
- (BOOL) validateJsText:(NSString *)jsText;
- (void) didReceiveLinkMakerJSText:(NSString *)jsText;
*/
- (NSString *) urlWithAffiliateParameter:(NSString *)iTunesUrl countryCode:(NSString *)countryCode withWebView:(WebView *)aWebView;
/*
- (NSString *) linkMakerJS:(NSString *)iTunesUrl countryCode:(NSString *)countryCode withWebView:(WebView *)aWebView;
- (NSString *) linkMaker:(NSString *)iTunesUrl countryCode:(NSString *)countryCode;
- (NSString *) linkMakerForPHG:(NSString *)iTunesUrl;
- (NSString *) linkMakerForTdWithProgramId:(NSString *)pId affiliateId:(NSString *)aId iTunesUrl:(NSString *)iTunesUrl;
*/

@end
