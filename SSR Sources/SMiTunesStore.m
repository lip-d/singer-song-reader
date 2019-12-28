//
//  SMiTunesStore.m
//  Singer Song Reader
//
//  Created by Developer on 13/10/31.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMiTunesStore.h"
#import "SMCountries.h"


NSString * const SMiTunesReleaseDateFormat = @"\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z";

NSString * const SMStoreLangJapanese = @"ja_jp";
NSString * const SMStoreLangEnglish  = @"en_us";

@interface SMiTunesStore()
@property (readwrite, retain) NSString *lang;
@end

@implementation SMiTunesStore

@synthesize countryCode;
@synthesize lang;
@synthesize matchThreshold;
@synthesize artistScore;

- (id)init {
    self = [super init];
    if (self) {
		[super setSiteName:@"iTunesStore"];
		
		[super addSearch:self
			   urlMethod:@"url1"
		   analyzeMethod:@"analyze1:"];
		
		[super addSearch:self
			   urlMethod:@"url1_"
		   analyzeMethod:@"analyze1_:"];
		
        [super addSearch:self
			   urlMethod:@"url2"
		   analyzeMethod:@"analyze2:"];
        
        [super addSearch:self
			   urlMethod:@"url3"
		   analyzeMethod:@"analyze3:"];
        
		countryCode = nil;
        lang        = nil;
        
        matchThreshold = 0;
								
        //-----------------------------
        // 第一検索 (Title+Artist)
        //-----------------------------
        // 10 件取得して、ベストを決定する
        urlFormat1 = @"https://itunes.apple.com/search?term=%@+%@&media=music&entity=song&limit=10&country=%@&lang=%@";
        
        //-----------------------------
        // 第一補完検索 (Artist Only)
        //-----------------------------
        // attribute=artistTerm を追加して Artist 名のみを検索。
        // これが無いと、feat. などで他のアーティストがヒットしてしまう場合がある。
        urlFormat1_ = @"https://itunes.apple.com/search?term=%@&media=music&entity=musicArtist&limit=1&country=%@&lang=%@&attribute=artistTerm";
        
        //-----------------------------
        // 第二検索 (Top Songs)
        //-----------------------------
        // Most Popular 用 URL (未実装)
        // 　　artistId を指定して、最も Popularity の高い20曲を取得する
        //     *lookup でも country を指定することで、その国の iTunes Store の曲が取得できる
        //     *lang に英語を指定することで、アーティストページ artistLinkUrl で取得する HTML の内容が英語になる
        //       但し、iTunes にリダイレクト表示される際には、その国の言語表記になる
        urlFormat2 = @"https://itunes.apple.com/lookup?id=%@&media=music&entity=song&limit=20&country=%@&lang=%@";
		
		
		// iTunes Store 用検索結果
		storeResult = [[SMStoreResult alloc] init];
		
		// 親クラスの検索結果クラスを iTunes Store 用の検索結果クラスに置き換える
		[srchResult release];
		srchResult = storeResult;
        
        // Artist 単独マッチ率
        artistScore = [[SMResultScore alloc] init];;
	}
	return self;
}

- (void)dealloc {
	/* storeResult は親クラスで release されるのでここでは release 不要 */

    [artistScore release];
    [super dealloc];
}

- (void) markAsNoHit {
	resultCode = 0;
	[resultScore clear];
	[artistScore clear];
}

- (void) markSongAsNoHit {
	[resultScore clear];
}

- (void) markArtistAsNoHit {
	[artistScore clear];
}

- (NSString *) url1 {
	NSString *ttl = track.title.urlEncoded;
	NSString *art = track.artist.urlEncoded;
	
    //---------------------
    // 検索言語設定
    //---------------------
    if (track.isJapanese) lang = SMStoreLangJapanese;
    else                  lang = SMStoreLangEnglish;
    
	NSString *url = [NSString stringWithFormat:urlFormat1, art, ttl, countryCode, lang];
	
	return url;
}

- (NSString *) url1_ {
	NSString *art = track.artist.urlEncoded;
	
	NSString *url = [NSString stringWithFormat:urlFormat1_, art, countryCode, lang];
	
	return url;
}

