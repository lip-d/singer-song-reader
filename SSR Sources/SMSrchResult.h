//
//  SMSrchResult.h
//  Singer Song Reader
//
//  Created by Developer on 13/10/02.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSCommon.h"
#import "SMSrchResultProtocol.h"


@interface SMSrchResult : NSObject <SMSrchResultProtocol> {
	NSString *title;
	NSString *artist;
	NSString *lyrics;
	NSString *url;
}

@property (retain) NSString *title;
@property (retain) NSString *artist;
@property (retain) NSString *lyrics;
@property (retain) NSString *url;

- (void) clear;

- (void) setData:(NSString *)source to:(NSString **)target;

@end
