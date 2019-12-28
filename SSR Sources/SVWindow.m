//
//  SVWindow.m
//  Singer Song Reader
//
//  Created by Developer on 2014/02/16.
//
//

#import "SVWindow.h"
#import "SCDelegate.h"
#import "NSView+SSR.h"

@implementation SVWindow

@synthesize titleTextField;
@synthesize artistTextField;
@synthesize contentsForegroundView;

@synthesize topView;
@synthesize messageView;
@synthesize bottomView;

- (void)keyUp:(NSEvent *)event {

    //NSLog(@"MainWindow KeyUp: %@ [%hu]", [event characters], [event keyCode]);
    
    // Main Window のキーイベント
    if (event.window == self) {
        
        if ([NSEvent modifierFlags] & NSShiftKeyMask) {
            
        } else {
            
            // SCDelegate に通知
            [(SCDelegate *)[super delegate] keyUpEvent:event];
        }
        
        [super keyUp:event];
    }
    // SongInfo 又は Biography Panel
    else {

        // Enter/Return キー - 76 追加 (v3.8)
        if ([event keyCode] == 36 || [event keyCode] == 76) {
            
            // SCDelegate に通知
            [(SCDelegate *)[super delegate] keyUpEvent:event];
        }
    }
}

#ifdef SS_DEBUG_MAKE_FIRST_RESPONDER

- (BOOL) makeFirstResponder:(NSResponder *)responder {

    NSResponder *current = [self firstResponder];
    
    NSLog(@"DEBUG == (%3ld) makeFirstResponder(%3ld)", [current debugTag], [responder debugTag]);

    BOOL retValue = [super makeFirstResponder:responder];
    
    return retValue;
}

#endif

- (void) makeFirstResponderToContentsFirstTextView {
    
    [self makeFirstResponder:contentsForegroundView.firstTextView];
}

//-------------------------------------------------------------------
// Contents 領域への強制 VO フォーカス移動
// Contents 領域以外の View を一旦剥がし付け直す (Voice Over Cursor 対策)
//-------------------------------------------------------------------
- (void) forceMakeFirstResponderToContentsFirstTextView {
    
    NSView *topSuper      = topView.superview;
    NSView *contentsSuper = contentsView.superview;
    NSView *messageSuper  = messageView.superview;
    NSView *bottomSuper   = bottomView.superview;
    
    NSView *topTemp      = [[[NSView alloc] init] autorelease];
    NSView *contentsTemp = [[[NSView alloc] init] autorelease];
    NSView *messageTemp  = [[[NSView alloc] init] autorelease];
    NSView *bottomTemp   = [[[NSView alloc] init] autorelease];
    
    // 全 View を一旦取り外す (VoiceOver Cursor が外れる)
    if (topSuper) [topSuper      replaceSubview:topView      with:topTemp];
    [contentsSuper replaceSubview:contentsView with:contentsTemp];
    [messageSuper  replaceSubview:messageView  with:messageTemp];
    [bottomSuper   replaceSubview:bottomView   with:bottomTemp];

    // ContentsView だけ先に取り付け、フォーカスをセット
    [contentsSuper replaceSubview:contentsTemp with:contentsView];
    [self makeFirstResponderToContentsFirstTextView];
    
    // 残りの View を取り付ける
    if (topSuper) [topSuper     replaceSubview:topTemp     with:topView];
    [messageSuper replaceSubview:messageTemp with:messageView];
    [bottomSuper  replaceSubview:bottomTemp  with:bottomView];
}

- (void) setInitialFirstResponderToTitleTextField {
    
    [super setInitialFirstResponder:titleTextField];
}

- (void) setInitialFirstResponderToContentsFirstTextView {
    
    [super setInitialFirstResponder:contentsForegroundView.firstTextView];
}

/*
 
 // test
 - (void) keyLog:(NSEvent *)event {
 
 //    if (event.modifierFlags & NSCommandKeyMask) {
 
 NSString *character = event.charactersIgnoringModifiers;
 
 if ([character compare:@"s" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
 
 NSMutableArray *keyArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
 
 NSUInteger modFlags = event.modifierFlags;
 
 if (modFlags & NSAlphaShiftKeyMask) [keyArray addObject:@"Caps Lock"];
 if (modFlags & NSShiftKeyMask)      [keyArray addObject:@"Shift"];
 if (modFlags & NSControlKeyMask)    [keyArray addObject:@"Control"];
 if (modFlags & NSAlternateKeyMask)  [keyArray addObject:@"Option"];
 if (modFlags & NSCommandKeyMask)    [keyArray addObject:@"Command"];
 if (modFlags & NSNumericPadKeyMask) [keyArray addObject:@"Numeric Keypad"];
 if (modFlags & NSHelpKeyMask)       [keyArray addObject:@"Help"];
 if (modFlags & NSFunctionKeyMask)   [keyArray addObject:@"Function"];
 
 [keyArray addObject:@"S"];
 
 NSString *keyString = [keyArray componentsJoinedByString:@" + "];
 
 //            NSLog(@"## KeyDown: %@", keyString);
 
 NSAlert *alert = [NSAlert alertWithMessageText:keyString defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
 
 [alert runModal];
 }
 //    }
 }
 
 // test
 - (BOOL)performKeyEquivalent:(NSEvent *)theEvent {
 
 [self keyLog:theEvent];
 return NO;
 }
 
 */

@end
