//
//  SMSite.m
//  Singer Song Reader
//
//  Created by Developer on 13/09/28.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMSite.h"

@implementation SMSite

@synthesize siteIndex;
@synthesize siteKey;
@synthesize siteName;
@synthesize siteFullName;
@synthesize isFinished;
@synthesize sitePriority;
@synthesize prefs;

@synthesize taggedLyrics;


- (id)init {
    self = [super init];
    if (self) {
		siteIndex = 0;
        siteKey   = nil;
        siteFullName = nil;
		siteName  = nil;
        sitePriority  = 0;
        
        taggedLyrics = nil;
        
		resultScore = 0;
		resultCode = 0;
		
		srchResult  = [[SMSrchResult alloc] init];
		resultScore = [[SMResultScore alloc] init];
		
		startDate = nil;
		endDate = nil;
		
		track = nil;
        prefs = nil;
		
		srchSelector = [[SMSrchSelector alloc] init];
		
		SEDidFinish = @selector(siteDidFinishSearching:);
		
		isFinished = YES;
		
        encodingSetting    = [[NSMutableArray alloc] initWithCapacity:0];
		encodingDetected   = SS_ENC_NOT_DETECTED;
        
        loopMax = 30;
	}
	
	return self;
}

- (void)dealloc {
	[srchResult release];
	[resultScore release];
	[srchSelector release];
    [encodingSetting release];
    [super dealloc];
}

- (void) setDelegate:(id)aDelegate {
	delegate = aDelegate;
}

- (SMTrack *)track {
	return track;
}

- (void) setTrack:(SMTrack *)aTrack {
	track = aTrack;
}

#pragma mark - Result

- (SMSrchResult *) srchResult {
	return srchResult;
}

- (SMResultScore *) resultScore {
	return resultScore;
}

- (BOOL) isHit {
	if (resultCode == 1) {
		return YES;
	} else {
		return NO;
	}
}

- (void) markAsNoHit {
	resultCode = 0;
	//[resultScore clear];
}

- (void) markAsHit {
    resultCode = 1;
}

- (NSInteger) resultCode {
	return resultCode;
}

- (void) clearResult {
	[srchResult clear];
	[resultScore clear];
	resultCode = 0;
	[srchSelector reset];
	isFinished = NO;
    [self setTaggedLyrics:nil];
}

#pragma mark - Timer

- (void) startTimer {
	startDate = [[NSDate date] retain];
}

- (void) stopTimer {
	endDate = [[NSDate date] retain];
}

- (void) resetTimer {
	[startDate release];
	startDate = nil;
	
	[endDate release];
	endDate = nil;
}

- (NSString*) searchTime {
	
	//NSTimeInterval accessTime = [srchSelector accessTime];
	
	NSTimeInterval totalTime = [endDate timeIntervalSinceDate:startDate];
	
	// For Debug
	//return [NSString stringWithFormat:@"%.2f(%.2f)s", totalTime, accessTime];

	return [NSString stringWithFormat:@"%.1fs", totalTime];
}

#pragma mark - Site Setting

- (SMSrchSelector *) srchSelector {
	return srchSelector;
}

// NSURLConnection を使用した検索
- (void) addSearch:(id)aChild urlMethod:(NSString *)aUrlMethod analyzeMethod:(NSString *)aAnalyzeMethod {
	
	[srchSelector addSelectors:SMHTTP childObject:aChild urlMethod:aUrlMethod analyzeMethod:aAnalyzeMethod frameName:nil elementMethod:nil];
    
    [encodingSetting addObject:@SS_ENC_AUTO_DETECT];
    
	// デリゲートセット
	[srchSelector setDelegate:self];
}

// WebView を使用した検索
- (void) addSearch:(id)aChild urlMethod:(NSString *)aUrlMethod analyzeMethod:(NSString *)aAnalyzeMethod frameName:(NSString *)aFrameName elementMethod:(NSString *)aElementMethod {
	
	[srchSelector addSelectors:SMWebView childObject:aChild urlMethod:aUrlMethod analyzeMethod:aAnalyzeMethod frameName:aFrameName elementMethod:aElementMethod];
	
    [encodingSetting addObject:@SS_ENC_AUTO_DETECT];

	// デリゲートセット
	[srchSelector setDelegate:self];
}

#pragma mark - Search

