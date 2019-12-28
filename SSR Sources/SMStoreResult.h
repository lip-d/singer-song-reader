//
//  SMStoreResult.h
//  Singer Song Reader
//
//  Created by Developer on 13/10/02.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSCommon.h"
#import "SMSrchResultProtocol.h"


@interface SMStoreResult : NSObject <SMSrchResultProtocol> {

    // 第一検索
	NSString *title;
	NSString *artist;
	NSString *url;
	NSString *artworkUrl60;
	NSString *trackId;
	NSInteger trackNumber;
	NSString *releaseYear;
	NSString *releaseDate;
    NSString *artistId;
    NSString *artistUrl;
	NSDictionary *others;

    // 第二検索
    NSMutableArray  *topSongs;
    NSInteger        topSongsIndex;
    
    // 第三検索
    NSMutableArray  *bioStats;
    NSString        *biography;
}

@property (retain) NSString *title;
@property (retain) NSString *artist;
@property (retain) NSString *url;
@property (retain) NSString *artworkUrl60;
@property (retain) NSString *trackId;
@property          NSInteger trackNumber;
@property (retain) NSString *releaseYear;
@property (retain) NSString *releaseDate;
@property (retain) NSString *artistId;
@property (retain) NSString *artistUrl;
@property (retain) NSDictionary *others;

@property (retain) NSMutableArray  *topSongs;

@property (retain) NSMutableArray  *bioStats;
@property (retain) NSString        *biography;

- (void) clear;

@end
