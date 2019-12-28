//
//  SCOpenFile.h
//  Singer Song Reader
//
//  Created by Developer on 4/25/14.
//
//

#import <Foundation/Foundation.h>

#import "SSCommon.h"

#import "SMLocalFile.h"

@interface SCOpenFile : SSCommon <NSTextFieldDelegate> {
    
    // UI コネクション
    IBOutlet NSWindow *mainWindow;
    
    IBOutlet NSWindow *openFileWindow;
    IBOutlet NSArrayController *localFilesArrayController;
    
    IBOutlet NSTextField   *mainMessageTextField;
    IBOutlet NSSearchField *searchField;
    IBOutlet NSTableView   *localFilesTableView;
    
    IBOutlet NSScrollView  *localFilesScrollView;
    
    IBOutlet NSDateFormatter *mDateFormatter;
    
    // UI バインディング
    NSInteger showDateModified;
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification;
- (void) applicationShouldTerminate;

- (void) openDialog;
- (void) closeDialog;
- (void) stopModal;

- (SMLocalFile *) selectedFile;

- (IBAction) showDateModifiedCheckboxClicked:(id)sender;

@end
