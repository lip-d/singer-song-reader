//
//  SMAnimeLyrics.m
//  Singer Song Reader
//
//  Created by Developer on 5/11/14.
//
//

#import "SMAnimeLyrics.h"

@interface SMAnimeLyrics ()

@property (readwrite, retain) NSString *titleRest;
@property (readwrite, retain) NSString *artistRest;

@end

@implementation SMAnimeLyrics

@synthesize titleRest;
@synthesize artistRest;

- (id)init {
    self = [super init];
    if (self) {
        
		[super setJsonChild:self siteName:@"AnimeLyrics"];

        // 検索結果クラス入れ替え
        [srchResult release];
        srchResult = [[SMAnimeLyricsSrchResult alloc] init];
        
        //-----------------------------
        // - エンコーディング固定
        //-----------------------------
        encodingSetting[0] = @(SS_ENC_AUTO_DETECT);
        encodingSetting[1] = @(NSShiftJISStringEncoding);
    }
	return self;
}

- (NSString *) urlFormat1 {
	
    // - 最初の 10 件取得
    // - "filetype:htm" をキーワードに含めているので、歌詞以外を除外できる
    //   除外対象例: "Anime Lyrics dot Com - Searching for hironobu"
	static NSString * const format = @"https://www.googleapis.com/customsearch/v1element?key=AIzaSyCVAXiUzRYsML1Pv6RwSG1gunmMikTzQqY&rsz=filtered_cse&num=10&hl=en&prettyPrint=false&source=gcsc&gss=.com&cx=partner-pub-9427451883938449:gd93bg-c1sx&q=%@%%20filetype%%3Ahtm&safe=active";
	
	return format;
}

- (NSNumber *) analyze1:(id)aData {
	
	@try {
		NSDictionary *jsonDict = [self getJsonRootElement:aData];
        
		if (jsonDict == nil) {
			return [NSNumber numberWithInt:-111];
		}
        
        NSString *targetKey    = [self targetKey1];
        
		NSArray  *resultsArray = [jsonDict objectForKey:targetKey];
		
		NSInteger resultsCount = [resultsArray count];
		
		// No Hit の場合: "results":[]
		if (resultsCount == 0) {
			return [NSNumber numberWithInt:0];
		}
		
        int       bestIndex = 0;
        NSInteger bestScore = 0;
        
		int i = 0;
		for (NSDictionary *item in resultsArray) {
			
			NSArray *values = [self itemValue1:item];
			
			if (!values) {
				i++;
				continue;
			}
            
			NSString *ttl = values[0];

            // マッチ率算出
            NSInteger score = 0;
            
            @try {
                // Title のみでマッチ率
                score    = [self matchTitle:ttl];
            }
            @catch (NSException * e) {
                return [NSNumber numberWithInt:-101];
            }
            
            // マッチ率がひとつ前を上回っていた場合
            if (score > bestScore) {
                
                // マッチ率を上書き
                bestScore = score;
                bestIndex = i;
            }
            
//            NSLog(@"## Title: %@ (Score: %ld)", ttl, score);
            
            // 100% マッチが見つかったら、その時点でループを抜ける
            if (bestScore == 100) {
                
                break;
            }

            i++;
		}
        
//        NSLog(@"## Best item = %d", (int)bestIndex+1);
        
        // マッチ率の一番良かった検索結果
        NSDictionary *resultsItem = resultsArray[bestIndex];
        
        NSString *url = resultsItem[@"url"];
        
        if (!url) return @0;
        
        srchResult.url = url;
	}
	@catch (NSException * e) {
		return [NSNumber numberWithInt:-100];
	}
	
	return [NSNumber numberWithInt:1];
}

- (NSString *) targetKey1 {
    
    static NSString * const key = @"results";
    
    return key;
}

- (NSArray *) itemValue1:(NSDictionary *)item {
    
    // Anime Lyrics dot Com - タイトル - アーティスト - ジャンル
    // 　注: アーティスト以降は長い場合に途切れてしまうので使えない
    //      また、タイトルの後にタイトル英語名が来る場合もあり、
    //      タイトル英語名かアーティストか区別がつかない
    NSString *tnf = item[@"titleNoFormatting"];
    
//    NSLog(@"## tnf: %@", tnf);
    
    if (!tnf) return nil;

    NSArray *tmpArray = [tnf componentsSeparatedByString:@" - "];
    
    NSString *ttl;
    
    NSInteger count = tmpArray.count;
    
    if (count == 1) {
        
        ttl = tnf;
    }
    else if (count > 1) {
        
        NSRange range = [tmpArray[0] rangeOfString:@"Anime Lyrics dot Com" options:NSCaseInsensitiveSearch];
        
        if (range.location != NSNotFound)
            ttl = tmpArray[1];
        else
            ttl = tmpArray[0];
    }
    else {
        
        ttl = @"";
    }
    
//    NSLog(@"## title: %@", ttl);
    
	//------------------------------
	// URL 取得
	//------------------------------
	NSString *url = item[@"url"];
	
    //    NSLog(@"## url: %@", url);
    
	if (!url) return nil;
	
//    NSLog(@"## content: %@", [item valueForKey:@"content"]);
    
	NSArray *values = [NSArray arrayWithObjects:ttl, @"", url, nil];
	
	return values;
}

