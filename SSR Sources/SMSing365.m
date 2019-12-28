//
//  SMSing365.m
//  Singer Song Reader
//
//  Created by Developer on 13/10/19.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMSing365.h"


@implementation SMSing365

- (id)init {
    self = [super init];
    if (self) {
		[super setSiteName:@"Sing365"];
		
		[super addSearch:self
			   urlMethod:@"url1" 
		   analyzeMethod:@"analyze1:"];
		
		[super addSearch:self
			   urlMethod:@"url2" 
		   analyzeMethod:@"analyze2:"];
		
		urlFormat1 = @"https://www.googleapis.com/customsearch/v1element?key=AIzaSyCVAXiUzRYsML1Pv6RwSG1gunmMikTzQqY&cx=partner-pub-0919305250342516:9855113007&q=%@&num=10";
        
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
	
	@try {
		NSDictionary *jsonDict = [super getJsonRootElement:aData];
		
		if (jsonDict == nil) {
			return [NSNumber numberWithInt:-111];
		}
				
		NSArray *resultsArray = [jsonDict objectForKey:@"results"];
		
		NSInteger resultsCount = [resultsArray count];
		
		// No Hit の場合: "results":[]
		if (resultsCount == 0) {
			return [NSNumber numberWithInt:0];
		}
		
		NSDictionary *resultsItem = nil;
		
		for (int i=0; i<resultsCount; i++) {
			
			if (i == 10) return [NSNumber numberWithInt:0];
			
			resultsItem = [resultsArray objectAtIndex:i];
            
            /*
            // Debug
            for (NSString * key in [resultsItem allKeys]) {
                
                //NSLog(@"## %@ : %@", key, [resultsItem valueForKey:key]);
            }
			*/
            
			// url: http://www.sing365.com/music/lyric.nsf/One-lyrics-U2/8CACE0A331FD891948256896002F4079
			NSString *url = [resultsItem valueForKey:@"url"];
			
			//			NSLog(@"########### url: %@", url);

/*
            //------------------------------------------------------------
            // タイトル、アーティスト取得箇所を contentNoFormatting へ変更 (V3.0)
            // titleNoFormatting よりは大文字になる確率は低い
            // ==> ゴミがヒットする場合あり。3.0 以前に戻す。(V3.2)
            //------------------------------------------------------------
            
            // contentNoFormatting : "Ride On Time (Massive Mix)" Lyrics by Black Box: Gotta get up, gotta get up,
            NSString *cnf = [resultsItem valueForKey:@"contentNoFormatting"];
            
            if (!cnf) continue;
            
            static NSString * const regex = @"^\"(.+)\" Lyrics by (.+): .+";
			
            NSString *ttl = nil;
            NSString *art = nil;
            
            NSRange range = NSMakeRange(0, cnf.length);
            
            // 正規表現に一致するか
            if ([cnf isMatchedByRegex:regex]) {
                
                // タイトル取得
                ttl = [cnf stringByMatching:regex options:RKLCaseless inRange:range capture:1L error:nil];
                
                // アーティスト取得
                art = [cnf stringByMatching:regex options:RKLCaseless inRange:range capture:2L error:nil];
                
            } else {
                
                //NSLog(@"++++++REGEX No MATCH %@", cnf);
                continue;
            }
*/
            
            //---------------------------------------------------
            // titleNoFormating 復活 (V3.2)
            //---------------------------------------------------
            // titleNoFormating: ONE TREE HILL LYRICS - U2
			//    [title] LYRICS - [artist]
			NSString *tnfValue = [resultsItem valueForKey:@"titleNoFormatting"];
			
			//NSLog(@"########### titleNoFormatting: %@", tnfValue);
			
			// " LYRICS - " で分割 (大文字・小文字区別なし)
			NSArray *tnfArray = [self separateTitleAndArtist:tnfValue];
			
			//NSLog(@"########### %d", [tnfArray count]);
			
			// 歌詞以外も検索ヒットする場合があり、その場合は "LYRICS" で分割できず count が 1 になる。
			if ([tnfArray count] != 2) continue;
			
			NSString *ttl = [tnfArray objectAtIndex:0];
			NSString *art = [tnfArray objectAtIndex:1];

            
            
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
	
	@try {
//        NSError  *err   = nil;
        NSString *xPath = nil;
        
        NSXMLElement *aRootElement = [super getDocRootElement:aData];
		
		if (!aRootElement) return [NSNumber numberWithInt:-222];
		
		// 歌詞表示ボックス取得
        // v3.8
        xPath = @"//div[@id=\"main\"]";
		NSXMLNode *lyricbox = [super firstNodeForXPath:xPath baseNode:aRootElement];
        
        //NSLog(@"lyricbox: %@", lyricbox);
        
		if (!lyricbox) return [NSNumber numberWithInt:0];
        
//        NSLog(@"## %@", lyricbox);
        
        // コメントノードを削除する
        xPath = @"comment()";
        [super removeNodeByXPath:xPath baseNode:lyricbox];
        
        // 最初のテキストノード (歌詞の先頭) を探す
        NSXMLNode *node = lyricbox.nextNode;
        do {
            if (node.kind == NSXMLTextKind) {
                
                NSString *nodeStr = [node.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                if (nodeStr.length != 0) {
                    
//                    NSLog(@"##p %@", node.previousSibling);
//                    NSLog(@"##c %@", node);
//                    NSLog(@"##n %@", node.nextSibling);
                    break;
                }
            }
            node = node.nextSibling;
        } while (node != nil);
        
        if (node == nil) return [NSNumber numberWithInt:0];
        
        NSMutableString *lyr = [[[NSMutableString alloc] initWithCapacity:0] autorelease];
        
        BOOL inP = false;
        
        // テキストノードまたはBRタグ以外を探す
        do {
            NSString *text = node.stringValue;
            
            //　テキストノードの場合
            if (node.kind == NSXMLTextKind) {
                
                // 両端空白類削除
                text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
   
//            NSLog(@"## name: %@ text: %@(%ld) kind: %ld", node.name, text, text.length, node.kind);
            
            if ([text compare:@"Sponsored Links" options:NSCaseInsensitiveSearch] != NSOrderedSame &&
                text.length) {
                
                [lyr appendString:node.stringValue];
                //NSLog(@"## %@", node);
            }

            if (node.nextSibling) {
                node = node.nextSibling;
            }else {
                if (inP) {
                    node = node.parent.nextSibling;
                    inP = false;
                }else {
                    node = node.nextSibling;
                }
            }
          
            // pタグだった場合
            if (node.kind != NSXMLTextKind && [node.name compare:@"p" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                
                // コメントノードを削除する
                [super removeNodeByXPath:@"comment()" baseNode:node];

                node = node.children[0];
                inP = true;
                continue;
            }

            if (node.kind != NSXMLTextKind && [node.name compare:@"br" options:NSCaseInsensitiveSearch] != NSOrderedSame) {
               break;
            }
        } while (node != nil);
        
        
		[srchResult setLyrics:lyr];
        
//        NSLog(@"## %@", lyr);

        /*
        //--------------------------------------------
        // タイトル、アーティストを小文字で取得し直し
        //--------------------------------------------
        xPath = @"h1";
        NSXMLNode *h1 = [super firstNodeForXPath:xPath baseNode:lyricbox];
        
        if (h1) {
            
            // 前後空白類削除
            NSString *h1Str = [h1.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSArray *ary = [self separateTitleAndArtist:h1Str];
            
            if (ary.count == 2) {
                
                NSString *ttl = [ary objectAtIndex:0];
                NSString *art = [ary objectAtIndex:1];
                
                // test
                //NSLog(@"## before: |%@|, |%@|", srchResult.title, srchResult.artist);
                //NSLog(@"## after : |%@|, |%@|", ttl, art);
                
                [srchResult setTitle:ttl];
				[srchResult setArtist:art];
            }
        }
         */
	}
	@catch (NSException * e) {
		return [NSNumber numberWithInt:-200];
	}
	
	return [NSNumber numberWithInt:1];
}

- (NSArray *) separateTitleAndArtist:(NSString *)aString {
 
    // " LYRICS - " で分割 (大文字・小文字区別なし)
    NSArray *ary = [aString componentsSeparatedByRegex:@"\\sLYRICS\\s-\\s" options:RKLCaseless range:NSMakeRange(0, aString.length) error:nil];
    
    return ary;
}
@end