// Top Songs
- (NSString *) url2 {
	
	NSString *url = [NSString stringWithFormat:urlFormat2, [srchResult artistId], countryCode, lang];
	
	return url;
}

// Biography
- (NSString *) url3 {
    
	return [srchResult artistUrl];
}

- (NSNumber *) analyze1:(id)aData {
    
#ifdef SS_DEBUG_STORE
    NSLog(@"DEBUG ---------------");
    NSLog(@"DEBUG 1st: %.2f", (float)[srchSelector accessTimeForIndex:0]);
#endif
	@try {
		NSDictionary *jsonDict = [super getJsonRootElement:aData];
		
		if (jsonDict == nil) {
			return [NSNumber numberWithInt:-111];
		}
		
		NSString *rCount = [jsonDict objectForKey:@"resultCount"];
		if (rCount) {
			if ([rCount integerValue] == 0) {
                
                //NSLog(@"## Song+Art No Hit");
                
                // Artist 検索へ
				return [NSNumber numberWithInt:1];
			}
		} else {
			// 国コードの全 249 件中 84 件はパラメータエラーとなり、
			// 検索結果にエラーメッセージが返る。北朝鮮やキューバなど iTunes Store が
			// 利用できない国が該当すると思われる。
			
			NSString *errorMessage = [jsonDict objectForKey:@"errorMessage"];
			
			if ([errorMessage isEqualToString:@"Invalid value(s) for key(s): [country]"]) {
				return [NSNumber numberWithInt:-5];
			} else {
                //NSLog(@"## analyze1: %@", errorMessage);
				return [NSNumber numberWithInt:-6];				
			}
			/* For Debug
			NSInteger index = [[SMCountries codes] indexOfObject:countryCode];
			NSString *countryName = [[SMCountries names] objectAtIndex:index];
			//NSLog(@"## %@ : %@|%@", errorMessage, countryCode, countryName);
			 */
		}

		
		NSArray *resultsArray = [jsonDict objectForKey:@"results"];
		
		NSInteger resultsCount = [resultsArray count];
		
		// No Hit の場合: "results":[]
		if (resultsCount == 0) {
            
            //NSLog(@"## Song+Art No Hit");

            // Artist 検索へ
			return [NSNumber numberWithInt:1];
		}
		
        int bestIndex = 0;
        
        // 1 件目がベストとは限らないので一定数ループしてベストの結果を探す
        int i = 0;
        for (NSDictionary *item in resultsArray) {
            
            NSString *ttlTmp = [item valueForKey:@"trackName"];
            NSString *artTmp = [item valueForKey:@"artistName"];
            
            // マッチ率算出
            NSInteger score = 0;
            
            @try {
                // Title & Artist 合計マッチ率
                score    = [super matchTitle:ttlTmp andArtist:artTmp];
            }
            @catch (NSException * e) {
                return [NSNumber numberWithInt:-101];
            }
            
            if (i==0) {
                
                [resultScore setTotalScore:score];
                
                bestIndex = i;
            } else {
                
                // マッチ率がひとつ前を上回っていた場合
                if (score > resultScore.totalScore) {
                    
                    // マッチ率を上書き
                    [resultScore setTotalScore:score];
                    
                    bestIndex = i;
                }
            }
            
            //NSLog(@"## 1st Song+Art: %d (%@ : %@)", (int)score, ttlTmp, artTmp);

            // 100% マッチが見つかったら、その時点でループを抜ける
            if (resultScore.totalScore == 100) {

                break;
            }
            i++;
        }
        
        //NSLog(@"## best item = %d", (int)bestIndex+1);
        
        // マッチ率の一番良かった検索結果
        NSDictionary *resultsItem = [resultsArray objectAtIndex:bestIndex];
        
        // タイトル関連情報をセット
        [self setTitleResult:resultsItem];
        
        // アーティスト関連情報をセット
        NSString *art         = [resultsItem valueForKey:@"artistName"];
        NSString *artistId    = [resultsItem valueForKey:@"artistId"];
        NSString *artistUrl   = [resultsItem valueForKey:@"artistViewUrl"];
        
        [srchResult setArtist    :art];
        [srchResult setArtistId  :artistId];
        [srchResult setArtistUrl :artistUrl];

	}
	@catch (NSException * e) {
		return [NSNumber numberWithInt:-100];
	}

    // Title+Artist マッチ率がしきい値以上の場合
    if (resultScore.totalScore >= matchThreshold) {

        // そのマッチ率をそのまま Artist 単独マッチ率として採用する
        [artistScore setTotalScore:resultScore.totalScore];
        
        // Artist 検索をスキップ
        [srchSelector next];
    }
    // Title+Artist マッチ率がしきい値未満の場合
    else {
        
        @try {
            
            // Artist 単独マッチ率を算出
            NSInteger score = [super matchArtist:srchResult.artist];
            
            [artistScore setTotalScore:score];
            
            // Artist 単独でしきい値以上の場合
            if (score >= matchThreshold) {
                
                // Artist 検索をスキップ
                [srchSelector next];
            }
        }
        @catch (NSException * e) {
            return [NSNumber numberWithInt:-102];
        }
    }

    //NSLog(@"## 1st artist: %d (%@)", (int)artistScore.totalScore, srchResult.artist);
    
    // 第一検索のみで終わることはないので必ず 1 を返す
	return [NSNumber numberWithInt:1];
}

