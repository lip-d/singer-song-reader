//
//  SMLyricWiki.m
//  Singer Song Reader
//
//  Created by Developer on 13/10/19.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMLyricWiki.h"


@implementation SMLyricWiki

- (id)init {
    self = [super init];
    if (self) {
		[super setSiteName:@"LyricWiki"];
		
		[super addSearch:self
			   urlMethod:@"url1" 
		   analyzeMethod:@"analyze1:"];
		
		[super addSearch:self
			   urlMethod:@"url2" 
		   analyzeMethod:@"analyze2:"];
		
		urlFormat1 = @"http://lyrics.wikia.com/api.php?func=getSong&artist=%@&song=%@";
	}
	return self;
}

- (NSString *) url1 {
	NSString *ttl = track.title.urlEncoded;
    
    // アーティスト名 全小文字化 (v3.8)
    //   全大文字の単語があるとヒットしない - LyricWiki 特有の仕様/バグ対応
    NSString *art_lc = track.artist.normalized.lowercaseString;
    NSString *art = [SSCommon urlEncode:art_lc];
    
	NSString *url = [NSString stringWithFormat:urlFormat1, art, ttl];
	
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

		xPath = @"/html/body";
		NSXMLNode *bodyNode = [super firstNodeForXPath:xPath baseNode:aRootElement];
		
		if (!bodyNode) return [NSNumber numberWithInt:-101];

		// Not found 判定: <pre> タグ (歌詞の一部) の内容で判断
		xPath = @"pre";
		NSXMLNode *preNode = [super firstNodeForXPath:xPath baseNode:bodyNode];
		
		// <pre> タグ自体が存在しても、中身が空の場合 nil が返る
		if (!preNode) return [NSNumber numberWithInt:0];
		
		NSString *preValue = [preNode stringValue];
		preValue = [SSCommon removeSpacesAtBothSides:preValue];
		
		// <pre> タグの内容が "Not Found"
		if ([preValue isEqualToString:@"Not found"]) {
			return [NSNumber numberWithInt:0];
		}
	
		// タイトル、アーティスト取得
		xPath = @"h3/a";
		NSArray *nodeList = [bodyNode nodesForXPath:xPath error:&err];
		
		NSInteger nodeNum = [nodeList count];
		if (nodeNum !=2) {
			return [NSNumber numberWithInt:-103];
		}			
		
		NSXMLNode *titleNode = [nodeList objectAtIndex:0];
		NSXMLNode *artistNode = [nodeList objectAtIndex:1];
		
		NSString *ttl = [titleNode stringValue];
		NSString *art = [artistNode stringValue];
		
		[srchResult setTitle:ttl];
		[srchResult setArtist:art];
		
		// 歌詞 URL 取得
		xPath = @"//a[@title=\"url\"][1]";
		NSXMLNode *urlNode = [super firstNodeForXPath:xPath baseNode:bodyNode];

        //NSLog(@"## ttl: %@", ttl);
        //NSLog(@"## art: %@", art);
        //NSLog(@"## url: %@", [urlNode stringValue]);
        
		if (!urlNode) return [NSNumber numberWithInt:-104];
		
		NSString *url = [urlNode stringValue];
        
        // %2F -> "/" 変換 (v3.8)
        // メモ：%2F のままだと、404 Not Found になってしまう。LyricWiki側のbug?
        url = [url stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
        
		[srchResult setUrl:url];

/*
 		NSInteger score = 0;
		
		@try {
			score = [super matchTitle:ttl andArtist:art];
		}
		@catch (NSException * e) {

			return [NSNumber numberWithInt:-110];
		}

        [resultScore setTotalScore:score];
*/
        // 修正 (V3.4)
        [resultScore setTotalScore:100];
	}
	@catch (NSException * e) {
		return [NSNumber numberWithInt:-100];
	}
	
	return [NSNumber numberWithInt:1];
}

- (NSNumber *) analyze2:(id)aData {
	
	NSString *xPath = nil;
	
	@try {
        // dataType: XML 指定 (Ver 3.5)
        // XML 指定により、&#XX; などのメタ文字のアンエスケープが行われる。
		NSXMLElement *aRootElement = [super getDocRootElement:aData dataType:NSXMLDocumentTidyXML];
		
		if (!aRootElement) return [NSNumber numberWithInt:-222];
		
        // test
        //NSLog(@"###0\n %@", aRootElement);
        
		xPath = @"//div[@class=\"lyricbox\"][1]";
		NSXMLNode *lyricbox = [super firstNodeForXPath:xPath baseNode:aRootElement];
        
        // test
//        NSLog(@"###1\n %@", lyricbox);

        // 各 xPath の先頭に .// を付ける (v3.7)
        
		// Ringtone のノードを削除する
        xPath = @".//div[@class=\"rtMatcher\"]";
		[super removeNodeByXPath:xPath baseNode:lyricbox];
		
		// コメントノードを削除する
		xPath = @".//comment()";
		[super removeNodeByXPath:xPath baseNode:lyricbox];

        // script タグのノードを削除する (v3.4.1)
        xPath = @".//script";
        [super removeNodeByXPath:xPath baseNode:lyricbox];
        
        // XML node -> XML text 変換 (v3.5)
        NSString *lyrString = [lyricbox XMLStringWithOptions:NSXMLTextKind];
        
        // XML text -> HTML document 変換  (v3.5)
        NSXMLDocument *lyrDocument = [[[NSXMLDocument alloc] initWithXMLString:lyrString
                                                               options:NSXMLDocumentTidyHTML
                                                                 error:nil] autorelease];
        
        // HTML document -> Text 変換  (v3.5)
        NSString *lyr = [lyrDocument stringValue];
 
//        NSString *lyr = [lyricbox stringValue];

		
		// Lyrics の内容に以下の文章が含まれる場合、歌詞が一部しか表示されない。
		// --> 歌詞なし扱いとする
		NSString *mes = @"Unfortunately, we are not licensed to display the full lyrics";
		NSRange range = [lyr rangeOfString:mes];
		
		if (range.length > 0) return [NSNumber numberWithInt:0];

		[srchResult setLyrics:lyr];
	}
	@catch (NSException * e) {
		return [NSNumber numberWithInt:-200];
	}
	
	return [NSNumber numberWithInt:1];
}

@end