//
//  kkBookListBaseViewController.m
//  cjg
//
//  Created by Wang Jinggang on 12-10-21.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import "kkBookListBaseViewController.h"
#import "kkFactory.h"
#import "UIImageView+ASYNC.h"
#import "KKBookInfoController.h"

@interface kkBookListBaseViewController ()

@end

@implementation kkBookListBaseViewController

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
	// Do any additional setup after loading the view.
    CGRect frame = self.view.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    tableView = [[kkBookTableView alloc] initWithFrame:frame type:type];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    tableView.bookDelegate = self;
    [self.view addSubview:tableView];
    [tableView show];
    [self changeTitle];
}

-(void) setType:(NSString*) _type {
    type = _type;
    //currentPage = 0;
    [tableView setType:_type];
    [self changeTitle];
}

-(void) onTableStatusChanged {
    //NSLog(@"table status changed");
    [self changeTitle];
}

-(void) changeTitle {
    if ([type isEqualToString:@"all"]) {
        self.navigationItem.title = @"全部藏书";
    } else if ([type isEqualToString:@"buylist"]) {
        self.navigationItem.title = @"购书单";
    } else if ([type isEqualToString:@"read"]) {
        self.navigationItem.title = @"已读藏书";
    } else if ([type isEqualToString:@"unread"]) {
        self.navigationItem.title = @"未读藏书";
    } else if ([type isEqualToString:@"reading"]) {
        self.navigationItem.title = @"在读藏书";
    } else if ([type hasPrefix:@"tag:"]) {
        self.navigationItem.title = [type substringFromIndex:4];
    } else if ([type hasPrefix:@"category:"]) {
        self.navigationItem.title = [type substringFromIndex:9];
    } else if ([type hasPrefix:@"author:"]) {
        self.navigationItem.title = [type substringFromIndex:7];
    }
    if (tableView.bookNum > 0) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@(%d)",
                                     self.navigationItem.title, tableView.bookNum];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(id) initWithType:(NSString* ) _type {
    type = _type;
    return self;
}

-(void) onBookSelected:(NSDictionary *)bookInfo tableView:(kkBookTableView *)tableView {
    KKBookInfoController* controller = nil;
    NSDictionary* newBookInfo = [[[kkFactory getInstance] getDBMgr] getBookByID:[bookInfo objectForKey:@"id"]];
    if (newBookInfo == nil) {
        controller = [[KKBookInfoController alloc] initWithBookInfo:bookInfo];
    } else {
        controller = [[KKBookInfoController alloc] initWithBookInfo:newBookInfo];
    }
    [self.navigationController pushViewController:controller animated:YES];
}
@end
