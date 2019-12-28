//
//  SCSiteTabs.m
//  Singer Song Reader
//
//  Created by Developer on 2014/02/10.
//
//

#import "SCSiteTabs.h"

@implementation SCSiteTabs

- (void) disableAll {
    
    NSInteger count = [siteTab segmentCount];
    
    for (int i=0; i<count; i++) {
        
        [siteTab setEnabled :NO forSegment:i];
		[siteTab setSelected:NO forSegment:i];
    }
}

- (void) clearAllWith:(NSArray *)siteList {
    
    // サイトタブ数リセット
    [siteTab setSegmentCount:0];
    [siteTab display];
    [siteTab setSegmentCount:[siteList count]];
    
    int i = 0;
	for (id site in siteList) {
        
        [siteTab setWidth:0     forSegment:i];
        [siteTab setEnabled :NO forSegment:i];
		[siteTab setSelected:NO forSegment:i];
        
        NSImage *img = [[super SC_STATE] objectAtIndex:SC_STATE_OFF];
        
        [siteTab setImage:img forSegment:i];
        
        // サイト名表示
        NSString *siteName = nil;
        
        if (i < 5) siteName = [site siteName];
        else       siteName = [site siteKey];
            
        [siteTab setLabel:siteName forSegment:i];
        
        // ツールチップ設定
        [[siteTab cell] setToolTip:[site siteName] forSegment:i];
        
        i++;
    }
}

- (void) syncAllWith:(NSArray *)siteList {
    
    // サイトタブ数を一旦リセット
    [siteTab setSegmentCount:0];
    [siteTab display];

    // タブ数
    int tabNum = siteList.count;
    
    // Hide no hit 設定取得
    if ([super userHideNoHits])
        tabNum = [self countHitSites:siteList];
    
    // サイトタブ数を再セット
    [siteTab setSegmentCount:tabNum];
    
    int i = 0;
    for (id site in siteList) {

        if (i == tabNum) break;
        
        // サイトタブに反映
        [self syncWith:site andEnable:NO];

        i++;
    }
}

- (void) syncWith:(SMSite *)site andEnable:(BOOL)enableFlag {
    
    NSInteger idx  = [site siteIndex];
    NSInteger code = [site resultCode];
    NSInteger sts  = statusForCode(code);
    
    // 幅自動
    [siteTab setWidth:0     forSegment:idx];

    // LED 表示
    NSImage *img = [[super SC_STATE] objectAtIndex:sts];
    
	[siteTab setImage:img forSegment:idx];
    
    // サイト名表示
    NSString *siteName = nil;
    
    if (idx < 5) siteName = [site siteName];
    else         siteName = [site siteKey];
    
    [siteTab setLabel:siteName forSegment:idx];
    
    // ツールチップ設定
    [[siteTab cell] setToolTip:[site siteName] forSegment:idx];
    
    if (enableFlag) {
        [siteTab setEnabled:enableFlag forSegment:idx];
    }
}

- (void) syncStatusWith:(SMSite *)site andEnable:(BOOL)enableFlag {
    
    NSInteger idx  = [site siteIndex];
    NSInteger code = [site resultCode];
    NSInteger sts  = statusForCode(code);
    
    // LED 表示
    NSImage *img = [[super SC_STATE] objectAtIndex:sts];
    
	[siteTab setImage:img forSegment:idx];

    if (enableFlag) {
        [siteTab setEnabled:enableFlag forSegment:idx];
    }
}

- (void) syncStatusAllWith:(NSArray *)siteList {
    
    NSInteger sts;
    
    // タブ数
    int tabNum = siteList.count;
    
    // Hide no hit 設定取得
    if ([super userHideNoHits])
        tabNum = [self countHitSites:siteList];
    
    int i = 0;
    for (id site in siteList) {
        
        if (i == tabNum) break;
        
        if ([site taggedLyrics]) {
            
            sts = SC_STATE_CHECK;
        } else {
            
            sts  = statusForCode([site resultCode]);
        }
        
        NSImage *img = [[super SC_STATE] objectAtIndex:sts];
        
        [siteTab setImage:img forSegment:i];
        
        i++;
    }
}

- (void) clickNextTab {
 
    if (siteTab.selectedSegment+1 < siteTab.segmentCount) {
        
        [[siteTab cell] makeNextSegmentKey];
        [siteTab performClick:self];
    }
}

- (void) clickPrevTab {
    
    if (siteTab.selectedSegment > 0) {
        
        [[siteTab cell] makePreviousSegmentKey];
        [siteTab performClick:self];
    }
}

- (void) selectTabAtIndex:(NSInteger)index {
    
    [siteTab setSelectedSegment:index];
}

- (NSInteger) selectedIndex {
    
    return siteTab.selectedSegment;
}

- (NSInteger) count {
    
    return siteTab.segmentCount;
}

// 次の Tab インデックスを返す。現在位置が最終の場合、最終インデックスを返す。
- (NSInteger) nextTabIndex {
    
    NSInteger selectedSegment = siteTab.selectedSegment;
    NSInteger lastSegment     = siteTab.segmentCount-1;
    
    if (selectedSegment == -1) return -1;
    
    if (selectedSegment < lastSegment) return selectedSegment+1;
    else                               return lastSegment;
}

// 前の Tab インデックスを返す。現在位置が先頭の場合、先頭インデックスを返す。
- (NSInteger) prevTabIndex {

    NSInteger selectedSegment = siteTab.selectedSegment;
    NSInteger firstSegment     = 0;

    if (selectedSegment == -1) return -1;

    if (selectedSegment > firstSegment) return selectedSegment-1;
    else                                return firstSegment;
}

- (NSInteger) countHitSites:(NSArray *)siteList {

    // ヒットサイト数カウント
    int num = 0;

    for (id site in siteList) {
        if ([site isHit])
            num++;
        else
            break;
    }

    return num;
}

@end
