//
//  kkBookTableView.h
//  cjg
//
//  Created by Wang Jinggang on 12-11-3.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKNetworkLoadingView.h"

@class kkBookTableView;

@protocol kkBookTableViewDelegate <NSObject>

@optional
-(void) onBookSelected:(NSDictionary *) bookInfo tableView:(kkBookTableView *) tableView;

-(void) onTableStatusChanged;

- (void) bookTableViewViewDidScroll:(kkBookTableView *)bookTableView;

@end

@interface kkBookTableView : UITableView <UITableViewDataSource, UITableViewDelegate, KKNetworkLoadingViewDelegate, UIScrollViewDelegate> {
    NSMutableArray* bookList;
    NSString* type;
    int currentPage;
    int bookNum;
    int perPageNum;
    BOOL hasMore;
    
    id<kkBookTableViewDelegate> bookDelegate;
    
    int mode;
    
    KKNetworkLoadingView* searchView;
    KKNetworkLoadingView* moreSearchView;
    int reqNum;
    
}

@property (readonly) int bookNum;
@property (retain, nonatomic) id<kkBookTableViewDelegate> bookDelegate;

-(void) setType:(NSString*) _type;
- (id)initWithFrame:(CGRect)frame type:(NSString*) type;
-(void) show;

@end
