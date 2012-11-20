//
//  kkDBMgr.m
//  cjg
//
//  Created by Wang Jinggang on 12-10-21.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import "kkDBMgr.h"
#import <CoreData/CoreData.h>
#import "Mybook.h"
#import "../kkAppDelegate.h"
#import "kkDouBan.h"
#import "kkBookEntity.h"
#import "RegexKitLite.h"
#import "VComment.h"
#import "CustomCategory.h"
#import "Category.h"
@implementation kkDBMgr

-(NSPredicate *) getPredicateFromType:(NSString *) type {
    NSPredicate *predicate = nil;
    if ([type isEqualToString:@"all"]) {
        predicate = [NSPredicate predicateWithFormat:@"is_mine == 1"];
    } else if ([type isEqualToString:@"buylist"]) {
        predicate = [NSPredicate predicateWithFormat:@"status == 'buylist'"];
    } else if ([type isEqualToString:@"read"]) {
        predicate = [NSPredicate predicateWithFormat:@"status == 'read'"];
    } else if ([type isEqualToString:@"unread"]) {
        predicate = [NSPredicate predicateWithFormat:@"status == 'unread'"];
    } else if ([type isEqualToString:@"reading"]) {
        predicate = [NSPredicate predicateWithFormat:@"status == 'reading'"];
    } else if ([type hasPrefix:@"search:"]) {
        NSString* word = [type substringFromIndex:7];
        NSString* likeWord = [NSString stringWithFormat:@"*%@*", word];
        predicate = [NSPredicate predicateWithFormat:@"is_mine == 1 AND (author like[cd] %@ OR title like[cd] %@ OR isbn == %@)", likeWord, likeWord, word];
    } else if ([type hasPrefix:@"tag:"]) {
        NSString* word = [type substringFromIndex:4];
        predicate = [NSPredicate predicateWithFormat:@"ANY tags.name = %@ AND is_mine == 1", word];
    } else if ([type hasPrefix:@"author:"]) {
        NSString* word = [type substringFromIndex:7];
        predicate = [NSPredicate predicateWithFormat:@"ANY authors.name = %@ AND is_mine == 1", word];
    } else if ([type hasPrefix:@"category:"]) {
        NSString* word = [type substringFromIndex:9];
        predicate = [NSPredicate predicateWithFormat:@"category.name = %@ AND is_mine == 1", word];
    }
    return predicate;

}

-(NSInteger) countTheType:(NSString *) type {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    kkAppDelegate* currentDelegate = (kkAppDelegate *)[[UIApplication sharedApplication] delegate];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Mybook" inManagedObjectContext:currentDelegate.managedObjectContext]];
    
    NSPredicate *predicate = [self getPredicateFromType:type];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    return [currentDelegate.managedObjectContext countForFetchRequest:fetchRequest error:&error];
}

-(NSArray *) getBookListOfType:(NSString *) type from:(int) fromNo Num:(int) num {
    //NSLog(@"here ...");
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    kkAppDelegate* currentDelegate = (kkAppDelegate *)[[UIApplication sharedApplication] delegate];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Mybook" inManagedObjectContext:currentDelegate.managedObjectContext]];
    
    NSPredicate *predicate = [self getPredicateFromType:type];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    [fetchRequest setFetchLimit:num];
    [fetchRequest setFetchOffset:fromNo];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modify_time" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedItems = [currentDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedItems == nil) {
        return nil;
    }
    //NSLog(@"the total num:%d", [self countTheType:type]);
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for (int i = 0; i < fetchedItems.count; i++) {
        [result addObject:[kkBookEntity object2Dict:[fetchedItems objectAtIndex:i]]];
    }
    return result;
}

-(void) save:(NSDictionary *) dict {
    NSDictionary* already = [self getBookByID:[dict objectForKey:@"id"]];
    if (already != nil) {
        // ignore
        return ;
    }
    kkAppDelegate* currentDelegate = (kkAppDelegate *)[[UIApplication sharedApplication] delegate];
    Mybook *book = (Mybook *)[NSEntityDescription insertNewObjectForEntityForName:@"Mybook" inManagedObjectContext:currentDelegate.managedObjectContext];
    
    [kkBookEntity dict2Object:dict book:book];
    
    NSError *error = nil;
    if (![currentDelegate.managedObjectContext save:&error ]) {
        // handle error
    }
}



