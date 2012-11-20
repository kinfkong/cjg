//
//  kkDBMgr.h
//  cjg
//
//  Created by Wang Jinggang on 12-10-21.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface kkDBMgr : NSObject {

}

-(NSArray *) getBookListOfType:(NSString *) type from:(int) fromNo Num:(int) num;

-(NSInteger) countTheType:(NSString *) type;

-(NSDictionary *) getBookByISBN:(NSString *)isbn;

-(void) save:(NSDictionary *) dict;

-(void) updateStatus:(NSString* ) status forBookId:(NSString *)bookid;
-(void) updateCategory:(NSString* ) category forBookId:(NSString *)bookid;
-(void) addComment:(NSString*) soundFile toBook:(NSString*) bookid;

-(NSDictionary *) getBookByID:(NSString *)bookid;

-(NSArray *) groupByTags;
-(NSArray *) groupByAuthors;
-(NSArray *) groupByCategories;

-(NSString *) saveCustomCategory:(NSString *) name;

-(NSArray *) getAllCustomCategories;

@end
