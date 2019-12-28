//
//  SMPrefs.h
//  Singer Song Reader
//
//  Created by Developer on 5/18/14.
//
//

#import <Foundation/Foundation.h>

typedef enum {
	SM_JP_ANY    = 0,
	SM_JP_KANJI  = 1,
	SM_JP_ROMAJI = 2
} SMJapaneseType;

@interface SMPrefs : NSObject {
    
    NSInteger japaneseType;
}

@property (readonly) NSInteger japaneseType;

- (void) setRomaji:(BOOL)romajiFlag kanji:(BOOL)kanjiFlag;

@end
