//
//  SMBioStatsDataSource.h
//  Singer Song Reader
//
//  Created by Developer on 2014/01/29.
//
//

#import <Foundation/Foundation.h>

@interface SMBioStatsDataSource : NSObject <NSTableViewDataSource> {
    
    NSMutableArray *dataArray;
}

- (void) setDataArray:(NSArray *)aDataArray;
- (void) clearDataArray;

@end
