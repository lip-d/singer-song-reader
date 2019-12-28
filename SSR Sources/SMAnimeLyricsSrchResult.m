//
//  SMAnimeLyricsSrchResult.m
//  Singer Song Reader
//
//  Created by Developer on 5/14/14.
//
//

#import "SMAnimeLyricsSrchResult.h"

@implementation SMAnimeLyricsSrchResult

@synthesize otherArtists;
@synthesize headerNotes;
@synthesize footerNotes;

- (id)init {
    self = [super init];
    if (self) {
		otherTitle     = nil;
		otherArtists   = nil;
        headerNotes    = nil;
        footerNotes    = nil;
	}
	
	return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void) clear {
    [super clear];

	[self setOtherTitle:SMEmpty];
    [self setOtherArtists:nil];
    [self setHeaderNotes:nil];
    [self setFooterNotes:nil];
}

- (NSString *) otherTitle {
    
    return otherTitle;
}

- (void) setOtherTitle:(NSString *)ttl {
    
    [self setData:ttl to:&otherTitle];
}



@end
