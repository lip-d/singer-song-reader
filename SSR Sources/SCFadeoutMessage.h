//
//  SCFadeoutMessage.h
//  Singer Song Reader
//
//  Created by Developer on 2014/02/06.
//
//

#import <Foundation/Foundation.h>
#import "SSCommon.h"

@interface SCFadeoutMessage : SSCommon {
    
    IBOutlet NSTextField *textField;
    
    NSString *textPool;
}

@property (retain) NSString *textPool;
@property (readonly) NSTextField *textField;

// 即時表示用
- (void) show;
- (void) setText:(NSString *)aText;

// 時間差表示用
- (void) setText:(NSString *)aText afterDelay:(NSTimeInterval)aDelay;

- (void) fadeoutAfterDelay:(NSTimeInterval)aDelay;

- (void) hide;

@end