/* メモ: Lyrics table の Romaji セルひとつ分のタグ構造
 <td class="romaji" nowrap="">
 <dl>
   <dt>
     <span class="lyrics">Lyrics from Animelyrics.com</span>
   </dt>
 
   <dt>
     <span class="lyrics">
       Angel... Angel... Angel... <br>
       </br>Angel... Angel... Angel... <br>
       </br><br>
       </br>
     </span>
   </dt>
 </dl>
 </td>
 
 */

- (NSNumber *) analyze2:(id)aData {
    
    titleRest  = @"";
    artistRest = @"";
    
	@try {
		NSXMLElement *aRootElement = [self getDocRootElement:aData];
        
		if (!aRootElement) return [NSNumber numberWithInt:-222];

        // debug
        //NSLog(@"###\n%@", aRootElement);
        
		//----------------------------------------
        // タイトル (ローマ字、英語)
		//----------------------------------------
        NSArray *ttls = [self extractTitle:aRootElement];
        
        if (!ttls) return @201;

        NSInteger ttlScore, artScore, totalScore;
        
        // まずタイトルのみでマッチ率算出
        ttlScore = [self matchTitles:ttls];

//        NSLog(@"## Titles: %@", ttls);
        
        if (ttlScore < SSLooseMatchThreshold) return @0;
        
        srchResult.title      = ttls[0];
        srchResult.otherTitle = ttls[1];
        
		//----------------------------------------
        // アーティスト/番組名 (ローマ字)
		//----------------------------------------
        NSString *art = [self extractArtist:aRootElement];
        
        if (!art) return @202;
        
        srchResult.artist = art;
        
		//----------------------------------------
        // アーティスト/番組名 (英語)
		//----------------------------------------
        NSArray *oarts = [self extractOtherArtists:aRootElement];
        
//        NSLog(@"## Other Artists: %@", oarts);
        
        srchResult.otherArtists = oarts;
        
		//----------------------------------------
        // ヘッダー付加情報
		//----------------------------------------
        NSArray *hnotes = [self extractHeaderNotes:aRootElement];
        
//        NSLog(@"## Header notes : %@", hnotes);

        srchResult.headerNotes = hnotes;
        
        NSArray *harts = [self filterHeaderNotes:hnotes];
        
//        NSLog(@"## Header artists: %@", harts);

        // 全 Artist をまとめる
        NSArray *artAll = [[harts arrayByAddingObjectsFromArray:oarts] arrayByAddingObject:art];
        
//        NSLog(@"## Artists: %@", artAll);

        // 次にアーティストのみでマッチ率算出
        artScore = [self matchArtists:artAll];
        
        // 単語がひとつもマッチしない場合
        if (artScore == 0) return @0;
        
        BOOL isLooseMatch = NO;
        
        // Title マッチ、余りなし
        if (ttlScore == 100) {
            
            if (titleRest.length > 3 || artistRest.length > 3 ) {
                
                isLooseMatch = YES;
            }
            else {
                // ヒット扱い
                ;
            }
        }
        // Title 余り 1 単語まで
        else {
            
            isLooseMatch = YES;
        }
        
        if (isLooseMatch)
            // 最後の -1 は、しきい値に達するのを防ぐため
            totalScore = ttlScore - (100 - SSNormalMatchThreshold) - 1;
        else
            totalScore = ttlScore;
        
        resultScore.totalScore = totalScore;
        
//        NSLog(@"## Total score=%ld (Title: %ld, Artist: %ld) titleRest=|%@| artistRest=|%@|", totalScore, ttlScore, artScore, titleRest, artistRest);
        
        //----------------------------------------
        // Romaji/Translation の2列テーブルの場合
		//----------------------------------------
		// 歌詞テーブルの Romaji セルのみを抽出
        NSArray *lyricsArray = [aRootElement nodesForXPath:@"//table//td[@class=\"romaji\"]//dt[2]" error:nil];

		if (lyricsArray.count == 0) {
            
            //----------------------------------------
            // Romaji のみでテーブルなしの場合
            //----------------------------------------
            // dt[1]: <dt><span class="lyrics">Lyrics from Animelyrics.com</span></dt>
            // dt[2]: <dt><span class="lyrics">sake no maruku ni yararetanda<br>...
            // dt の 2 番目を取得
            // メモ: 歌詞内の " " は空白記号がめずらしい \U00a0 が使われているため
            
            lyricsArray = [aRootElement nodesForXPath:@"//dt[2]/span[@class=\"lyrics\"]" error:nil];
        }
		
        if (lyricsArray.count == 0) return @0;

        NSMutableArray *lyrArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        
        for (NSXMLNode *l in lyricsArray) {
            
            [lyrArray addObject:[l stringValue]];
        }
        
        // 各セルの最後に空改行が含まれているため、結合用の改行は必要なし
        NSString *lyr = [lyrArray componentsJoinedByString:@""];
		
		[srchResult setLyrics:lyr];
	}
	@catch (NSException * e) {
		return [NSNumber numberWithInt:-200];
	}
	
	return [NSNumber numberWithInt:1];
}

