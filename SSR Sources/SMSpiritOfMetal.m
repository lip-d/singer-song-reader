//
//  SMSpiritOfMetal.m
//  Singer Song Reader
//
//  Created by Developer on 11/14/14.
//
//

#import "SMSpiritOfMetal.h"

@interface LyricData : NSObject {
    
    NSString *ttl;
    NSRange ttlRange;
    NSRange lyrRange;
}
@property (retain) NSString *ttl;
@property NSRange ttlRange;
@property NSRange lyrRange;
@end

@implementation LyricData

@synthesize ttl;
@synthesize ttlRange;
@synthesize lyrRange;

- (id) init {
    self = [super init];
    if (self) {
        ttl = nil;
        ttlRange = NSMakeRange(NSNotFound, 0);
        lyrRange = NSMakeRange(NSNotFound, 0);
    }
    
    return self;
}

@end

@implementation SMSpiritOfMetal

- (id)init {
    self = [super init];
    if (self) {

        [super setJsonChild:self siteName:@"SpiritOfMetal"];

        
        //-----------------------------
        // - エンコーディング固定
        //-----------------------------

        encodingSetting[0] = @(SS_ENC_AUTO_DETECT);
//        encodingSetting[1] = @(NSASCIIStringEncoding);
        encodingSetting[1] = @(NSUTF8StringEncoding);
    }
    
    return self;
}

- (NSString *) url1 {
//    NSString *ttl = track.title.urlEncoded;
//    NSString *art = track.artist.urlEncoded;
    // 検索用の正規化をスキップ
    NSString *ttl = [SSCommon urlEncode:track.title.original];
    NSString *art = [SSCommon urlEncode:track.artist.original];
    
    NSString *url = [NSString stringWithFormat:[self urlFormat1], ttl, art];
    
    return url;
}

- (NSString *) urlFormat1 {
    
    static NSString * const format = @"https://www.googleapis.com/customsearch/v1element?key=AIzaSyCVAXiUzRYsML1Pv6RwSG1gunmMikTzQqY&num=10&cx=018409797516699207803:y_ewllptv_w&q=%%22%@%%22%%20%%22%@%%20Album%%27s%%20lyrics%%22&hl=ja";
    
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
    
//    NSLog(@"## url: %@", url);

    //----------------
    // タイトル 取得
    //----------------
    NSString *content = [item valueForKey:@"content"];
    
    if (!content) return nil;

//    NSLog(@"## content: %@", content);
    
    // 改行で分割された <b> タグをひとつにまとめる
    NSString *content2 = [content stringByReplacingOccurrencesOfRegex:@"</b>\\s+<b>" withString:@" "];
    
//    NSLog(@"## content2: %@", content2);

    // 仮ルートタグ <div> で XML 生成
    NSString *contentXML = [NSString stringWithFormat:@"<div>%@</div>", content2];
    
    NSError *err = nil;

    // &#XX; などのメタ文字をアンエスケープする。
    NSXMLDocument *doc = [[[NSXMLDocument alloc] initWithXMLString:contentXML
                                                           options:NSXMLDocumentTidyXML
                                                             error:&err] autorelease];
    if (err) return nil;
    
    // <b>タグのみ抽出
    NSArray *bList = [doc nodesForXPath:@"//b" error:nil];
    
    NSString *ttl = nil;
    
    for (NSXMLNode *bNode in bList) {
        
        NSXMLNode *prev = bNode.previousNode;
        
        NSString *bStr = bNode.stringValue;
        
        BOOL numFlag = NO;
        
        if (prev.level == bNode.level) {
            
            NSString *numStr = [prev.stringValue stringByMatching:@"(\\d+\\. )$" capture:1L];

            // 番号付き: Track list にマッチ
            if (numStr != NULL) {
                
                numFlag = YES;
            }
        }

        if (numFlag) {
            
            ttl = bStr;
            break;
        }
        else {
            
            if ([bStr rangeOfRegex:@"[a-z]"].location == NSNotFound) {
                
                ttl = bStr;
                break;
            }
        }
    }
    
    if (!ttl) return nil;
    
//    NSLog(@"## ttl: %@", ttl);

    //----------------
    // アーティスト 取得
    //----------------
    NSDictionary *richSnippet  = [item        valueForKey:@"richSnippet"];
    NSArray      *breadcrumb   = [richSnippet valueForKey:@"breadcrumb"];
    
    if (breadcrumb.count != 2) return nil;
    
    NSString *art = [breadcrumb[1] valueForKey:@"title"];
    
//    NSLog(@"## art: %@", art);
    
    if (![art isKindOfClass:[NSString class]]) return nil;
    
    NSArray *values = [NSArray arrayWithObjects:ttl, art, url, nil];
    
    return values;
}

