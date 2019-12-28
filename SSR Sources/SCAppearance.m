//
//  SCAppearance.m
//  Singer Song Reader
//appearanceMode
//  Created by Developer on 13/11/16.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SCAppearance.h"
#import "NSWindow+AccessoryView.h"

@implementation SCAppearance

- (id)init {
    self = [super init];
    if (self) {

		// IB の Window 設定を基準として、各画面パーツの表示/非表示を行う
		currentMode = SC_APPEARANCE_FULL;
	}
    return self;
}

@synthesize currentMode;


- (void)dealloc {
    [super dealloc];
}

- (void) setDelegate:(id)aDelegate {
	delegate = aDelegate;
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
	
	// Title Bar にカスタム3つボタン設定
	[mainWindow addTitleBarButtons:titleBarButtons];
    
    // Title Bar にカスタム Window タイトル設定
    [mainWindow addTitleBarText:titleBarTextField];
    [[titleBarTextField cell] setBackgroundStyle:NSBackgroundStyleRaised];
    
	// Title Bar に Info ボタン設置
    //[mainWindow addTitleBarInfoButton:titleBarInfoButton];
    
	// Title Bar に Autosave ボタン設置
    //[mainWindow addTitleBarAutosaveButton:titleBarAutosaveButton];

    // Title Bar にマッチ率表示
    //[[titleBarMatchRatio cell] setBackgroundStyle:NSBackgroundStyleRaised];
	//[mainWindow addTitleBarMatchRatioTextField:titleBarMatchRatio];

	// Window 背景透過 有効化
	[mainWindow setOpaque:NO];
	
	// Window 3つボタンを取得しておく
	closeButton       = [mainWindow standardWindowButton:
						 NSWindowCloseButton];
	miniaturizeButton = [mainWindow standardWindowButton:
						 NSWindowMiniaturizeButton];
	zoomButton        = [mainWindow standardWindowButton:
						 NSWindowZoomButton];

	// 前回の Appearance 取り出し・設定
	NSInteger appearance = [super userAppearance];
	[self changeAppearanceWithTag:appearance];	
}

// Mode メニュー項目がクリックされた場合
- (IBAction) changeAppearance:(id)sender {
	
	NSInteger tag = [sender tag];
	
	[self changeAppearanceWithTag:tag];
}

// Full/Minimum/Panel モード変更
- (void) changeAppearanceWithTag:(NSInteger)aTag {
    
    // 先に initialFirstResponder を変更しておく (V3.4)
    if (aTag == SC_APPEARANCE_FULL)
        [mainWindow setInitialFirstResponderToTitleTextField];
    else
        [mainWindow setInitialFirstResponderToContentsFirstTextView];
    
	    
	// Full モード
	if (aTag == SC_APPEARANCE_FULL) {
		
		// 1) Top & Bottom バー: 表示
		[self barsSetHidden:NO];
		
		// 2) 3つボタン: 表示
		[self buttonsSetHidden:NO];
		
		// 3) タイトルバーのカスタム3つボタン: 非表示
		[titleBarButtons setHidden:YES];
		
        // 3') タイトルバーの Autosave ボタン: 表示
		//[titleBarAutosaveButton setHidden:YES];
        //[titleBarMatchRatio setHidden:YES];

		// 4) Lyrics エリア: Narrow
		[self contentsSetWide:NO];
		
		// 5) 背景: 不透明
		[self windowSetOpaque:YES];
    }
	// Minimum or Panel モード
	else {
		
		// 1) Top & Bottom バー: 非表示
		[self barsSetHidden:YES];
		
		// 2) 3つボタン: 非表示
		[self buttonsSetHidden:YES];
		
		// 3) タイトルバーのカスタム3つボタン: 表示
		[titleBarButtons setHidden:NO];
		
        // 3') タイトルバーの Autosave ボタン: 非表示
		//[titleBarAutosaveButton setHidden:NO];
        //[titleBarMatchRatio setHidden:NO];

		// Panel モード
		if (aTag == SC_APPEARANCE_PANEL) {
			
			if ([contents.currentView isKindOfClass:[NSScrollView class]]) {

				// 4) Lyrics エリア: Narrow
				[self contentsSetWide:NO];
			} else {

				// 4) Lyrics エリア: Wide
				[self contentsSetWide:YES];
			}

			// 5) 背景: 透明
			[self windowSetOpaque:NO];			
		} 
		// Minimum モード
		else {	
			
			// 4) Lyrics エリア: Wide
			[self contentsSetWide:YES];

			// 5) 背景: 不透明
			[self windowSetOpaque:YES];
		}
	}
	
	// 新しいモードを保存
	currentMode = aTag;
	[userDefault setInteger:aTag forKey:UDAppearance];
	
	// 即反映
	[userDefault synchronize];
	
	// delegate に Appearance 変更通知
	[delegate performSelector:@selector(appearanceDidChange:)
				   withObject:self];	

	// メニュー制御
	[self menuControl];
}

