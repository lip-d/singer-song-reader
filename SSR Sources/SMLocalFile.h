//
//  SMLocalFile.h
//  Singer Song Reader
//
//  Created by Developer on 4/25/14.
//
//

#import <Foundation/Foundation.h>

@interface SMLocalFile : NSObject {
    
    NSString *title;
    NSString *artist;
    NSString *path;
    NSDate   *cdate;
    NSDate   *mdate;
}

@property (retain) NSString *title;
@property (retain) NSString *artist;
@property (retain) NSString *path;
@property (retain) NSDate   *cdate;
@property (retain) NSDate   *mdate;

@end
