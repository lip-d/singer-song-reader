//
//  SMWebViewAccessControl.m
//  Singer Song Reader
//
//  Created by Developer on 13/09/29.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMWebViewAccessControl.h"
#import "SMWebPreference.h"
#import "SMSite.h"


NSString * const SMWebViewMainFrameName = @"SMWebViewMainFrame";
NSString * const SMResourceIdentifierIgnore = @"SMResourceIgnore";
NSString * const SMResourceIdentifierUse = @"SMResourceUse";


@implementation SMWebViewAccessControl

@synthesize loopCount;

- (id) init {
    self = [super init];
    if (self) {
		
		loopCount = 0;
		resourceCount = 0;

		// Frame サイズを {1, 1} にすることで、余分な js の読み込みを防止できる。 {0, 0} も可。
		
		webView = [[WebView alloc] 
				   initWithFrame:NSMakeRect(0.0, 0.0, 1.0, 1.0)
				   frameName:SMWebViewMainFrameName
				   groupName:nil
				   ];
		
		[webView setHidden:YES];
		
		[webView setFrameLoadDelegate:self];
		[webView setResourceLoadDelegate:self];
		[webView setPolicyDelegate:self];
		
		WebPreferences *webPref = [SMWebPreference sharedWebPreference];
		
		[webView setPreferences:webPref];
		
		SEGetDom = @selector(getDOMDocument:);
	}
	
	return self;
}

- (void)dealloc {
	[webView release];
    [super dealloc];
}

- (void) access {

	NSURLRequest *urlRequest = [super accessRequest];
		
	loopCount = 0;
	resourceCount = 0;

	[[webView mainFrame] loadRequest:urlRequest];
}

- (void) cancel {
	
	[webView stopLoading:self];
}

//-------------------------------
// Frame Delegate
//-------------------------------

// frame: finish loading
- (void) webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    
    statusCode = 0;
	
	[self performSelector:SEGetDom withObject:frame afterDelay:0.1];
}

// frame: fail loading
- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
	
    statusCode = error.code;
    
	[lyricsSite performSelector:SEDidFail withObject:error];
}

- (void) getDOMDocument:(WebFrame *)frame {
	
	if (loopCount == SMGetDocumentTryLimit) {
		[lyricsSite performSelector:SEDidFail withObject:nil];
		return;
	}
	
	DOMDocument *document = [frame DOMDocument];
		
	// Javascript によって動的に生成される HTML の DOM 要素を取得する
	DOMElement *element = [[lyricsSite srchSelector] element:document];
	
	if (element == nil) {
		// 生成が完了していない場合は、0.1s 待ってから再取得を試みる
		loopCount = loopCount + 1;
		[self performSelector:SEGetDom withObject:frame afterDelay:0.5];
		return;
	}
	
	
	[lyricsSite performSelector:SEDidFinish withObject:element];
}

//-------------------------------
// Resource Delegate
//-------------------------------

// resource: assign identifier
- (id)webView:(WebView *)sender identifierForInitialRequest:(NSURLRequest *)request fromDataSource:(WebDataSource *)dataSource {
	
	// 不要な resource に identifier で印をつける
	NSString *identifier = [self resourceIdentifier:request];
	
	return identifier;
}

// resource: will send request
- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource {

	if ([(NSString *)identifier isEqualToString:SMResourceIdentifierIgnore]) {
		return nil;
	}
	
	return request;
}

// resource: finish loading
- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource {

	resourceCount = resourceCount + 1;
	//NSLog(@"########### resource count: %d", resourceCount);
}

// resource: fail loading
- (void)webView:(WebView *)sender resource:(id)identifier didFailLoadingWithError:(NSError *)error fromDataSource:(WebDataSource *)dataSource {
	
	// Resource Delegate でのキャンセル
	if ([(NSString *)identifier isEqualToString:SMResourceIdentifierIgnore]) {
		return;
	}
	
	NSInteger code = [error code];
	//NSString *desc = [error localizedDescription];
	//NSString *reason = [error localizedFailureReason];
	
	// Policy Delegate でのキャンセル
	if (code == 102) {
		return;
	}
	
	//NSLog(@"########### resource fail: %d (%@)", code, desc);
	
	[[webView mainFrame] stopLoading];
	[lyricsSite performSelector:SEDidFail withObject:error];
}

//-------------------------------
// Policy Delegate
//-------------------------------
// frame name で フィルタリング
- (void)webView:(WebView *)webView decidePolicyForMIMEType:(NSString *)type request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id < WebPolicyDecisionListener >)listener {
	
	NSString *targetFrameName = [[lyricsSite srchSelector] frameName];
	NSString *frameName = [frame name];
	
	if ([frameName isEqualToString:targetFrameName] == NO) {
		[listener ignore];
	}
}

//------------------------------
// Other
//------------------------------
- (NSString *) resourceIdentifier:(NSURLRequest *)request {
	
	NSURL *reqURL = [request URL];
	
	// domain filtering test
	NSString *host = [reqURL host];
	NSRange rgGoogle = [host rangeOfString:@"google"];
	NSRange rgMetroLyrics = [host rangeOfString:@"metrolyrics"];
	
	if (rgGoogle.length == 0 && rgMetroLyrics.length == 0) {
		return SMResourceIdentifierIgnore;
	}
	
	// extension filtering test
	NSString *extension = [reqURL pathExtension];
	
	if ([extension isEqualToString:@"css"] ||
		[extension isEqualToString:@"woff"] ||
		[extension isEqualToString:@"ttf"] ||
		[extension isEqualToString:@"svg"]
		) {
		return SMResourceIdentifierIgnore;
	}
	
	return SMResourceIdentifierUse;
}

@end