// ダミー
- (NSString *) targetXPath2 {
	return nil;
}
// ダミー
- (NSString *) nodeValue2:(NSXMLNode *)node {
    return nil;
}


#pragma mark - Private

- (NSArray *) extractTitle:(NSXMLNode *)baseNode {
    
    NSArray *titles;
    
    NSXMLNode *ttlNode = [super firstNodeForXPath:@"//table[1]//h1" baseNode:baseNode];
    
    if (!ttlNode) return nil;
    
    NSString *tmpTtl = [SSCommon removeSpacesAtBothSides:ttlNode.stringValue];
    
    if (tmpTtl.length == 0) return nil;
    
    titles = [tmpTtl componentsSeparatedByString:@"\n"];
    
    if (titles.count > 1)
        return titles;
    else
        return [titles arrayByAddingObject:@""];
}

- (NSString *) extractArtist:(NSXMLNode *)baseNode {
    
    NSString *artist;
    
    NSArray *crumbsArray = [baseNode nodesForXPath:@"//ul[@id=\"crumbs\"]/li/a" error:nil];
    
    if ([crumbsArray count] == 0) return nil;
    
    artist = [crumbsArray.lastObject stringValue];
    
    if ([artist length] == 0) return nil;
    
    return artist;
}

- (NSArray *) extractOtherArtists:(NSXMLNode *)baseNode {
    
    NSArray *otherArtists;
    
    NSXMLNode *metaNode = [super firstNodeForXPath:@"//head[1]/meta[@name=\"description\"]" baseNode:baseNode];
    
    NSString *desc = [[(NSXMLElement *)metaNode attributeForName:@"content"] stringValue];
    
    if (!desc) return [NSArray array];
    
    NSString *tmp = [desc stringByMatching:@"; (.+), " capture:1L];
    
    if (!tmp) otherArtists = [NSArray array];
    else {
        
        otherArtists = [tmp componentsSeparatedByString:@"; "];
    }
    
    return otherArtists;
}

- (NSArray *) extractHeaderNotes:(NSXMLNode *)baseNode {
    
    NSMutableArray *headerNotes;
    
    NSXMLNode *ytbNode = [super firstNodeForXPath:@"//div[@id=\"ytb\"]" baseNode:baseNode];
    
    if (!ytbNode) return [NSArray array];
    
    NSXMLNode *node = ytbNode.nextSibling;
    
    int  brCount = 0;
    BOOL brFound = NO;
    
    for (int i=0; i<20; i++) {
        
        if ([node.name isEqualToString:@"br"]) brCount++;
        else                                   brCount = 0;
        
        node = node.nextSibling;
        
        if (brCount == 2) {
            brFound = YES;
            break;
        }
    }
    
    if (!brFound) return [NSArray array];
    
    headerNotes = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    for (int i=0; i<20; i++) {
        
        NSString *nodeName = node.name;
        
        if (nodeName == nil) {
            
            NSString *val = node.stringValue;
            
            if (![val hasPrefix:@"Description"]) {
                
                [headerNotes addObject:val];
            }
        }
        else if ([nodeName isEqualToString:@"br"]) {
            ;
        }
        else {
            break;
        }
        
        node = node.nextSibling;
    }
    
    return headerNotes;
}

- (NSArray *) filterHeaderNotes:(NSArray *)headerNotes {
    
    NSMutableArray *filteredArray = [NSMutableArray arrayWithCapacity:0];
    
    for (NSString *note in headerNotes) {
        
        if ([note isMatchedByRegex:@"^(lyric\\w+|compos\\w+|arrang\\w+|music|writ\\w+|and|revis\\w+|word\\w*|produc\\w+|\\W)+(\\s+by|\\s*:|\\s*=)"
                           options:RKLCaseless
                           inRange:NSMakeRange(0, note.length)
                             error:nil]) {
            
//                NSLog(@"## Excluded: |%@|", val);
        }
        else {
            NSRange range = [note rangeOfRegex:@"(^|\\s+)by\\s+|:\\s*|=\\s*"
                                       options:RKLCaseless
                                       inRange:NSMakeRange(0, note.length)
                                       capture:0
                                         error:nil];
            
//                NSLog(@"## Included: |%@|", val);
            
            NSString *val;
            
            if (range.length) {
                
                val = [note substringFromIndex:(range.location + range.length)];
            }
            else {
                val = note;
            }
            
            [filteredArray addObject:val];
        }
    }
    
    return filteredArray;
}

