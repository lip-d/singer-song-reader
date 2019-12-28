//
//  SMLyricsMania.m
//  Singer Song Reader
//
//  Created by Developer on 13/11/20.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMLyricsMania.h"


@implementation SMLyricsMania

- (id)init {
    self = [super init];
    if (self) {
		[super setSiteName:@"LyricsMania"];
		
		[super addSearch:self
			   urlMethod:@"url1" 
		   analyzeMethod:@"analyze1:"];
		
		[super addSearch:self
			   urlMethod:@"url2" 
		   analyzeMethod:@"analyze2:"];
		
        // k(キーワード)は必ず、アーティスト、タイトルの順にする
		urlFormat1 = @"http://www.lyricsmania.com/searchnew.php?k=%@&x=-975&y=-167";
		urlFormat2 = @"http://www.lyricsmania.com%@";
        
        // v4.1
        //-----------------------------
        // - エンコーディング固定
        //-----------------------------
        encodingSetting[0] = @(SS_ENC_AUTO_DETECT);
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
//		xPath = @"//div[@id=\"albums\"]//li/a";
		xPath = @"//div[@class=\"col-left\"]//li/a";
		NSArray *resultsList = [aRootElement nodesForXPath:xPath error:&err];
		
		NSInteger resultsNum = [resultsList count];

		//NSLog(@"## resultsNum: %d", resultsNum);
		
		// No Hit 判定
		if (resultsNum == 0) return [NSNumber numberWithInt:0];
		
		NSXMLNode *aNode = nil;
		
		for (int i=0; i<resultsNum; i++) {
			
			if (i == 10) return [NSNumber numberWithInt:0];
			
			aNode = [resultsList objectAtIndex:i];
			
			// アーティスト - タイトル
			NSString *art_ttl = [aNode stringValue];
			
			NSArray *components = [art_ttl componentsSeparatedByString:@" - "];
			
            // Change (V4.1) !=2 -> <2 (3個以上の場合があるため)
			if ([components count] < 2) continue;
			
			// アーティスト取得
			NSString *art = [components objectAtIndex:0];

            //NSLog(@"## art: %@", art);

			// タイトル取得
			NSString *ttl = [components objectAtIndex:1];
			
			//NSLog(@"## ttl: %@", ttl);
			
			// URL 取得
			NSXMLNode *urlNode = [(NSXMLElement *)aNode attributeForName:@"href"];
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
        
        // 歌詞表示ボックス取得
        // Change (V3.8)
//        xPath = @"//div[@class=\"lyrics-body\"]//div[@class=\"p402_premium\"]"
        
        // Change (V4.1)
        // Lyricboxの構造
        //  親Lyricsの中に子Lyrics(p402_premium)が入れ子になっている。
        // 対応
        //  まず、子Lyricsを親から切り離し、中身だけを再度、親Lyricsに取り付ける（入れ子を解除する）
        //  その上で、通常通りの処理を行う。
        // 親Lyrics
        //    |-- 切り離す
        //   子Lyrics(p402_premium)
        //      |-- 切り離す
        //     中身
        
        // 親Lyrics取得
//        xPath = @"//div[@class=\"lyrics-body\"]";
        
        // Change (v4.5)
        //        lyrics-body
        //          |-- fb-quotable     <-- 追加された
        //                |-- p402_premium
        xPath = @"//div[@class=\"fb-quotable\"]";
        NSXMLNode *lyricbox = [super firstNodeForXPath:xPath baseNode:aRootElement];
        
//        NSLog(@"lyrics-body: %@", lyricbox);
        
        if (!lyricbox) return [NSNumber numberWithInt:0];

        // 子Lyrics取得
//        xPath = @"./div[@class=\"p402_premium\"]";
        xPath = @".//div[@class=\"p402_premium\"]";
        NSXMLNode *lybox = [super firstNodeForXPath:xPath baseNode:lyricbox];

        // 子Lyricsの位置を覚えておく
        NSInteger lyIndex= lybox.index;
        
        // 親から子Lyricsを切り離す
        [lybox detach];
        
        NSArray *lyChildren = lybox.children;
        
        // 子Lyrics内の要素一つひとつにおいて、親タグから切り離す
        for (NSXMLNode *lyChild in lyChildren) {
            [lyChild detach];
        }
        
        // 子Lyricsの中身を再度、親Lyricsに取り付ける
        [(NSXMLElement *)lyricbox insertChildren:lyChildren atIndex:lyIndex];
        
        // Add (V3.2)
        // div タグを削除 (Video)
        xPath = @"./div";
        [super removeNodeByXPath:xPath baseNode:lyricbox];
        
        // Add (V3.3)
        // strong タを削除 (タイトル: "Lyrics to 〜")
        xPath = @"./strong";
        [super removeNodeByXPath:xPath baseNode:lyricbox];
        
        // Add (V3.8)
        // script タを削除 (credits)
        xPath = @"./script";
        [super removeNodeByXPath:xPath baseNode:lyricbox];
        
        // Add (V4.1)
        // コメントノードを削除する
        xPath = @"comment()";
        [super removeNodeByXPath:xPath baseNode:lyricbox];
        
        
		NSString *lyr = [lyricbox stringValue];
				
		// 引用URL "[ From: http://サイトアドレス ]" を削除する		
		lyr = [lyr stringByReplacingOccurrencesOfRegex:@"\\[.*http://.*\\]\n" withString:@""];

		
		[srchResult setLyrics:lyr];
	}
	@catch (NSException * e) {
		return [NSNumber numberWithInt:-200];
	}
	
	return [NSNumber numberWithInt:1];
}

@end
