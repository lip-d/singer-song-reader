//
//  SMSiteData.m
//  Singer Song Reader
//
//  Created by Developer on 2013/11/30.
//
//

#import "SMSiteDataSource.h"
#import "SSCommon.h"

const int SCTableRowMax = 10;


@implementation SMSiteDataSource

- (id)init {
    self = [super init];
    if (self) {
        
		// サイト名キー (3文字コード 例:"LWK") を有効/無効に分けて管理
        enabledSites  = [[NSMutableArray alloc] initWithCapacity:0];
        disabledSites = [[NSMutableArray alloc] initWithCapacity:0];

		siteDict = nil;
	}
	
	return self;
}

@synthesize enabledSites;
@synthesize disabledSites;

- (void)dealloc {
    [enabledSites  release];
    [disabledSites release];
    [super dealloc];
}

- (void) setDelegate:(id)aDelegate {
	delegate = aDelegate;
}

- (void) setSiteDictionary:(NSDictionary *)aSiteDict {
	
	siteDict = aSiteDict;
}

// ユーザ設定から取得した検索サイトのリストをセットする
- (void) setEnabledSites:(NSArray *)aEnabledSites disabledSites:(NSArray *)aDisabledSites {
    
    [enabledSites  removeAllObjects];
    [disabledSites removeAllObjects];

    NSMutableDictionary *siteTemp = [[NSMutableDictionary alloc] init];
    
    [siteTemp setDictionary:siteDict];
    
    // 有効サイトリスト
    for (NSString *key in aEnabledSites) {
        
		// サイト存在チェック
        if ([siteDict objectForKey:key]) {
            
            // 有効サイトリストに追加
            [enabledSites addObject:key];
			
            [siteTemp removeObjectForKey:key];
        }
    }
	
    // 無効サイトリスト
    for (NSString *key in aDisabledSites) {
        
		// サイト存在チェック
        if ([siteDict objectForKey:key]) {
            
            // 無効サイトリストに追加
            [disabledSites addObject:key];
			
            [siteTemp removeObjectForKey:key];
        }
    }
	
    // 残り (バージョンアップで追加されたサイト)
    for (NSString *key in [siteTemp allKeys]) {

        // 有効サイトリストに追加
        [enabledSites addObject:key];
    }
    
    [siteTemp release];
}

// サイト有効化
- (void) enableSiteAtIndex:(NSInteger)index {
	
	NSString *siteName = [disabledSites objectAtIndex:index];
    
	[enabledSites addObject:siteName];

    [disabledSites removeObjectAtIndex:index];
}

// サイト無効化
- (void) disableSiteAtIndex:(NSInteger)index {
    
	NSString *siteName = [enabledSites objectAtIndex:index];
    
	[disabledSites addObject:siteName];

    [enabledSites removeObjectAtIndex:index];
}

// 全サイト無効化
- (void) disableAllSites {
    
    NSMutableArray *disabledSitesTmp = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    // 現在の Enabled サイトから優先して Disabled サイトに移す
    for (NSString *siteName in enabledSites) {
        
        [disabledSitesTmp addObject:siteName];
    }
    
    // Disabled サイト
    for (NSString *siteName in disabledSites) {
        
        [disabledSitesTmp addObject:siteName];
    }
    
    // Disabled サイト置き換え
    [disabledSites setArray:disabledSitesTmp];
    
    // Enabled サイト消去
    [enabledSites removeAllObjects];
}

// 各 TableView の行数を返す
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
	
	NSInteger rowNum = 0;
	NSInteger rMax   = 0;
	
	rowNum = [enabledSites count];
	
	switch ([aTableView tag]) {
		case SM_ENABLED_SITES:
			
			if (rowNum > SCTableRowMax) {
				return SCTableRowMax;
			} else {
				return rowNum;
			}
			break;
			
		case SM_DISABLED_SITES:
			
			if (rowNum > SCTableRowMax) {
				return 0;
			} else {
				rMax = SCTableRowMax - rowNum;
				
				return rMax;
			}
			break;
			
		case SM_ENABLED_SITES2:

			if (rowNum > SCTableRowMax) {
				return rowNum - SCTableRowMax;
			} else {
				return 0;
			}
			break;
			
		case SM_DISABLED_SITES2:
			
			if (rowNum > SCTableRowMax) {
				
				return [disabledSites count];
			} else {
				rMax = SCTableRowMax - rowNum;
				
				rowNum = [disabledSites count];
				
				return rowNum - rMax;
			}
			break;

	}
	return 0;
}

