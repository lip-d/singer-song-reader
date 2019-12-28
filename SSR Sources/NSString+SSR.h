//
//  NSString+SSR.h
//  Singer Song Reader
//
//  Created by Developer on 5/18/14.
//
//

#import <Foundation/Foundation.h>

@interface NSString (SSR)

- (NSArray *)componentsSeparatedByNewline;
- (NSString *)convertedStringFromUTF8Mac;

- (BOOL) containsJapaneseKana;
- (BOOL) containsJapaneseKanaOrKanji;
- (BOOL) containsRomaji;

- (NSString *)stringByPaddingToLength:(NSUInteger)newLength;

@end
