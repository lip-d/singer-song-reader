//
//  SMSrchResultProtocol.h
//  Singer Song Reader
//
//  Created by Developer on 13/10/08.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol SMSrchResultProtocol

@optional   //実装任意

// Lyrics サイトの検索結果用
@property (retain) NSString *lyrics;

// iTunes Store の検索結果用
@property (retain) NSString *artworkUrl60;
@property (retain) NSString *trackId;
@property          NSInteger trackNumber;
@property (retain) NSString *releaseYear;
@property (retain) NSString *releaseDate;
@property (retain) NSString *artistId;
@property (retain) NSString *artistUrl;
@property (retain) NSDictionary *others;

@property (retain) NSMutableArray  *topSongs;
@property          NSInteger        topSongsIndex;

@property (retain) NSMutableArray  *bioStats;
@property (retain) NSString        *biography;

// AnimeLyrics 検索用
@property (retain) NSString *otherTitle;
@property (retain) NSArray  *otherArtists;
@property (retain) NSArray  *headerNotes;
@property (retain) NSArray  *footerNotes;

@required   //実装必須

@property (retain) NSString *title;
@property (retain) NSString *artist;
@property (retain) NSString *url;

- (void) clear;

@end