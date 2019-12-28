//
//  SMGenius.m
//  Singer Song Reader
//
//  Created by Developer on 2013/12/17.
//
//

#import "SMGenius.h"

@implementation SMGenius

- (id)init {
    self = [super init];
    if (self) {
		
		[super setHtmlChild:self siteName:@"Genius"];
        
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
    
    NSString *url = [NSString stringWithFormat:[self urlFormat1], ttl, art];
    
    return url;
}

- (NSString *) urlFormat1 {
	
    static NSString * const format = @"http://genius.com/search?q=%@+%@";
	
	return format;
}

- (NSString *) targetXPath1 {
	
	static NSString * const target = @"//li[@class=\"search_result\"]";
	
	return target;
}

- (NSArray *) nodeValue1:(NSXMLNode *)node {
	
//    NSLog(@"### %@", node);
    
	//----------------
	// タイトル取得
	//----------------
	NSXMLNode *titleNode = [super firstNodeForXPath:@".//span[@class=\"song_title\"]" baseNode:node];
	
	if (!titleNode) return nil;
	
	NSString *ttl = [titleNode stringValue];
		
	//NSLog(@"## ttl: %@", ttl);
	
	//----------------
	// アーティスト取得
	//----------------
	NSXMLNode *artistNode = [super firstNodeForXPath:@".//span[@class=\"artist_name\"]" baseNode:node];
	
	if (!artistNode) return nil;
	
	NSString *art = [artistNode stringValue];
	
	//NSLog(@"## art: %@", art);
	
	//----------------
	// URL 取得
	//----------------
    NSXMLNode *aNode = [super firstNodeForXPath:@"ancestor::a" baseNode:titleNode];

    NSXMLNode *urlAttr = [(NSXMLElement *)aNode attributeForName:@"href"];

    
	if (!urlAttr) return nil;
	
	NSString *url = [urlAttr stringValue];

    // URL形式チェック
    static NSString * const regex = @"//genius.com/.+-lyrics$";
    
    NSRange range = [url rangeOfRegex:regex];
    
    if (range.location == NSNotFound) {
        
        //NSLog(@"## (Skip: %@)", url);
        return nil;
    }
    
	//NSLog(@"## url: %@", url);
	
	NSArray *values = [NSArray arrayWithObjects:ttl, art, url, nil];
	
	return values;
}

- (NSString *) targetXPath2 {

    //                                                   pタグ(brタグを一つ以上含む)
    static NSString * const target = @"//div[@class=\"song_body-lyrics\"]//p[br]";
	
	return target;
}

- (NSString *) nodeValue2:(NSXMLNode *)node {
    
    //NSLog(@"## lyr: %@", node);

	NSString *lyr = [node stringValue];
	
	return lyr;
}

@end
