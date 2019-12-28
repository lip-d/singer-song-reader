//
//  SMUtamap.m
//  Singer Song Reader
//
//  Created by Developer on 5/10/14.
//
//

#import "SMUtamap.h"

// メモ
// 検索キーワード: Shift-JIS 変換してURLエンコードする
//
// 第一検索：　自動判定: EUC-JP、Shift-JIS の２種類
//           実際　　: EUC-JP
//           ==> 自動判定結果を無視して、EUC-JP とみなす。
//               (Shift-JIS に誤判定されると、その後の処理で問題が出るため)
// 第二検索：　自動判定: EUC-JP
//           実際　　: UTF-8
//           ==> 自動判定結果を無視して、UTF-8 とみなす。

@implementation SMUtamap

- (id)init {
    self = [super init];
    if (self) {
		
		[super setHtmlChild:self siteName:@"Utamap"];
        
        //-----------------------------
        // - エンコーディング固定
        //-----------------------------
        encodingSetting[0] = @(SS_ENC_AUTO_DETECT);
        encodingSetting[1] = @(NSUTF8StringEncoding);
    }
	return self;
}

- (NSString *) url1 {
    
    NSString *ttlSjis = [track.title urlEncodedShiftJis];
    
//    NSLog(@"## UTF-8 : %@", ttl);
//    NSLog(@"## SJIS  : %@", ttlSjis);
    
	NSString *url = [NSString stringWithFormat:[self urlFormat1], ttlSjis];
	
	return url;
}

- (NSString *) urlFormat1 {
	
    // pattern
    // 1: 前方一致
    // 2: 後方一致
    // 3: 部分一致
    // 4: 完全一致 (大文字・小文字まで一致しなくてはならない)
    
	static NSString * const format = @"http://www.utamap.com/searchkasi.php?searchname=title&word=%@&act=search&search_by_keyword=%%8C%%9F%%26%%23160%%3B%%26%%23160%%3B%%26%%23160%%3B%%8D%%F5&sortname=1&pattern=1";
	
	return format;
}

- (NSString *) targetXPath1 {
	
	static NSString * const target = @"//table//tr/td[@class=\"ct160\"][1]";
	
	return target;
}

- (NSArray *) nodeValue1:(NSXMLNode *)node {
    
	//----------------
	// タイトル取得
	//----------------
	NSString *ttl = [node stringValue];
	
	//NSLog(@"## ttl: |%@|", ttl);

	if (!ttl) return nil;
    
	//----------------
	// アーティスト取得
	//----------------
	NSXMLNode *artistNode = [node nextSibling];
    
	NSString *art = [artistNode stringValue];
	
	//NSLog(@"## art: |%@|", art);
	
    if (!art) return nil;
    
	//----------------
	// URL 取得
	//----------------
    if (node.childCount == 0) return nil;
    
    NSXMLNode *urlNode = [node childAtIndex:0];
    
	NSXMLNode *urlAttr = [(NSXMLElement *)urlNode attributeForName:@"href"];
	
	if (!urlAttr) return nil;
    
	NSString *u = [urlAttr stringValue];
    
    if ([u hasPrefix:@"./"])
        u = [u substringFromIndex:1];
    
    NSString *url = [NSString stringWithFormat:[self urlFormat2], u];
	   
	//NSLog(@"## url: %@", url);
	
	NSArray *values = [NSArray arrayWithObjects:ttl, art, url, nil];
	
	return values;
}

- (NSString *) url2 {
    
    // 検索結果: http://www.utamap.com/showkasi.php?surl=k-110126-312
    
    NSString *unum = [srchResult.url stringByMatching:@"surl=([^&]+)" capture:1L];

    // unum: k-110126-312
    
    NSString *url = [NSString stringWithFormat:@"http://www.utamap.com/phpflash/flashfalsephp.php?unum=%@", unum];

    // 変換後:  http://www.utamap.com/phpflash/flashfalsephp.php?unum=k-110126-312
    
    return url;
}

- (NSString *) urlFormat2 {
    
	static NSString * const format = @"http://www.utamap.com%@";
	
	return format;
}

// aData: プレーンテキスト
- (NSNumber *) analyze2:(id)aData {
    
    NSString *lyr = [super utf8StringFromData:aData];

    if ([lyr length] == 0) return @0;
    
    NSRange range = [lyr rangeOfRegex:@"^.+="];
    
    if (range.location != NSNotFound) {
        
        lyr = [lyr substringFromIndex:range.length];
    }
    
    [srchResult setLyrics:lyr];
    
    return @1;
}

// ダミー
- (NSString *) targetXPath2 {
	return nil;
}

// ダミー
- (NSString *) nodeValue2:(NSXMLNode *)node {
	return nil;
}

@end
