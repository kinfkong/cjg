//
//  kkTagDisplayViewController.h
//  cjg
//
//  Created by Wang Jinggang on 12-11-3.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface kkTagDisplayViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    //UIWebView* webView;
    IBOutlet UITableView* tableView;
    NSString* type;
    NSArray* dataSourceArray;
}

-(id) initWithType:(NSString*) type;
@end
