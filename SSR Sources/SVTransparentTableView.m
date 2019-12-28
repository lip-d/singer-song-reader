//
//  SVTransparentTableView.m
//  Singer Song Reader
//
//  Created by Developer on 2014/01/29.
//
//

#import "SVTransparentTableView.h"

@implementation SVTransparentTableView

- (void)awakeFromNib {
    
    [[self enclosingScrollView] setDrawsBackground: NO];
}

- (BOOL)isOpaque {
    
    return NO;
}

- (void)drawBackgroundInClipRect:(NSRect)clipRect {
    
    // don't draw a background rect
}

- (void)highlightSelectionInClipRect:(NSRect)theClipRect
{
    // ハイライト処理をしない
}

// テーブル選択行のデータをクリップボードにコピー (最終カラムのデータのみ)
- (IBAction) copy:(id)sender
{
    NSInteger row = self.selectedRow;
    
    if (row == -1) return;
    
    // 最終カラムを取得
    NSTableColumn *col = [self.tableColumns objectAtIndex:self.tableColumns.count-1];
    
    // 選択行のデータを取得
    id dat = [self.dataSource tableView:self objectValueForTableColumn:col row:row];
    
    NSString *str = nil;
    
    if ([dat isKindOfClass:[NSString class]]) {
        
        str = dat;
    }
    else if ([dat isKindOfClass:[NSAttributedString class]]) {
        
        str = [dat string];
    }
    else {
        
        str = @"";
    }
    
    // クリップボードへ保存
	NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
	[pasteBoard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    
	[pasteBoard setString:str forType:NSStringPboardType];
}

@end
