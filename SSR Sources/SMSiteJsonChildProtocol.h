//
//  SMSiteJsonChildProtocol.h
//  Singer Song Reader
//
//  Created by Developer on 5/10/14.
//
//

#import <Foundation/Foundation.h>
#import "SMSiteChildProtocol.h"

@protocol SMSiteJsonChildProtocol <SMSiteChildProtocol>

@required

// 第 1 検索用
- (NSString *) targetKey1;
- (NSArray *)  itemValue1:(NSDictionary *)item;
//- (NSArray *)  itemValue1:(id)item;

@end
