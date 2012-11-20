//
//  kkDouBan.h
//  cjg
//
//  Created by Wang Jinggang on 12-10-27.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface kkDouBan : NSObject {
}

-(NSDictionary *) getBookInfo:(NSString*) isbn;

-(NSArray *) searchBooks:(NSString *) query From:(NSInteger) from Num:(NSInteger) num;

@end
