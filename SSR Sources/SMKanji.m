//
//  SMKanji.m
//  Singer Song Reader
//
//  Created by Developer on 2014/03/28.
//
//

#import "SMKanji.h"

@implementation SMKanji

- (id)init {
    self = [super init];
    if (self) {
        
        NSString *path = [[NSBundle mainBundle] resourcePath];
        
        NSString *param = [NSString stringWithFormat:@"-d \"%@/mecabdic\" -Ohatsuon", path];

        mecab = mecab_new2([param UTF8String]);
        
        if (!mecab) {
            mecab_destroy(mecab);
            mecab = nil;
            return nil;
        }
        
	}
    return self;
}

- (void)dealloc {
    if (mecab) {
        mecab_destroy(mecab);
    }
    [super dealloc];
}

- (NSString *) romajiByConvertingFrom:(NSString *)kanji {
    
    const char *result = nil;
    
    result = mecab_sparse_tostr(mecab, [kanji UTF8String]);
    
    if (!result) {
        
        return nil;
    }

    return [NSString stringWithUTF8String:result];
}

#pragma mark - Debug

#define CHECK(eval) if (! eval) { \
fprintf (stderr, "Exception:%s\n", mecab_strerror (mecab)); \
mecab_destroy(mecab); \
return; }

+ (void) mecabTest:(NSString *)input {
    
    //char input[] = "太郎は次郎が持っている本を花子に渡した。";
    mecab_t    *mecab;
    const char *result;
    
    NSString *path = [[NSBundle mainBundle] resourcePath];
    
    NSString *param = [NSString stringWithFormat:@"-d \"%@\" -Ohatsuon", path];
    
    // Create tagger object
    mecab = mecab_new2([param UTF8String]);
    CHECK(mecab);
    
    // Gets tagged result in string.
    result = mecab_sparse_tostr(mecab, [input UTF8String]);
    CHECK(result)
    printf ("INPUT: %s\n", [input UTF8String]);
    printf ("RESULT:%s", result);
    
    /*
     // Dictionary info
     const mecab_dictionary_info_t *d = mecab_dictionary_info(mecab2);
     for (; d; d = d->next) {
     printf("filename: %s\n", d->filename);
     printf("charset: %s\n", d->charset);
     printf("size: %d\n", d->size);
     printf("type: %d\n", d->type);
     printf("lsize: %d\n", d->lsize);
     printf("rsize: %d\n", d->rsize);
     printf("version: %d\n", d->version);
     }
     */
    mecab_destroy(mecab);
}
@end
