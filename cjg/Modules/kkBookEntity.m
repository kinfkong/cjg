//
//  kkBookEntity.m
//  cjg
//
//  Created by Wang Jinggang on 12-10-27.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import "kkBookEntity.h"
#import "kkAppDelegate.h"
#import "Tag.h"
#import "Author.h"
#import "RegexKitLite.h"
#import "VComment.h"
#import "Category.h"

@implementation kkBookEntity

+(NSDictionary *) object2Dict:(Mybook *) book {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    /*
     @property (nonatomic, retain) NSString * author;
     @property (nonatomic, retain) NSString * author_info;
     @property (nonatomic, retain) NSString * detail_url;
     @property (nonatomic, retain) NSString * id;
     @property (nonatomic, retain) NSString * image;
     @property (nonatomic, retain) NSString * isbn;
     @property (nonatomic, retain) NSString * price;
     @property (nonatomic, retain) NSString * pubdate;
     @property (nonatomic, retain) NSString * publisher;
     @property (nonatomic, retain) NSNumber * rating;
     @property (nonatomic, retain) NSString * status;
     @property (nonatomic, retain) NSString * summary;
     @property (nonatomic, retain) NSString * title;
     @property (nonatomic, retain) NSDate * modify_time;
     */
    [dict setObject:book.id forKey:@"id"];
    [dict setObject:book.author forKey:@"author"];
    [dict setObject:book.author_info forKey:@"author_info"];
    [dict setObject:book.detail_url forKey:@"detail_url"];
    [dict setObject:book.image forKey:@"image"];
    [dict setObject:book.isbn forKey:@"isbn"];
    [dict setObject:book.price forKey:@"price"];
    [dict setObject:book.pubdate forKey:@"pubdate"];
    [dict setObject:book.publisher forKey:@"publisher"];
    [dict setObject:book.rating forKey:@"rating"];
    [dict setObject:book.status forKey:@"status"];
    [dict setObject:book.summary forKey:@"summary"];
    [dict setObject:book.title forKey:@"title"];
    [dict setObject:book.modify_time forKey:@"modify_time"];
    if (book.category == nil) {
        [dict setObject:@"默认分类" forKey:@"category"];
    } else {
        [dict setObject:((Category *) book.category).name forKey:@"category"];
    }
    
    NSSet* tags = book.tags;
    NSMutableArray* tagArray = [[NSMutableArray alloc] init];
    for (Tag* tag in tags) {
        NSDictionary* tagDict = [NSDictionary dictionaryWithObjectsAndKeys:tag.name, @"name", nil];
        [tagArray addObject:tagDict];
    }
    [dict setObject:tagArray forKey:@"tags"];
    
    NSSet* comments = book.comments;
    NSMutableArray* commentArray = [[NSMutableArray alloc] init];
    for (VComment* comment1 in comments) {
        NSDictionary* commentDict = [NSDictionary dictionaryWithObjectsAndKeys:comment1.file, @"file", comment1.create_time, @"create_time", nil];
        [commentArray addObject:commentDict];
    }
    [dict setObject:commentArray forKey:@"comments"];
    if (book.latest_comment != nil) {
        NSDictionary* latest = [NSDictionary dictionaryWithObjectsAndKeys:book.latest_comment.file, @"file", book.latest_comment.create_time, @"create_time", nil];
        [dict setObject:latest forKey:@"latest_comment"];
    }
    
    return dict;
}

+(void) dict2Object:(NSDictionary *) dict book:(Mybook *) book {
    
    book.id = [dict objectForKey:@"id"];
    book.author = [dict objectForKey:@"author"];
    book.author_info = [dict objectForKey:@"author_info"];
    book.detail_url = [dict objectForKey:@"detail_url"];
    book.image = [dict objectForKey:@"image"];
    book.isbn = [dict objectForKey:@"isbn"];
    book.price = [dict objectForKey:@"price"];
    book.pubdate = [dict objectForKey:@"pubdate"];
    book.publisher = [dict objectForKey:@"publisher"];
    book.rating = [dict objectForKey:@"rating"];
    book.status = [dict objectForKey:@"status"];
    book.summary = [dict objectForKey:@"summary"];
    book.title = [dict objectForKey:@"title"];
    book.modify_time = [dict objectForKey:@"modify_time"];
    if ([book.status isEqualToString:@"read"]
        || [book.status isEqualToString:@"reading"]
        || [book.status isEqualToString:@"unread"]) {
        book.is_mine = [NSNumber numberWithBool:YES];
    } else {
        book.is_mine = [NSNumber numberWithBool:NO];
    }
    
    NSString* category = [dict objectForKey:@"category"];
    if (category == nil) {
        category = @"默认分类";
    }
    kkAppDelegate* currentDelegate = (kkAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Category *theCategory = (Category *)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:currentDelegate.managedObjectContext];
    
    theCategory.name = category;
    book.category = theCategory;
    
    
    NSArray* tags = [dict objectForKey:@"tags"];
    for (int i = 0; i < [tags count]; i++) {
        NSDictionary* tag = [tags objectAtIndex:i];
        Tag *tagEntity = (Tag *)[NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:currentDelegate.managedObjectContext];
        tagEntity.name = (NSString *) [tag objectForKey:@"name"];
        [book addTagsObject:tagEntity];
    }
    
    NSArray* authors = [dict objectForKey:@"authors"];
    for (int i = 0; i < [authors count]; i++) {
        NSString* author = [authors objectAtIndex:i];
        Author *authorEntity = (Author *)[NSEntityDescription insertNewObjectForEntityForName:@"Author" inManagedObjectContext:currentDelegate.managedObjectContext];
        authorEntity.name = author;
        [book addAuthorsObject:authorEntity];
    }
    
}

