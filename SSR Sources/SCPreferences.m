//
//  SCPreferences.m
//  Singer Song Reader
//
//  Created by Developer on 13/10/25.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SCPreferences.h"
#import "SSCommon.h"
#import "SMCountries.h"

@implementation SCPreferences

- (id)init {
    self = [super init];
    if (self) {
	
		// 前回の有効/無効サイトリスト取り出し
		NSArray *userEnabledSites  = [super userEnabledSites];
		NSArray *userDisabledSites = [super userDisabledSites];
		
		// 有効/無効サイト TableView のデータソースを管理するクラス
        siteDataSource = [[SMSiteDataSource alloc] init];
		
		// サイト Dictionary をセット
		[siteDataSource setSiteDictionary:[super siteDict]];
		
		// サイト有効/無効リストをセット
		[siteDataSource setEnabledSites:userEnabledSites disabledSites:userDisabledSites];

		// Enabled/Disabled Site list
		NSArray *enabledSites   = [siteDataSource enabledSites];
		NSArray *disabledSites  = [siteDataSource disabledSites];

		// バージョンアップでサイトが追加されている場合があるため、ここでチェックし、UD と同期する
		if ([enabledSites isEqualToArray:userEnabledSites] == NO) {

			// サイトが追加されていたら、設定を再保存
			[userDefault setObject:[super dataFromArray:enabledSites]  forKey:UDEnabledSites];
			[userDefault setObject:[super dataFromArray:disabledSites] forKey:UDDisabledSites];

			// 即反映
			[userDefault synchronize];
		}

		// データ更新時に自分に通知をもらよう設定
		[siteDataSource setDelegate:self];
	}
	
	return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void) setDelegate:(id)aDelegate {
	delegate = aDelegate;
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
	
	//----------------------------------------
	// 国名リスト
	//----------------------------------------

	// 国名リストを Country ポップアップボタンに反映
	for (NSString *name in [SMCountries names]) {
		
		[storeCountryPopUpButton addItemWithTitle:name];
	}
	
	// 前回の国コード取り出し・画面反映
	NSString *code  = [super userCountryCode];
	NSInteger index = [SMCountries indexOfCode:code];

	[storeCountryPopUpButton selectItemAtIndex:index];
    
	//----------------------------------------
	// 検索サイトリスト
	//----------------------------------------

	// Table View に識別用の Tag を設定
	[enabledSitesTableView  setTag:SM_ENABLED_SITES];
	[disabledSitesTableView setTag:SM_DISABLED_SITES];
	
	[enabledSitesTableView2  setTag:SM_ENABLED_SITES2];
	[disabledSitesTableView2 setTag:SM_DISABLED_SITES2];
	
	// TableView のデータソースを紐付け
    [enabledSitesTableView  setDataSource:siteDataSource];
    [disabledSitesTableView setDataSource:siteDataSource];
	
    [enabledSitesTableView2  setDataSource:siteDataSource];
    [disabledSitesTableView2 setDataSource:siteDataSource];
	
	// Table 仕切り位置調整
	[self adjustDividerPosition];
    
	// テーブル第一列をチェックボックスに設定
	NSButtonCell* cell = [[[NSButtonCell alloc] initTextCell: @""] autorelease];
	[cell setButtonType:NSSwitchButton];
	
	[[enabledSitesTableView   tableColumnWithIdentifier:@"CHK"] setDataCell:cell];
	[[disabledSitesTableView  tableColumnWithIdentifier:@"CHK"] setDataCell:cell];

	[[enabledSitesTableView2  tableColumnWithIdentifier:@"CHK"] setDataCell:cell];
	[[disabledSitesTableView2 tableColumnWithIdentifier:@"CHK"] setDataCell:cell];
    
    
    // Disable elasticity
    if ([enabledSitesScrollView respondsToSelector:@selector(setVerticalScrollElasticity:)]) {
        
        [enabledSitesScrollView    setVerticalScrollElasticity:NSScrollElasticityNone];
        [disabledSitesScrollView   setVerticalScrollElasticity:NSScrollElasticityNone];
        [enabledSitesScrollView2   setVerticalScrollElasticity:NSScrollElasticityNone];
        [disabledSitesScrollView2  setVerticalScrollElasticity:NSScrollElasticityNone];
    }
}