-(NSDictionary *) getBookByISBN:(NSString *)isbn {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    kkAppDelegate* currentDelegate = (kkAppDelegate *)[[UIApplication sharedApplication] delegate];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Mybook" inManagedObjectContext:currentDelegate.managedObjectContext]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isbn == %@", isbn];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    [fetchRequest setFetchLimit:1];
    
    NSError *error = nil;
    NSArray *fetchedItems = [currentDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedItems == nil) {
        return nil;
    }
    if (fetchedItems.count == 1) {
        return [kkBookEntity object2Dict:[fetchedItems objectAtIndex:0]];
    }
    return nil;
}

-(NSDictionary *) getBookByID:(NSString *)bookid {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    kkAppDelegate* currentDelegate = (kkAppDelegate *)[[UIApplication sharedApplication] delegate];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Mybook" inManagedObjectContext:currentDelegate.managedObjectContext]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", bookid];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    [fetchRequest setFetchLimit:1];
    
    NSError *error = nil;
    NSArray *fetchedItems = [currentDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedItems == nil) {
        return nil;
    }
    if (fetchedItems.count == 1) {
        return [kkBookEntity object2Dict:[fetchedItems objectAtIndex:0]];
    }
    return nil;
}

-(void) addComment:(NSString*) soundFile toBook:(NSString*) bookid {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    kkAppDelegate* currentDelegate = (kkAppDelegate *)[[UIApplication sharedApplication] delegate];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Mybook" inManagedObjectContext:currentDelegate.managedObjectContext]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", bookid];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    [fetchRequest setFetchLimit:1];
    
    NSError *error = nil;
    NSArray *fetchedItems = [currentDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedItems == nil) {
        return;
    }
    
    if (fetchedItems.count == 1) {
        Mybook* book = [fetchedItems objectAtIndex:0];
        VComment* vcomment = (VComment *)[NSEntityDescription insertNewObjectForEntityForName:@"VComment" inManagedObjectContext:currentDelegate.managedObjectContext];
        vcomment.file = soundFile;
        vcomment.create_time = [NSDate date];
        book.latest_comment = vcomment;
        [book addCommentsObject:vcomment];
        NSError *error = nil;
        if (![currentDelegate.managedObjectContext save:&error ]) {
            // handle error
        }
    }
    
}
-(void) updateStatus:(NSString* ) status forBookId:(NSString *)bookid {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    kkAppDelegate* currentDelegate = (kkAppDelegate *)[[UIApplication sharedApplication] delegate];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Mybook" inManagedObjectContext:currentDelegate.managedObjectContext]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", bookid];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    [fetchRequest setFetchLimit:1];
    
    NSError *error = nil;
    NSArray *fetchedItems = [currentDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedItems == nil) {
        return;
    }
    if (fetchedItems.count == 1) {
        //return [kkBookEntity object2Dict:[fetchedItems objectAtIndex:0]];
        Mybook* book = [fetchedItems objectAtIndex:0];
        book.status = status;
        if ([book.status isEqualToString:@"read"]
            || [book.status isEqualToString:@"unread"]
            || [book.status isEqualToString:@"reading"]) {
            book.is_mine = [NSNumber numberWithBool:YES];
        } else {
            book.is_mine = [NSNumber numberWithBool:NO];
        }
        book.modify_time = [NSDate date];
        //NSLog(@"status is update to:%@", status);
        NSError *error = nil;
        if (![currentDelegate.managedObjectContext save:&error ]) {
            // handle error
        }
    }
    return;

}

-(void) updateCategory:(NSString *)category forBookId:(NSString *)bookid {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    kkAppDelegate* currentDelegate = (kkAppDelegate *)[[UIApplication sharedApplication] delegate];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Mybook" inManagedObjectContext:currentDelegate.managedObjectContext]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", bookid];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    [fetchRequest setFetchLimit:1];
    
    NSError *error = nil;
    NSArray *fetchedItems = [currentDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedItems == nil) {
        return;
    }
    if (fetchedItems.count == 1) {
        //NSLog(@"here...");
        //return [kkBookEntity object2Dict:[fetchedItems objectAtIndex:0]];
        Mybook* book = [fetchedItems objectAtIndex:0];
        Category* theCategory = (Category *) book.category;
        if (theCategory == nil) {
            theCategory = (Category *)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:currentDelegate.managedObjectContext];
            book.category = theCategory;
        }
        theCategory.name = category;        
        //book.modify_time = [NSDate date];
        //NSLog(@"status is update to:%@", status);
        NSError *error = nil;
        if (![currentDelegate.managedObjectContext save:&error ]) {
            // handle error
        }
    }
    return;
    
}


