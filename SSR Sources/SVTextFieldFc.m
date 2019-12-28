//
//  SVTextFieldFc.m
//  Singer Song Reader
//
//  Created by Developer on 4/9/14.
//
//

#import "SVTextFieldFc.h"

@implementation SVTextFieldFc

- (BOOL)acceptsFirstResponder {
    
    return YES;
}

// ビープ音を鳴らさないためのコード
- (BOOL)performKeyEquivalent:(NSEvent *)event {

    // Return/Enter キーの場合 - 76 追加 (v3.8)
    if ([event keyCode] == 36 || [event keyCode] == 76)
        return YES;
    else
        return NO;
}

@end
