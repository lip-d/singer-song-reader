//
//  AZLyrics.m
//  Singer Song Reader
//
//  Created by Developer on 2013/12/06.
//
//

#import "SMAZLyrics.h"

@implementation SMAZLyrics

- (id)init {
    self = [super init];
    if (self) {
		[super setSiteName:@"AZLyrics"];
		
		[super addSearch:self
			   urlMethod:@"url1"
		   analyzeMethod:@"analyze1:"];
		
		[super addSearch:self
			   urlMethod:@"url2"
		   analyzeMethod:@"analyze2:"];
		
		urlFormat1 = @"http://search.azlyrics.com/search.php?q=%@";
        
        // v4.1
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
		xPath = @"//td[@class=\"text-left visitedlyr\"]//a[contains(@href,\"www.azlyrics.com/lyrics\")]";
		NSArray *resultsList = [aRootElement nodesForXPath:xPath error:&err];
		
		NSInteger resultsNum = [resultsList count];
		
//		NSLog(@"## resultsNum: %ld", resultsNum);
		
		// No Hit 判定
		if (resultsNum == 0) return [NSNumber numberWithInt:0];
		
		NSXMLNode *aNode = nil;
		
		for (int i=0; i<resultsNum; i++) {
			
			if (i == 5) return [NSNumber numberWithInt:0];
			
			aNode = [resultsList objectAtIndex:i];
			
			// タイトル取得
			NSString *ttl = [aNode stringValue];
			
//			NSLog(@"## ttl: %@", ttl);

			// アーティスト取得
            NSXMLNode *artistNode = aNode.nextSibling.nextSibling;
            
            if ([artistNode.name compare:@"b" options:NSCaseInsensitiveSearch] != NSOrderedSame) {
                continue;
            }
            
			NSString *art = [artistNode stringValue];
			
//			NSLog(@"## art: %@", art);
			
			// URL 取得
			NSXMLNode *urlNode = [(NSXMLElement *)aNode attributeForName:@"href"];
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
        
//        NSLog(@"### %@", aRootElement);
		
        // <div class="lyricsh"> を探す
        xPath = @"//div[@class=\"lyricsh\"][1]";
        NSXMLNode *lyricsh = [super firstNodeForXPath:xPath baseNode:aRootElement];
        
        if (!lyricsh) return [NSNumber numberWithInt:0];

        // <b>アーティスト</b> を探す
        NSXMLNode *node = lyricsh;
        do {
            node = node.nextSibling;
            
//            NSLog(@"## %@", node);
            
            if (node.kind == NSXMLElementKind && [node.name compare:@"b" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                
                NSRange range = [node.stringValue rangeOfString:srchResult.title options:NSCaseInsensitiveSearch];
                if (range.location != NSNotFound) {
                    break;
                }
            }
        } while (node != nil);
        
        if (!node) return [NSNumber numberWithInt:-201];
        
        // 歌詞表示ボックス取得
        do {
            node = node.nextSibling;
            
            if (node.kind == NSXMLElementKind && [node.name compare:@"div" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                break;
            }
            
        } while (node != nil);
        
        if (!node) return [NSNumber numberWithInt:-202];
        
        NSXMLNode *lyricbox = node;
		
		// コメントノードを削除する
		xPath = @"comment()";
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
