//
//  SMLyricsTime.h
//  Singer Song Reader
//
//  Created by Developer on 13/11/20.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SMSite.h"

@interface SMLyricsTime : SMSite {
	
	NSString *urlFormat1;
	NSString *urlFormat2;
}

- (NSString *) url1;
- (NSString *) url2;
- (NSNumber *) analyze1:(id)aData;
- (NSNumber *) analyze2:(id)aData;


@end