// 第一検索でノーヒットまたは、Artist がしきい値に達しなかった場合の代替検索用
- (NSNumber *) analyze1_:(id)aData {
    
#ifdef SS_DEBUG_STORE
    NSLog(@"DEBUG 1st_: %.2f", (float)[srchSelector accessTimeForIndex:1]);
#endif
	@try {
		NSDictionary *jsonDict = [super getJsonRootElement:aData];
		
		if (jsonDict == nil) {
			return [NSNumber numberWithInt:-222];
		}
		
		NSString *rCount = [jsonDict objectForKey:@"resultCount"];
		if (rCount) {
            
			if ([rCount integerValue] == 0) {
                
                if (resultScore.totalScore == 0) {
                
                    return [NSNumber numberWithInt:0];
                } else {
                    
                    [srchSelector next];
                    [srchSelector next];
                    
                    return [NSNumber numberWithInt:1];
                }
			}
		} else {
			// 国コードの全 249 件中 84 件はパラメータエラーとなり、
			// 検索結果にエラーメッセージが返る。北朝鮮やキューバなど iTunes Store が
			// 利用できない国が該当すると思われる。
			
			NSString *errorMessage = [jsonDict objectForKey:@"errorMessage"];
			
			if ([errorMessage isEqualToString:@"Invalid value(s) for key(s): [country]"]) {
				return [NSNumber numberWithInt:-5];
			} else {
                //NSLog(@"## analyze1_: %@", errorMessage);
				return [NSNumber numberWithInt:-6];
			}
			/* For Debug
             NSInteger index = [[SMCountries codes] indexOfObject:countryCode];
             NSString *countryName = [[SMCountries names] objectAtIndex:index];
             //NSLog(@"## %@ : %@|%@", errorMessage, countryCode, countryName);
			 */
		}
        
		NSArray *resultsArray = [jsonDict objectForKey:@"results"];
		
		NSInteger resultsCount = [resultsArray count];
        
		// No Hit の場合: "results":[]
		if (resultsCount == 0) {
            
            if (resultScore.totalScore == 0) {
                
                return [NSNumber numberWithInt:0];
            } else {
                
                [srchSelector next];
                [srchSelector next];
                
                return [NSNumber numberWithInt:1];
            }
		}
		
		NSDictionary *resultsItem = [resultsArray objectAtIndex:0];
		
		NSString *art         = [resultsItem valueForKey:@"artistName"];
        NSString *artistId    = [resultsItem valueForKey:@"artistId"];
        NSString *artistUrl   = [resultsItem valueForKey:@"artistLinkUrl"];
        
		// マッチ率算出
		NSInteger score = 0;
        
		@try {
            // Artist 単独マッチ率
            score = [super matchArtist:art];
		}
		@catch (NSException * e) {
			return [NSNumber numberWithInt:-201];
		}

        // しきい値以上の場合
        if (score > matchThreshold) {
            
            // Artist 単独マッチ率を上書き
            [artistScore setTotalScore:score];
            
            // 検索結果を上書き
            [srchResult setArtist    :art];
            [srchResult setArtistId  :artistId];
            [srchResult setArtistUrl :artistUrl];
            
            //NSLog(@"## 1st_ artist: %d (%@)", (int)artistScore.totalScore, srchResult.artist);

        } else {
            //NSLog(@"## 1st_ artist: %d (%@)", (int)score, art);

            if (resultScore.totalScore == 0) {
                
                return [NSNumber numberWithInt:0];
            } else {
                
                [srchSelector next];
                [srchSelector next];
                
                return [NSNumber numberWithInt:1];
            }
        }
    }
	@catch (NSException * e) {
		return [NSNumber numberWithInt:-200];
	}
	
	return [NSNumber numberWithInt:1];
}

