//
//  SVWindow.h
//  Singer Song Reader
//
//  Created by Developer on 2014/02/16.
//
//

#import <Foundation/Foundation.h>
#import "SVTitleTextField.h"
#import "SVArtistTextField.h"
#import "SVContentsForegroundView.h"

@interface SVWindow : NSWindow {

    // FirstResponder 関連リンク
    IBOutlet SVTitleTextField         *titleTextField;
    IBOutlet SVArtistTextField        *artistTextField;
    IBOutlet SVContentsForegroundView *contentsForegroundView;
    
    // その他
    IBOutlet NSView                   *topView;
    IBOutlet NSView                   *contentsView;
    IBOutlet NSView                   *messageView;
    IBOutlet NSView                   *bottomView;
}

@property (readonly) SVTitleTextField         *titleTextField;
@property (readonly) SVArtistTextField        *artistTextField;
@property (readonly) SVContentsForegroundView *contentsForegroundView;

@property (readonly) NSView                   *topView;
@property (readonly) NSView                   *messageView;
@property (readonly) NSView                   *bottomView;

- (void) makeFirstResponderToContentsFirstTextView;
- (void) forceMakeFirstResponderToContentsFirstTextView;

- (void) setInitialFirstResponderToTitleTextField;
- (void) setInitialFirstResponderToContentsFirstTextView;


@end
