//
//  SMTrack.m
//  Singer Song Reader
//
//  Created by Developer on 13/10/12.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMTrack.h"
#import "SSCommon.h"
#import "RegexKitLite.h"

// タイトル検索文字列の削除対象
// - 末尾の "(XXXX)"
// - 末尾の "[XXXX]"
// - 末尾の空白
// 例: Girl On Fire (Inferno Version) [Radio Edit]

@implementation SMTrack

@synthesize title;
@synthesize artist;

@synthesize urlEncoded;

- (id) init {
    self = [super init];
    if (self) {
		
		title  = [[SMKeyword alloc] init];
		artist = [[SMKeyword alloc] init];
		
		matchCache  = [[NSMutableDictionary alloc] initWithCapacity:0];
	}
	
	return self;
}

- (void)dealloc {
    
	[title  release];
	[artist release];
	[matchCache release];
    [super dealloc];
}

- (void) clear {
	
	[title  clear];
	[artist clear];
	[matchCache removeAllObjects];
}

#pragma mark - Setter

- (void) setTitle:(NSString *)aTitle artist:(NSString *)aArtist {
    
    [title  setKeywords:aTitle];
    [artist setKeywords:aArtist];
    
	// キャッシュをクリア
	[matchCache removeAllObjects];
}

#pragma mark - Getter

- (NSString *) urlEncoded {
    
    static NSString * const fmt = @"%@%%20%@";
    
	NSString *term = [SSCommon joinString:artist.urlEncoded withString:title.urlEncoded format:fmt];

    return term;
}

- (NSArray *) allwordsArray {
    
    NSArray *array =  [title.allwordsArray arrayByAddingObjectsFromArray:artist.allwordsArray];
    
    return array;
}

- (NSArray *) subwordsArray {
    
    NSArray *array = [title.subwordsArray arrayByAddingObjectsFromArray:artist.subwordsArray];
    
    return array;
}

- (NSInteger) allwordsLength {

    return title.allwordsLength + artist.allwordsLength;
}

- (NSArray *) arrayArray {
    
    return [NSArray arrayWithObjects:title.mainwordsArray, title.subwordsArray, artist.mainwordsArray, artist.subwordsArray, nil];
}

- (BOOL) isJapanese {
    
    if (title.isJapanese || artist.isJapanese)
        return YES;
    else
        return NO;
}

#pragma mark - Compare

//------------------------------------
// タイトル、アーティスト比較
//------------------------------------
- (NSInteger) compare:(SMTrack *)aTrack option:(SMCompareOption)option {
    
    NSArray *searcher    = nil;
    NSArray *searched    = nil;
    
    NSString *key;
    
    // タイトル、アーティスト比較
    if (option == SM_COMP_ALL) {
        
        static NSString * const fmt = @"%@ %@";
        
        //-----------------------------
        // キャッシュがあればそれを使う
        //-----------------------------
        key = [SSCommon joinString:aTrack.title.original
                        withString:aTrack.artist.original format:fmt];
        
        NSNumber *value = [matchCache valueForKey:key];
        
        if (value) {
            //NSLog(@"+++ Cache match: %@", key);
            
            return [value integerValue];
        }
        
        searcher    = aTrack.arrayArray;
        searched    =   self.arrayArray;
	}
    // タイトルのみ比較
    else if (option == SM_COMP_TTL) {
        
        searcher    = aTrack.title.arrayArray;
        searched    =   self.title.arrayArray;
    }
    // アーティストのみ比較
    else if (option == SM_COMP_ART) {
        
        searcher    = aTrack.artist.arrayArray;
        searched    =   self.artist.arrayArray;
    }
    
    // 比較実行
	NSInteger ratio = [SMTrack compareArrayArray:searcher searched:searched searcherFilter:YES searchedFilter:YES searchedRest:nil scoreWithoutRest:NO];
    
    // タイトル末尾に数字がある場合の比較精度アップ　(v3.8)
    if (option == SM_COMP_ALL || option == SM_COMP_TTL) {
        
        NSNumber *no1 = aTrack.title.withNo;
        NSNumber *no2 = self.title.withNo;
        
        BOOL diff = NO;
        if      (no1 && !no2) diff = YES;
        else if (!no1 && no2) diff = YES;
        else if (no1 && no2) {
            if ([no1 isEqualToNumber:no2] == NO)
                diff = YES;
        }
        
        if (diff) {

            ratio = ratio - (100 - SSNormalMatchThreshold);
            
            if (ratio < 0) ratio = 0;
        }
    }
    
    
    // タイトル、アーティスト比較の場合
    if (option == SM_COMP_ALL) {
        
        NSNumber *value = [NSNumber numberWithInteger:ratio];
        
        // キャッシュに格納
        [matchCache setValue:value forKey:key];
    }
    
    return ratio;
}

