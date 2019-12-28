//
//  SMHTTPAccessControl.m
//  Singer Song Reader
//
//  Created by Developer on 13/09/29.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMHTTPAccessControl.h"
#import "SMSite.h"


@implementation SMHTTPAccessControl

@synthesize encoding;

- (id) init {
    self = [super init];
    if (self) {
		
		urlConnection = nil;
		httpData      = nil;
		encoding      = nil;
	}
	
	return self;
}

- (void)dealloc {
	if (httpData) {
		[httpData release];
	}
    [super dealloc];
}

- (void) access {

	NSMutableURLRequest *urlRequest = [super accessRequest];
		
	urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];

	if (urlConnection == nil) {
		[lyricsSite performSelector:SEDidFail withObject:nil];
	}
}

- (void) cancel {

	//	NSLog(@"## cancel   : %@", [lyricsSite siteName]);

	if (urlConnection) {

		[urlConnection cancel];
		[urlConnection release];
		urlConnection = nil;
	}
}

- (void) clearTemp {

	//NSLog(@"## clearTemp: %@", [lyricsSite siteName]);

	if (httpData) {
		[httpData release];
		httpData = nil;
	}
}

// 接続エラー (ネットに接続されていない、またはタイムアウト)
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
	[urlConnection release];
	urlConnection = nil;

	NSInteger errorCode   =[error code];
	
	switch (errorCode) {

		// タイムアウト
		case NSURLErrorTimedOut:
			
			[lyricsSite performSelector:SEDidFail 
							 withObject:[NSNumber numberWithInt:-10]];
			break;
			
		// ネットに接続されていない
		default:
			
			[lyricsSite performSelector:SEDidFail 
							 withObject:[NSNumber numberWithInt:-1]];
			break;
	}
}

// 接続が出来たあと、200 (OK) と 503 (Service Unavailable) などの異常に分かれる
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

	// HTTP ステータスコードを覚えておく
	statusCode = ((NSHTTPURLResponse *)response).statusCode;

	// エンコーディングを覚えておく
	[self setEncoding:[response textEncodingName]];
	
	httpData = [[NSMutableData alloc] init];
}

// Receiveing data
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
	[httpData appendData:data];
}

// Finished
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

	// 再起呼び出しがあるため、以下の performSelector を呼び出す前に release する
	[urlConnection release];
	urlConnection = nil;

#ifdef SS_DEBUG_HTTP_RESPONSE
	NSLog(@"## DEBUG HTTP Status: %d, Data length: %d", (int)statusCode, (int)[httpData length]);
#endif
    
    
	// HTTP ステータスコードで処理を分ける
	switch (statusCode) {
			
		// 正常応答
		case 200:

			// データがある場合
			if ([httpData length] > 0) {

				[lyricsSite performSelector:SEDidFinish
								 withObject:httpData
								 withObject:encoding];
			}
			// データが空の場合
			//   連続アクセスでサービスが利用できなくなったときに
			//   データが空になる場合がある (例: AZLyrics)
			else {
				
				// 503 (Service Unavailable) と同様の扱いとする
				[lyricsSite performSelector:SEDidFail
								 withObject:[NSNumber numberWithInt:-2]];
			}
			
			break;
			
		// Bad Request
		// iTunes Store の国コードが無効 (iTunes Store が利用できない国) な場合はここ。
		case 400:

			[lyricsSite performSelector:SEDidFinish 
							 withObject:httpData
							 withObject:encoding];	
			break;

		// 503 (Service Unavailable) などの異常応答
		default:
			[lyricsSite performSelector:SEDidFail 
							 withObject:[NSNumber numberWithInt:-2]];
			break;
	}
}

@end
