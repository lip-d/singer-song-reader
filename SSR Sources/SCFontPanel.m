//
//  SCFontPanel.m
//  Singer Song Reader
//
//  Created by Developer on 13/10/25.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SCFontPanel.h"
#import "SSCommon.h"

@implementation SCFontPanel

- (id)init {
    self = [super init];
    if (self) {
		
		// フォントパネル インスタンス
		fontPanel = [NSFontPanel sharedFontPanel];
		[fontPanel setDelegate:self];
	}
	
	return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {

	// NSFontPanel に Accessory View 取り付け
	[fontPanel setAccessoryView:fontAccessoryView];
	[fontPanel setMinSize:NSMakeSize(500, 350)];
	[fontPanel update];

	// 前回のフォント取り出し・反映
	NSFont *font = [super userFont];
	[fontPanel setPanelFont:font isMultiple:NO];
	
	// 前回の文字色取り出し・反映
	NSColor *textColor = [super userTextColor];
	[textColorWell setColor:textColor];

	// 前回の背景色取り出し・反映
	NSColor *bgColor = [super userBackgroundColor];
	[backgroundColorWell setColor:bgColor];
	
	// フォント変更メソッドを独自のものに変更
	//   Default : changeFont
	//   After   : changeTextStorageFont
	//   これをしないと、テキストフィールドにフォーカスがあるときにフォントを変更できない
	NSFontManager *sharedFontManager = [NSFontManager sharedFontManager];
	[sharedFontManager setAction:@selector(changeTextStorageFont:)];
	[sharedFontManager setTarget:self];
}

// フォント変更 (sender == NSFontManager)
- (void) changeTextStorageFont:(id)sender {

	NSFont *oldFont = [contents.textStorage font];
    NSFont *newFont = [sender convertFont:oldFont];
	
	// 画面へ反映
    [contents.textStorage setFont:newFont];
	
	// 画面リフレッシュ (フォント大→小で、最終列にフォント大のゴミ文字が残る現象を回避)
	[[[contents columnarView] view] display];
	
	// フォントパネルへ反映
	[fontPanel setPanelFont:newFont isMultiple:NO];
	
	// 設定保存
	[userDefault setObject:[super dataFromFont:newFont] forKey:UDFont];
	
    return;
}

// 文字色変更
- (IBAction) changeTextColor:(id)sender {
	
	NSColor *color = [sender color];
	
	// 画面へ反映
	[contents changeTextColor:color];
	
	// 設定保存
	[userDefault setObject:[super dataFromColor:color] forKey:UDTextColor];
}

// 背景色変更
- (IBAction) changeBackgroundColor:(id)sender {
	
	NSColor *color = [sender color];
	
	// 画面へ反映
	[contents changeBackgroundColor:color];
	
	// 設定保存
	[userDefault setObject:[super dataFromColor:color] forKey:UDBackgroundColor];
}

// FontPanel Open/Close
- (IBAction) showFontPanel:(id)sender {

	if ([fontPanel isVisible]) {
		[fontPanel close];
	} else {
		[fontPanel setContentSize:NSMakeSize(500, 350)];
		[fontPanel update];
		[fontPanel makeKeyAndOrderFront:self];
	}
}

// FontPanel 下部の Text & Background Color ボタン 有効/無効化
- (void) controlColorButtons {

	NSInteger appearance = [super userAppearance];
	BOOL      flag = YES;
	
	if (appearance == SC_APPEARANCE_PANEL) {
		
		flag = NO;
	}

	[textTextField       setEnabled:flag];
	[textColorWell       setEnabled:flag];
	[backgroundColorWell setEnabled:flag];
	[backgroundTextField setEnabled:flag];
}

// FontPanel 表示要素設定
- (NSUInteger)validModesForFontPanel:(NSFontPanel *)fPanel {
	
	// 必要な画面要素のみを返す
	return (NSFontPanelCollectionModeMask|
			NSFontPanelSizeModeMask|
			NSFontPanelFaceModeMask);
}


@end
