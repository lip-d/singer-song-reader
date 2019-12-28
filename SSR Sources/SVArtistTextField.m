//
//  SVArtistTextField.m
//  Singer Song Reader
//
//  Created by Developer on 5/4/14.
//
//

#import "SVArtistTextField.h"
#import "NSView+SSR.h"

@implementation SVArtistTextField

- (NSView *) nextKeyView {
    
    NSView *retView = self.svwindow.contentsForegroundView.firstTextView;
    
    return retView;
}

- (NSView *) previousKeyView {
    
    NSView *retView = self.svwindow.titleTextField;
    
    return retView;
}

@end