// For Top Songs (JSON)
- (NSNumber *) analyze2:(id)aData {
    
#ifdef SS_DEBUG_STORE
    NSLog(@"DEBUG 2nd: %.2f", (float)[srchSelector accessTimeForIndex:2]);
#endif
    
	@try {
		NSDictionary *jsonDict = [super getJsonRootElement:aData];
		
		if (jsonDict == nil) {
			return [NSNumber numberWithInt:-333];
		}
		
		NSString *rCount = [jsonDict objectForKey:@"resultCount"];
		if (rCount) {
			if ([rCount integerValue] == 0) {
                // 第三検索が実行されるよう 1 を返す
				return [NSNumber numberWithInt:1];
			}
		}
		
		NSArray *resultsArray = [jsonDict objectForKey:@"results"];
		
		NSInteger resultsCount = [resultsArray count];
		
		// No Hit の場合: "results":[]
		if (resultsCount == 0) {
            // 第三検索が実行されるよう 1 を返す
			return [NSNumber numberWithInt:1];
		}
		
		NSMutableSet *trackNameSet = [[[NSMutableSet alloc] initWithCapacity:0] autorelease];
        
        SMTrack *trk = [[[SMTrack alloc] init] autorelease];
        
		// Top Songs 格納 (タイトル重複削除)
		int i = 0;
		for (NSDictionary *resultsItem in resultsArray) {
			
			if (i == 10) break;
			
			NSString *kind = [resultsItem valueForKey:@"kind"];
			
			// 第一要素 (アーティスト情報) を除外
			if (![kind isEqualToString:@"song"]) {
				
                //NSString *artistLinkUrl = [resultsItem valueForKey:@"artistLinkUrl"];
                //NSLog(@"Link: %@", artistLinkUrl);
				continue;
			}
			
			NSString *trackName = [resultsItem valueForKey:@"trackName"];

            // 比較用トラック作成
            [trk setTitle:trackName artist:[srchResult artist]];
            
            // メイン部分の単語のみを取得
            trackName = trk.title.mainwords;
            
			// タイトル重複チェック (最初のアイテムを格納し、2番目以降は除外する)
			if (![trackNameSet containsObject:trackName]) {
                
                //------------------------------
                // Top Songs に格納
                //------------------------------
				[[srchResult topSongs] addObject:resultsItem];
                
                
                //------------------------------
                // 検索条件のタイトルと同じか確認
                //------------------------------
                // まだ見つかっていなかったら
                if ([srchResult topSongsIndex] == -1) {
                    
                    // 検索条件と比較
                    int score = [track compare:trk option:SM_COMP_ALL];
                    
                    // マッチ率しきい値を超えていたら
                    if (score >= matchThreshold) {
                        
                        // Top Songs 内のインデックスを記録しておく
                        [srchResult setTopSongsIndex:i];
                        
                        // 第一検索でヒットしていなかったら
                        if (resultScore.totalScore < matchThreshold) {
                            
                            // Top Songs の情報で第一検索の結果を書き換える
                            [self setTitleResult:resultsItem];
                            
                            // スコアも書き換え
                            [resultScore setTotalScore:score];
                            
                            //NSLog(@"+++++++++++++ Saved!! ++++++++");
                        }
                    }
				}
				[trackNameSet addObject:trackName];
                
                //NSLog(@"%2d %@", i, trackName);
                //NSLog([resultsItem valueForKey:@"trackViewUrl"]);
				
				i++;
			} else {
                
                //NSLog(@"removed: %@", trackName);
            }
		}
        //NSLog(@"----------------------");

	}
	@catch (NSException * e) {
		return [NSNumber numberWithInt:-300];
	}
	
	return [NSNumber numberWithInt:1];
}

