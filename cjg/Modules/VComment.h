//
//  VComment.h
//  cjg
//
//  Created by Wang Jinggang on 12-11-10.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface VComment : NSManagedObject

@property (nonatomic, retain) NSDate * create_time;
@property (nonatomic, retain) NSString * file;

@end
