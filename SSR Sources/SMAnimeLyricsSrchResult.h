//
//  SMAnimeLyricsSrchResult.h
//  Singer Song Reader
//
//  Created by Developer on 5/14/14.
//
//

#import "SMSrchResult.h"

@interface SMAnimeLyricsSrchResult : SMSrchResult {

    NSString *otherTitle;
    NSArray  *otherArtists;
    NSArray  *headerNotes;
    NSArray  *footerNotes;
}

@property (retain) NSString *otherTitle;
@property (retain) NSArray  *otherArtists;
@property (retain) NSArray  *headerNotes;
@property (retain) NSArray  *footerNotes;

- (void) clear;

@end
