//
//  SMCountries.h
//  Singer Song Reader
//
//  Created by Developer on 13/11/02.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SMCountries : NSObject {

}

+ (NSString *) nameOfCode:(NSString *)aCode;
+ (NSString *) codeAtIndex:(NSInteger)aIndex;
+ (NSString *) nameAtIndex:(NSInteger)aIndex;
+ (NSInteger)  indexOfCode:(NSString *)aCode;
+ (NSInteger)  afpgOfCode:(NSString *)aCode;
+ (NSNumber *) afpgAtIndex:(NSInteger)aIndex;

+ (NSArray *) codes;
+ (NSArray *) names;
+ (NSArray *) afpgs;

@end
