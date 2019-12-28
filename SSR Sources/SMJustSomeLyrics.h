//
//  SMJustSomeLyrics.h
//  Singer Song Reader
//
//  Created by Developer on 2013/12/06.
//
//

#import <Cocoa/Cocoa.h>
#import "SMSite.h"

@interface SMJustSomeLyrics : SMSite {
	
	NSString *urlFormat1;
}

- (NSString *) url1;
- (NSString *) url2;
- (NSNumber *) analyze1:(id)aData;
- (NSNumber *) analyze2:(id)aData;

@end
