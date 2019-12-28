//
//  SVTransparentTextFieldCell.m
//  Singer Song Reader
//
//  Created by Developer on 4/9/14.
//
//

#import "SVTransparentTextFieldCell.h"

@implementation SVTransparentTextFieldCell

- (NSColor *)highlightColorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {

    // ハイライト色に nil を返すことでハイライトを無効化
    return nil;
}

- (NSBackgroundStyle)interiorBackgroundStyle {
    
    // 以下の指定で、ハイライト文字列が細めになるのを回避できる
    return NSBackgroundStyleLight;
}

@end
