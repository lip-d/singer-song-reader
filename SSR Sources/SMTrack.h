//
//  SMTrack.h
//  Singer Song Reader
//
//  Created by Developer on 13/10/12.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SMKeyword.h"
#import "SSCommon.h"

// 動作モード
typedef enum {
	SM_COMP_ALL  = 0,
	SM_COMP_TTL  = 1,
	SM_COMP_ART  = 2
} SMCompareOption;

@interface SMTrack : NSObject {
    
	SMKeyword *title;
	SMKeyword *artist;
		
	NSMutableDictionary *matchCache;
}

@property (readonly) SMKeyword *title;
@property (readonly) SMKeyword *artist;

@property (readonly) NSString  *urlEncoded;

@property (readonly) NSArray   *allwordsArray;
@property (readonly) NSArray   *subwordsArray;
@property (readonly) NSInteger  allwordsLength;

@property (readonly) NSArray   *arrayArray;

@property (readonly) BOOL       isJapanese;

- (void) clear;

- (void) setTitle:(NSString *)aTitle artist:(NSString *)aArtist;

- (NSInteger) compare:(SMTrack *)aTrack option:(SMCompareOption)option;

+ (NSInteger) compareArrayArray:(NSArray *)searcher searched:(NSArray *)searched searcherFilter:(BOOL)searcherFilter searchedFilter:(BOOL)searchedFilter searchedRest:(NSString **)searchedRest scoreWithoutRest:(BOOL)scoreWithoutRest;
@end
