//
//  SMMetalArchives.m
//  Singer Song Reader
//
//  Created by Developer on 11/17/14.
//
//

#import "SMMetalArchives.h"

@implementation SMMetalArchives

- (id)init {
    self = [super init];
    if (self) {
        
        [super setJsonChild:self siteName:@"MetalArchives"];
        
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
    
    static NSArray *baseArray = nil;
    
    // es, en, da, la 追加 (v4.1)
    if (!baseArray) {
        baseArray = [[NSArray alloc] initWithObjects:@"a", @"i", @"u", @"e", @"o", @"es", @"en", @"da", @"la", nil];
    }
    
    // Lyrics キーワードにタイトルを含める (v4.1)
    NSArray *orgArray = [track.title.original componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSMutableArray *ttlArray = [NSMutableArray arrayWithCapacity:0];
    
    // URLエンコード後、Arrayに格納
    for (NSString *org in orgArray) {
        
        [ttlArray addObject:[SSCommon urlEncode:org]];
    }
    
    // baseArray と ttlArray を結合
    NSArray *lyArray = [baseArray arrayByAddingObjectsFromArray:ttlArray];
    
    // Lyrics 検索キーワードを "||" で結合
    NSString *lyr = [lyArray componentsJoinedByString:@"+%7C%7C+"];
    
    NSString *ttl = track.title.urlEncoded;
    NSString *art = track.artist.urlEncoded;
    
    
    NSString *url = [NSString stringWithFormat:[self urlFormat1], ttl, art, lyr];
    
    return url;
}

- (NSString *) urlFormat1 {
    
    static NSString * const format = @"http://www.metal-archives.com/search/ajax-advanced/searching/songs/?songTitle=%@&bandName=%@&lyrics=%@&releaseType%%5B%%5D=1&releaseType%%5B%%5D=2&releaseType%%5B%%5D=3&releaseType%%5B%%5D=4&releaseType%%5B%%5D=5&releaseType%%5B%%5D=8";
    
    return format;
}

- (NSString *) targetKey1 {
    
    static NSString * const key = @"aaData";
    
    return key;
}

- (NSArray *) itemValue1:(NSArray *)item {

    if (item.count != 5) return nil;
    
    //NSLog(@"## %@", item);
    
    //----------------
    // URL 取得
    //----------------
    static NSString * const regex = @" id=\\\"lyricsLink_(.+)\\\" title";
    
    NSString *lyr_id = [item[4] stringByMatching:regex capture:1L];
    
    if (!lyr_id) return nil;

    NSString *url = [NSString stringWithFormat:@"http://www.metal-archives.com/release/ajax-view-lyrics/id/%@?highlight=", lyr_id];
    
//    NSLog(@"## url: %@", url);
    
    //---------------------------
    // タイトル取得
    //---------------------------
    NSString *ttl = item[3];
    
    //NSLog(@"## ttl: %@", ttl);

    //---------------------------
    // アーティスト取得
    //---------------------------
    static NSString * const regex2 = @">(.+)</\\w+>$";
    
    NSString *art = [item[0] stringByMatching:regex2 capture:1L];
    
    if (!art) return nil;
    
    //NSLog(@"## art: %@", art);

    NSArray *values = [NSArray arrayWithObjects:ttl, art, url, nil];

    return values;
}

- (NSString *) targetXPath2 {
    
    static NSString * const target = @"/";
    
    return target;
}

- (NSString *) nodeValue2:(NSXMLNode *)node {
    
    NSString *lyr = [node stringValue];
    
//        NSLog(@"## %@", lyr);
    
    return lyr;
}

@end
