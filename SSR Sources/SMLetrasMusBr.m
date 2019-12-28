//
//  SMLetrasMusBr.m
//  Singer Song Reader
//
//  Created by Developer on 2013/12/17.
//
//

#import "SMLetrasMusBr.h"

@implementation SMLetrasMusBr

- (id)init {
    self = [super init];
    if (self) {
		
		[super setJsonChild:self siteName:@"LetrasMusBr"];
        
        // V3.1 文字化け対処
        //-----------------------------
        // - エンコーディング固定
        //-----------------------------
        encodingSetting[0] = @(NSUTF8StringEncoding);
        encodingSetting[1] = @(NSUTF8StringEncoding);
	}
	return self;
}

- (NSString *) urlFormat1 {
	
    // 追加: hl=pt_PT (v3.7)
    // hl(表示言語)によって検索結果が変わってくる
    static NSString * const format = @"https://www.googleapis.com/customsearch/v1element?key=AIzaSyCVAXiUzRYsML1Pv6RwSG1gunmMikTzQqY&num=10&hl=pt_PT&cx=partner-pub-9911820215479768:4038644078&q=%@";
//    static NSString * const format = @"https://www.googleapis.com/customsearch/v1element?key=AIzaSyCVAXiUzRYsML1Pv6RwSG1gunmMikTzQqY&rsz=20&num=20&hl=pt_PT&prettyPrint=false&source=gcsc&gss=.br&sig=23952f7483f1bca4119a89c020d13def&cx=partner-pub-9911820215479768:4038644078&q=%@&googlehost=www.google.com";
	
	return format;
}

- (NSString *) targetKey1 {
    
    static NSString * const key = @"results";
    
    return key;
}

- (NSArray *) itemValue1:(NSDictionary *)item {
    
    
    // Debug
    
    //NSLog(@"-------------------------------------");
//     for (NSString * key in [item allKeys]) {
//         NSLog(@"## %@ : %@", key, [item valueForKey:key]);
//     }
    

	//----------------
	// URL 取得
	//----------------
	NSString *url = [item valueForKey:@"url"];
    
    if (!url) return nil;
	
	//NSLog(@"## url: %@", url);
	
	// Lyrics とそれ以外を判別する
	//   Lyrics の場合の形式: http://letras.mus.br/u2/XXX/
	//   それ以外の形式例    : http://letras.mus.br/u2/XXX/traducao.html
    //                      http://letras.mus.br/jan-and-dean/discografia/

    // (v3.6 修正) XXX の部分は数字のみとは限らない。アーティスト名が入る場合も考慮する。
    //	static NSString * const regex = @"^http://letras.mus.br/.+/[0-9]+/$";
//    static NSString * const regex = @"^https://letras.mus.br/.+/.+/$";
    // (v4.2) http と https の両方に対応するため、先頭の http: をなくす
//    static NSString * const regex = @"//letras.mus.br/.+/.+/$";

    // (v4.5) www.letras.mus.br にも対応するため、"//"をなくす
    static NSString * const regex = @"letras.mus.br/.+/.+/$";
	NSRange range = [url rangeOfRegex:regex];
	
	if (range.location == NSNotFound) {

//        NSLog(@"## (Skip: %@)", url);
        return nil;
	}
	
    // (v3.6 修正) discografia を除外する
    if ([url hasSuffix:@"/discografia/"]) {
//        NSLog(@"## (Skip discofrafia: %@)", url);
        return nil;
    }
    
//    NSLog(@"## url: %@", url);
    
    //---------------------------
    // タイトル、アーティスト取得
    // V3.0 修正
    //---------------------------
/*
    NSDictionary *richSnippet    = [item        valueForKey:@"richSnippet"];
    NSDictionary *musicrecording = [richSnippet valueForKey:@"musicrecording"];

    NSString *ttl = [musicrecording valueForKey:@"name"];
    
    NSLog(@"+++++++++++ ttl: %@", ttl);

    if (![ttl isKindOfClass:[NSString class]]) return nil;
    
	NSString *art = [musicrecording valueForKey:@"byartist"];

    NSLog(@"+++++++++++ art: %@", art);

    if (![art isKindOfClass:[NSString class]]) return nil;
*/
    
    
    //---------------------------
	// タイトル、アーティスト取得
	// 例: ONE - U2 | Letras.mus.br
    // V4.1 (以前の方法に戻す)
	//---------------------------
	NSString *tnf = [item valueForKey:@"titleNoFormatting"];
	
	if (!tnf) return nil;
    
    //NSLog(@"tnf: %@", tnf);
	
	static NSString * const regex2 = @"^(.+) - (.+) \\| Letras\\.mus\\.br$";
	
	NSString *ttl = nil;
	NSString *art = nil;

    BOOL matched = NO;
    
	// 正規表現に一致するか
	if ([tnf isMatchedByRegex:regex2]) {
		
		// タイトル取得
		ttl = [tnf stringByMatching:regex2 capture:1L];
		
		// アーティスト取得
		art = [tnf stringByMatching:regex2 capture:2L];
		
        matched = YES;
	}
    
    // (v4.2)
    //------------------------------
    // タイトル、アーティスト取得 (その２)
    // 例: "One – U2 – LETRAS.MUS.BR"
    //------------------------------
    if (matched == NO) {

        // "–", "-", "|" のすべてに対応する
        static NSString * const regex3 = @"^(.+) [–-] (.+) [–|-] ";

        // 正規表現に一致するか
        if ([tnf isMatchedByRegex:regex3]) {
            
            // タイトル取得
            ttl = [tnf stringByMatching:regex3 capture:1L];
            
            // アーティスト取得
            art = [tnf stringByMatching:regex3 capture:2L];
            
            matched = YES;
        }
    }
    
    if (matched == NO) return nil;
    
    //NSLog(@"## ttl: %@", ttl);
    //NSLog(@"## art: %@", art);
    
	NSArray *values = [NSArray arrayWithObjects:ttl, art, url, nil];
	
	return values;
}

