//
//  SCStore.h
//  Singer Song Reader
//
//  Created by Developer on 13/11/01.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSCommon.h"
#import "SMiTunesStore.h"
#import "SCSongInformation.h"
#import "iTunes.h"

@interface SCStore : SSCommon {
	id delegate;

	SMTrack       *track;
	SMiTunesStore *iTunesStore;

    IBOutlet NSPanel *songInformationPanel;
	IBOutlet NSPanel *biographyPanel;

	IBOutlet SCSongInformation *songInformation;
    
    BOOL searching;
    BOOL selfCancel;
    NSString *titlePool;
    NSString *artistPool;
    NSInteger matchThresholdPool;
    
    NSInteger       matchThreshold;
}

@property (retain) NSString *titlePool;
@property (retain) NSString *artistPool;

- (void) setDelegate:(id)aDelegate;

- (void) applicationWillFinishLaunching:(NSNotification *)aNotification;

- (void) clear;
- (void) searchWithTitle:(NSString *)aTitle withArtist:(NSString *)aArtist matchThreshold:(NSInteger)threshold;
- (void) cancel;
- (void) timeout;
- (void) siteDidFinishSearching:(id)sender;

- (void) waitForSelfCancel;
    
- (SMStoreResult *) srchResult;

@end