// 検索実行：外部からの呼び出し用
- (void) search {

	[self clearResult]; // isFinished <= NO がセットされる
	
	[self _search];
}

- (void) cancel {

	if (!isFinished) {
		isFinished = YES;

		[srchSelector cancel];

		resultCode = -1000;
		[resultScore  clear];
		[srchSelector clearTemp];
		[delegate performSelector:SEDidFinish withObject:self];	
	}
}

- (void) timeout {

	if (!isFinished) {
		isFinished = YES;
		
		[srchSelector cancel];
		
		resultCode = -10;
		[resultScore  clear];
		[srchSelector clearTemp];
		[delegate performSelector:SEDidFinish withObject:self];
	}
}

// 検索：内部用
// 検索結果一覧、歌詞ページでそれぞれ1回ずつ、計2回再起的に呼び出される
- (void) _search {

	// キャンセル チェックポイント
	if (isFinished) return;
	
	//---------------------
	// 検索実行
	//---------------------
	[srchSelector access];
    
#ifdef SS_DEBUG_HTTP_REQUEST
    
	NSLog(@"## DEBUG @%@[%d] request: %@", siteName, (int)srchSelector.selectorsIndex+1, [srchSelector url]);
#endif

}

- (void) didFinishSearching:(id)aData encoding:(NSString *)aEncoding {
	
	// キャンセル チェックポイント
	if (isFinished) {
        
#ifdef SS_DEBUG_RESULT_SUMMARY
        NSLog(@"## DEBUG @%@[%d] cancel/timeout", siteName, (int)srchSelector.selectorsIndex+1);
#endif
     
        return;
    }

	//-----------------------------------
	// 自動検出したエンコーディングを覚えておく
	//-----------------------------------
    if (aEncoding) encodingDetected = [self encodingFromString:aEncoding]; // 検出
    else           encodingDetected = SS_ENC_NOT_DETECTED;                 // 不明
    
	//---------------------
	// ページ解析
	//---------------------
	NSInteger code = [srchSelector analyze:aData];
	
#ifdef SS_DEBUG_HTTP_RESPONSE
    NSString *rawData = [self utf8StringFromData:aData];
	NSLog(@"## DEBUG @%@[%d] response (size: %d)\n%@ ", siteName, (int)srchSelector.selectorsIndex+1, (int)(rawData.length), rawData);
#endif
	
#ifdef SS_DEBUG_RESULT_SUMMARY
	NSLog(@"## DEBUG http: %.3fs analyze: %.3fs @%@[%d]",
          [srchSelector accessTimeForCuttent], [srchSelector analyzeTimeForCuttent],
          siteName, (int)srchSelector.selectorsIndex+1);
#endif
	
    
	if (code != 1) {
		if (!isFinished) {
			isFinished = YES;

			resultCode = code;
			[resultScore  clear];
			[srchSelector clearTemp];
			[delegate performSelector:SEDidFinish withObject:self];
			return;
		}
	}

	// 検索動作設定を次にシフト
	[srchSelector next];
	
	if ([srchSelector isEnd]) {
		if (!isFinished) {
			isFinished = YES;

			resultCode = 1;
			[srchSelector clearTemp];
			[delegate performSelector:SEDidFinish withObject:self];
		}
	} else {
		
		[srchSelector clearTemp];
		[self _search];
	}
}

// (NSNumber *)
// -1 (重): ネットに接続されていない
// -2 (中): 接続できたがサーバのサービスが利用不可 (HTTP Status Code 503 はここに含まれる)
// -10(軽): タイムアウト
- (void) didFailSearching:(id)aError {
	
#ifdef SS_DEBUG_RESULT_SUMMARY
    NSLog(@"## DEBUG @%@[%d] error: http code: %d", siteName, (int)srchSelector.selectorsIndex+1, (int)[srchSelector httpStatusCodeForCurrent]);
#endif

	if (!isFinished) {
		isFinished = YES;
		
		resultCode = [aError integerValue];
		[resultScore  clear];
		[srchSelector clearTemp];
		[delegate performSelector:SEDidFinish withObject:self];
	}
}

#pragma  mark - Matching

