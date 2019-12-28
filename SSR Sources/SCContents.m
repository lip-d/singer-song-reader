//
//  SCContents.m
//  Singer Song Reader
//
//  Created by Developer on 13/10/08.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SCContents.h"
#import "SSCommon.h"


@implementation SCContents

@synthesize columnCount;

@synthesize textStorage;

@synthesize singularView;
@synthesize columnarView;

- (id)init {
    self = [super init];
    if (self) {
		
		textStorage = [[NSTextStorage alloc] initWithString:@""];

		columnarView = [[SCColumnarView alloc] initWithTextStorage:textStorage];
		singularView = [[SCSingularView alloc] initWithTextStorage:textStorage];
        
        columnCount = 1;
    }

    return self;
}

- (void)dealloc {
	[textStorage release];
	[columnarView release];
	[singularView release];
    [super dealloc];
}

- (void) setDelegate:(id)aDelegate {
	delegate = aDelegate;
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {

    NSInteger cNum = [super userNumberOfColumns];

    // 前回のカラム数取り出し・反映
    [self changeColumns:cNum];
    
	// 前回のフォント取り出し・反映
	NSFont *font = [super userFont];
	[textStorage setFont:font];
		
	// 前回の背景色取り出し・反映
	NSColor *bgColor = [super userBackgroundColor];
	[self changeBackgroundColor:bgColor];
}

- (void) applicationShouldTerminate {
    
    // 設定保存
	[userDefault setInteger:self.columnCount forKey:UDNumberOfColumns];
}

// Contents テキスト変更
- (void) changeText:(NSString *)str refresh:(BOOL)refreshFlag {

	// 現在の文字色取り出し・設定
	NSColor *color = [super userTextColor];

	[self changeText:str color:color refresh:refreshFlag];
}

// Contents テキスト変更 (文字色指定)
- (void) changeText:(NSString *)str color:(NSColor *)color refresh:(BOOL)refreshFlag {
    
    // テキスト選択範囲解除
    [self deselectText];
	
	NSTextStorage *newStorage = [[NSTextStorage alloc] initWithString:str];
	
	if (textStorage != newStorage) {
		
        // 現在のフォント取り出し・設定
		NSFont *font = [super userFont];
		[newStorage setFont:font];
		
		// 文字色設定
		[newStorage setForegroundColor:color];
		
        [columnarView replaceTextStorage:newStorage];
        [singularView replaceTextStorage:newStorage];
		
        [textStorage release];
		textStorage = newStorage;
    
        //----------------------------------------
        // VoiceOver 対応 (V3.3)
        // TextView を一旦剥がして、再度取り付ける
        //----------------------------------------
        // refreshFlag で切分け (V3.4)
        if (refreshFlag) {
            
            // View 自体に refresh を実装 (V3.4)
            [mainWindow.contentsForegroundView refresh];
            
        } else {
            
            // Local Lyrics File を開く場合がここに来る。
            // TextView の貼り直しをすると、VoiceOver のカーソルが Lost して
            // "Scroll Area ..." と読み上げられて、TextView 内のテキストが
            // 読み上げられなくなってしまうため。
        }

        // 自動で少し下がるスクロールバーの位置を修正する。
        [[[singularView view] verticalScroller] setFloatValue:0];
        [[singularView view] display];
    }
}

- (void) changeColumns:(NSInteger)num {
    
    // テキスト選択範囲解除
    [self deselectText];

    //--------------------------------------
    // コンテンツ View 付け替え
    //--------------------------------------
    NSView *beforeView, *afterView;
    
    beforeView = self.currentView;
    
    // 一旦剥がす
    [beforeView removeFromSuperview];
    
#ifdef SS_DEBUG_MAKE_FIRST_RESPONDER
    NSLog(@"DEBUG ===========================[%3d]", ++contentsRefreshCount);
#endif
    
	if (num == 1) {
        
        afterView = [singularView view];
	} else {
        
        afterView = [columnarView viewOf:num];
	}
	
    // フレームサイズ再割り当て
    [afterView setFrame:contentsForeground.frame];
    
    // View 再取り付け
    [contentsForeground addSubview:afterView];
    
    // カラム数記憶
    columnCount = num;
    
    if (beforeView != afterView) {
        
        // View タイプ変更通知 -> Appearance 処理へ
        [delegate performSelector:@selector(contentsViewDidSwitched:) withObject:self];
    }
    
    // フォーカスセット (V3.4)
    [mainWindow makeFirstResponder:[self firstTextView]];
    
    //--------------------------
    // メニュー項目 有効/無効化
    //--------------------------
	if (num == 1) {
		[reduceColumn setEnabled:NO];
	} else {
		[reduceColumn setEnabled:YES];
	}
	
	if (num == 10) {
		[addColumn setEnabled:NO];
	} else {
		[addColumn setEnabled:YES];
	}
	
	for (int i=0; i<10; i++) {
		NSInteger cTag = i+1;
		NSMenuItem *cNumItem = [columnsMenu itemWithTag:cTag];
		
		if (cTag == num) {
			[cNumItem setState:NSOnState];
		} else {
			[cNumItem setState:NSOffState];
		}
	}
}

// Contents 文字色変更
- (void) changeTextColor:(NSColor *)color {
	
	[textStorage setForegroundColor:color];
}

// Contents 背景色変更
- (void) changeBackgroundColor:(NSColor *)color {

	[contentsBackground setFillColor:color];
}

// Contents 背景 不透明/透明化
- (void) setOpaque:(BOOL)aFlag {

	[contentsBackground setHidden:!aFlag];
	
	if (aFlag) {

		[singularView useNormalScroller];
	} else {

		[singularView useCustomScroller];
        
	}
}

- (void) setAlignment:(NSTextAlignment)mode {
	
    if (IS_OS10_10_LATER) {

        [singularView setAlignment:mode];
        [columnarView setAlignment:mode];
    }else{
        if (mode != [singularView alignment]) {
            
            [singularView setAlignment:mode];
            [columnarView setAlignment:mode];
        }
    }
}

- (void) setEditable:(BOOL)flag {
    
    [singularView setEditable:flag];
    [columnarView setEditable:flag];
}

- (void) setArrowsLeftRight:(NSInteger)flag {
    
    [singularView setArrowsLeftRight:flag];
    [columnarView setArrowsLeftRight:flag];
}

- (void) setArrowsUpDown:(NSInteger)flag {
    
    [singularView setArrowsUpDown:flag];
    [columnarView setArrowsUpDown:flag];
}

- (IBAction) setColumns:(id)sender {
	NSInteger num = [[sender title] intValue];
	[self changeColumns:num];
}

- (IBAction) addColumn:(id)sender {
	NSInteger cNum = [self columnCount];
	[self changeColumns:cNum+1];
}

- (IBAction) reduceColumn:(id)sender {
	NSInteger cNum = [self columnCount];
	[self changeColumns:cNum-1];
}

- (void) deselectText {
    
    NSTextView *firstTextView = [self firstTextView];
    
    if (firstTextView)
        [firstTextView setSelectedRange:NSMakeRange(0, 0)];
}

- (NSString *) text {
    
    return [textStorage string];
}

- (NSTextView *) firstTextView {
 
    NSTextView *firstTextView = nil;

    NSView *view = self.currentView;

    if (view) {
        
        if      ([view isKindOfClass:[NSScrollView class]])
            firstTextView = [(NSScrollView *)view documentView];
        
        else if ([view isKindOfClass:[NSSplitView  class]])
//            firstTextView = [[(NSSplitView  *)view subviews] objectAtIndex:0];
            // V4.2
            firstTextView = [[[[(NSSplitView  *)view subviews] objectAtIndex:0] subviews] objectAtIndex:0];
    }
    
    return firstTextView;
}

- (NSView *) currentView {
    
    NSArray *foregroundSubviews = contentsForeground.subviews;
    
    if (foregroundSubviews.count > 0) {
        
        return [foregroundSubviews objectAtIndex:0];
    } else {
        return nil;
    }
}

- (void) setAccessibilityDescription:(NSString *)descriotion {
    
    NSString * const attribute = NSAccessibilityDescriptionAttribute;
    
    [[singularView firstTextView] accessibilitySetOverrideValue:descriotion forAttribute:attribute];
    [[columnarView firstTextView] accessibilitySetOverrideValue:descriotion forAttribute:attribute];
}

@end
