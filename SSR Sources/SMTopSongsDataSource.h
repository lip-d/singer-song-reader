//
//  SMTopSongsDataSource.h
//  Singer Song Reader
//
//  Created by Developer on 2014/01/29.
//
//

#import <Foundation/Foundation.h>

@interface SMTopSongsDataSource : NSObject <NSTableViewDataSource> {
    
    NSMutableArray *dataArray;
}

- (void) setDataArray:(NSArray *)aDataArray;
- (void) clearDataArray;
- (NSString *) copyRow:(NSInteger)index;

- (void) setHighlightItemOfIndex:(NSInteger)aIndex;

@end
