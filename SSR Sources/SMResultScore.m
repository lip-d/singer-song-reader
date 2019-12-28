//
//  SMResultScore.m
//  Singer Song Reader
//
//  Created by Developer on 13/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMResultScore.h"


@implementation SMResultScore

@synthesize totalScore;

- (id) init {
    self = [super init];
    if (self) {
		totalScore  = 0;
	}
	
	return self;
}

- (void) clear {

	totalScore  = 0;
}
@end
