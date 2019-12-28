//
//  SMMetroLyrics.m
//  Singer Song Reader
//
//  Created by Developer on 5/10/14.
//
//

#import "SMMetroLyrics.h"

@implementation SMMetroLyrics

- (id)init {
    self = [super init];
    if (self) {
        
		[super setJsonChild:self siteName:@"MetroLyrics"];
        
        // v4.1
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
	
//    static NSString * const format = @"http://api.metrolyrics.com/v1/search/artistsong/format/json/?artist=%@&song=%@&X-API-KEY=196f657a46afb63ce3fd2015b9ed781280337ea7";
    static NSString * const format = @"http://api.metrolyrics.com/v1//multisearch/all/X-API-KEY/196f657a46afb63ce3fd2015b9ed781280337ea7/format/json?find=%@+%@&theme=desktop&category=artistsong&offset=0&limit=50";
	
	return format;
}

- (NSString *) targetKey1 {

//    static NSString * const key = @"items";
    
    // v4.5
    static NSString * const key = @"results.songs.d";
    
    return key;
}

- (NSArray *) itemValue1:(NSDictionary *)item {
	
	//----------------
	// URL、タイトル、アーティスト取得
	//----------------
//	NSString *url = [item valueForKey:@"url"];
//    NSString *ttl = [item valueForKey:@"title"];
//    NSString *art = [item valueForKey:@"artist"];

    // v4.5
    NSString *url     = [item valueForKey:@"u"];
    NSString *art_ttl = [item valueForKey:@"p"];

    NSXMLDocument *art_ttlXml = [[[NSXMLDocument alloc] initWithXMLString:art_ttl
                                                                   options:NSXMLDocumentTidyHTML
                                                                     error:nil] autorelease];
    
    art_ttl = [art_ttlXml stringValue];
    
    NSArray *art_ttlAry = [art_ttl componentsSeparatedByString:@"\n"];
    
    if (art_ttlAry.count != 2) {
        return nil;
    }
    
    NSString *art = art_ttlAry[0];
    NSString *ttl = art_ttlAry[1];
    
//   NSLog(@"## url: %@", url);
//   NSLog(@"## art: %@", art);
//NSLog(@"## ttl: %@", ttl);

	if (!url || !ttl || !art) return nil;
	
    url = [NSString stringWithFormat:@"http://www.metrolyrics.com/%@", url];
    
	NSArray *values = [NSArray arrayWithObjects:ttl, art, url, nil];
	
	return values;
}

- (NSString *) targetXPath2 {
	
//	static NSString * const target = @"//div[@class=\"lyrics-body\"][1]";
	static NSString * const target = @"//div[@id=\"lyrics-body-text\"]";
	
	return target;
}

- (NSString *) nodeValue2:(NSXMLNode *)node {
	
    NSError *err = nil;
    
    NSString *xPath = @".//p[@class=\"verse\"]";
    NSArray *pArray = [node nodesForXPath:xPath error:&err];
    
    if (err) return nil;
    
    NSMutableArray *pAry = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    for (NSXMLNode *p in pArray) {
        [pAry addObject:[p stringValue]];
    }
    
    NSString *lyr = [pAry componentsJoinedByString:@"\n"];
    
    // Lyrics の内容が空の場合は No Hit とする
    if ([lyr length] == 0) return nil;
    
    // 次の文章が出たら No Hit とする
    // We are not in a position to display these lyrics due to
    // licensing restriction Sorry for the inconvenience.
    // Read more: Michael Jackson - You Rock My World Lyrics | MetroLyrics
    
    NSString *mes = @"We are not in a position to display these lyrics";
    
    if ([lyr hasPrefix:mes]) return nil;
    
    return lyr;
}

@end
