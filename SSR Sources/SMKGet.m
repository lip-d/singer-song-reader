//
//  SMKGet.m
//  Singer Song Reader
//
//  Created by Developer on 2014/02/23.
//
//

#import "SMKGet.h"

@implementation SMKGet

- (id)init {
    self = [super init];
    if (self) {
		
		[super setHtmlChild:self siteName:@"KashiGet"];

        //-----------------------------
        // - エンコーディング固定
        //-----------------------------
        encodingSetting[0] = @(NSUTF8StringEncoding);
        encodingSetting[1] = @(NSUTF8StringEncoding);
	}
	return self;
}

- (NSString *) url1 {
    
    NSString *ttl = track.title.urlEncoded;
	NSString *art = track.artist.urlEncoded;

	NSString *url = [NSString stringWithFormat:[self urlFormat1], art, ttl];
	
	return url;
}

- (NSString *) urlFormat1 {
	
	static NSString * const format = @"http://www.kget.jp/search/index.php?c=0&r=%@&t=%@&v=&f=";
	
	return format;
}

- (NSString *) targetXPath1 {
	
	static NSString * const target = @"//div[@id=\"search-result\"]//div[@class=\"title-wrap cf\"]";
	
	return target;
}

- (NSArray *) nodeValue1:(NSXMLNode *)node {
    
	NSError *err = nil;
	
	NSArray *ttl_art = [node nodesForXPath:@".//a" error:&err];
	
	if (err) return nil;
	
	if ([ttl_art count] != 2) return nil;
    
	//----------------
	// タイトル取得
	//----------------
	NSXMLNode *titleNode = [ttl_art objectAtIndex:0];
	
	NSString *ttl = [titleNode stringValue];
	
//	NSLog(@"## ttl before: %@", ttl);
	
    // タイトル末尾の日本語タイトル削除 (V3.4)
    NSArray *ttlComponents;
    
    ttlComponents = [ttl captureComponentsMatchedByRegex:@"(.+) / (.+)"];

    if (ttlComponents.count != 3) {
        
        ttlComponents = [ttl captureComponentsMatchedByRegex:@"(.+) \\((.+)\\)"];
    }
    

    if (ttlComponents.count == 3) {
        
        NSString *main = ttlComponents[1];
        NSString *sub = ttlComponents[2];
        
        if (![main containsJapaneseKanaOrKanji] && [sub containsJapaneseKanaOrKanji])
            ttl = main;
    }
    
//	NSLog(@"## ttl after : %@", ttl);

	//----------------
	// アーティスト取得
	//----------------
	NSXMLNode *artistNode = [ttl_art objectAtIndex:1];
    
	NSString *art = [artistNode stringValue];
	
	//NSLog(@"## art: %@", art);
	
	//----------------
	// URL 取得
	//----------------
	NSXMLNode *urlAttr = [(NSXMLElement *)titleNode attributeForName:@"href"];
	
	if (!urlAttr) return nil;
    
	NSString *url = [urlAttr stringValue];
	
    url = [NSString stringWithFormat:[self urlFormat2], url];
    
	//NSLog(@"## url: %@", url);
	
	NSArray *values = [NSArray arrayWithObjects:ttl, art, url, nil];
	
	return values;
}

- (NSString *) urlFormat2 {
	
	static NSString * const format = @"http://www.kget.jp%@";
	
	return format;
}

- (NSString *) targetXPath2 {
	
	static NSString * const target = @"//div[@id=\"lyric-trunk\"]";
	
	return target;
}

- (NSString *) nodeValue2:(NSXMLNode *)node {
	
	NSString *lyr = [node stringValue];
    
	return lyr;
}

@end
