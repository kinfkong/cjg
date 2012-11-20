//
//  kkFactory.h
//  cjg
//
//  Created by Wang Jinggang on 12-10-21.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "kkDBMgr.h"

@interface kkFactory : NSObject {
    kkDBMgr* dbmgr;
}

+(kkFactory *) getInstance;


-(kkDBMgr *) getDBMgr;

@end
