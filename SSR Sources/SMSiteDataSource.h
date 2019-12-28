//
//  SMSiteDataSource.h
//  Singer Song Reader
//
//  Created by Developer on 2013/11/30.
//
//

#import <Cocoa/Cocoa.h>

// サイト TableView Tag
typedef enum {
	SM_ENABLED_SITES   = 0,
	SM_DISABLED_SITES  = 1,
	SM_ENABLED_SITES2  = 2,
	SM_DISABLED_SITES2 = 3,
} SMSiteTableTag;


@interface SMSiteDataSource : NSObject <NSTableViewDataSource> {
	id delegate;
	
    NSMutableArray *enabledSites;
    NSMutableArray *disabledSites;
    
@private
    
    NSDictionary   *siteDict;
}

@property (readonly) NSMutableArray *enabledSites;
@property (readonly) NSMutableArray *disabledSites;

- (void) setDelegate:(id)aDelegate;

- (void) setSiteDictionary:(NSDictionary *)aSiteDict;
- (void) setEnabledSites:(NSArray *)aEnabledSites disabledSites:(NSArray *)aDisabledSites;

- (void) enableSiteAtIndex:(NSInteger)index;
- (void) disableSiteAtIndex:(NSInteger)index;
- (void) disableAllSites;

- (NSInteger) count;

@end
