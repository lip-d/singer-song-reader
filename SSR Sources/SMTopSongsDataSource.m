//
//  SMTopSongsDataSource.m
//  Singer Song Reader
//
//  Created by Developer on 2014/01/29.
//
//

#import "SMTopSongsDataSource.h"

@implementation SMTopSongsDataSource

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
    
    int i = 0;
    for (NSDictionary *dict in aDataArray) {
        
        /*
        NSString *testString = [dict valueForKey:@"trackName"];
        NSAttributedString *attrString = [[NSAttributedString alloc]
                                   initWithString:testString
                                   attributes:@{
                                                NSForegroundColorAttributeName : [NSColor blueColor]}
                                   ];
*/
 
        NSArray *item = [NSArray arrayWithObjects:
                         [NSString stringWithFormat:@"%2d", i+1], // NUM
                         [dict valueForKey:@"trackName"],         // TTL
                         nil];
/*
        NSArray *item = [NSArray arrayWithObjects:
                         [NSString stringWithFormat:@"%2d", i+1], // NUM
                         attrString,         // TTL
                         nil];
*/
        // テーブルのデータソースとして要素を追加
        [dataArray addObject:item];
        
        i++;
    }
}

- (void) clearDataArray {
    
    [dataArray removeAllObjects];
}

- (NSArray *) dataArray {
    
    return dataArray;
}

- (NSString *) copyRow:(NSInteger)index {
    
    return @"test";
}

// 指定行の文字色をグリーンに変更する
- (void) setHighlightItemOfIndex:(NSInteger)aIndex {
    
    if (aIndex < [dataArray count]) {
    
        NSArray *item = [dataArray objectAtIndex:aIndex];
        
        NSString     *str = [item objectAtIndex:1];
        NSDictionary *attr = @{NSForegroundColorAttributeName : [NSColor greenColor]};

        
        NSAttributedString *attrStr = [[[NSAttributedString alloc] initWithString:str attributes:attr] autorelease];
        
   
        NSArray *newItem = [NSArray arrayWithObjects:
                         [NSString stringWithFormat:@"%2d", (int)(aIndex+1)], // NUM
                         attrStr,         // TTL
                         nil];

        [dataArray replaceObjectAtIndex:aIndex withObject:newItem];
    }
}

// TableView の行数を返す
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    
    return [dataArray count];
}

// TableView の中身を返す
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    
    NSString *columnIdentifier = [aTableColumn identifier];
    
    if ([columnIdentifier isEqualToString:@"NUM"]) {
        
        return [[dataArray objectAtIndex:rowIndex] objectAtIndex:0];
    } else {
        
        return [[dataArray objectAtIndex:rowIndex] objectAtIndex:1];
    }
}

@end
