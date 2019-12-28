//
//  SMLinkMaker.m
//  Singer Song Reader
//
//  Created by Developer on 13/11/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMLinkMaker.h"
#import "SSCommon.h"
#import "SMCountries.h"

// linkMaker JS 版ファイルを置いておくサーバ
NSString * const SMLinkMakerSvr1 = @"xxx"; // メイン
NSString * const SMLinkMakerSvr2 = @"xxx";         // サブ

NSString * const SMLinkMakerDir  = @"xxx/";
NSString * const SMLinkMakerFile = @"xxx";


@implementation SMLinkMaker

- (id) init {
    self = [super init];
    if (self) {
		
		linkMakerJSText = nil;
		
		NSString *linkMakerURL1 = [NSString stringWithFormat:@"%@%@%@",
								   SMLinkMakerSvr1, SMLinkMakerDir,SMLinkMakerFile];
		NSString *linkMakerURL2 = [NSString stringWithFormat:@"%@%@%@",
								   SMLinkMakerSvr2, SMLinkMakerDir,SMLinkMakerFile];
		
		// LinkMaker Javascript を置いておくサーバのリスト
		linkMakerJSServers = [[NSArray alloc] initWithObjects:
							  linkMakerURL1,
							  linkMakerURL2,
							  nil];
		
		serverIndex = 0;
		
		// バックグラウンド (別スレッド) 実行
		[self performSelectorInBackground:@selector(accessServerForLinkMakerJSText) withObject:nil];
	}
	
	return self;
}

- (void)dealloc {
	if (linkMakerJSText) {
		[linkMakerJSText release];
	}
    [super dealloc];
}

// LinkMaker JS 取得のためサーバにアクセス
- (void) accessServerForLinkMakerJSText {

	// 別スレッドで実行される
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *url = [linkMakerJSServers objectAtIndex:serverIndex];
	
	serverIndex++;
	
	NSURL *jsUrl = [NSURL URLWithString:url];
	
	// HTTP で GET (取得に失敗した場合は nil が返る)
	NSString *jsText = [NSString stringWithContentsOfURL:jsUrl encoding:NSUTF8StringEncoding error:nil];
	
	BOOL isValid = [self validateJsText:jsText];
	
	if (isValid == NO) {
		jsText = nil;

		//NSLog(@"## url: %@ (Failed)", url);
	} else {
		[jsText retain];

		//NSLog(@"## url: %@\n%@", url, jsText);
		//NSLog(@"## url: %@", url);
	}
	
	// メインスレッドに戻る
	[self performSelectorOnMainThread:@selector(didReceiveLinkMakerJSText:)
						   withObject:jsText
						waitUntilDone:NO];

	[pool release];		
}

- (BOOL) validateJsText:(NSString *)jsText {

	if (jsText == nil) {
		return NO;
	}
	
	NSString *signature = [NSString stringWithFormat:@"<!--%@-->", SMLinkMakerFile];
	
	if ([jsText hasPrefix:signature] == NO) {
		return NO;
	}
	
	return YES;
}

// LinkMaker JS 受け取り
- (void) didReceiveLinkMakerJSText:(NSString *)jsText {

	if (jsText) {
		
		linkMakerJSText = [[NSString alloc] initWithString:jsText];

		[jsText release];
	} else {
		
		// JS 取得に失敗した場合は、別のサーバで再度取得を試みる
		if (serverIndex < [linkMakerJSServers count]) {
			
			[self performSelectorInBackground:@selector(accessServerForLinkMakerJSText) withObject:nil];
		}
	}
	
	//NSLog(@"## JSText:\n%@", linkMakerJSText);	
	//NSLog(@"## retain count: %d", [jsText retainCount]);
}

// iTunes から取得した曲リンクにアフィリエイト用パラメータを付加する
- (NSString *) urlWithAffiliateParameter:(NSString *)iTunesUrl countryCode:(NSString *)countryCode withWebView:(WebView *)aWebView {
	
	NSString *url = @"";

	if (linkMakerJSText) {

		// JS 版 LinkMaker で実行
		url = [self linkMakerJS:iTunesUrl countryCode:countryCode withWebView:aWebView];

        /*
        //-------------------------------------------------------------------
        // Debug
        NSString *url2 = [self linkMaker:iTunesUrl countryCode:countryCode];
        
        //NSLog(@"-*-*-*- AF LINK -*-*-*-\n%@", url);
        if ([url isEqualToString:url2] == NO) {
            
            //NSLog(@"## Different!!!!!!!!!!!!!!");
        }
        //-------------------------------------------------------------------
         */
	}
	
	// JS 版が失敗した場合
	if ([url length] == 0) {

		// Objective-c 版 LinkMaker を実行
		url = [self linkMaker:iTunesUrl countryCode:countryCode];	
	}
	
	return url;
}