// For Biography (HTML)
- (NSNumber *) analyze3:(id)aData {

#ifdef SS_DEBUG_STORE
    NSLog(@"DEBUG 3rd: %.2f", (float)[srchSelector accessTimeForIndex:3]);
#endif
    //NSLog(@"%@", [srchResult artistUrl]);
    
    NSError *err = nil;

	NSString *xPath = nil;
	
	@try {
		NSXMLElement *aRootElement = [super getDocRootElement:aData];
		
		if (!aRootElement) return [NSNumber numberWithInt:-444];
		
		// 取得
		xPath = @"//div[@id=\"left-stack\"]/div[@class=\"bio-stats\"]/h5";
        
        NSArray *nodeList = [aRootElement nodesForXPath:xPath error:&err];
        
        if (err) {
            return [NSNumber numberWithInt:-401];
        }

        for (NSXMLNode *node in nodeList) {
            
            NSString *key   = [SSCommon removeSpacesAtBothSides:[node stringValue]];
            
            NSString *value = @"";
            
            NSXMLNode *sibling = [node nextSibling];
            
            if (sibling != nil) {
                
                value = [SSCommon removeSpacesAtBothSides:[sibling stringValue]];
            }
            
            [[srchResult bioStats] addObject:[NSArray arrayWithObjects:key, value, nil]];
            
            //NSLog(@"%@ %@", key, value);
        }

        // Biography 取得
		xPath = @"//div[@id=\"biography\"]/div/p";
        
        NSArray *pArray = [aRootElement nodesForXPath:xPath error:&err];
        
        if (err) {
            return [NSNumber numberWithInt:-402];
        }

        NSMutableArray *pAry = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        
        for (NSXMLNode *p in pArray) {
            [pAry addObject:[p stringValue]];
        }
        
        NSString *bio = [pAry componentsJoinedByString:@"\n"];
        
        [srchResult setBiography:bio];
    }
	@catch (NSException * e) {
		return [NSNumber numberWithInt:-400];
	}
	
	return [NSNumber numberWithInt:1];
}

- (void) setTitleResult:(NSDictionary *)resultsItem {
    
    NSString *ttl         = [resultsItem valueForKey:@"trackName"];
    NSString *url         = [resultsItem valueForKey:@"trackViewUrl"];
    NSString *artworkUrl  = [resultsItem valueForKey:@"artworkUrl60"];
    NSString *trackId     = [resultsItem valueForKey:@"trackId"];
    NSString *numStr      = [resultsItem valueForKey:@"trackNumber"];
    
    NSInteger trackNumber = 0;
    
    if (numStr) {
        trackNumber = [numStr integerValue];
    }
    
    NSString *releaseDate = [resultsItem valueForKey:@"releaseDate"];
    NSString *releaseYear = nil;
    
    if (releaseDate) {
        NSRange range = [releaseDate rangeOfRegex:SMiTunesReleaseDateFormat];
        if (range.length != 0) {
            releaseYear = [releaseDate substringToIndex:4];
            releaseDate = [releaseDate substringToIndex:10];
        }
    }
    
    [srchResult setTitle :ttl];
    [srchResult setUrl   :url];
    [srchResult setArtworkUrl60:artworkUrl];
    [srchResult setTrackId:trackId];
    [srchResult setTrackNumber:trackNumber];
    [srchResult setReleaseYear:releaseYear];
    [srchResult setOthers:resultsItem];
    [srchResult setReleaseDate:releaseDate];
}

@end
