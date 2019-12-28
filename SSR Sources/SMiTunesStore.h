//
//  SMiTunesStore.h
//  Singer Song Reader
//
//  Created by Developer on 13/10/31.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SMSite.h"
#import "SMStoreResult.h"


@interface SMiTunesStore : SMSite {

	// iTunes Store の国指定
	NSString *countryCode;
    
    // iTunes Store の検索/レスポンス言語指定
    NSString *lang;
    
    NSInteger matchThreshold;
	
	NSString *urlFormat1;
	NSString *urlFormat1_;
	NSString *urlFormat2;
	
	SMStoreResult *storeResult;
    
    SMResultScore *artistScore;
}

@property (retain) NSString *countryCode;
@property (readonly, retain) NSString *lang;
@property          NSInteger matchThreshold;
@property (readonly) SMResultScore *artistScore;

- (void) markAsNoHit;
- (void) markSongAsNoHit;
- (void) markArtistAsNoHit;

// 国指定あり。最初の 1 件のみ取得
- (NSString *) url1;
- (NSNumber *) analyze1:(id)aData;

// 第一検索の代替
- (NSString *) url1_;
- (NSNumber *) analyze1_:(id)aData;

- (NSString *) url2;
- (NSNumber *) analyze2:(id)aData;

- (NSString *) url3;
- (NSNumber *) analyze3:(id)aData;

@end