- (NSString *) targetXPath2 {
	
    // メモ (v3.0 修正)
    // Safari や FireFox の Web 開発ツールで HTML ソースを見ると
    // <div id="div_letra"> というタグがあるが、実際に取得したデータを見るとない。
    // 実際のデータでは、一つ上位のタグ <div id="main_cnt"> が Lyrics の
    // 親タグになっている。
    
    // メモ (追記: v3.6)
    // <div id="main_cnt"> の下に <div id="div_letra"> がある場合とない場合が
    // あるらしい。ない場合に備えて、取得タグは親タグ <div id="main_cnt"> のままにしておく。
    
//	static NSString * const target = @"//div[@id=\"div_letra\"]";
//    static NSString * const target = @"//div[@id=\"main_cnt\"]";
    // V4.1
//    static NSString * const target = @"//div[@class=\"cnt-letra\"]";

    // (V4.2) 以下の両方に対応する
    // div class="cnt-letra"
    // div class="cnt-letra p402_premium"
    static NSString * const target = @"//div[contains(@class,\"cnt-letra\")]";

    return target;
}

- (NSString *) nodeValue2:(NSXMLNode *)node {
    
	NSError *err = nil;
	
    // メモ (v3.0 修正)
    // <div id="main_cnt">
    //   <div id="div_letra"> --- ある場合と、ない場合がある？　どちらでも対応できるようにする。
    //     <p></p>
    //     <p></p>
    //     <p></p>
//    NSArray  *pArray = [node nodesForXPath:@"p" error:&err];

    // まずは、<div id="div_letra"> があるかどうか探す
/*
    NSString *xPath = @".//div[@id=\"div_letra\"]";
    NSXMLNode *div_letra = [super firstNodeForXPath:xPath baseNode:node];
    
    // あれば起点ノードを上書き
    if (div_letra != nil) {
        node = div_letra;
    }
*/
    NSArray  *pArray = [node nodesForXPath:@"p" error:&err];
	
    if (err) return nil;
	
    NSMutableArray *pAry = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
	
	for (NSXMLNode *p in pArray) {
		[pAry addObject:[p stringValue]];
}
	
	NSString *lyr = [pAry componentsJoinedByString:@"\n"];

    
	return lyr;
}

@end
