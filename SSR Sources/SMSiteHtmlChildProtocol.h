//
//  SMSiteHtmlChildProtocol.h
//  Singer Song Reader
//
//  Created by Developer on 5/10/14.
//
//

#import <Foundation/Foundation.h>
#import "SMSiteChildProtocol.h"

@protocol SMSiteHtmlChildProtocol <SMSiteChildProtocol>

@required

// 第 1 検索用
- (NSString *) targetXPath1;
- (NSArray *)  nodeValue1:(NSXMLNode *)node;

@end