// アフィリエイト リンク生成 (JS 版)
- (NSString *) linkMakerJS:(NSString *)iTunesUrl countryCode:(NSString *)countryCode withWebView:(WebView *)aWebView {
	
	NSString *url = nil;
	NSString *js  = nil;
	
	// その国のインデックス番号を取得
	NSInteger countryIndex = [SMCountries indexOfCode:countryCode];
	
	// JS 内の URL と 国インデックス番号を置換する
	js = [NSString stringWithFormat:linkMakerJSText, iTunesUrl, countryIndex];
	
	// JS 実行
	url = [aWebView stringByEvaluatingJavaScriptFromString:js];
	
	return url;
}

// アフィリエイト リンク生成 (Objective-c 版)
- (NSString *) linkMaker:(NSString *)iTunesUrl countryCode:(NSString *)countryCode {
	
	NSString *url = nil;
	
	// その国に対応するアフィリエイトプログラムを判別する
	NSInteger affiliateProgram = [SMCountries afpgOfCode:countryCode];
	
	// アフィリエイトプログラムごとに URL 生成処理を分ける
	switch (affiliateProgram) {
			// PHG
		case 1:
			url = [self linkMakerForPHG:iTunesUrl];
			break;
			// Tradedoubler Europe
		case 2:
			url = [self linkMakerForTdWithProgramId:@"xxx"
										affiliateId:@"xxx"
										  iTunesUrl:iTunesUrl];
			break;
			// Tradedoubler Central & South America
		case 3:
			url = [self linkMakerForTdWithProgramId:@"xxx"
										affiliateId:@"xxx"
										  iTunesUrl:iTunesUrl];
			break;
			// Tradedoubler Brazil
		case 4:
			url = [self linkMakerForTdWithProgramId:@"xxx"
										affiliateId:@"xxx"
										  iTunesUrl:iTunesUrl];
			break;
			// アフィリエイトプログラムが利用できない国はすべて PHG 用パラメータを付加。
			// ※アフィリエイトパラメータがないと iTunes が開かれないため。
		default:
			url = [self linkMakerForPHG:iTunesUrl];
			break;
	}
	
	return url;
}

// PHG 用リンク生成
- (NSString *) linkMakerForPHG:(NSString *)iTunesUrl {
	
	// 単純に URL 末尾に Affiliate ID (at) を付加する。
	NSString *url = [NSString stringWithFormat:@"%@&at=xxx", iTunesUrl];
	
	return url;
}

// Tradedoubler 用リンク生成
- (NSString *) linkMakerForTdWithProgramId:(NSString *)pId affiliateId:(NSString *)aId iTunesUrl:(NSString *)iTunesUrl {
	
	NSString *url = nil;
	NSString *u   = nil; // iTunesUrl + partnerIdパラメータ
	NSString *connector = nil;
	
	
	// iTunes URL に "?" が含まれているか調べる
	NSRange range = [iTunesUrl rangeOfString:@"?"];
	
	if (range.length > 0) connector = @"&"; // iTunes URL に "?" が含まれている場合
	else                  connector = @"?"; // iTunes URL に "?" が含まれていない場合
	
	// iTunes URL に partnerId パラメータを追加する
	u = [NSString stringWithFormat:@"%@%@partnerId=xxx", iTunesUrl, connector];
	
	// (iTunes URL + partnerId)全体を URL エンコードする
	u = [SSCommon urlEncode:u];
	
	// Program ID (p), Affiliate ID (a), iTunesUrl (url) を埋め込んで URL を完成させる
	NSString *format = @"http://clk.tradedoubler.com/click?p=%@&a=%@&url=%@";
	url = [NSString stringWithFormat:format,pId, aId, u];
	
	return url;
}


@end