// Apply ボタンクリック
- (IBAction) applyButtonClicked:(id)sender {
	
	//----------------------------------------
	// Search Tab
	//----------------------------------------
	
	// 各設定値保存
	//   - 値が正常範囲内の場合: 保存
	//   - 値が正常範囲外の場合: 元の値を表示
	
	// Automatic search timeout
	[self saveIfValid:autoSrchTimeoutComboBox forKey:UDAutoSrchTimeout];

	// Manual search timeout
	[self saveIfValid:manuSrchTimeoutComboBox forKey:UDManuSrchTimeout];

    // Japanese Lyrics: Romaji
    [userDefault setObject:[super dataFromInteger:[japaneseLyricsRomajiCheckBox state]] forKey:UDJapaneseLyricsRomaji];
    
    // Japanese Lyrics: Kanji
    [userDefault setObject:[super dataFromInteger:[japaneseLyricsKanjiCheckBox state]] forKey:UDJapaneseLyricsKanji];
    
    // Hide no hits
    [userDefault setObject:[super dataFromInteger:[hideNoHitsCheckBox state]] forKey:UDHideNoHits];
    
    // Hide lyrics footer URL
    [userDefault setObject:[super dataFromInteger:[hideLyricsFooterURLCheckBox state]] forKey:UDHideLyricFooterURL];
    
	//----------------------------------------
	// Save Tab
	//----------------------------------------

    // Include lyric header
    [userDefault setObject:[super dataFromInteger:[includeLyricHeaderCheckBox state]] forKey:UDIncludeLyricHeader];
    
    // Include lyric footer
    [userDefault setObject:[super dataFromInteger:[includeLyricFooterCheckBox state]] forKey:UDIncludeLyricFooter];
    
    // Lyrics Folder
    NSString *path = [lyricsFolderTextField stringValue];
    [userDefault setObject:path forKey:UDLyricsFolder];
    
    // Create sub-folders by artist's name
    [userDefault setObject:[super dataFromInteger:[subFolderByArtistCheckBox state]] forKey:UDSubFolderByArtist];
    
    // Ask before overwrite
    [userDefault setObject:[super dataFromInteger:[askBeforeOverwriteCheckBox state]] forKey:UDAskBeforeOverwrite];

    
	// Country
	NSMenuItem *item  = [storeCountryPopUpButton selectedItem];
	NSInteger   index = [storeCountryPopUpButton indexOfItem:item];
	NSString   *code  = [SMCountries codeAtIndex:index];
	
	// 現在の国コード設定を取り出して、変更されたかを判断する
	NSString *userCode = [super userCountryCode];
	BOOL countryChanged = NO;
	if ([code isEqualToString:userCode] == NO) {
		countryChanged = YES;
	}

	// delegate に国コード変更通知
	if (countryChanged) {

		// 設定保存
		[userDefault setObject:code forKey:UDCountryCode];
		
		// 即反映
		[userDefault synchronize];

		// 通知
		[delegate performSelector:@selector(preferencesCountryChanged:)
					   withObject:self];
	}
		
	//----------------------------------------
	// Sites Tab
	//----------------------------------------
	
	// Enabled/Disabled Site list
	NSArray *enabledSites  = [siteDataSource enabledSites];
	NSArray *disabledSites = [siteDataSource disabledSites];
	
	// 現在の検索サイトリストを取り出して、変更されたかを判断する
	NSArray *userEnabledSites = [super userEnabledSites];
	BOOL siteListChanged = NO;
	if ([enabledSites isEqualToArray:userEnabledSites] == NO) {
		siteListChanged = YES;
	}

	// delegate に検索サイトリスト変更通知
	if (siteListChanged) {

		// 設定保存
		[userDefault setObject:[super dataFromArray:enabledSites]  forKey:UDEnabledSites];
		[userDefault setObject:[super dataFromArray:disabledSites] forKey:UDDisabledSites];
		
		// 即反映
		[userDefault synchronize];

		// 通知
		[delegate performSelector:@selector(preferencesSiteListChanged:)
					   withObject:self];
	}

    //----------------------------------------
    // Bottom
    //----------------------------------------
    // OpeniTunesAtLaunch
    [userDefault setObject:[super dataFromInteger:[openiTunesAtLaunchCheckBox state]] forKey:UDOpeniTunesAtLaunch];
    
    // AlwaysOnTop
    [userDefault setObject:[super dataFromInteger:[alwaysOnTopCheckBox state]] forKey:UDAlwaysOnTop];
    
    // 通知
    [delegate performSelector:@selector(preferencesAlwaysOnTopChanged:)
                   withObject:self];
    
	// 即反映
	[userDefault synchronize];
}

- (IBAction) browseButtonClicked:(id)sender {
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:NO];
    
    NSInteger result = [openPanel runModal];
    
    if (result == NSOKButton) {
        
        NSString *path = [[openPanel URL] path];
        
        [lyricsFolderTextField setStringValue:path];
    }
}

// Window Open/Close
- (IBAction) showPreferenceWindow:(id)sender {
	
	if ([preferencesWindow isVisible]) {
		
		[preferencesWindow close];
	} else {
		
		[self loadPreferences];
        [preferencesWindow center];
        [preferencesWindow setLevel:NSFloatingWindowLevel];
		[preferencesWindow makeKeyAndOrderFront:self];
	}
}

- (IBAction) openCountryTab:(id)sender {
	
	[tabView selectTabViewItemAtIndex:0];
	[preferencesWindow makeKeyAndOrderFront:self];	
}