// タイトル、アーティスト総合比較
- (NSInteger) matchTitle:(NSString *)aTitle andArtist:(NSString *)aArtist {
	
	//-----------------------------
	// 比較対象の準備処理
	//-----------------------------
    SMTrack *trk = [[[SMTrack alloc] init] autorelease];
    
    [trk setTitle:aTitle artist:aArtist];
    
	//-----------------------------
	// 比較
	//-----------------------------
    NSInteger ratio = [track compare:trk option:SM_COMP_ALL];
    
#ifdef SS_DEBUG_MATCH_RATIO
    //if (ratio > SSLooseMatchThreshold) {
        NSLog(@"## DEBUG @%@ %3d %@ : %@", [siteName stringByPaddingToLength:12], (int)ratio, [aTitle stringByPaddingToLength:25], aArtist);
    //}
#endif
    
	return ratio;
}

// タイトルのみ比較
- (NSInteger) matchTitle:(NSString *)aTitle {
	
    if (aTitle.length == 0) return 0;
    
    SMTrack *trk = [[[SMTrack alloc] init] autorelease];
    
    [trk setTitle:aTitle artist:@""];
    
    NSInteger ratio = [track compare:trk option:SM_COMP_TTL];
    
	return ratio;
}

// アーティストのみ比較
- (NSInteger) matchArtist:(NSString *)aArtist {

    if (aArtist.length == 0) return 0;

    SMTrack *trk = [[[SMTrack alloc] init] autorelease];
    
    [trk setTitle:@"" artist:aArtist];
    
    NSInteger ratio = [track compare:trk option:SM_COMP_ART];
    
	return ratio;
}


#pragma  mark - Contents

- (NSString *) lyricHeader {
    
    NSString *ttl = [srchResult title];
    NSString *art = [srchResult artist];

    return [NSString stringWithFormat:@"%@\n\n%@\n\n", ttl, art];
}

- (NSString *) lyricFooter:(BOOL)withURL {

    NSString *url;
    
    if (withURL) url = [NSString stringWithFormat:@"\n[%@]", [srchResult url]];
    else         url = @"";
    
    return [NSString stringWithFormat:@"\n\n\n\n%@%@", siteFullName, url];
}

- (NSString *) contents:(BOOL)withFooterURL {

	NSString *cont = nil;
    
    if (resultCode == 1) {
		
		// 歌詞コンテンツ生成
        NSString *header = [self lyricHeader];
		NSString *lyr    = [srchResult lyrics];
        NSString *footer = [self lyricFooter:withFooterURL];
		
		cont = [NSString stringWithFormat:@"%@%@%@", header, lyr, footer];
	} else if (resultCode == 0) {
		
		//cont = @"Not found";
		cont = @""; // Not found 表示なし。代わりに Fadeout メッセージで表示 (V3.0)
	} else if (resultCode == -1) {
		
		cont = @"Can not connect to the server\n\nPlease try again later.";
	} else if (resultCode == -2) {
		
		cont = @"Service is temporarily unavailable\n\nPlease try again later.";
	} else if (resultCode == -10) {
		
		cont = @"Search Timeout";
	} else if (resultCode == -1000) {
		
		cont = @"Search Canceled";
	} else {
		
		cont = [NSString stringWithFormat:@"Parse Error (%d)", (int)resultCode];
	}
	
	return cont;
}

#pragma  mark - Analyze

// v3.5
- (NSXMLElement *) getDocRootElement:(NSData *)aData dataType:(NSUInteger)aDataType {
    
    NSXMLDocument *document   = nil;
    
    // 自動検出で UTF8 が検出された場合、
    // または不明な場合 (V4.1)
    if (self.currentEncodingSetting == SS_ENC_AUTO_DETECT &&
        (encodingDetected == NSUTF8StringEncoding ||
         encodingDetected == SS_ENC_NOT_DETECTED)) {
    
        document = [[[NSXMLDocument alloc] initWithData:aData
                                                options:aDataType
                                                  error:nil] autorelease];
        
#ifdef SS_DEBUG_ENCODING
        NSLog(@"## DEBUG @%@[%ld] Encoding: %@ (through)",
              [siteName stringByPaddingToLength:12],
              srchSelector.selectorsIndex+1,
              [[self stringFromEncoding:encodingDetected] stringByPaddingToLength:10]);
#endif
    }
    // 自動検出で UTF8 以外が検出された場合、または固定設定の場合
    else {
        
        NSString *utf8String = [self utf8StringFromData:aData];
        
        if (utf8String == nil) {
            return nil;
        }
        
        document = [[[NSXMLDocument alloc] initWithXMLString:utf8String
                                                     options:aDataType
                                                       error:nil] autorelease];
    }
    
    // test (v3.7 - v4.0、理由は覚えてない)
/*
    NSXMLNode *n = [self firstNodeForXPath:@"//html" baseNode:document];
    NSXMLElement *root = (NSXMLElement *)n;
*/
        NSXMLElement *root = [document rootElement];
    
    return root;
}

