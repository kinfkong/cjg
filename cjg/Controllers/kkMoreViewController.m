//
//  kkMoreViewController.m
//  cjg
//
//  Created by Wang Jinggang on 12-11-10.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import "kkMoreViewController.h"
#import "UMFeedback.h"
#import <GameKit/GameKit.h>
#import "kkFactory.h"
#import "kkAboutViewController.h"
#import <StoreKit/StoreKit.h>
#import "UMSNSService.h"

@interface kkMoreViewController ()

@end

@implementation kkMoreViewController

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
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"更多";
    tableView.delegate = self;
    tableView.dataSource = self;
    
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 3;
    } else if (section == 2) {
        return 1;
    }
    return 0;
}

-(UITableViewCell *) tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* ccell = [_tableView dequeueReusableCellWithIdentifier:@"commoncell"];
    if (ccell == nil) {
        ccell = [[[NSBundle mainBundle]loadNibNamed:@"BookCommonCell" owner:self options:nil] objectAtIndex:0];
    }
    
    UILabel* title = (UILabel *) [ccell viewWithTag:1];
    title.textAlignment = NSTextAlignmentLeft;
    int section = [indexPath section];
    int row = [indexPath row];
    if (section == 0) {
        title.text = @"查看排行榜";
    } else if (section == 1 && row == 0) {
        title.text = @"给藏经阁打个好评";
    } else if (section == 1 && row == 1) {
        title.text = @"反馈意见";
    } else if (section == 1 && row == 2) {
        title.text = @"分享到微博";
    } else if (section == 2) {
        title.text = @"关于";
    } else {
        title.text = @"";
    }
    return ccell;
}

-(void) reportScore {
    int score = [[[kkFactory getInstance] getDBMgr] countTheType:@"all"];
    NSString* category = @"com.obanana.cjg.all.rank";
    GKScore *scoreReporter = [[GKScore alloc] initWithCategory:category];
    scoreReporter.value = score;
    [scoreReporter reportScoreWithCompletionHandler: ^(NSError *error) {
        if(error != nil) {
            // doest nothing
            NSLog(@"failed to submit:%@,%d", category, score);
        }
        else {
            // show
            NSLog(@"success to submit:%@,%d", category, score);
        }
    }];
    
    score = [[[kkFactory getInstance] getDBMgr] countTheType:@"read"];
    category = @"com.obanana.cjg.read.rank";
    scoreReporter = [[GKScore alloc] initWithCategory:category];
    scoreReporter.value = score;
    [scoreReporter reportScoreWithCompletionHandler: ^(NSError *error) {
        if(error != nil) {
            // doest nothing
            NSLog(@"failed to submit:%@,%d", category, score);
        }
        else {
            // show
            NSLog(@"success to submit:%@,%d", category, score);
        }
    }];
}

-(void) showGameCenter {
    GKLeaderboardViewController *controller = [[GKLeaderboardViewController alloc] init];
    
    [controller setTimeScope:GKLeaderboardTimeScopeAllTime];
    [controller setLeaderboardDelegate:self];
    
    [self presentModalViewController:controller animated:YES];
}

-(void) dismissProcessView {
    [av stopAnimating];
    [processingView removeFromSuperview];
}


-(void) authorGameCenter {
    if (av.isAnimating) {
        return;
    }
    processingView.center = tableView.center;
    if ([processingView superview] != self.view) {
        [self.view addSubview:processingView];
    }
    [av startAnimating];
    
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
        [self performSelectorOnMainThread:@selector(dismissProcessView) withObject:nil waitUntilDone:NO];
        if (error == nil){
            // report score
            [self reportScore];
            [self performSelectorOnMainThread:@selector(showGameCenter) withObject:nil waitUntilDone:NO];
        } else {
            NSLog(@"Could not authenticate the local player. Error = %@", error);
        }
    }];
}

-(void) tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int section = [indexPath section];
    int row = [indexPath row];
    if (section == 0 && row == 0) {
        [self authorGameCenter];
    } else if (section == 1 && row == 0) {
        NSString *str = [NSString stringWithFormat:
                         @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",
                         @"578075328"];
        //NSLog(@"here");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    } else if (section == 1 && row == 1) {
        [UMFeedback showFeedback:self withAppkey:@"509e793152701519ee000149"];
    } else if (section == 1 && row == 2) {
        //[UMSNSService showSNSActionSheetInController:self appkey:@"509e793152701519ee000149" status:@"分享文字"image:nil];
        [UMSNSService presentSNSInController:self appkey:@"509e793152701519ee000149" status:@"藏经阁是一款十分强大的书籍管理应用，推荐给大家。https://itunes.apple.com/us/app/cang-jing-ge/id578075328?ls=1&mt=8" image:nil platform:UMShareToTypeSina];
    } else if (section == 2 && row == 0) {
        kkAboutViewController* controller = [[kkAboutViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)leaderboardViewControllerDidFinish:
(GKLeaderboardViewController *)viewController{
    
    /* We are finished here */
    //NSLog(@"finished ...");
    [self dismissModalViewControllerAnimated:YES];
    
}
@end