// Top & Bottom バー 表示/非表示
- (void) barsSetHidden:(BOOL)aFlag {
	
	// Toolbar (背景用) 
	[toolbar      setVisible:!aFlag];

	// Top Bar
	// 注: setHidden だけでは、テキストフィールドの反応が悪くなる
	//     必ず、super view への取り付け/取り外しで表示/非表示を実装する
	if (aFlag) {
		// Top Bar 取り外し
		[topView removeFromSuperview];
	} else {
		// Top Bar 取り付け
		[mainWindow addTopBar:topView];
	}		

	// Bottom Bar
	[bottomView   setHidden:aFlag];
}

// Lyrics エリア Wide/Narrow 切替え
- (void) contentsSetWide:(BOOL)aFlag {

	static BOOL isFirstTime = YES;
	
	static NSInteger bottomHeight  = 0;
	static NSInteger cFrameOriginY = 0;
	
	if (isFirstTime) {
		
		isFirstTime = NO;

		NSRect    bottomFrame  = [bottomView frame];
		
		// Bottom Bar の高さを取得
		bottomHeight = bottomFrame.size.height;	

		NSRect cFrame = [contentsView frame];

		// Contnets View の Y 座標を覚えておく
		cFrameOriginY = cFrame.origin.y;
	}
	
	// 現在の Contents Frame
	NSRect cFrame = [contentsView frame];
	

	if (aFlag) {

		if (cFrame.origin.y == cFrameOriginY) {

			// Y 座標を下げ、Height を広げる
			cFrame.origin.y    -= bottomHeight;
			cFrame.size.height += bottomHeight;
		}
	} else {
		
		if (cFrame.origin.y < cFrameOriginY) {

			// Y 座標を上げ、Height を狭める
			cFrame.origin.y    += bottomHeight;
			cFrame.size.height -= bottomHeight;
		}
	}
	
	// 画面に反映
	[contentsView setFrame:cFrame];
}

// Window 不透明/透明化
- (void) windowSetOpaque:(BOOL)aFlag {
	
	static 	NSColor *originalColor = nil;
	
	if (originalColor == nil) {

		// 元の背景色を記憶しておく
		originalColor = [[mainWindow backgroundColor] retain];
	}
	
	// 不透明
	if (aFlag) {
		
		// Window 背景を元に戻す
		[mainWindow setBackgroundColor:originalColor];
		
	} else {
		
		// Window 背景を透明化
		[mainWindow setBackgroundColor:[NSColor colorWithCalibratedWhite:SSPanelWhite alpha:SSPanelAlpha]];
	}

	[contents   setOpaque:aFlag];
}

// 3つボタン表示/非表示
- (void) buttonsSetHidden:(BOOL)aFlag {

	[closeButton       setHidden:aFlag];
	[miniaturizeButton setHidden:aFlag];
	[zoomButton        setHidden:aFlag];

    //[titleBarMatchRatio setHidden:!aFlag];
}

// Mode メニュー項目 有効/無効制御
- (void) menuControl {
		
	for (NSMenuItem *item in [appearanceMenu itemArray]) {
		
		if([item tag] == currentMode) {
			[item setState:NSOnState];
		} else {
			[item setState:NSOffState];
		}
	}
}

// マウスがメインウインドウ内に入った
- (void)mouseEntered:(NSEvent *)theEvent {

	// Minimum, Panel モード時のみ、3つボタン 表示/非表示 処理を行う
	if (currentMode != SC_APPEARANCE_FULL) {

		// 3つボタン: 表示
		//[self buttonsSetHidden:NO];
	}

    if (currentMode == SC_APPEARANCE_PANEL) {
        [contents.singularView.customScroller setAllowKnob:YES];
        [contents.singularView.customScroller display];
    }
}

// マウスがメインウインドウ内から出た
- (void)mouseExited:(NSEvent *)theEvent {
	
	// Minimum, Panel モード時のみ、3つボタン 表示/非表示 処理を行う
	if (currentMode != SC_APPEARANCE_FULL) {
        
		// 3つボタン: 非表示
		//[self buttonsSetHidden:YES];
	}
    
    if (currentMode == SC_APPEARANCE_PANEL) {
        [contents.singularView.customScroller setAllowKnob:NO];
        [contents.singularView.customScroller display];
    }
}

// Contents View 切替に伴うコンテンツ領域高さ変更
- (void) contentsSetWideFor:(NSView *)newView {
    
	// Panel モードの場合のみ
	if (currentMode == SC_APPEARANCE_PANEL) {
		
        if ([newView isKindOfClass:[NSScrollView class]]) {
			
			// Lyrics エリア Narrow
			[self contentsSetWide:NO];
		} else {
			
			// Lyrics エリア Wide
			[self contentsSetWide:YES];
		}
	}
}

@end
