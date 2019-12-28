//
//  SMLyrics.m
//  Singer Song Reader
//
//  Created by Developer on 2013/12/17.
//
//

#import "SMLyrics.h"

@implementation SMLyrics

- (id)init {
    self = [super init];
    if (self) {
		
		[super setHtmlChild:self siteName:@"Lyrics"];
	}
	return self;
}

- (NSString *) urlFormat1 {
	
	static NSString * const format = @"http://www.lyrics.com/search.php?what=all&keyword=%@";
	
	return format;
}

- (NSString *) targetXPath1 {
	
	static NSString * const target = @"//div[@id=\"rightcontent\"]//div[@class=\"left\"]";
	
	return target;
}

- (NSArray *) nodeValue1:(NSXMLNode *)node {
	
	//----------------
	// タイトル取得
	//----------------
	NSXMLNode *titleNode = [super firstNodeForXPath:@"div/a" baseNode:node];
	
	if (!titleNode) return nil;
	
	NSString *ttl = [titleNode stringValue];
		
	//NSLog(@"## ttl: %@", ttl);
	
	//----------------
	// アーティスト取得
	//----------------
	NSXMLNode *artistNode = [super firstNodeForXPath:@"a" baseNode:node];
	
	if (!artistNode) return nil;
	
	NSString *art = [artistNode stringValue];
	
	//NSLog(@"## art: %@", art);
	
	//----------------
	// URL 取得
	//----------------
	NSXMLNode *urlAttr = [(NSXMLElement *)titleNode attributeForName:@"href"];
	
	if (!urlAttr) return nil;
	
	NSString *url = [urlAttr stringValue];
	
	url = [NSString stringWithFormat:@"http://www.lyrics.com%@", url];
	
	//NSLog(@"## url: %@", url);
	
	NSArray *values = [NSArray arrayWithObjects:ttl, art, url, nil];
	
	return values;
}

- (NSString *) targetXPath2 {
	
	static NSString * const target = @"//div[@id=\"lyrics\"]";
	
	return target;
}

- (NSString *) nodeValue2:(NSXMLNode *)node {
	
	NSString *lyr = [node stringValue];
	
	return lyr;
}

@end
