//
//  SCPreferences.h
//  Singer Song Reader
//
//  Created by Developer on 13/10/25.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSCommon.h"
#import "SCSongInformation.h"
#import "SMSiteDataSource.h"
#import "SVSiteTableView.h"

@interface SCPreferences : SSCommon <NSWindowDelegate,  NSControlTextEditingDelegate, NSTableViewDelegate> {

	id delegate;
	
	IBOutlet NSWindow *preferencesWindow;
	IBOutlet NSTabView *tabView;
	
	// Search Tab
	IBOutlet NSComboBox    *autoSrchTimeoutComboBox;
	IBOutlet NSComboBox    *manuSrchTimeoutComboBox;
    IBOutlet NSButton      *japaneseLyricsRomajiCheckBox;
    IBOutlet NSButton      *japaneseLyricsKanjiCheckBox;
    IBOutlet NSButton      *hideNoHitsCheckBox;
    IBOutlet NSButton      *hideLyricsFooterURLCheckBox;
	IBOutlet NSPopUpButton *storeCountryPopUpButton;
	
	// Save Tab
    IBOutlet NSButton      *includeLyricHeaderCheckBox;
    IBOutlet NSButton      *includeLyricFooterCheckBox;
    
    IBOutlet NSTextField   *lyricsFolderTextField;
    IBOutlet NSButton      *subFolderByArtistCheckBox;
    
    IBOutlet NSButton      *askBeforeOverwriteCheckBox; // 現在未使用
    
	// Sites Tab
	IBOutlet NSSplitView   *siteSplitView;
    IBOutlet SVSiteTableView   *enabledSitesTableView;
    IBOutlet SVSiteTableView   *disabledSitesTableView;
    IBOutlet NSScrollView      *enabledSitesScrollView;
    IBOutlet NSScrollView      *disabledSitesScrollView;
    
	IBOutlet NSSplitView   *siteSplitView2;
    IBOutlet SVSiteTableView   *enabledSitesTableView2;
    IBOutlet SVSiteTableView   *disabledSitesTableView2;
    IBOutlet NSScrollView      *enabledSitesScrollView2;
    IBOutlet NSScrollView      *disabledSitesScrollView2;
    
    
	IBOutlet NSButton      *applyButton;

    IBOutlet NSButton      *openiTunesAtLaunchCheckBox;
    IBOutlet NSButton      *alwaysOnTopCheckBox;

    SMSiteDataSource *siteDataSource;
}

- (void) setDelegate:(id)aDelegate;

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification;

- (IBAction) applyButtonClicked:(id)sender;
- (IBAction) showPreferenceWindow:(id)sender;
- (IBAction) openCountryTab:(id)sender;
- (IBAction) browseButtonClicked:(id)sender;

- (BOOL) control:(NSControl *)control isValidObject:(id)object;

- (void) loadPreferences;
- (IBAction) resetSiteList:(id)sender;
- (IBAction) deselectAll:(id)sender;
- (BOOL) isValid:(NSControl *) control;
- (void) load:(NSComboBox *)comboBox forKey:(NSString *)key;
- (void) save:(NSComboBox *)comboBox forKey:(NSString *)key;
- (void) saveIfValid:(NSComboBox *)comboBox forKey:(NSString *)key;

- (void) adjustDividerPosition;
- (void) siteDataDidChange:(id)sender;

@end
