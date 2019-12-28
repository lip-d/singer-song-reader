//
//  SMSiteChildProtocol.h
//  Singer Song Reader
//
//  Created by Developer on 2013/12/17.
//
//

#import <Cocoa/Cocoa.h>

@protocol SMSiteChildProtocol <NSObject>

// 第 1 検索用
@optional
- (NSString *) url1;
- (NSNumber *) analyze1:(id)aData;

@required
- (NSString *) urlFormat1;

// 第 2 検索用
@optional
- (NSString *) url2;
- (NSNumber *) analyze2:(id)aData;

@required
- (NSString *) targetXPath2;
- (NSString *) nodeValue2:(NSXMLNode *)node;

@end
