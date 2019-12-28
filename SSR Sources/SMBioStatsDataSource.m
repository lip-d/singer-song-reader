//
//  SMBioStatsDataSource.m
//  Singer Song Reader
//
//  Created by Developer on 2014/01/29.
//
//

#import "SMBioStatsDataSource.h"

@implementation SMBioStatsDataSource

- (id)init {
    self = [super init];
    if (self) {

        dataArray = [[NSMutableArray alloc] initWithCapacity:0];
	}
	
	return self;
}

- (void)dealloc {
    [dataArray release];
    [super dealloc];
}

- (void) setDataArray:(NSArray *)aDataArray {
    
    [dataArray setArray:aDataArray];
}

- (void) clearDataArray {
    
    [dataArray removeAllObjects];
}

// TableView の行数を返す
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {

    return [dataArray count];
}

// TableView の中身を返す
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    
    NSString *columnIdentifier = [aTableColumn identifier];
    
    if ([columnIdentifier isEqualToString:@"KEY"]) {

        return [[dataArray objectAtIndex:rowIndex] objectAtIndex:0];
    } else {
    
        return [[dataArray objectAtIndex:rowIndex] objectAtIndex:1];
    }
}

@end
