//
//  SMKeyword.m
//  Singer Song Reader
//
//  Created by Developer on 13/10/12.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMKeyword.h"
#import "SSCommon.h"

@interface SMKeyword()
@property (readwrite, retain) NSString *original;
@property (readwrite, retain) NSString *normalized;
@property (readwrite, retain) NSString *urlEncoded;
@property (readwrite, retain) NSNumber *withNo;
@property (readwrite, retain) NSArray  *mainwordsArray;
@property (readwrite, retain) NSArray  *subwordsArray;
@end

@implementation SMKeyword

@synthesize original;
@synthesize normalized;
@synthesize urlEncoded;
@synthesize withNo;
@synthesize mainwordsArray;
@synthesize subwordsArray;

- (id) init {
    self = [super init];
    if (self) {
        
		original       = nil;
		normalized     = nil;
		urlEncoded     = nil;
        mainwordsArray = nil;
        subwordsArray  = nil;
        withNo         = nil;
        _isJapanese    = -1;
	}
	
	return self;
}

- (void)dealloc {
    
    if (original      ) [original       release];
    if (normalized    ) [normalized     release];
    if (urlEncoded    ) [urlEncoded     release];
    if (withNo        ) [withNo         release];
    if (mainwordsArray) [mainwordsArray release];
    if (subwordsArray ) [subwordsArray  release];
    
    [super dealloc];
}

- (void) clear {
    
    [self setOriginal      :nil];
    [self setNormalized    :nil];
    [self setUrlEncoded    :nil];
    [self setWithNo        :nil];
    [self setMainwordsArray:nil];
    [self setSubwordsArray :nil];
    _isJapanese = -1;
}

#pragma mark - Setter

- (void) setKeywords:(NSString *)keywords {
    
    if (keywords == nil) {
        
        [self clear];
        return;
    }
    
    _isJapanese = -1;
    
    // 両端空白類削除
    keywords = [SSCommon removeSpacesAtBothSides:keywords];
    
    //----------------------
    // オリジナル格納
    //----------------------
    [self setOriginal:keywords];
    
    // メイン部分と末尾カッコ部分に分割
    NSArray  *array     = [SSCommon separateBrackets:keywords];
    NSString *mainwords = [array objectAtIndex:0];
    NSString *subwords  = [array objectAtIndex:1];
    
    // "XXX (1983) [Radio Edit]" のようなカッコが二つ連続する場合があるため、
    // もう一度分割を試みる
    array                = [SSCommon separateBrackets:mainwords];
    NSString *mainwords2 = [array objectAtIndex:0];
    NSString *subwords2  = [array objectAtIndex:1];
    
    if (subwords2.length > 0) {
        
        mainwords = mainwords2;
        subwords = [SSCommon joinString:subwords
                             withString:subwords2 format:@"%@ %@"];
    }
    
    //------------------------------------------
    // 検索用正規化/URL エンコード＋格納
    // (メイン部分のみ)
    //------------------------------------------
    [self setNormalizedAndUrlEncoded:mainwords];
    
    //------------------------------------------
    // 比較用正規化＋格納
    // (メイン部分、カッコ部分)
    //------------------------------------------
    [self setWords:mainwords subwords:subwords];
}

#pragma  mark - Getter

// 比較用文字列の全体長を返す
- (NSInteger) allwordsLength {
    
    int len = 0;
    for (NSString *str in self.allwordsArray) {
        
        len += str.length;
    }
    
    return len;
}

// 比較用文字列のメイン部分を返す
- (NSString *) mainwords {
 
    return [mainwordsArray componentsJoinedByString:SSBlank];
}

// 比較用文字列のメイン部分、カッコ部分すべてを Array で返す
- (NSArray *) allwordsArray {
    
    if ([subwordsArray count] == 0) {
    
        return mainwordsArray;
    }
    else {
        
        return [mainwordsArray arrayByAddingObjectsFromArray:subwordsArray];
    }
}

// main と sub を Array の入れ子で返す。[0] mainwordsArray, [1] subwordsArray
- (NSArray *) arrayArray {
    
    return [NSArray arrayWithObjects:mainwordsArray, subwordsArray, nil];
}

// 日本語判定 (V3.4)
// iTunes の検索パラメタ lang を決定するために使用
- (BOOL) isJapanese {
    
    if (_isJapanese == -1) {
        
        BOOL isJp = [original containsJapaneseKanaOrKanji];

        // キャッシュに格納
        if (isJp) _isJapanese = 1;
        else      _isJapanese = 0;
    }
    
    return (BOOL)_isJapanese;
}

#pragma mark - Private

//---------------------------------
// 検索用正規化 (メイン部分のみ)
// 1) 記号類削除 ("'" 残す)
//---------------------------------
- (void) setNormalizedAndUrlEncoded:(NSString *)string {
    
    // 1) 記号類削除 ("'" 残す)
    [self setNormalized:[SSCommon removeSymbols:string removeSQuate:NO]];
    
    //NSLog(@"## norm %@", normalized);
    
    // URL エンコード (検索用文字列を使用)
    [self setUrlEncoded:[SSCommon urlEncode:normalized]];
    
    //NSLog(@"## enc  %@", urlEncoded);
}

//---------------------------------
// 比較用正規化 (メイン部分、カッコ部分共通)
// 1) 記号類削除 ("'" 削除)
// 2) アクセント除去＋小文字化
//---------------------------------
- (NSArray *) makeArray:(NSString *)words {
    
    if ([words length] == 0) return [NSArray array];
    
    // 1) 記号類削除 ("'" 削除)
    words = [SSCommon removeSymbols:words removeSQuate:YES];
    
    // 2) アクセント除去＋小文字化
    words = [SSCommon removeAccents:words];
    
    if ([words length] == 0) return [NSArray array];

    // 空白分割で Array 化
    NSArray *array = [words componentsSeparatedByString:SSBlank];
    
    return array;
}

//---------------------------------
// 比較用正規化 (メイン部分、カッコ部分)
//---------------------------------
- (void) setWords:(NSString *)mainwords subwords:(NSString *)subwords {
    
    //---------------------------------
    // 比較用正規化 (メイン部分)
    //---------------------------------
    [self setMainwordsArray:[self makeArray:mainwords]];
    
    // メイン部分最後の単語が数字の場合、それを withNo に覚えておく
    NSString *last = [SSCommon convertRomanNumber:mainwordsArray.lastObject];
    NSNumber *num  = [SSCommon convertToNumber:last];
    
    [self setWithNo:num];
    
    //---------------------------------
    // 比較用正規化 (カッコ部分)
    //---------------------------------
    [self setSubwordsArray:[self makeArray:subwords]];
}

- (NSString *) urlEncodedShiftJis {
    
    return [SSCommon urlEncode:normalized targetEncoding:kCFStringEncodingShiftJIS];
}

@end
