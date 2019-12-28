//
//  SMStoreResult.m
//  Singer Song Reader
//
//  Created by Developer on 13/10/02.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMStoreResult.h"


@implementation SMStoreResult

@synthesize title;
@synthesize artist;
@synthesize url;
@synthesize artworkUrl60;
@synthesize trackId;
@synthesize trackNumber;
@synthesize releaseYear;
@synthesize releaseDate;
@synthesize artistId;
@synthesize artistUrl;
@synthesize others;

@synthesize topSongs;
@synthesize topSongsIndex;

@synthesize bioStats;
@synthesize biography;

- (id)init {
    self = [super init];
    if (self) {
		title        = nil;
		artist       = nil;
		url          = nil;
		artworkUrl60 = nil;
		trackId      = nil;
		trackNumber  = 0;
		releaseYear  = nil;
		releaseDate  = nil;
        artistId     = nil;
        artistUrl    = nil;
		others       = nil;

        topSongs     = [[NSMutableArray alloc] initWithCapacity:0];
        topSongsIndex= -1;

        bioStats     = [[NSMutableArray alloc] initWithCapacity:0];
        biography    = nil;
    }
	
	return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void) clear {
	[self setTitle:SMEmpty];
	[self setArtist:SMEmpty];
	[self setUrl:SMEmpty];
	[self setArtworkUrl60:SMEmpty];
	[self setTrackId:SMEmpty];
	[self setTrackNumber:0];
	[self setReleaseYear:SMEmpty];
	[self setReleaseDate:SMEmpty];
    [self setArtistId:SMEmpty];
    [self setArtistUrl:SMEmpty];
	[self setOthers:nil];

    [topSongs removeAllObjects];
    [self setTopSongsIndex:-1];

    [bioStats removeAllObjects];
    [self setBiography:SMEmpty];
}
@end
