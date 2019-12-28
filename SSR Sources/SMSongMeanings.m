//
//  SMSongMeanings.m
//  Singer Song Reader
//
//  Created by Developer on 2013/12/17.
//
//

#import "SMSongMeanings.h"

@implementation SMSongMeanings

- (id)init {
    self = [super init];
    if (self) {
		
		[super setHtmlChild:self siteName:@"SongMeanings"];
	}
	return self;
}

- (NSString *) urlFormat1 {
	
	static NSString * const format = @"http://songmeanings.com/query/?query=%@&type=all";
	
	return format;
}

- (NSString *) targetXPath1 {
	
	static NSString * const target = @"//ul[@class=\"topics\"]//tr[@class=\"item\"]";
	
	return target;
}

- (NSArray *) nodeValue1:(NSXMLNode *)node {
		
	NSError *err = nil;
	
	NSArray *ttl_art = [node nodesForXPath:@"td/a" error:&err];
	
	if (err) return nil;
	
	if ([ttl_art count] != 2) return nil;

	//----------------
	// タイトル取得
	//----------------
	NSXMLNode *titleNode = [ttl_art objectAtIndex:0];
	NSXMLNode *titleAttr = [(NSXMLElement *)titleNode attributeForName:@"title"];
	
	if (!titleAttr) return nil;
	
	NSString *ttl = [titleAttr stringValue];
	
//	NSLog(@"## ttl: %@", ttl);
	
	//----------------
	// アーティスト取得
	//----------------
	NSXMLNode *artistNode = [ttl_art objectAtIndex:1];
	NSXMLNode *artistAttr = [(NSXMLElement *)artistNode attributeForName:@"title"];

	if (!artistAttr) return nil;

	NSString *art = [artistAttr stringValue];
	
//	NSLog(@"## art: %@", art);
	
	//----------------
	// URL 取得
	//----------------
	NSXMLNode *urlAttr = [(NSXMLElement *)titleNode attributeForName:@"href"];
	
	if (!urlAttr) return nil;

	NSString *url = [urlAttr stringValue];
	
    //	NSLog(@"## url: %@", url);
    
    /* 以下のように、http: が抜けている場合は http: を付け足す (v4.2)
     //songmeanings.com/songs/view/10267/
     */
    if ([url hasPrefix:@"//"]) {
    
        url = [NSString stringWithFormat:@"http:%@", url];
    }
	
	NSArray *values = [NSArray arrayWithObjects:ttl, art, url, nil];
	
	return values;
}

- (NSString *) targetXPath2 {

    // v3.6 修正
//    static NSString * const target = @"//div[@id=\"textblock\"]";
    static NSString * const target = @"//div[@id=\"content\"]//div[@class=\"holder lyric-box\"]";
	
	return target;
}

- (NSString *) nodeValue2:(NSXMLNode *)node {
	
    // v3.6 追加
    [super removeNodeByXPath:@".//div" baseNode:node];

//    NSLog(@"### %@", node);

	NSString *lyr = [node stringValue];
    
    // 以下の文章で始まる場合、No hit 扱いとする (1)
    if ([lyr hasPrefix:@"Due to copyright restrictions,"]) return nil;
    
    // 以下の文章で始まる場合、No hit 扱いとする (2)
    if ([lyr hasPrefix:@"Due to a publisher block,"]) return nil;
    
    // v3.6 追加
    // 以下の文章で始まる場合、No hit 扱いとする (3)
    if ([lyr hasPrefix:@"There was an error"]) return nil;
    
    // タイトル末尾が途切れている場合は、再取得する (V3.4)
    if ([srchResult.title hasSuffix:@"..."]) {
        
        NSXMLNode *h1Node = [super firstNodeForXPath:@"//h1" baseNode:node.rootDocument];
        
        if (h1Node) {
            
            // test
//            NSString *testNormal    = @"Stevie Wonder - You Are The Sunshine Of My Life";
//            NSString *testIrregular = @"Stevie Wonder – You Are The Sunshine Of My Life";
            
            // ハイフンが通常の半角ハイフンと違うので要注意。見た目ではほとんど分からない。
            NSArray *components = [h1Node.stringValue componentsSeparatedByRegex:@" – | - "];
//            NSArray *components = [testIrregular componentsSeparatedByRegex:@" – | - "];

            if (components.count == 2) {
                
                // 検索結果のタイトルを上書き
                srchResult.title = components[1];
            }
        }
    }
    
	return lyr;
}

@end
