//
//  SMResultScore.h
//  Singer Song Reader
//
//  Created by Developer on 13/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SMResultScore : NSObject {
	NSInteger totalScore;
}

@property NSInteger totalScore;

- (void) clear;

@end
