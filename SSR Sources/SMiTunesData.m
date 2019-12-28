//
//  SMiTunesData.m
//  Singer Song Reader
//
//  Created by Developer on 13/10/23.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SSCommon.h"
#import "SMiTunesData.h"
#import "SCiTunes.h"

#import "objc/runtime.h"

@implementation SMiTunesData

@synthesize source;
@synthesize title;
@synthesize artist;
@synthesize trackId;
@synthesize bitRate;
@synthesize category;
@synthesize lyrics;
@synthesize mediaType;
@synthesize persistentId;

@synthesize currentTrack;

@synthesize currentStreamTitle;

- (id) init {
    self = [super init];
    if (self) {
		source     = nil;
		title      = nil;
		artist     = nil;
		trackId    = 0;
		bitRate    = nil;
		category   = nil;
		lyrics     = nil;
        mediaType  = SC_MEDIA_NONE;
        persistentId = nil;
		
        currentTrack = nil;
        
		currentStreamTitle = nil;
	}
	
	return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void) clear {
	if ([self isEmpty] == NO) {
		[self setSource:nil];
		[self setTitle:nil];
		[self setArtist:nil];
		[self setTrackId:0];
		[self setBitRate:nil];
		[self setCategory:nil];
		[self setLyrics:nil];
        [self setMediaType:SC_MEDIA_NONE];
        [self setPersistentId:nil];
        
        [self setCurrentTrack:nil];
		
		[self setCurrentStreamTitle:nil];
	}
}

- (BOOL) isEmpty {

	if (title == nil) {
		return YES;
	} else {
		return NO;
	}

}

// 旧データ基準。引数に新データ。
- (BOOL) updateWith:(NSString *)aCurrentStreamTitle currentTrack:(iTunesTrack *)aCurrentTrack iTunesNotif:(SMiTunesNotif *)aITunesNotif {
	
    // Apple Music (My Music 追加前) (v4.0)
    if (aCurrentTrack.size == 0 && aCurrentStreamTitle == nil) {
        
        BOOL notifChanged = NO;
        
        //NSLog(@"## %@, %@", persistentId, aITunesNotif.persistentID);
        
        // 両方 nil の場合に、isEqualToString が NO を返すため、ここではじいておく。(v4.1)
        if (persistentId.length == 0 && aITunesNotif.persistentID == nil) {
            notifChanged = NO;
        } else {
            if ([persistentId isEqualToString:aITunesNotif.persistentID] == NO) {
                notifChanged = YES;
            } else {
                notifChanged = NO;
            }
        }
        
        if (notifChanged) {
            
            //NSLog(@"## notifChanged");
            
            iTunesTrack *itrk = [aCurrentTrack get];
            
            // Tagging 用に保存
            [self setCurrentTrack:itrk];
            [self setCurrentStreamTitle:aCurrentStreamTitle];
            
            // メンバ変数にセット
            [self setSource:aITunesNotif.album
                      title:aITunesNotif.title
                     artist:aITunesNotif.artist
                    trackId:aITunesNotif.persistentID.integerValue
                    bitRate:-1
                   category:nil // セットしないでおく
                     lyrics:nil
                  mediaType:SC_MEDIA_RADIO
               persistentId:aITunesNotif.persistentID];
            
            return YES;
        }
    }
	// ラジオ
	else if (aCurrentTrack.size == 0) {
		
		BOOL streamChanged = NO;

        // 両方 nil の場合に、isEqualToString が NO を返すため、ここではじいておく。
		if (currentStreamTitle == nil && aCurrentStreamTitle == nil) {
			streamChanged = NO;
		} else {
			if ([currentStreamTitle isEqualToString:aCurrentStreamTitle] == NO) {
				streamChanged = YES;
			} else {
				streamChanged = NO;
			}
		}
		
		// 曲が変わると currentStreamTitle が変わる
		// 局が変わると currentTrack.id    が変わる
		if (streamChanged || trackId != aCurrentTrack.id) {
			         
            iTunesTrack *itrk = [aCurrentTrack get];
            
            // Tagging 用に保存
            [self setCurrentTrack:itrk];
			[self setCurrentStreamTitle:aCurrentStreamTitle];
			
			// タイトル、アーティスト分解
			//   "アーティスト1 - アーティスト2 - タイトル"
			NSString *art = nil;
			NSString *ttl = nil;

			if (aCurrentStreamTitle) {
				NSRange range = [aCurrentStreamTitle rangeOfString:@" - " 
														   options:NSBackwardsSearch];
			
				if (range.location != NSNotFound) {
					art = [aCurrentStreamTitle substringToIndex:range.location];
					ttl = [aCurrentStreamTitle substringFromIndex:range.location+range.length];
				} else {
					ttl = aCurrentStreamTitle;
					art = @"";
				}
			}
			
			// メンバ変数にセット
			[self setSource:aCurrentTrack.name
					  title:ttl
					 artist:art
					trackId:aCurrentTrack.id
					bitRate:aCurrentTrack.bitRate
				   category:aCurrentTrack.category
					 lyrics:nil
                  mediaType:SC_MEDIA_RADIO
               persistentId:aCurrentTrack.persistentID];
			
			return YES;
		}
	} 
	// ラジオ以外
	else {
		// 曲が変わると currentTrack.id    が変わる
		if (trackId != aCurrentTrack.id) {
            
            iTunesTrack *itrk = [aCurrentTrack get];
			
            // Tagging 用に保存
            [self setCurrentTrack:itrk];
			[self setCurrentStreamTitle:aCurrentStreamTitle];
            
			// メンバ変数にセット
			[self setSource:aCurrentTrack.album
					  title:aCurrentTrack.name
					 artist:aCurrentTrack.artist
					trackId:aCurrentTrack.id
					bitRate:aCurrentTrack.bitRate
				   category:aCurrentTrack.category
					 lyrics:aCurrentTrack.lyrics
                  mediaType:SCDetectMedia(aCurrentTrack)
               persistentId:aCurrentTrack.persistentID];
            
			return YES;
		}
	} 
	
	return NO;
}