- (NSNumber *) analyze2:(id)aData {
    
    // aData の中身に UTF8 とそれ以外の文字コードが混在しているため、まず、歌詞が含まれている <div> タグのみを抽出する。
    
    NSString* sTag = @"<td class=StandardWideCadreContent><div";
    NSString* eTag = @"</div>";
    
    NSData* data = nil;
    NSRange range;
    
    NSInteger dataLen = [aData length];
    
    NSInteger sPos = 0;
    NSInteger ePos = 0;
    
    // 開始タグを検索
    data  = [sTag dataUsingEncoding:NSUTF8StringEncoding];
    range = [aData rangeOfData:data options:0 range:NSMakeRange(0, dataLen)];
    
    if (range.length > 0) sPos = range.location;
    
    if (sPos > 0) {
        
        // 終了タグを検索
        data  = [eTag dataUsingEncoding:NSUTF8StringEncoding];
        range = [aData rangeOfData:data options:0 range:NSMakeRange(sPos, dataLen - sPos)];
        
        if (range.length > 0) ePos = range.location;
    }
    
    // 抽出位置調整
    if (sPos > 0 && ePos > 0) {
        
        sPos += (sTag.length - 4); // <div> タグ直前まで進める
        ePos += 6;                 // </div> タグ直後まで進める
    }
    else{
        
        return [NSNumber numberWithInt:0];
    }
    
    // div タグ内抽出
    NSData *newData = [aData subdataWithRange:NSMakeRange(sPos, ePos-sPos)];
/*
    // Debug
    NSString *newStr = [[[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding] autorelease];
    
    NSLog(@"#### %@", newStr);
 */
    NSString *xPath = nil;
    
    @try {
        NSXMLElement *aRootElement = [self getDocRootElement:newData];
        
//        NSLog(@"### %@", aRootElement);
        
        if (!aRootElement) return [NSNumber numberWithInt:-222];
        
        // 歌詞表示ボックス取得
        xPath = [child targetXPath2];
        
        NSXMLNode *lyricbox = [self firstNodeForXPath:xPath baseNode:aRootElement];
  
//        NSLog(@"## %@", lyricbox);
        
        if (!lyricbox) return [NSNumber numberWithInt:0];
        
        NSString *lyr = [child nodeValue2:lyricbox];
        
        if (!lyr) return [NSNumber numberWithInt:0];
        
        if ([lyr length] == 0) return [NSNumber numberWithInt:0];
        
        [srchResult setLyrics:lyr];
    }
    @catch (NSException * e) {
        return [NSNumber numberWithInt:-200];
    }
    
    return [NSNumber numberWithInt:1];
}

- (NSString *) targetXPath2 {
    
//    static NSString * const target = @"//td[@class=\"StandardWideCadreContent\"]/div";
    static NSString * const target = @"//div";
    
    return target;
}

- (NSString *) nodeValue2:(NSXMLNode *)node {
    
    NSString *lyrAll = node.stringValue;
    
//    NSLog(@"## %@", node);
//    NSLog(@"## %@", lyrAll);
    
    // まず、lyrics テキストからタイトルのみを抽出する
    NSRange range = NSMakeRange(0, lyrAll.length);
    
    NSMutableArray *scoreList = [NSMutableArray arrayWithCapacity:0];
    
    while (1) {
    
        NSRange matched = [lyrAll rangeOfRegex:@"^\\s*\\d+\\. *.+ *\\n\\n|\\n\\n *\\d+\\. *.+ *\\n\\n" inRange:range];
//        NSRange matched = [lyrAll rangeOfRegex:@"\\d+\\. *.+ *\\n\\n" inRange:range];
    
        if (matched.location == NSNotFound) break;
        
//        NSLog(@"++ %@", [lyrAll substringWithRange:matched]);
        
        NSString *tmp = [[lyrAll substringWithRange:matched] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
//        NSLog(@"++ %@", tmp);

        NSString *ttl = [tmp stringByReplacingOccurrencesOfRegex:@"^(\\d+\\. *)+" withString:@""];
        
        NSInteger sco = [super matchTitle:ttl andArtist:srchResult.artist];

//        NSLog(@"++ (%ld) %@", sco, ttl);
        
        // 検索結果スコアを保存：{score, lyricData}
        LyricData *lyrData = [[[LyricData alloc] init] autorelease];
        
        lyrData.ttl = ttl;
        lyrData.ttlRange = matched;
        
        NSArray *scoData = [NSArray arrayWithObjects:
                            [NSNumber numberWithInt:sco],
                            lyrData,
                            nil];
        
        [scoreList addObject:scoData];
        
        range.location = (matched.location + matched.length);
        range.length   = lyrAll.length - range.location;
    }

    // 各 lyrics 本体の範囲を記録しておく
    int cnt = scoreList.count;
    
    for (int i=0; i<cnt; i++) {

        NSUInteger location;
        NSUInteger length;
        
        LyricData *lyrData = scoreList[i][1];
        
        location = lyrData.ttlRange.location + lyrData.ttlRange.length;
        
        if (i+1 < cnt) {
         
            LyricData *lyrData2 = scoreList[i+1][1];
            
            length = lyrData2.ttlRange.location - location;
        }
        else {
            
            length = lyrAll.length              - location;
        }

        // lyrics range を記録
        lyrData.lyrRange = NSMakeRange(location, length);
    }

    // スコアリストを降順でソート
    [scoreList sortUsingFunction:som_numberSort context:nil];

    // ベストな lyrics を選ぶ
    int bestIdx = -1;
    for (int i=0; i<cnt; i++) {
        
        NSInteger score     = [scoreList[i][0] integerValue];
        LyricData *lyrData  = scoreList[i][1];
        NSInteger lyrLength = lyrData.lyrRange.length;
        
        // スコアチェック
        if (score < SSLooseMatchThreshold) break;
        
        // lyrics 長チェック
        if (lyrLength < SSLyricsLengthMin) continue;
        
        bestIdx = i;

//        NSLog(@"## Best (%ld%%): %@", score, lyrData.ttl);

        break;
    }
    
    NSString *lyr;
    
    if (bestIdx != -1) {
        
        LyricData *lyrData  = scoreList[bestIdx][1];
        
        lyr = [lyrAll substringWithRange:lyrData.lyrRange];
        [srchResult  setTitle:lyrData.ttl];
        [resultScore setTotalScore:scoreList[bestIdx][0]];
    }else{
        
        lyr = @"";
        [srchResult  setTitle:@""];
        [resultScore setTotalScore:0];
    }
    
    return lyr;
}

// スコア降順ソート用関数
NSInteger som_numberSort(id num1, id num2, void *context){
    NSInteger ret = [[num2 objectAtIndex:0] compare:[num1 objectAtIndex:0]]; //昇順
    return ret;
}

@end
