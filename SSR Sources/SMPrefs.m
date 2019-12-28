//
//  SMPrefs.m
//  Singer Song Reader
//
//  Created by Developer on 5/18/14.
//
//

#import "SMPrefs.h"

@implementation SMPrefs

@synthesize japaneseType;

- (void) setRomaji:(BOOL)romajiFlag kanji:(BOOL)kanjiFlag {
    
    if      ( romajiFlag && !kanjiFlag) japaneseType = SM_JP_ROMAJI;
    else if (!romajiFlag &&  kanjiFlag) japaneseType = SM_JP_KANJI;
    else                                japaneseType = SM_JP_ANY;
}

@end