+(NSString* ) normalizeAuthor:(NSString *) author {
    NSMutableString* result = [NSMutableString stringWithString:author];
    NSArray* old = [NSArray arrayWithObjects:@"（", @"）", @"【", @"】", @".", @"-", @"．", @".", @"[", @"]", @"・", nil];
    NSArray* new = [NSArray arrayWithObjects:@"(", @")", @"(", @")", @"·", @"·", @"·", @"·", @"(", @")", @"·", nil];
    for (int i = 0; i < [old count]; i++) {
        [result replaceOccurrencesOfString:[old objectAtIndex:i] withString:[new objectAtIndex:i] options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    }
    NSString* reg = [result stringByReplacingOccurrencesOfRegex:@"\\([^)(]*\\)" withString:@""];
    reg = [reg stringByReplacingOccurrencesOfRegex:@"^.*／" withString:@""];
    NSString *trimmedString = [reg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // sorted by length
    NSArray* suf = [NSArray arrayWithObjects:@"选编", @"编选", @"主编", @"编著", @"著", @"编", @"选",  @"等", nil];
    for (NSString* suffix in suf) {
        if ([trimmedString hasSuffix:suffix]) {
            trimmedString = [trimmedString substringToIndex:(trimmedString.length - suffix.length)];
        }
    }
    trimmedString = [trimmedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return trimmedString;
}

+(NSDictionary *) doubanJSON2Dict:(NSDictionary *) douban {
    NSString* bookid = [douban objectForKey:@"id"];
    if (bookid == nil) {
        return nil;
    }
    NSString* author = @"";
    NSArray* doubanAuthor = [douban objectForKey:@"author"];
    if (doubanAuthor != nil && doubanAuthor.count >= 2) {
        author = [NSString stringWithFormat:@"%@ %@等", [doubanAuthor objectAtIndex:0], [doubanAuthor objectAtIndex:1]];
    } else if (doubanAuthor != nil && doubanAuthor.count == 1) {
        author = [doubanAuthor objectAtIndex:0];
    }
    
    NSString* author_info = [douban objectForKey:@"author_intro"];
    if (author_info == nil) {
        author = @"";
    }
    
    NSString* detail_url = [douban objectForKey:@"alt"];
    if (detail_url == nil) {
        detail_url = @"";
    }
    
    NSString* image =[douban objectForKey:@"image"];
    if (image == nil) {
        image = @"";
    }
    
    NSString* isbn = [douban objectForKey:@"isbn13"];
    if (isbn == nil) {
        isbn = [douban objectForKey:@"isbn10"];
    }
    if (isbn == nil) {
        return nil;
    }
    
    NSString* price = [douban objectForKey:@"price"];
    if (price == nil) {
        price = @"";
    }
    
    NSString* pubdate = [douban objectForKey:@"pubdate"];
    if (pubdate == nil) {
        pubdate = @"";
    }
    
    NSString* publisher = [douban objectForKey:@"publisher"];
    if (publisher == nil) {
        publisher = @"";
    }
    
    NSNumber* rating;
    NSString* ratingstr = [[douban objectForKey:@"rating"] objectForKey:@"average"];
    if (ratingstr == nil) {
        rating = [NSNumber numberWithDouble:0];
    } else {
        rating = [NSNumber numberWithDouble:[ratingstr doubleValue]];
    }
    
    
    NSString* summary = [douban objectForKey:@"summary"];
    if (summary == nil) {
        summary = @"";
    }
    
    NSString* title = [douban objectForKey:@"title"];
    if (title == nil) {
        title = @"";
    }
    
    NSArray* tags = [douban objectForKey:@"tags"];
    if (tags == nil) {
        tags = [[NSArray alloc] init];
    }
    
    NSArray* authorarray = [douban objectForKey:@"author"];
    if (authorarray == nil) {
        authorarray = [[NSArray alloc] init];
    }
    NSMutableArray* authors = [[NSMutableArray alloc] init];
    for (NSString* authorstr in authorarray) {
        @autoreleasepool {
            NSString* name = [kkBookEntity normalizeAuthor:authorstr];
            [authors addObject:name];
            //NSLog(@"The author name[%@]", name);
        }
    }
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:bookid forKey:@"id"];
    [dict setObject:author forKey:@"author"];
    [dict setObject:author_info forKey:@"author_info"];
    [dict setObject:detail_url forKey:@"detail_url"];
    [dict setObject:image forKey:@"image"];
    [dict setObject:isbn forKey:@"isbn"];
    [dict setObject:price forKey:@"price"];
    [dict setObject:pubdate forKey:@"pubdate"];
    [dict setObject:publisher forKey:@"publisher"];
    [dict setObject:rating forKey:@"rating"];
    [dict setObject:@"none" forKey:@"status"];
    [dict setObject:summary forKey:@"summary"];
    [dict setObject:title forKey:@"title"];
    [dict setObject:[NSDate date] forKey:@"modify_time"];
    [dict setObject:tags forKey:@"tags"];
    [dict setObject:authors forKey:@"authors"];
    [dict setObject:@"默认分类" forKey:@"category"];
    
    return dict;
}

@end
