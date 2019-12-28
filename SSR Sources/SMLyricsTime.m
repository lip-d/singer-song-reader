//
//  SMLyricsTime.m
//  Singer Song Reader
//
//  Created by Developer on 13/11/20.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMLyricsTime.h"


@implementation SMLyricsTime

- (id)init {
    self = [super init];
    if (self) {
		[super setSiteName:@"LyricsTime"];
		
		[super addSearch:self
			   urlMethod:@"url1" 
		   analyzeMethod:@"analyze1:"];
		
		[super addSearch:self
			   urlMethod:@"url2" 
		   analyzeMethod:@"analyze2:"];
		
		urlFormat1 = @"http://www.lyricstime.com/search/?q=%@&t=default";
		urlFormat2 = @"http://www.lyricstime.com%@";
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
		xPath = @"//div[@id=\"searchresult\"]//li";
		NSArray *resultsList = [aRootElement nodesForXPath:xPath error:&err];
		
		NSInteger resultsNum = [resultsList count];
		
		// No Hit 判定
		if (resultsNum == 0) return [NSNumber numberWithInt:0];
		
		NSXMLNode *aNode = nil;
		
		for (int i=0; i<resultsNum; i++) {
			
			if (i == 10) return [NSNumber numberWithInt:0];
			
			aNode = [resultsList objectAtIndex:i];
			
			xPath = @"a";
			NSArray *ttl_art = [aNode nodesForXPath:xPath error:&err];
			
			if ([ttl_art count] != 2) continue;
			
			// タイトル取得
			NSXMLNode *titleNode = [ttl_art objectAtIndex:0];
			NSString *ttl = [titleNode stringValue];
            
            // "(Tradução)" が末尾にあったら No hit 扱いとする (V3.0)
            if ([ttl hasSuffix:@"(Tradução)"]) continue;
            
			//NSLog(@"## ttl: %@", ttl);
			
			// アーティスト取得
			NSXMLNode *artistNode = [ttl_art objectAtIndex:1];
			NSString *art = [artistNode stringValue];
			
			//NSLog(@"## art: %@", art);
						
			// URL 取得
			NSXMLNode *urlNode = [(NSXMLElement *)titleNode attributeForName:@"href"];
			NSString *url = [urlNode stringValue];
			
			url = [NSString stringWithFormat:urlFormat2, url];
			
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

        // "Tradução" チェック (V3.4)
        // analyze1 では検出できない場合がある (検索結果一覧では "Tradução" なし)
		xPath = @"//h1";
		NSXMLNode *h1Node = [super firstNodeForXPath:xPath baseNode:aRootElement];

        if (!h1Node) return @0;
        
        NSRange range = [h1Node.stringValue rangeOfString:@"Tradução" options:NSCaseInsensitiveSearch];
        
        if (range.length) return @0;
        
		// 歌詞表示ボックス取得
		xPath = @"//div[@id=\"songlyrics\"]";
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