// 各 TableView の中身を返す
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {

	NSString *columnIdentifier = [aTableColumn identifier];
	
	NSInteger rowNum = 0;
	NSInteger rMax   = 0;
	
	rowNum = [enabledSites count];
	
	// 有効サイト
	if ([aTableView tag] == SM_ENABLED_SITES ||
		[aTableView tag] == SM_ENABLED_SITES2) {

		if ([aTableView tag] == SM_ENABLED_SITES2) {
			rowIndex += SCTableRowMax;
		}
		
		if ([columnIdentifier isEqualToString:@"CHK"]) {

			return @"1";
		}
		else if ([columnIdentifier isEqualToString:@"NUM"]) {
		
			return [NSString stringWithFormat:@"%2d", (int)(rowIndex + 1)];
		}
		else if ([columnIdentifier isEqualToString:@"NAM"]) {
		
			NSString *key = [enabledSites  objectAtIndex:rowIndex];
			
			// サイト Dictionary で Key を指定してサイト正式名称を取得
			NSString *siteName = [[siteDict objectForKey:key] objectAtIndex:0];
		
			return siteName;
		}
		else {
			return [enabledSites objectAtIndex:rowIndex];
		}
	}
	// 無効サイト
	else {
		
		if ([aTableView tag] == SM_DISABLED_SITES2) {
			
			if (rowNum < SCTableRowMax) {
			
				rMax = SCTableRowMax - rowNum;
				
				rowIndex += rMax;
			}
		}

		if ([columnIdentifier isEqualToString:@"CHK"]) {
			
			return @"0";
		}
		else if ([columnIdentifier isEqualToString:@"NUM"]) {

			return @"";
		}
		else if ([columnIdentifier isEqualToString:@"NAM"]) {
			
			NSString *key = [disabledSites  objectAtIndex:rowIndex];
			
			// サイト Dictionary で Key を指定してサイト正式名称を取得
			NSString *siteName = [[siteDict objectForKey:key] objectAtIndex:0];
			
			return siteName;
		}
		else {
			return [disabledSites objectAtIndex:rowIndex];
		}
	}
}

// 有効/無効チェックボックスクリック時に呼ばれる
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	
	if (rowIndex < 0) return;
	
	BOOL dataChanged = NO;
	
	if ([aTableView tag] == SM_ENABLED_SITES ||
		[aTableView tag] == SM_ENABLED_SITES2) {
		
		if ([aTableView tag] == SM_ENABLED_SITES2) {
			rowIndex += SCTableRowMax;
		}
		
		if ([[aTableColumn identifier] isEqualToString:@"CHK"]) {
			
			[self disableSiteAtIndex:rowIndex];
			
			dataChanged = YES;
		}
	}
	else {
		
		if ([aTableView tag] == SM_DISABLED_SITES2) {
			
			NSInteger rowNum = 0;
			NSInteger rMax   = 0;
			
			rowNum = [enabledSites count];
			
			if (rowNum < SCTableRowMax) {
				
				rMax = SCTableRowMax - rowNum;
				
				rowIndex += rMax;
			}
		}
		
		if ([[aTableColumn identifier] isEqualToString:@"CHK"]) {
			
			[self enableSiteAtIndex:rowIndex];

			dataChanged = YES;
		}
	}

	if (dataChanged) {
		// データ変更通知
		[delegate performSelector:@selector(siteDataDidChange:) withObject:self];
	}
}

- (NSInteger) count {
	
	return [enabledSites count] + [disabledSites count];
}

@end
