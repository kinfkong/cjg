//
//  Mybook.h
//  cjg
//
//  Created by Wang Jinggang on 12-11-10.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Author, Tag, VComment;

@interface Mybook : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * author_info;
@property (nonatomic, retain) NSString * detail_url;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSNumber * is_mine;
@property (nonatomic, retain) NSString * isbn;
@property (nonatomic, retain) NSDate * modify_time;
@property (nonatomic, retain) NSString * price;
@property (nonatomic, retain) NSString * pubdate;
@property (nonatomic, retain) NSString * publisher;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *authors;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) VComment *latest_comment;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) NSManagedObject *category;
@end

@interface Mybook (CoreDataGeneratedAccessors)

- (void)addAuthorsObject:(Author *)value;
- (void)removeAuthorsObject:(Author *)value;
- (void)addAuthors:(NSSet *)values;
- (void)removeAuthors:(NSSet *)values;

- (void)addCommentsObject:(VComment *)value;
- (void)removeCommentsObject:(VComment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
