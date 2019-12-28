//
//  SMAnimeLyrics.h
//  Singer Song Reader
//
//  Created by Developer on 5/11/14.
//
//

#import "SMSite.h"
#import "SMAnimeLyricsSrchResult.h"

@interface SMAnimeLyrics : SMSite <SMSiteJsonChildProtocol> {

    NSString *titleRest;
    NSString *artistRest;
}

@property (readonly, retain) NSString *titleRest;
@property (readonly, retain) NSString *artsitRest;

@end