// HTML 用 ルート要素取得
- (NSXMLElement *) getDocRootElement:(NSData *)aData {
		
    return [self getDocRootElement:aData dataType:NSXMLDocumentTidyHTML];
}

// Json 用 ルート要素取得
- (NSDictionary *) getJsonRootElement:(NSData *)aData {

	NSDictionary *root       = nil;
	NSError      *error      = nil;

    SBJsonParser *jsonParser = [[[SBJsonParser alloc] init] autorelease];

    // 自動検出で UTF8 が検出された場合
    // または不明の場合 (V4.1)
    if (self.currentEncodingSetting == SS_ENC_AUTO_DETECT &&
                   (encodingDetected == NSUTF8StringEncoding ||
                    encodingDetected == SS_ENC_NOT_DETECTED)) {

        root = [jsonParser objectWithData:aData];

#ifdef SS_DEBUG_ENCODING
        NSLog(@"## DEBUG @%@[%ld] Encoding: %@ (through)",
        [siteName stringByPaddingToLength:12],
              srchSelector.selectorsIndex+1,
              [[self stringFromEncoding:encodingDetected] stringByPaddingToLength:10]);
#endif
    }
    // 自動検出で UTF8 以外が検出された場合、または固定設定の場合
    else {
        
        NSString *utf8String = [self utf8StringFromData:aData];
        
        if (utf8String == nil) {
            return nil;
        }
        
        root = [jsonParser objectWithString:utf8String error:&error];
    }
    
	return root;
}

// NSData を UTF-8 文字列に変換する。
- (NSString *) utf8StringFromData:(NSData *)aData {
    
	NSString *str = [[[NSString alloc] initWithData:aData
										   encoding:self.encodingDetermined]
                     autorelease];

#ifdef SS_DEBUG_ENCODING
    // エンコーディング固定設定
    if (self.currentEncodingSetting != SS_ENC_AUTO_DETECT) {
        
        NSLog(@"## DEBUG @%@[%ld] Encoding: %@ setting=%@ (forced conversion)",
              [siteName stringByPaddingToLength:12],
              srchSelector.selectorsIndex+1,
              [[self stringFromEncoding:encodingDetected] stringByPaddingToLength:10],
              [self stringFromEncoding:self.currentEncodingSetting]);
    }
    // エンコーディング自動判定
    else {
        
        NSLog(@"## DEBUG @%@[%ld] Encoding: %@",
              [siteName stringByPaddingToLength:12],
              srchSelector.selectorsIndex+1,
              [[self stringFromEncoding:encodingDetected] stringByPaddingToLength:10]);
    }
#endif
    
    return str;
}

- (void) removeNodeByXPath:(NSString *)aXPath baseNode:(NSXMLNode *)aNode {
	
	NSError *err = nil;
	
	NSArray *nodeList = [aNode nodesForXPath:aXPath error:&err];

	if (err) {
		return;
	}

	NSInteger nodeNum = [nodeList count];

	
    
	// ノード番号
	NSInteger idx = 0;

	// ノード番号を割り出して削除する
	for (int i=0; i<nodeNum; i++) {
		idx = [(NSXMLNode *)[nodeList objectAtIndex:i] index];
        
//        NSLog(@"## %@",[[aNode childAtIndex:idx] stringValue]);
        
		[(NSXMLElement *)aNode removeChildAtIndex:idx];
	}
	
}

- (NSXMLNode *) firstNodeForXPath:(NSString *)aXPath baseNode:(NSXMLNode *)aNode {

	NSError *err = nil;

	NSArray *nodeList = [aNode nodesForXPath:aXPath error:&err];
	
	if (err) {
		return nil;
	}
	
	NSInteger nodeNum = [nodeList count];
	if (nodeNum == 0) {
		return nil;
	}			
	
	NSXMLNode *node = [nodeList objectAtIndex:0];
	
	return node;
}