// ヒット率しきい値 ComboBox 妥当性チェック
- (BOOL) control:(NSControl *)control isValidObject:(id)object {

	BOOL isValid = NO;
	
	NSInteger value = [object integerValue];

	switch ([control tag]) {
		case 0:
			// Automatic search timeout
			if (value >= 1 && value <= 30) {
				isValid = YES;
			}
			break;
		case 1:
			// Manual search timeout
			if (value >= 1 && value <= 60) {
				isValid = YES;
			}
			break;
		default:
			isValid = NO;
			break;
	}
	
	return isValid;
}

// 設定値取り出し・画面反映
- (void) loadPreferences {
	
	// 前回の各設定値取り出し・画面項目に反映
	
	// Search Tab
	[self load:autoSrchTimeoutComboBox forKey:UDAutoSrchTimeout];
	[self load:manuSrchTimeoutComboBox forKey:UDManuSrchTimeout];
    [japaneseLyricsRomajiCheckBox setState:[super userJapaneseLyricsRomaji]];
    [japaneseLyricsKanjiCheckBox  setState:[super userJapaneseLyricsKanji]];
    [hideNoHitsCheckBox           setState:[super userHideNoHits]];
    [hideLyricsFooterURLCheckBox  setState:[super userHideLyricFooterURL]];
    
	// Save Tab
    [includeLyricHeaderCheckBox setState:[super userIncludeLyricHeader]];
    [includeLyricFooterCheckBox setState:[super userIncludeLyricFooter]];
    
    [lyricsFolderTextField setStringValue:[super userLyricsFolder]];
    [subFolderByArtistCheckBox setState:[super userSubFolderByArtist]];
    
    [askBeforeOverwriteCheckBox setState:[super userAskBeforeOverwrite]];
    
    [openiTunesAtLaunchCheckBox setState:[super userOpeniTunesAtLaunch]];

    [alwaysOnTopCheckBox        setState:[super userAlwaysOnTop]];
}

// サイトリストをデフォルトの状態に戻す
- (IBAction) resetSiteList:(id)sender {
    
    NSArray *defaultSiteList         = [super defaultSiteList];
    NSArray *defaultDisabledSiteList = [super defaultDisabledSiteList];
    
    [siteDataSource setEnabledSites:defaultSiteList
                      disabledSites:defaultDisabledSiteList];
    
    [self siteDataDidChange:self];
}

// 全サイトのチェックを外す
- (IBAction) deselectAll:(id)sender {
    
    [siteDataSource disableAllSites];
    
    [self siteDataDidChange:self];
}

- (BOOL) isValid:(NSControl *) control {
	return [self control:control isValidObject:[control objectValue]];
}

// forKey 引数：現在未使用
- (void) load:(NSComboBox *)comboBox forKey:(NSString *)key {
	
	NSInteger value = 0;
	
	switch ([comboBox tag]) {
		case 0:
			// Automatic search timeout
			value = [super userAutoSrchTimeout];
			break;
		case 1:
			// Manual search timeout
			value = [super userManuSrchTimeout];
			break;
	}
	
	[comboBox setIntegerValue:value];
}

- (void) save:(NSComboBox *)comboBox forKey:(NSString *)key {
	
	NSInteger value = 0;

	value = [comboBox integerValue];
	[userDefault setInteger:value forKey:key];
}

- (void) saveIfValid:(NSComboBox *)comboBox forKey:(NSString *)key {

	if ([self isValid:comboBox]) {
		[self save:comboBox forKey:key];
	} else {
		[self load:comboBox forKey:key];
	}	
}

- (void) adjustDividerPosition {
	
	static CGFloat rowHeight = -1;
	
	if (rowHeight == -1) {
		
		// 行の高さ
		rowHeight  = [enabledSitesTableView rowHeight];
		
		// 余白をプラス
		rowHeight += [enabledSitesTableView intercellSpacing].height;
	}
	
	NSInteger num = 0;
	CGFloat   pos = 0;
	
	num = [enabledSitesTableView numberOfRows];
	
	pos = (num * rowHeight);
	
	[siteSplitView setPosition:pos ofDividerAtIndex:0];

	num = [enabledSitesTableView2 numberOfRows];
	
	pos = (num * rowHeight);
	
	[siteSplitView2 setPosition:pos ofDividerAtIndex:0];
}

- (void) siteDataDidChange:(id)sender {

	[enabledSitesTableView  reloadData];
	[disabledSitesTableView reloadData];
	
	[enabledSitesTableView2  reloadData];
	[disabledSitesTableView2 reloadData];
	
	[self adjustDividerPosition];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {

	if (!enabledSitesTableView.isFirstResponder)   [enabledSitesTableView   deselectAll:self];
	if (!disabledSitesTableView.isFirstResponder)  [disabledSitesTableView  deselectAll:self];

	if (!enabledSitesTableView2.isFirstResponder)  [enabledSitesTableView2  deselectAll:self];
	if (!disabledSitesTableView2.isFirstResponder) [disabledSitesTableView2 deselectAll:self];
}

@end
