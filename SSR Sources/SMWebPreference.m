//
//  SMWebPreference.m
//  Singer Song Reader
//
//  Created by Developer on 13/10/03.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMWebPreference.h"
#import <WebKit/WebKit.h>

NSString * const UDWebPreference = @"UDWebPreference";

@implementation SMWebPreference

static id webPref = nil;

+ (id) sharedWebPreference {

	if (webPref == nil) {

		// 読み込まれるのは,html, js, css
		
		webPref = [[WebPreferences alloc]
				   initWithIdentifier:UDWebPreference];
		[webPref setAllowsAnimatedImageLooping:NO];
		[webPref setAllowsAnimatedImages:NO];
		[webPref setJavaEnabled:NO];
		[webPref setJavaScriptCanOpenWindowsAutomatically:NO];
		[webPref setLoadsImagesAutomatically:NO];
		[webPref setPlugInsEnabled:NO];
		[webPref setUsesPageCache:YES];
		[webPref setCacheModel:WebCacheModelDocumentViewer];
	}
	return webPref;
}

@end
