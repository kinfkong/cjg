//
//  kkBookEntity.h
//  cjg
//
//  Created by Wang Jinggang on 12-10-27.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mybook.h"

@interface kkBookEntity : NSObject {
}

+(NSDictionary *) object2Dict:(Mybook *) book;
+(NSDictionary *) doubanJSON2Dict:(NSDictionary *) douban;
+(void) dict2Object:(NSDictionary *) dict book:(Mybook *) book;
@end