-(NSArray *) getAllCustomCategories {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    kkAppDelegate* currentDelegate = (kkAppDelegate *)[[UIApplication sharedApplication] delegate];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"CustomCategory" inManagedObjectContext:currentDelegate.managedObjectContext]];
    
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modify_time" ascending:NO];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedItems = [currentDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedItems == nil) {
        return nil;
    }
    //NSLog(@"the total num:%d", [self countTheType:type]);
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for (int i = 0; i < fetchedItems.count; i++) {
        CustomCategory* category = [fetchedItems objectAtIndex:i];
        [result addObject:category.name];
    }
    [result addObject:@"默认分类"];
    return result;
}

-(NSArray *) groupByTags {
    
    // Create the fetch request for the entity
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    kkAppDelegate* currentDelegate = (kkAppDelegate *)[[UIApplication sharedApplication] delegate];
    // Set Entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:currentDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
     NSSortDescriptor *sortDescriptorPDate = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptorPDate, nil]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"book.is_mine == 1"];
    [fetchRequest setPredicate:predicate];
    //[fetchRequest setFetchBatchSize:20];
    
    // Create and initialize the fetch results controller
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:currentDelegate.managedObjectContext sectionNameKeyPath:@"name" cacheName:nil];
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for (id<NSFetchedResultsSectionInfo> info in aFetchedResultsController.sections) {
        NSString* name = [info name];
        NSNumber* num = [NSNumber numberWithInt:[info numberOfObjects]];
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:name, @"name", num, @"num", nil];
        [result addObject:dict];
    }
    return result;
}

-(NSArray *) groupByCategories {
    // Create the fetch request for the entity
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    kkAppDelegate* currentDelegate = (kkAppDelegate *)[[UIApplication sharedApplication] delegate];
    // Set Entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:currentDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortDescriptorPDate = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptorPDate, nil]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"book.is_mine == 1"];
    [fetchRequest setPredicate:predicate];
    //[fetchRequest setFetchBatchSize:20];
    
    // Create and initialize the fetch results controller
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:currentDelegate.managedObjectContext sectionNameKeyPath:@"name" cacheName:nil];
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for (id<NSFetchedResultsSectionInfo> info in aFetchedResultsController.sections) {
        NSString* name = [info name];
        NSNumber* num = [NSNumber numberWithInt:[info numberOfObjects]];
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:name, @"name", num, @"num", nil];
        [result addObject:dict];
    }
    return result;
}
-(NSArray *) groupByAuthors {
    
    // Create the fetch request for the entity
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    kkAppDelegate* currentDelegate = (kkAppDelegate *)[[UIApplication sharedApplication] delegate];
    // Set Entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Author" inManagedObjectContext:currentDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortDescriptorPDate = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptorPDate, nil]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"book.is_mine == 1"];
    [fetchRequest setPredicate:predicate];
    //[fetchRequest setFetchBatchSize:20];
    
    // Create and initialize the fetch results controller
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:currentDelegate.managedObjectContext sectionNameKeyPath:@"name" cacheName:nil];
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for (id<NSFetchedResultsSectionInfo> info in aFetchedResultsController.sections) {
        NSString* name = [info name];
        NSNumber* num = [NSNumber numberWithInt:[info numberOfObjects]];
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:name, @"name", num, @"num", nil];
        [result addObject:dict];
    }
    return result;
}

-(NSString *) saveCustomCategory:(NSString *) name {
    NSString* trimName = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimName length] == 0) {
        return nil;
    }
    if ([trimName isEqualToString:@"默认分类"]) {
        return trimName;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    kkAppDelegate* currentDelegate = (kkAppDelegate *)[[UIApplication sharedApplication] delegate];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"CustomCategory" inManagedObjectContext:currentDelegate.managedObjectContext]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    [fetchRequest setFetchLimit:1];
    
    NSError *error = nil;
    NSArray *fetchedItems = [currentDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedItems == nil) {
        return trimName;
    }
    CustomCategory* cc = nil;
    if ([fetchedItems count] >= 1) {
        cc = [fetchedItems objectAtIndex:0];
    } else {
        cc = (CustomCategory *)[NSEntityDescription insertNewObjectForEntityForName:@"CustomCategory" inManagedObjectContext:currentDelegate.managedObjectContext];
    }
    
    cc.name = trimName;
    cc.modify_time = [NSDate date];
    if (![currentDelegate.managedObjectContext save:&error ]) {
        // handle error
    }
    
    return trimName;
    

}

@end