- (void) _setChild:(id <SMSiteChildProtocol>)aChild siteName:(NSString *)name {
    
	child = aChild;
	
	[self setSiteName:name];

    // child に url や analyze の定義がない場合、本クラスのメソッドが呼ばれる
    [self addSearch:aChild urlMethod:@"url1" analyzeMethod:@"analyze1:"];
	[self addSearch:aChild urlMethod:@"url2" analyzeMethod:@"analyze2:"];
}

- (void) setHtmlChild:(id <SMSiteHtmlChildProtocol>)aChild siteName:(NSString *)name {
    
    [self _setChild:aChild siteName:name];
}

- (void) setJsonChild:(id <SMSiteJsonChildProtocol>)aChild siteName:(NSString *)name {
	
    [self _setChild:aChild siteName:name];
}

- (NSString *) url1 {

	NSString *url = [NSString stringWithFormat:[child urlFormat1], [track urlEncoded]];

	return url;
}

- (NSString *) url2 {
	return [srchResult url];
}

// 検索結果一覧解析 (HTML, JSON 共通入り口)
- (NSNumber *) analyze1:(id)aData {

    NSNumber *retValue = nil;

    if      ([child conformsToProtocol:@protocol(SMSiteHtmlChildProtocol)])
    
        retValue = [self _analyzeHtml1:aData];
    
    else if ([child conformsToProtocol:@protocol(SMSiteJsonChildProtocol)])
        
        retValue = [self _analyzeJson1:aData];
    
    return retValue;
}

// 検索結果一覧解析 (HTML 版)
- (NSNumber *) _analyzeHtml1:(id)aData {
	
	NSError  *err   = nil;
	NSString *xPath = nil;
	
	@try {
		NSXMLElement *aRootElement = [self getDocRootElement:aData];

		if (!aRootElement) return [NSNumber numberWithInt:-111];
		
		// 検索結果一覧取得
		xPath = [(id <SMSiteHtmlChildProtocol>)child targetXPath1];
		NSArray *resultsList = [aRootElement nodesForXPath:xPath error:&err];
		
		if (err) return [NSNumber numberWithInt:0];
		
		NSInteger resultsNum = [resultsList count];
        
		// No Hit
		if (resultsNum == 0) return [NSNumber numberWithInt:0];
		
		int i = 0;
		for (NSXMLNode *node in resultsList) {
            
			if (i == loopMax) return [NSNumber numberWithInt:0];
			
			NSArray *values = [(id <SMSiteHtmlChildProtocol>)child nodeValue1:node];
			
			if (!values) {
				i++;
				continue;
			}

			NSString *ttl = [values objectAtIndex:0];
			NSString *art = [values objectAtIndex:1];
			NSString *url = [values objectAtIndex:2];
			
			NSInteger score = 0;
			
			@try {
				score = [self matchTitle:ttl andArtist:art];
				
				if (score < SSLooseMatchThreshold) {
					i++;
					continue;
				}
				
				[srchResult setTitle :ttl];
				[srchResult setArtist:art];
				[srchResult setUrl   :url];

				[resultScore setTotalScore:score];
				
				return [NSNumber numberWithInt:1];
			}
			@catch (NSException * e) {
				return [NSNumber numberWithInt:-110];
			}
		}
	}
	@catch (NSException * e) {
		return [NSNumber numberWithInt:-100];
	}
	
	return [NSNumber numberWithInt:0];
}

