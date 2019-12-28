//
//  SMAlbumCancionLetra.m
//  Singer Song Reader
//
//  Created by Developer on 13/10/19.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMAlbumCancionLetra.h"


@implementation SMAlbumCancionLetra

- (id)init {
    self = [super init];
    if (self) {
		[super setSiteName:@"AlbumCancion"];
		
		[super addSearch:self
			   urlMethod:@"url1" 
		   analyzeMethod:@"analyze1:"];
		
		[super addSearch:self
			   urlMethod:@"url2" 
		   analyzeMethod:@"analyze2:"];
		
		urlFormat1 = @"http://www.albumcancionyletra.com/resultado_canciones.aspx?s=%@";
		
		urlFormat2 = @"http://www.albumcancionyletra.com/%@";
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
		xPath = @"//a[@class=\"ui-corner-all\"]";
		NSArray *resultsList = [aRootElement nodesForXPath:xPath error:&err];

		NSInteger resultsNum = [resultsList count];
		
		// No Hit 判定
		if (resultsNum == 0) return [NSNumber numberWithInt:0];
		
		NSXMLNode *aNode = nil;
		
		for (int i=0; i<resultsNum; i++) {
			
			if (i == 10) return [NSNumber numberWithInt:0];
			
			aNode = [resultsList objectAtIndex:i];

			// タイトル取得
			NSXMLNode *titleNode = [(NSXMLElement *)aNode attributeForName:@"title"];
			NSString *ttl = [titleNode stringValue];
			
			// URL 取得
			NSXMLNode *urlNode = [(NSXMLElement *)aNode attributeForName:@"href"];
			NSString *url = [urlNode stringValue];
			
			url = [NSString stringWithFormat:urlFormat2, url];

			// アーティスト取得
			xPath = @"span";
			NSXMLNode *artNode = [super firstNodeForXPath:xPath baseNode:aNode];
			NSString *art = [artNode stringValue];
			
			// 前後空白類削除
			art = [SSCommon removeSpacesAtBothSides:art];
			
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
		xPath = @"//div[@class=\"letra\"]";
		NSXMLNode *lyricbox = [super firstNodeForXPath:xPath baseNode:aRootElement];
		
		if (!lyricbox) return [NSNumber numberWithInt:0];
		
		// <a class="urlMin">〜</a>ノードを削除する
		xPath = @"a[@class=\"urlMin\"]";
		[super removeNodeByXPath:xPath baseNode:lyricbox];		
		
		NSString *lyr = [lyricbox stringValue];
		
		[srchResult setLyrics:lyr];
	}
	@catch (NSException * e) {
		return [NSNumber numberWithInt:-200];
	}
	
	return [NSNumber numberWithInt:1];
}

@end