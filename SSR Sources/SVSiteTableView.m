//
//  SVSiteTableView.m
//  Singer Song Reader
//
//  Created by Developer on 4/9/14.
//
//

#import "SVSiteTableView.h"

@implementation SVSiteTableView

@synthesize isFirstResponder;

- (void)awakeFromNib {
    
    isFirstResponder = NO;
}

- (BOOL) becomeFirstResponder {
    
	BOOL didBecomeFirstResponder = [super becomeFirstResponder];
	
	isFirstResponder = YES;
	
	return didBecomeFirstResponder;
}

- (BOOL) resignFirstResponder {
	
	BOOL didResignFirstResponder = [super resignFirstResponder];
    
	isFirstResponder = NO;
	
	return didResignFirstResponder;
}

@end
