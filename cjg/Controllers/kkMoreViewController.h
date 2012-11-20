//
//  kkMoreViewController.h
//  cjg
//
//  Created by Wang Jinggang on 12-11-10.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import <StoreKit/StoreKit.h>

@interface kkMoreViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, GKLeaderboardViewControllerDelegate>{
    IBOutlet UITableView* tableView;
    IBOutlet UIActivityIndicatorView* av;
    IBOutlet UIView* processingView;
}

@end
