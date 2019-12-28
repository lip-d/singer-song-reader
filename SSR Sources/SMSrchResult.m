//
//  SMSrchResult.m
//  Singer Song Reader
//
//  Created by Developer on 13/10/02.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMSrchResult.h"


@implementation SMSrchResult

@synthesize url;

- (id)init {
    self = [super init];
    if (self) {
		title  = nil;
		artist = nil;
		lyrics = nil;
		url    = nil;
	}
	
	return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void) clear {
	[self setTitle:SMEmpty];
	[self setArtist:SMEmpty];
	[self setLyrics:SMEmpty];
	[self setUrl:SMEmpty];
}

- (NSString *) title {
    
    return title;
}

- (NSString *) artist {
    
    return artist;
}

- (NSString *) lyrics {
    
    return lyrics;
}

- (void) setTitle:(NSString *)ttl {
    
    [self setData:ttl to:&title];
}

- (void) setArtist:(NSString *)art {
    
    [self setData:art to:&artist];
}


- (void) setLyrics:(NSString *)lyr {
    
    [self setData:lyr to:&lyrics];
}

- (void) setData:(NSString *)source to:(NSString **)target {
    
    if (*target != source) {
        
        [*target release];
        
        *target = [[source stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] retain];
    }
}


@end
