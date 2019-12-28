//
//  SCSongInformation.h
//  Singer Song Reader
//
//  Created by Developer on 13/10/25.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSCommon.h"
#import "SMiTunesStore.h"
#import "SCPreferences.h"
#import "SMLinkMaker.h"
#import "SMBioStatsDataSource.h"
#import "SMTopSongsDataSource.h"
#import "SVTransparentTableView.h"
#import "SVTextView.h"
#import "SVScroller.h"

@interface SCSongInformation : SSCommon <NSWindowDelegate, NSTableViewDelegate, NSMenuDelegate> {
    id delegate;
	
	IBOutlet NSPanel *songInformationPanel;
	IBOutlet NSPanel *biographyPanel;
	    
    //------------------------------------
    // Song Info Panel
    //------------------------------------
	IBOutlet NSTextField *songTextField;
	IBOutlet NSImageView *artworkLargeImageView;
	IBOutlet NSTextField *albumTextField;
	
    IBOutlet NSTextField *trackTextField;
    IBOutlet NSTextField *timeTextField;
    
	IBOutlet NSProgressIndicator *spinningIcon1;
	IBOutlet NSProgressIndicator *spinningIcon2;
    
    IBOutlet NSTextField *countryTextField;
	IBOutlet NSTextField *aboutCountryTextField;
	IBOutlet NSButton    *changeCountryButton;
	IBOutlet NSTextField *changeCountryTextField;
    
    IBOutlet SVTransparentTableView *topSongsTableView;
    IBOutlet SVScroller             *topSongsScroller;
    
    IBOutlet NSScrollView *topSongScrollView;
    
    //------------------------------------
    // Biography Panel
    //------------------------------------
    IBOutlet SVTransparentTableView *bioStatsTableView;
    IBOutlet SVScroller             *bioStatsScroller;
    IBOutlet SVTextView             *biographyTextView;
    IBOutlet SVScroller             *biographyScroller;
    IBOutlet NSScrollView           *biographyScrollView;
    IBOutlet NSScrollView           *bioStatsScrollView;

	
    // UI バインディング
    NSString *artistName;
    NSImage  *songIcon;
    NSImage  *artistIcon;
    NSString *songUrl;
    NSString *artistUrl;
    
    SMiTunesStore         *iTunesStore;
	SMLinkMaker           *linkMaker;
    SMTopSongsDataSource  *topSongsDataSource;
    SMBioStatsDataSource  *bioStatsDataSource;
    
	WebView       *webView1;
	WebView       *webView2;
}

@property (retain) NSString *artistName;
@property (retain) NSImage  *songIcon;
@property (retain) NSImage  *artistIcon;
@property (retain) NSString *songUrl;
@property (retain) NSString *artistUrl;

- (void) setDelegate:(id)aDelegate;

- (void) applicationWillFinishLaunching:(NSNotification *)aNotification;

- (void) setStore:(SMiTunesStore *)store;

- (void) clear;
- (void) display;

- (IBAction) showPanel:(id)sender;
- (IBAction) showBiography:(id)sender;

- (IBAction) loadSongPage:(NSButton *)sender;
- (IBAction) loadArtistPage:(NSButton *)sender;

- (void) setArrowsLeftRight:(NSInteger)flag;
- (void) setArrowsUpDown:(NSInteger)flag;

@end
