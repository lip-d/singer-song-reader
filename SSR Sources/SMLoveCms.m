//
//  SMLoveCms.m
//  Singer Song Reader
//
//  Created by Developer on 2013/12/18.
//
//

#import "SMLoveCms.h"

@implementation SMLoveCms

- (id)init {
    self = [super init];
    if (self) {
		
		[super setJsonChild:self siteName:@"LoveCms"];
	}
	return self;
}

- (NSString *) urlFormat1 {
	
	static NSString * const format = @"https://www.googleapis.com/customsearch/v1element?key=AIzaSyCVAXiUzRYsML1Pv6RwSG1gunmMikTzQqY&num=10&cx=008826193304088922367:qdfmnorblj0&q=%@";
	
	return format;
}

- (NSString *) targetKey1 {
    
    static NSString * const key = @"results";
    
    return key;
}

- (NSArray *) itemValue1:(NSDictionary *)item {
	
	//----------------
	// URL 取得
	//----------------
	NSString *url = [item valueForKey:@"url"];
	
	if (!url) return nil;
	
	//NSLog(@"## url: %@", url);
		
	//---------------------------
	// タイトル、アーティスト取得
	// 例: Madonna - Like A Virgin Lyrics 歌詞、動画|愛の無料洋楽歌詞検索
	//---------------------------
	NSString *tnf = [item valueForKey:@"titleNoFormatting"];
	
	if (!tnf) return nil;
	
	static NSString * const regex2 = @"^(.+) - (.+) Lyrics ";
	
	NSString *ttl = nil;
	NSString *art = nil;
	
	// 正規表現に一致するか
	if ([tnf isMatchedByRegex:regex2]) {
		
		// タイトル取得
		ttl = [tnf stringByMatching:regex2 capture:2L];
		
		//NSLog(@"## ttl: %@", ttl);
		
		// アーティスト取得
		art = [tnf stringByMatching:regex2 capture:1L];
		
		//NSLog(@"## art: %@", art);
	} else {
		
		return nil;
	}
	
	NSArray *values = [NSArray arrayWithObjects:ttl, art, url, nil];
	
	return values;
}

- (NSString *) targetXPath2 {
	
	static NSString * const target = @"//div[@id=\"contDiv\"]";
	
	return target;
}

- (NSString *) nodeValue2:(NSXMLNode *)node {
	
	NSString *lyr = [node stringValue];
	
	return lyr;
}

@end
