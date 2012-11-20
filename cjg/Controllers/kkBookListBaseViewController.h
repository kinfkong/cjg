//
//  kkBookListBaseViewController.h
//  cjg
//
//  Created by Wang Jinggang on 12-10-21.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "kkBookTableView.h"

@interface kkBookListBaseViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, kkBookTableViewDelegate> {
    NSString* type;
    kkBookTableView* tableView;
}

-(id) initWithType:(NSString* ) type;

-(void) setType:(NSString*) _type;
@end
