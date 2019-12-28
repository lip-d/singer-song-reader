//
//  SMKeyword.h
//  Singer Song Reader
//
//  Created by Developer on 13/10/12.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SMKeyword : NSObject {

	NSString *original;
	NSString *normalized;
 	NSString *urlEncoded;
    NSNumber *withNo;

    NSArray  *mainwordsArray;
    NSArray  *subwordsArray;
    
    NSInteger _isJapanese; // 日本語判定キャッシュ
}

@property (readonly, retain) NSString *original;
@property (readonly, retain) NSString *urlEncoded;
@property (readonly, retain) NSString *normalized;
@property (readonly, retain) NSNumber *withNo;
@property (readonly, retain) NSArray  *mainwordsArray;
@property (readonly, retain) NSArray  *subwordsArray;
@property (readonly) NSArray  *allwordsArray;
@property (readonly) NSInteger allwordsLength;
@property (readonly) NSString *mainwords;

@property (readonly) NSArray  *arrayArray;

@property (readonly) BOOL      isJapanese;

- (void) clear;

- (void) setKeywords:(NSString *)keywords;

- (NSString *) urlEncodedShiftJis;

@end
