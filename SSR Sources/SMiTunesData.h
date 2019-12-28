//
//  SMiTunesData.h
//  Singer Song Reader
//
//  Created by Developer on 13/10/23.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "iTunes.h"
#import "Deezer.h"
#import "SMiTunesNotif.h"

@interface SMiTunesData : NSObject {

	NSString *source;
	NSString *title;
	NSString *artist;
	NSInteger trackId;
	NSString *bitRate;
	NSString *category;
	NSString *lyrics;
    NSInteger mediaType;
    NSString *persistentId;
    
    iTunesTrack *currentTrack;
	
@private
	NSString *currentStreamTitle;
}

@property (retain)    NSString *source;
@property (retain)    NSString *title;
@property (retain)    NSString *artist;
@property (nonatomic) NSInteger trackId;
@property (retain)    NSString *bitRate;
@property (retain)    NSString *category;
@property (retain)    NSString *lyrics;
@property (nonatomic) NSInteger mediaType;
@property (retain)    NSString *persistentId;

@property (retain)    iTunesTrack *currentTrack;

@property (retain)    NSString    *currentStreamTitle;

- (void) clear;
- (BOOL) isEmpty;

- (BOOL) updateWith:(NSString *)aCurrentStreamTitle currentTrack:(iTunesTrack *)aCurrentTrack iTunesNotif:(SMiTunesNotif *)aITunesNotif;
- (void) updateWithMusicTrack:(iTunesTrack *)aTrack;

// Deezer 用 (v4.0)
- (BOOL) updateWith:(DeezerTrack *)aLoadedTrack;


- (BOOL) isValid;
- (BOOL) isNotValid;
- (BOOL) isCloudStored;

- (void) setSource:(NSString *)aSource title:(NSString *)aTitle artist:(NSString *)aArtist trackId:(NSInteger)aTrackId bitRate:(NSInteger)aBitRate category:(NSString *)aCategory lyrics:(NSString *)aLyrics mediaType:(NSInteger)aMediaType persistentId:(NSString*)aPersistentId;

@end