// 検索結果一覧解析 (JSON 版)
- (NSNumber *) _analyzeJson1:(id)aData {
    
	@try {
		NSDictionary *jsonDict = [self getJsonRootElement:aData];

		if (jsonDict == nil) {
			return [NSNumber numberWithInt:-111];
		}

//        NSLog(@"## jsonDict: %@", jsonDict);
 
        NSString *targetKey    = [(id <SMSiteJsonChildProtocol>)child targetKey1];
        
        // (v4.5) キーの階層区切り対応
        NSRange rng = [targetKey rangeOfString:@"."];
        
        NSArray  *resultsArray;
        
        // キー: 階層なし
        if (rng.location == NSNotFound) {
            resultsArray = [jsonDict objectForKey:targetKey];
        }
        // キー: 階層あり
        else {
            resultsArray = [jsonDict valueForKeyPath:targetKey];
        }

//        NSLog(@"## resultsArray: %@", resultsArray);
        
		
		NSInteger resultsCount = [resultsArray count];
		
		// No Hit の場合: "results":[]
		if (resultsCount == 0) {
			return [NSNumber numberWithInt:0];
		}
		
		int i = 0;
		for (NSDictionary *item in resultsArray) {
			
			if (i == loopMax) return [NSNumber numberWithInt:0];
			
			NSArray *values = [(id <SMSiteJsonChildProtocol>)child itemValue1:item];
			
			if (!values) {
				i++;
				continue;
			}

			NSString *ttl = [values objectAtIndex:0];
			NSString *art = [values objectAtIndex:1];
			NSString *url = [values objectAtIndex:2];
			
			NSInteger score = 0;
			
			@try {
				score = [self matchTitle:ttl andArtist:art];
				
				if (score < SSLooseMatchThreshold) {
					i++;
					continue;
				}
				
				[srchResult setTitle :ttl];
				[srchResult setArtist:art];
				[srchResult setUrl   :url];
				
				[resultScore setTotalScore:score];
				
				return [NSNumber numberWithInt:1];
			}
			@catch (NSException * e) {
				return [NSNumber numberWithInt:-110];
			}
		}
	}
	@catch (NSException * e) {
		return [NSNumber numberWithInt:-100];
	}
	
	return [NSNumber numberWithInt:0];
}

- (NSNumber *) analyze2:(id)aData {
    
	NSString *xPath = nil;
	
	@try {
		NSXMLElement *aRootElement = [self getDocRootElement:aData];
        
		if (!aRootElement) return [NSNumber numberWithInt:-222];
		
		// 歌詞表示ボックス取得
		xPath = [child targetXPath2];
        
		NSXMLNode *lyricbox = [self firstNodeForXPath:xPath baseNode:aRootElement];
		
		if (!lyricbox) return [NSNumber numberWithInt:0];
		
		NSString *lyr = [child nodeValue2:lyricbox];
		
		if (!lyr) return [NSNumber numberWithInt:0];
		
		if ([lyr length] == 0) return [NSNumber numberWithInt:0];
		
		[srchResult setLyrics:lyr];
	}
	@catch (NSException * e) {
		return [NSNumber numberWithInt:-200];
	}
	
	return [NSNumber numberWithInt:1];
}

#pragma mark - Encoding

// 設定と検知情報を総合して、エンコーディングを決定する
- (NSStringEncoding) encodingDetermined {
    
    NSStringEncoding enc;
    
    // 自動検出の場合
    if (self.currentEncodingSetting == SS_ENC_AUTO_DETECT) {
        
        // 検出された場合
        if (encodingDetected != SS_ENC_NOT_DETECTED)
            
            // 検出されたものを使用
            enc = encodingDetected;
        
        // 不明の場合
        else
            
            // デフォルト値 UTF8 を使用
            enc = NSUTF8StringEncoding;
    }
    // 固定設定の場合
    else {
        
        // 設定を使用
        enc = self.currentEncodingSetting;
    }
    
    return enc;
}

- (NSString *) stringFromEncoding:(NSStringEncoding)enc {
    
    if (enc == SS_ENC_NOT_DETECTED) return @"unknown";
    
    CFStringEncoding cEnc = CFStringConvertNSStringEncodingToEncoding(enc);
    
    NSString *str = (NSString*)CFStringConvertEncodingToIANACharSetName(cEnc);
    
    return str;
}

- (NSStringEncoding) encodingFromString:(NSString *)str {
    
    if (str == nil)      return 0;
    if (str.length == 0) return 0;
    
    // CFStringEncoding 値へ変換
    CFStringEncoding cEnc = CFStringConvertIANACharSetNameToEncoding((CFStringRef)str);
    
    // さらに、NSStringEncoding 値へ変換
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(cEnc);
    
    return enc;
}

- (NSStringEncoding) currentEncodingSetting {
    
    return [encodingSetting[srchSelector.selectorsIndex] integerValue];
}

#pragma mark - Others

- (BOOL) useWebView {
	return [srchSelector useWebView];
}

- (NSInteger) webViewLoopCount {
	return [srchSelector webViewLoopCount];
}


@end