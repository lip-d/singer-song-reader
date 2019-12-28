//
//  SMLetsSingIt.m
//  Singer Song Reader
//
//  Created by Developer on 13/11/19.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMLetsSingIt.h"


@implementation SMLetsSingIt

- (id)init {
    self = [super init];
    if (self) {
		[super setSiteName:@"LetsSingIt"];
		
		[super addSearch:self
			   urlMethod:@"url1" 
		   analyzeMethod:@"analyze1:"];
		
		[super addSearch:self
			   urlMethod:@"url2" 
		   analyzeMethod:@"analyze2:"];
		
		urlFormat1 = @"http://search.letssingit.com/cgi-exe/am.cgi?a=search&l=song&s=%@";
        
        // v4.0 文字化け対処
        //-----------------------------
        // - エンコーディング固定
        //-----------------------------
        encodingSetting[0] = @(NSUTF8StringEncoding);
        encodingSetting[1] = @(NSUTF8StringEncoding);
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
		xPath = @"//div[@id=\"content_artist\"]//td/a[contains(@href,\"artists.letssingit.com\")][1]";
		NSArray *resultsList = [aRootElement nodesForXPath:xPath error:&err];
		
		NSInteger resultsNum = [resultsList count];
        
        
//		NSLog(@"## %d", (int)resultsNum);
        
		// No Hit 判定
		if (resultsNum == 0) return [NSNumber numberWithInt:0];
		
		NSXMLNode *aNode1 = nil;
		
		for (int i=0; i<resultsNum; i++) {
			
			if (i == 10) return [NSNumber numberWithInt:0];
			
			aNode1 = [resultsList objectAtIndex:i];
            
            // タイトル取得
            NSString *ttl = aNode1.stringValue;
            
            //NSLog(@"## ttl: %@", ttl);


            // タイトルとアーティストの間のタグをスキップ
            NSXMLNode *node = aNode1;
            do {
                node = node.nextSibling;
                
//                NSLog(@"# %@", node);
              
                if (node.kind == NSXMLElementKind && [node.name compare:@"a" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                    break;
                }
                
            } while (node != nil);
            
            if (!node) continue;
            
            // アーティスト取得
            NSString *art = node.stringValue;
            
//			NSLog(@"## art: %@", art);
			

			// URL 取得
			NSXMLNode *urlNode = [(NSXMLElement *)aNode1 attributeForName:@"href"];
			NSString *url = [urlNode stringValue];
			
//			NSLog(@"## url: %@", url);
            
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
		xPath = @"//div[@id=\"lyrics\"]";
		NSXMLNode *lyricbox = [super firstNodeForXPath:xPath baseNode:aRootElement];
        
        // test
        //NSLog(@"###1\n %@", lyricbox);
		
		if (!lyricbox) return [NSNumber numberWithInt:0];
		
        // ads 削除
        xPath = @"div";
        [super removeNodeByXPath:xPath baseNode:lyricbox];
        
        // フッター削除
        xPath = @"ul";
        [super removeNodeByXPath:xPath baseNode:lyricbox];
        
        NSString *lyr = [lyricbox stringValue];

        // test
        //NSLog(@"###2\n %@", lyr);
		
        // "... LetsSingIt ... " (v3.7)
        NSRange range = [lyr rangeOfString:@"LetsSingIt"];
        
        if (range.location != NSNotFound) return [NSNumber numberWithInt:0];

        // Lyrics の内容が以下の文章の場合 No hit とする。
        // "lyrics not yet available on LetsSingIt, submit the lyrics here"
        NSString *mes = @"lyrics not yet available";
        
        if ([lyr hasPrefix:mes]) return [NSNumber numberWithInt:0];
        
		[srchResult setLyrics:lyr];
	}
	@catch (NSException * e) {
		return [NSNumber numberWithInt:-200];
	}
	
	return [NSNumber numberWithInt:1];
}

@end
