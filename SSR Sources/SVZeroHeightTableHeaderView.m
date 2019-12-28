//
//  SVZeroHeightTableHeaderView.m
//  Singer Song Reader
//
//  Created by Developer on 5/5/14.
//
//

#import "SVZeroHeightTableHeaderView.h"

@implementation SVZeroHeightTableHeaderView

// IB 上のオブジェクトが読み込まれたときに呼ばれる
- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    NSSize frameSize = self.frame.size;
    
    frameSize.height = 0;
    
    [self setFrameSize:frameSize];
}

@end
