//
//  kkSearchViewController.h
//  cjg
//
//  Created by Wang Jinggang on 12-11-3.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "kkBookTableView.h"
#import "KKNetworkLoadingView.h"

@interface kkSearchViewController : UIViewController <UISearchBarDelegate, kkBookTableViewDelegate, UITableViewDataSource, UITableViewDelegate, KKNetworkLoadingViewDelegate>{
    
    IBOutlet UISearchBar* searchBar;
    IBOutlet UISegmentedControl* segment;
    UITableView* buttonTableView;
    //IBOutlet UISearchDisplayController* sdController;
    
    kkBookTableView* tableView;
    UIView* mask;
}

@end