#pragma mark - SMSite Override

// タイトルのみ比較
- (NSInteger) matchTitle:(NSString *)aTitle rest:(NSString **)aRest{
    
    NSInteger score;
    
    if (aTitle.length == 0) {
        
        *aRest = @"";
        return 0;
    }
    SMTrack *trk = [[[SMTrack alloc] init] autorelease];
    
    [trk setTitle:aTitle artist:@""];
    
    NSArray *searcher    = trk.title.arrayArray;
    NSArray *searched    = track.title.arrayArray;
    
    // 比較実行
	score = [SMTrack compareArrayArray:searcher searched:searched
                        searcherFilter:YES searchedFilter:NO
                          searchedRest:aRest scoreWithoutRest:YES];
    
	return score;
}

- (NSInteger) matchTitles:(NSArray *)aTitles {
    
    NSInteger score;
	
    if ([aTitles count] != 2) return 0;
    
    NSString *rest, *orest;
    NSInteger sco, osco;
    
    sco   = [self matchTitle:aTitles[0] rest:&rest];
    
    if (sco == 100) {
        osco = 0;
        orest = @"";
    } else {
        osco  = [self matchTitle:aTitles[1] rest:&orest];
    }
    
    if (sco > osco) {
        score  = sco;
        titleRest = rest;
    }
    else {
        score  = osco;
        titleRest = orest;
    }
    
    return score;
}

- (NSInteger) matchArtists:(NSArray *)aArtists {
    
    NSInteger score;
    
    if ([aArtists count] == 0) {
        
        artistRest = @"";
        return 0;
    }
    
    SMTrack *trk = [[[SMTrack alloc] init] autorelease];
    
    [trk setTitle:@"" artist:[aArtists componentsJoinedByString:@" "]];
    
    NSArray *searcher = trk.artist.arrayArray;
    
    NSArray *searched;
    
    // 検索条件のアーティストが空の場合
    if (track.artist.original.length == 0 && [titleRest length]) {
        
        NSString *artist = [NSString stringWithString:titleRest];
        
        // タイトルの余りを使用
        NSArray *mainwordsArray = @[artist];
        
        searched = @[mainwordsArray, track.artist.subwordsArray];
        
        titleRest = @"";
        
    } else {
        
        searched = track.artist.arrayArray;
    }
    
    //NSLog(@"## searcher: %@", searcher);
    //NSLog(@"## searched: %@", searched);
    
    NSString *rest;
    
    // 比較実行
	score = [SMTrack compareArrayArray:searcher searched:searched
                        searcherFilter:NO searchedFilter:NO
                          searchedRest:&rest scoreWithoutRest:NO];
    
    artistRest = rest;
    
    return score;
}

- (NSString *) lyricFooter:(BOOL)withURL {
    
    NSString *otherTitle;
    
    if ([srchResult.otherTitle length])
        otherTitle = [NSString stringWithFormat:@"Also known as:\n%@\n\n", srchResult.otherTitle];
    else
        otherTitle = @"";
    
    NSString *headerNotes;
    
    if ([srchResult.headerNotes count]) {
        NSString *joined = [srchResult.headerNotes componentsJoinedByString:@"\n"];
        headerNotes = [NSString stringWithFormat:@"%@\n\n", joined];
    }
    else
        headerNotes = @"";

    NSString *url;
    
    if (withURL) url = [NSString stringWithFormat:@"\n[%@]", [srchResult url]];
    else         url = @"";
    
    return [NSString stringWithFormat:@"\n\n\n\n%@%@%@%@", otherTitle, headerNotes, siteFullName, url];
}


/*
 - (NSString *) lyricHeader {
 
 
 NSString *otherTitle;
 
 if ([srchResult.otherTitle length])
 otherTitle = [srchResult.otherTitle stringByAppendingString:@"\n"];
 else
 otherTitle = @"";
 
 NSString *headerNotes;
 
 if ([srchResult.headerNotes count]) {
 NSString *joined = [srchResult.headerNotes componentsJoinedByString:@"\n"];
 headerNotes = [NSString stringWithFormat:@"\n%@\n", joined];
 }
 else
 headerNotes = @"";
 
 return [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n",
 srchResult.title, otherTitle,
 srchResult.artist, headerNotes];
 }
 */


@end