//---------------------------------------------------------------
// Matching 実処理
//
// searcher : 検索結果
// searched : 検索条件
//
// 検索結果から見て、検索条件にどれくらいマッチしているかをチェックする。
//
// searcher 側
//   - 不一致単語数が 1 つを超えると 0 ポイント化                 (フィルタ1)
//   - 不一致単語の長さが　 3 文字を超えるものがあると　-20 ポイント (フィルタ2)
//
// searched 側
//   - 不一致単語の合計長が 3 文字を超えると          -20 ポイント (フィルタ2)
//
// searcher/searched 共通
//   - () や [] 内に不一致単語がある場合、その単語数分 -1 ポイント
//
//---------------------------------------------------------------
+ (NSInteger) compareArrayArray:(NSArray *)searcher searched:(NSArray *)searched searcherFilter:(BOOL)searcherFilter searchedFilter:(BOOL)searchedFilter searchedRest:(NSString **)searchedRest scoreWithoutRest:(BOOL)scoreWithoutRest {
    
    // 元の合計長
    float originalLen =
    [SSCommon lengthOfArrayArray:searcher] +
    [SSCommon lengthOfArrayArray:searched];
    
    NSInteger wc0 = 0; // タイトルの    mainwords 一致数
    NSInteger wc2 = 0; // アーティストの mainwords 一致数
    
    // カッコ内で削除した単語数
    NSInteger rc = 0;
    
    NSMutableArray *searcherTmp = [self arrayTmp:searcher];
    NSMutableArray *searchedTmp = [self arrayTmp:searched];
    
    NSInteger searcherRemoveCount = 0;
    
	NSInteger idx = 0;
	
    //--------------------------------------------
    // カッコ内外に関わらず、一致する単語を探して削除する
    //--------------------------------------------
#ifdef SS_DEBUG_MATCH_RATIO_DETAIL
    NSLog(@"DEBUG Phase 1");
#endif
    int i = 0;
    int t = 0; // Total index
	for (NSArray *ary in searcher) {
        
        for (NSString *word in ary) {
            
            // 検索
            idx = [searchedTmp indexOfObject:word];
            
            // 見つかったら
            if (idx != NSNotFound) {

                // 相手側を削除
                [searchedTmp removeObjectAtIndex:idx];
                
                // 自分側は空置換
                [searcherTmp replaceObjectAtIndex:t withObject:@""];
                
                searcherRemoveCount++;
                
                if      (i == 0) wc0++; // タイトルの    mainwords 一致
                else if (i == 2) wc2++; // アーティストの mainwords 一致
            }
            
            t++;
        }
        
        i++;
	}
    
    //--------------------------------------------
    // カッコ内文字列と一致するものが残っていたら削除する
    //--------------------------------------------
    
    // 削除した単語の合計長
    int removed = 0;
    
    // 自分側
    if (searcherTmp.count != searcherRemoveCount) {
        
#ifdef SS_DEBUG_MATCH_RATIO_DETAIL
        NSLog(@"DEBUG Phase 2");
#endif
        i = 0;
        t = 0;
        for (NSArray *ary in searcher) {
            
            // subwords array のみ処理
            if (i == 1 || i == 3) {
                
                // subwords の単語取出し
                for (NSString *word in ary) {
                    
                    // まだ残っているか調べる
                    idx = [searcherTmp indexOfObject:word];
                    
                    // 残っていたら
                    if (idx != NSNotFound) {
                        
#ifdef SS_DEBUG_MATCH_RATIO_DETAIL
                        NSLog(@"DEBUG removed: %@", word);
#endif
                        // 自分側を空置換
                        [searcherTmp replaceObjectAtIndex:t withObject:@""];
                        searcherRemoveCount++;
                        removed += [word length];
                        rc++;
                    }
                    t++;
                }
            } else {
                
                t += [ary count];
            }
            
            i++;
        }
    }
    
    // 相手側
    if ([searchedTmp count]) {
        
#ifdef SS_DEBUG_MATCH_RATIO_DETAIL
        NSLog(@"DEBUG Phase 2'");
#endif
        i = 0;
        for (NSArray *ary in searched) {

            // subwords の array のみ処理
            if (i == 1 || i == 3) {
                
                // subwords の単語取出し
                for (NSString *word in ary) {
                    
                    // まだ残っているか調べる
                    idx = [searchedTmp indexOfObject:word];
                    
                    // 残っていたら
                    if (idx != NSNotFound) {
                        
#ifdef SS_DEBUG_MATCH_RATIO_DETAIL
                        NSLog(@"DEBUG removed: %@", word);
#endif
                        // 相手側から削除
                        [searchedTmp removeObjectAtIndex:idx];
                        removed += [word length];
                        rc++;
                    }
                }
            }
            i++;
        }
    }
    
    //---------------------------------------------
    // 複合単語対応 (例: One Republic と OneRepublic)
    //---------------------------------------------

    // 相手側を区切り文字なしで結合し、一致単語を探す
    NSMutableString *searchedStr = [[[NSMutableString alloc] initWithCapacity:0] autorelease];
    
    [searchedStr setString:[searchedTmp componentsJoinedByString:SSEmpty]];

    // 未一致の単語が残っていた場合
    if (searcherTmp.count != searcherRemoveCount) {
        
#ifdef SS_DEBUG_MATCH_RATIO_DETAIL
        NSLog(@"DEBUG Phase 3");
#endif
        
        i = 0;
        t = 0;
        
        for (NSArray *ary in searcher) {
            
            int count = [ary count];
            
            for (int j=0; j<count; j++) {
                
                NSString *word = [searcherTmp objectAtIndex:t];
                
                // ローマ字を考慮し、3文字を2文字に変更 (V3.4)
                // ここを減らす代わりに、LooseMatch のしきい値を 20から40へ引き上げてバランス調整
                
                // 2文字以上の単語が残っていたら (2文字: 単語として見なせる最短長)
                if (word.length >= 2) {
                    
                    // 文字列内で一致箇所を検索
                    NSRange range = [searchedStr rangeOfString:word];
                    
                    if (range.length > 0) {
                        
                        // NSLog(@"## match: %@", word);
                        
                        // 相手側から削除
                        [searchedStr deleteCharactersInRange:range];
                        
                        // 自分側を空置換
                        [searcherTmp replaceObjectAtIndex:t withObject:@""];
                        
                        if      (i == 0) wc0++; // タイトルの    mainwords 一致
                        else if (i == 2) wc2++; // アーティストの mainwords 一致
                    } else {
                        
#ifdef SS_DEBUG_MATCH_RATIO_DETAIL
                        NSLog(@"DEBUG rest: %@", word);
#endif                    
                    }
                }
                
                t++;
            }
            
            i++;
        }
    }
    
    // マッチしなかった部分の合計長
    float unmatchedLen;
    
    if (scoreWithoutRest)
        unmatchedLen = [SSCommon lengthOfArray:searcherTmp];
    else
        unmatchedLen = [SSCommon lengthOfArray:searcherTmp] + searchedStr.length;
    
    // カッコ文字列を削除した分を差し引いて100%マッチの全体長とする
    originalLen -= removed;
    
    float matchedLen = originalLen - unmatchedLen;
    
    //NSLog(@"## unmatchedLen %d", unmatchedLen);
	
	float fRatio = (matchedLen / originalLen) * 100;
	
    // 一致率暫定値
	NSInteger ratio = (NSInteger)fRatio;

    // 返却値に searched の余りをセット
    if (searchedRest != nil)
        *searchedRest = searchedStr;
    
    //------------------------------------
    // 暫定値の段階で 0 の場合は、ここで終わり
    //------------------------------------
    if (ratio == 0) return 0;
    
    
    // 一致率確定値
    NSInteger total = 0;
    
    //---------------------------
    // フィルタリング
    //---------------------------
    
    BOOL flag = NO;
    
    NSArray *array0 = [searcher objectAtIndex:0];
    
    if (searcherFilter) {
        
        // タイトル、アーティスト両方比較の場合
        if (searcher.count == 4) {
            
            NSArray *array2 = [searcher objectAtIndex:2];
            
            //-----------------------------------------------
            // フィルタ1) 不一致単語数チェック: -1 単語まで許容
            //-----------------------------------------------
            // タイトル
            if ([self isValid:array0 wordsHit:wc0] == NO) flag = YES;
            
            // タイトルでクリアした場合
            if (flag == NO) {
                
                // アーティスト
                if ([self isValid:array2 wordsHit:wc2] == NO) flag = YES;
            }

#ifdef SS_DEBUG_MATCH_RATIO_DETAIL
            NSLog(@"DEBUG ttl: %ld/%ld art: %ld/%ld (%ld)",
                  wc0, array0.count,
                  wc2, array2.count, rc);
#endif
        }
        // タイトル又はアーティストのみ比較の場合
        else {
            
            //-----------------------------------------------
            // フィルタ1) 不一致単語数チェック: -1 単語まで許容
            //-----------------------------------------------
            // タイトル又はアーティスト
            if ([self isValid:array0 wordsHit:wc0] == NO) flag = YES;
            
#ifdef SS_DEBUG_MATCH_RATIO_DETAIL
            NSLog(@"DEBUG art: %ld/%ld (%ld)",
                  wc0, array0.count, rc);
#endif
        }
    }
    
    // フィルタ1 をクリアした場合
    if (flag == NO) {
        
        //-----------------------------------------------
        // フィルタ2) 不一致単語長さチェック: 3 文字まで許容
        //-----------------------------------------------
        if (searchedFilter) {
            
            // Searched (検索条件)
            if (searchedStr.length > 3) {
                
                flag = YES;
            }
        }
        
        if (searcherFilter && flag == NO) {
            
            // Searcher (検索結果)
            for (NSString *word in searcherTmp) {
                
                if (word.length > 3) {
                    
                    flag = YES;
                    break;
                }
            }
        }
        
        // フィルタ2 をクリアした場合
        if (flag == NO) {
            
            total = ratio - rc;
        }
        // フィルタ2 をクリアできなかった場合
        else {

            // 減点 -20
            NSInteger deduction = 100 - SSNormalMatchThreshold;
            
            total = ratio - rc - deduction;
        }
        
    }
    // フィルタ1 をクリアできなかった場合
    else {
        
        total = 0;
    }
    
    // マイナス値防止
    if (total < 0) total = 0;
    
    return total;
}

+ (BOOL) isValid:(NSArray *)array wordsHit:(NSInteger)wc {
    
    NSInteger arrayCount = [array count];

    NSInteger threshold  = 0;
    
    if (arrayCount > 0) {
        
        if (arrayCount == 1) {
            
            threshold = 1;
        }
        else {
            
            threshold = arrayCount - 1;
        }
    }
    
    if (wc < threshold) {
        
        return NO;
    } else {
        
        
        
        return YES;
    }
}

+ (NSMutableArray *) arrayTmp:(NSArray *)arrayArray {
    
    int cnt = 0;
    
    cnt = [SSCommon countOfArrayArray:arrayArray];
    NSMutableArray *tmpArray = [[[NSMutableArray alloc] initWithCapacity:cnt] autorelease];

    for (NSArray *ary in arrayArray) {
        
        [tmpArray addObjectsFromArray:ary];
    }
    
    return tmpArray;
}


@end
