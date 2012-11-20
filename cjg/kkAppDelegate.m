//
//  kkAppDelegate.m
//  cjg
//
//  Created by Wang Jinggang on 12-10-21.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import "kkAppDelegate.h"

#import "kkFirstViewController.h"

#import "kkSecondViewController.h"
#import "Controllers/kkCJGViewController.h"
#import "KKZBarController.h"
#import "kkSearchViewController.h"
#import "kkMoreViewController.h"
#import "MobClick.h"


@implementation kkAppDelegate

@synthesize managedObjectModel;
@synthesize managedObjectContext;
@synthesize persistentStoreCoordinator;
@synthesize applicationDocumentsDirectory;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //sleep(2);
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.

    //UIViewController *viewController2 = [[kkSecondViewController alloc] initWithNibName:@"kkSecondViewController" bundle:nil];
    
     kkCJGViewController* cjgController = [[kkCJGViewController alloc] init];
    UINavigationController* cjgNavController = [[UINavigationController alloc] init];
    cjgNavController.navigationBar.tintColor = [UIColor blackColor];
    [cjgNavController pushViewController:cjgController animated:NO];

    
    KKZBarController * zbarController = [[KKZBarController alloc] init];
    
    UINavigationController* zbarNavController = [[UINavigationController alloc] init];
    zbarNavController.navigationBar.tintColor = [UIColor blackColor];
    [zbarNavController pushViewController:zbarController animated:NO];
   
    
    kkBookListBaseViewController* buyController = [[kkBookListBaseViewController alloc] initWithType:@"buylist"];
    UINavigationController* buyNavController = [[UINavigationController alloc] init];
        buyNavController.navigationBar.tintColor = [UIColor blackColor];
    [buyNavController pushViewController:buyController animated:NO];
    
    
     UINavigationController* searchNavController = [[UINavigationController alloc] init];
    //[searchNavController setNavigationBarHidden:YES];
    searchNavController.navigationBar.tintColor = [UIColor blackColor];
    
    kkSearchViewController* searchController = [[kkSearchViewController alloc] init];
    [searchNavController pushViewController:searchController animated:NO];
    
     UINavigationController* moreNavController = [[UINavigationController alloc] init];
    kkMoreViewController* moreController = [[kkMoreViewController alloc] init];
    [moreNavController pushViewController:moreController animated:NO];
    moreNavController.navigationBar.tintColor = [UIColor blackColor];
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[cjgNavController, buyNavController, zbarNavController, searchNavController, moreNavController];
    
    cjgNavController.tabBarItem.title = @"藏经阁";
    cjgNavController.tabBarItem.image = [UIImage imageNamed:@"shelf_logo.png"];
    
    buyNavController.tabBarItem.title = @"购书单";
    buyNavController.tabBarItem.image = [UIImage imageNamed:@"buy_logo.png"];
    
    zbarNavController.tabBarItem.title = @"扫描";
    zbarNavController.tabBarItem.image = [UIImage imageNamed:@"barcode_logo.png"];
    
    searchNavController.tabBarItem.title = @"搜索";
    searchNavController.tabBarItem.image = [UIImage imageNamed:@"search_logo.png"];
    
    
    moreNavController.tabBarItem.title = @"更多";
    moreNavController.tabBarItem.image = [UIImage imageNamed:@"more_logo.png"];
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    

    [MobClick startWithAppkey:@"509e793152701519ee000149" reportPolicy:REALTIME channelId:nil];
    [MobClick checkUpdate];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSAssert(0, @"save changes failed when terminage application!");
        }
    }
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    
    //从本地所有xcdatamodel文件中获得这个CoreData的数据模板
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil] ;
    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"booklist.sqlite"]];
    
    NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        NSAssert(0, @"persistentStoreCoordinator init failed!");
    }
    
    return persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

@end
