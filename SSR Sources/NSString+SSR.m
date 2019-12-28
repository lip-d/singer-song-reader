//
//  NSString+SSR.m
//  Singer Song Reader
//
//  Created by Developer on 5/18/14.
//
//

#import "SSCommon.h"
#import "NSString+SSR.h"
#import "RegexKitLite.h"

@implementation NSString (SSR)

- (NSArray *)componentsSeparatedByNewline {
    
    return [self componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

- (NSString *)convertedStringFromUTF8Mac {
    
    NSMutableString *converted = [NSMutableString stringWithString:self];
    CFStringNormalize((CFMutableStringRef)converted, kCFStringNormalizationFormC);
    
    return converted;
}

// 0.00002s
- (BOOL) containsJapaneseKana {
    
    NSRange range = [self rangeOfRegex:@"[\\p{Hiragana}\\p{Katakana}]"];

    if (range.location != NSNotFound)
        return YES;
    else
        return NO;
}

- (BOOL) containsJapaneseKanaOrKanji {

    NSRange range = [self rangeOfRegex:@"[\\p{Hiragana}\\p{Katakana}\\p{Han}]"];
    
    if (range.location != NSNotFound)
        return YES;
    else
        return NO;
}

// 以下の条件を満たした場合にローマ字とみなす
// - ローマ字100%行の行数がしきい値以上 (各行最低3単語)
// - しきい値に満たなくても、全行数の1/3がローマ字行
//    => 0.0006s
- (BOOL) containsRomaji {
    
//    NSDate *start = [NSDate date];
    
    NSMutableSet *romajiLineSet = [NSMutableSet setWithCapacity:0];
    
    BOOL isRomaji = NO;
    
    // まず先に、「行」で配列化
    NSArray *lineArray = [self componentsSeparatedByNewline];
    
    // 行ごとの処理
    for (NSString *line in lineArray) {
        
        //        NSLog(@"== %@", line);
        
        // 「単語」で配列化
        NSArray *wordArray = [line componentsMatchedByRegex:@"[\\w']+"];
        
        BOOL allRomaji = YES;
        
        // 単語ごとの処理
        for (NSString *word in wordArray) {
            
            //            NSLog(@"   %@", word);
            
            // ローマ字の単語
            if ([word isMatchedByRegex:@"^((([bdfghjkmnprstwyz]y?)|ch|cch|sh|ssh|ts|tts|tt|kk|pp|ss)?[aeiou]n?)+n?$"
                               options:RKLCaseless
                               inRange:NSMakeRange(0, word.length)
                                 error:nil]) {
            }
            // ローマ字以外の単語
            else {
                //                NSLog(@"-- %@", word);
                allRomaji = NO;
                break;
            }
        }
        
        // 100% Romaji & 3単語以上
        if (allRomaji && wordArray.count >= SSRomajiWordThreshold) {
         
            [romajiLineSet addObject:line];
        }
        
        if (romajiLineSet.count == SSRomajiLineThreshold) {
            
            isRomaji = YES;
            break;
        }
    }
    
    // しきい値の行数に満たなかった場合
    if (romajiLineSet.count < SSRomajiLineThreshold) {
        
        // 全行数の1/3がローマ字だったらローマ字とみなす
        if (romajiLineSet.count > (lineArray.count / 3)) {
            isRomaji = YES;
        }
    }
    
#ifdef SS_DEBUG_JP_ROMAJI_DETECTED_LINE
    if (romajiLineSet.count)
        NSLog(@"## DEBUG Romaji detected: %ld lines %@", romajiLineSet.count, romajiLineSet);
#endif
    
//    NSDate *end = [NSDate date];
//    NSTimeInterval interval = [end timeIntervalSinceDate:start];
//    NSLog(@"## %.8f", interval);
    
    return isRomaji;
}

- (NSString *)stringByPaddingToLength:(NSUInteger)newLength {

    return [self stringByPaddingToLength:newLength withString:@" " startingAtIndex:0];
}

@end
