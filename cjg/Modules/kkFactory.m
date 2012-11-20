//
//  kkFactory.m
//  cjg
//
//  Created by Wang Jinggang on 12-10-21.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import "kkFactory.h"

static kkFactory* instance = nil;

@implementation kkFactory

-(id) init {
    dbmgr = [[kkDBMgr alloc] init];
    return self;
}

+(kkFactory *) getInstance {
    if (instance == nil) {
        instance = [[kkFactory alloc] init];
    }
    return instance;
}

-(kkDBMgr *) getDBMgr {
    return dbmgr;
}

@end
