//
//  SMKanji.h
//  Singer Song Reader
//
//  Created by Developer on 2014/03/28.
//
//

#import <Foundation/Foundation.h>
#include "mecab.h"

@interface SMKanji : NSObject {
    
    mecab_t    *mecab;
}

- (NSString *) romajiByConvertingFrom:(NSString *)kanji;


+ (void) mecabTest:(NSString *)input;

@end
