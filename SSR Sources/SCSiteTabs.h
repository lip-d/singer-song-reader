//
//  SCSiteTabs.h
//  Singer Song Reader
//
//  Created by Developer on 2014/02/10.
//
//

#import <Foundation/Foundation.h>
#import "SSCommon.h"
#import "SMSite.h"


@interface SCSiteTabs : SSCommon {

    IBOutlet NSSegmentedControl *siteTab;

}

- (void) disableAll;
- (void) clearAllWith:(NSArray *)siteList;
- (void) syncAllWith:(NSArray *)siteList;
- (void) syncWith:(SMSite *)site andEnable:(BOOL)enableFlag;
- (void) syncStatusWith:(SMSite *)site andEnable:(BOOL)enableFlag;
- (void) syncStatusAllWith:(NSArray *)siteList;

- (void) clickNextTab;
- (void) clickPrevTab;
- (void) selectTabAtIndex:(NSInteger)index;

- (NSInteger) selectedIndex;
- (NSInteger) count;

- (NSInteger) nextTabIndex;
- (NSInteger) prevTabIndex;

@end
