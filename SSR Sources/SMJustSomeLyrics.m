//
//  SMJustSomeLyrics.m
//  Singer Song Reader
//
//  Created by Developer on 2013/12/06.
//
//

#import "SMJustSomeLyrics.h"

@implementation SMJustSomeLyrics

- (id)init {
    self = [super init];
    if (self) {
		[super setSiteName:@"JustSomeLyrics"];
		
		[super addSearch:self
			   urlMethod:@"url1"
		   analyzeMethod:@"analyze1:"];
		
		[super addSearch:self
			   urlMethod:@"url2"
		   analyzeMethod:@"analyze2:"];
		
		urlFormat1 = @"https://www.google.com/search?q=%@%%20site:justsomelyrics.com";
	}
	return self;
}

- (NSString *) url1 {

	NSString *url = [NSString stringWithFormat:urlFormat1, [track urlEncoded]];
	
	return url;
}

- (NSString *) url2 {
	return [srchResult url];
}

- (NSNumber *) analyze1:(id)aData {
	
	NSError *err = nil;
	NSString *xPath = nil;
	
	@try {
		NSXMLElement *aRootElement = [super getDocRootElement:aData];
		
		if (!aRootElement) return [NSNumber numberWithInt:-111];
		
		// 検索結果一覧取得
		//xPath = @"//div[@class=\"rc\"]";
		xPath = @"//h3[@class=\"r\"]";
		NSArray *resultsList = [aRootElement nodesForXPath:xPath error:&err];
		
		NSInteger resultsNum = [resultsList count];
		
		//NSLog(@"## resultsNum: %d", (int)resultsNum);
		
		// No Hit 判定
		if (resultsNum == 0) return [NSNumber numberWithInt:0];
		
		NSXMLNode *aNode = nil;
		
		for (int i=0; i<resultsNum; i++) {
			
			if (i == 10) return [NSNumber numberWithInt:0];
			
			aNode = [resultsList objectAtIndex:i];
			
			xPath = @"//span[@class=\"st\"]";
			NSXMLNode *descNode = [super firstNodeForXPath:xPath baseNode:[aNode nextSibling]];
			
			NSString *desc = [descNode stringValue];
			
			NSString *regex = @"^Lyrics to song \"(.+)\" by (.+): ";
			
			NSString *ttl = nil;
			NSString *art = nil;
			
			// 正規表現に一致するか
			if ([desc isMatchedByRegex:regex]) {
				
				// タイトル取得
				ttl = [desc stringByMatching:regex capture:1L];
				
				// アーティスト取得
				art = [desc stringByMatching:regex capture:2L];

				//NSLog(@"## ttl: %@", ttl);
				//NSLog(@"## art: %@", art);
			} else {
				
				continue;
			}
			
			
			// URL 取得

			//xPath = @"h3/a";
			xPath = @"a";
			NSXMLNode *urlNode = [super firstNodeForXPath:xPath baseNode:aNode];
			
			NSXMLNode *hrefNode = [(NSXMLElement *)urlNode attributeForName:@"href"];
			NSString *url = [hrefNode stringValue];

			regex = @"(http://.+\\.html)";

			if ([url isMatchedByRegex:regex]) {

				url = [url stringByMatching:regex capture:1L];
			} else {
				continue;
			}
			
			//NSLog(@"## url: %@", url);

			NSInteger score = 0;
			
			@try {
				score = [super matchTitle:ttl andArtist:art];
				
				if (score < SSLooseMatchThreshold) continue;
				
				[srchResult setTitle:ttl];
				[srchResult setArtist:art];
				[srchResult setUrl:url];
				
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
		NSXMLElement *aRootElement = [super getDocRootElement:aData];
		
		if (!aRootElement) return [NSNumber numberWithInt:-222];
		
		// 歌詞表示ボックス取得
		xPath = @"//p[@class=\"lyrics\"]";
		NSXMLNode *lyricbox = [super firstNodeForXPath:xPath baseNode:aRootElement];
		
		if (!lyricbox) return [NSNumber numberWithInt:0];
		
		NSString *lyr = [lyricbox stringValue];
		
		[srchResult setLyrics:lyr];
	}
	@catch (NSException * e) {
		return [NSNumber numberWithInt:-200];
	}
	
	return [NSNumber numberWithInt:1];
}

@end
