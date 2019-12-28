//
//  SMiTunesNotif.h
//  Singer Song Reader
//
//  Created by Developer on 7/2/15.
//
//

#import <Foundation/Foundation.h>

@interface SMiTunesNotif : NSObject {

    NSString *album;
    NSString *title;
    NSString *artist;
    NSString *genre;
    NSString *persistentID;
}

@property (retain)    NSString *album;
@property (retain)    NSString *title;
@property (retain)    NSString *artist;
@property (retain)    NSString *genre;
@property (retain)    NSString *persistentID;

- (void) clear;
- (BOOL) isEmpty;

@end
