//
//  kkCJGViewController.m
//  cjg
//
//  Created by Wang Jinggang on 12-10-21.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import "kkCJGViewController.h"
#import "../Modules/kkFactory.h"

@interface kkCJGViewController ()

@end

@implementation kkCJGViewController

-(id) init {
    return [super initWithType:@"all"];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem* item1 = [[UIBarButtonItem alloc] initWithTitle:@"筛选" style:UIBarButtonItemStylePlain target:self action:@selector(filter)];
    self.navigationItem.leftBarButtonItem = item1;
}

-(void) filter {
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"全部", @"未读", @"在读", @"已读", nil];
    //[sheet showInView:self.view];
    [sheet showFromTabBar:self.tabBarController.tabBar];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [super setType:@"all"];
    } else if (buttonIndex == 1) {
        [super setType:@"unread"];
    } else if (buttonIndex == 2) {
        [super setType:@"reading"];
    } else if (buttonIndex == 3) {
        [super setType:@"read"];
    }
}


@end
