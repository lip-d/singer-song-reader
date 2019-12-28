//
//  SSShare.m
//  Singer Song Reader
//
//  Created by Developer on 2014/03/08.
//
//

#import "SSShare.h"

@implementation SSShare

@synthesize batchMode;

- (id)init {
    self = [super init];
    if (self) {
        
        // UI バインディング
        [self setBatchMode:NSOffState];
    }
    
    return self;
}

@end
