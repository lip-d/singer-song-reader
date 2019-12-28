//
//  SMiTunesNotif.m
//  Singer Song Reader
//
//  Created by Developer on 7/2/15.
//
//

#import "SMiTunesNotif.h"

@implementation SMiTunesNotif

@synthesize album;
@synthesize title;
@synthesize artist;
@synthesize genre;
@synthesize persistentID;

- (id) init {
    self = [super init];
    if (self) {
        album        = nil;
        title        = nil;
        artist       = nil;
        genre        = nil;
        persistentID = nil;
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void) clear {
    [self setAlbum:nil];
    [self setTitle:nil];
    [self setArtist:nil];
    [self setGenre:nil];
    [self setPersistentID:nil];
}

- (BOOL) isEmpty {
    
    if (title == nil) {
        return YES;
    } else {
        return NO;
    }
}
@end