- (void) updateWithMusicTrack:(iTunesTrack *)aTrack {
    
    // Tagging 用に保存
    [self setCurrentTrack:aTrack];
    
    [self setCurrentStreamTitle:@""];
    
    // メンバ変数にセット
    [self setSource:aTrack.album
              title:aTrack.name
             artist:aTrack.artist
            trackId:aTrack.id
            bitRate:aTrack.bitRate
           category:aTrack.category
             lyrics:aTrack.lyrics
          mediaType:SC_MEDIA_MUSIC
       persistentId:aTrack.persistentID];
}

// Deezer 用
- (BOOL) updateWith:(DeezerTrack *)aLoadedTrack {
    
    NSInteger aLoadedTrack_id = aLoadedTrack.id.integerValue;
    
    // 曲が変わると aLoadedTrack.id    が変わる
    if (trackId != aLoadedTrack_id) {
        
        [self setCurrentTrack:nil];
        [self setCurrentStreamTitle:@""];
        
        // メンバ変数にセット
        [self setSource:aLoadedTrack.album
                  title:aLoadedTrack.title
                 artist:aLoadedTrack.artist
                trackId:aLoadedTrack_id
                bitRate:aLoadedTrack.bpm
               category:@""
                 lyrics:@""
              mediaType:SC_MEDIA_RADIO
           persistentId:aLoadedTrack.id];
        
        return YES;
    }
    
    return NO;
}

- (BOOL) isValid {

	if ([title length] || [artist length]) {
		return YES;
	}
	return NO;
}

- (BOOL) isNotValid {
    
    return ![self isValid];
}

- (BOOL) isCloudStored {
    
    return [currentTrack.className isEqualToString:@"ITunesSharedTrack"];
}

- (void) setSource:(NSString *)aSource title:(NSString *)aTitle artist:(NSString *)aArtist trackId:(NSInteger)aTrackId bitRate:(NSInteger)aBitRate category:(NSString *)aCategory lyrics:(NSString *)aLyrics mediaType:(NSInteger)aMediaType persistentId:(NSString*)aPersistentId {

	
	if (aSource == nil)     [self setSource:@""];
	else                    [self setSource:aSource];
	
	if (aTitle == nil)      [self setTitle:@""];
	else                    [self setTitle:aTitle];
	
	if (aArtist == nil)     [self setArtist:@""];
	else                    [self setArtist:aArtist];
	
	[self setTrackId:aTrackId];
	
	[self setBitRate:[NSString stringWithFormat:@"%d kbps", (int)aBitRate]];

	if (aCategory   == nil) [self setCategory:@""];
	else                    [self setCategory:aCategory];
	
	if (aLyrics     == nil) [self setLyrics:@""];
	else {
     
        // 前後空白類削除 (全半角スペース、タブ、改行)
        NSString *lyrTrim = [aLyrics stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [self setLyrics:lyrTrim];
    }
	
    [self setMediaType:aMediaType];

	if (aPersistentId == nil) [self setPersistentId:@""];
	else                      [self setPersistentId:aPersistentId];
}
@end
