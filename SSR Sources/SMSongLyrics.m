//
//  SMSongLyrics.m
//  Singer Song Reader
//
//  Created by Developer on 13/10/19.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMSongLyrics.h"


@implementation SMSongLyrics

- (id)init {
    self = [super init];
    if (self) {
		[super setSiteName:@"SongLyrics"];
		
		[super addSearch:self
			   urlMethod:@"url1" 
		   analyzeMethod:@"analyze1:"];
		
		[super addSearch:self
			   urlMethod:@"url2" 
		   analyzeMethod:@"analyze2:"];
		
		urlFormat1 = @"http://www.songlyrics.com/index.php?section=search&searchW=%@&submit=Search&searchIn1=artist&searchIn3=song";
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
		xPath = @"//div[@class=\"serpresult\"]";
		NSArray *resultsList = [aRootElement nodesForXPath:xPath error:&err];
		
		NSInteger resultsNum = [resultsList count];

		// No Hit
		if (resultsNum == 0) return [NSNumber numberWithInt:0];
		
		NSXMLNode *aNode = nil;
		
		for (int i=0; i<resultsNum; i++) {
			
			if (i == 10) return [NSNumber numberWithInt:0];
			
			NSXMLNode *rNode = [resultsList objectAtIndex:i];
			
			// タイトル、歌詞 URL 取得
			xPath = @"h3[1]/a[1]";
			aNode = [super firstNodeForXPath:xPath baseNode:rNode];
			
			if (!aNode) return [NSNumber numberWithInt:-101];
            
//            NSLog(@"## %@", aNode);
			
			NSXMLNode *titleNode = [(NSXMLElement *)aNode attributeForName:@"title"];
			NSXMLNode *urlNode = [(NSXMLElement *)aNode attributeForName:@"href"];

			NSString *ttl = [titleNode stringValue];
			NSString *url = [urlNode stringValue];
			
			// アーティスト取得
			xPath = @"div[@class=\"serpdesc-2\"][1]/p[1]/a[1]";
			aNode = [super firstNodeForXPath:xPath baseNode:rNode];

			if (!aNode) return [NSNumber numberWithInt:-102];
			
			NSString *art = [aNode stringValue];
			
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
		xPath = @"//p[@id=\"songLyricsDiv\"]";
		NSXMLNode *lyricbox = [super firstNodeForXPath:xPath baseNode:aRootElement];
		
		if (!lyricbox) return [NSNumber numberWithInt:0];
		
		NSString *lyr = [lyricbox stringValue];
		
		// Lyrics の内容が以下の文章の場合 No hit とする。
		// "We do not have the lyrics for [タイトル] yet."

		NSString *mes = @"We do not have the lyrics for";
		
		if ([lyr hasPrefix:mes]) return [NSNumber numberWithInt:0];
        
        // ヘッダー部分の三行を削除する (Artist¥nMiscellaneous¥nTitle)
        lyr = [self removeMiscellaneousHeader:lyr];
        
        // V3.0 追加
        // Lyrics の内容が以下の文章で始まる場合は No hit とする。
        // Copyrights do not allow these lyrics to be displayed on the net.
		mes = @"Copyrights do not allow";
		
		if ([lyr hasPrefix:mes]) return [NSNumber numberWithInt:0];

		[srchResult setLyrics:lyr];
	}
	@catch (NSException * e) {
		return [NSNumber numberWithInt:-200];
	}
	
	return [NSNumber numberWithInt:1];
}

- (NSString *) removeMiscellaneousHeader:(NSString *)lyr {
    
    lyr = [SSCommon removeSpacesAtBothSides:lyr];
    
    static NSString * const regex = @"^(.+)\n(.+)\n(.+)\n";
    
    if ([lyr isMatchedByRegex:regex]) {
        
        // 第一行
        NSString *art = [lyr stringByMatching:regex capture:1L];
        
        // 第二行
        NSString *ttl = [lyr stringByMatching:regex capture:3L];
        
        NSInteger score = [super matchTitle:ttl andArtist:art];
        
        if (score > 80) {
            
            //NSLog(@"++++++++SongLyrics: Misc removed");
            
            lyr = [lyr stringByReplacingOccurrencesOfRegex:regex withString:SMEmpty];
        }
    }

    return lyr;
}

@end