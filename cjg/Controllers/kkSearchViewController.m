//
//  kkSearchViewController.m
//  cjg
//
//  Created by Wang Jinggang on 12-11-3.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import "kkSearchViewController.h"
#import "KKBookInfoController.h"
#import "kkTagDisplayViewController.h"
#import "kkFactory.h"
#import "kkBookEntity.h"
#import "MobClick.h"

@interface kkSearchViewController ()

@end

@implementation kkSearchViewController

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
    //searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    //searchBar.tintColor = [UIColor blackColor];
    //searchBar.placeholder = @"输入作者、书名或ISBN号";
    
    [segment addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
     
    self.navigationItem.titleView  = searchBar;
    searchBar.delegate = self;

    CGFloat offy = segment.frame.size.height;
    CGFloat tableheight = self.view.frame.size.height - offy - self.tabBarController.tabBar.frame.size.height;
    buttonTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, offy, self.view.frame.size.width, tableheight) style:UITableViewStyleGrouped];
    buttonTableView.delegate = self;
    buttonTableView.dataSource = self;
    
    buttonTableView.autoresizesSubviews = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:buttonTableView];
    
    mask = [[UIView alloc] initWithFrame:buttonTableView.frame];
    mask.backgroundColor = [UIColor blackColor];
    mask.alpha = 0.9;
}

-(void) touchTheView:(id) sender {
    [searchBar resignFirstResponder];
}

-(void) segmentAction:(id) sender {
    [buttonTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)_searchBar
{
    searchBar.showsCancelButton = true;
    if (mask.superview != self.view) {
        [self.view addSubview:mask];
    }

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar
{
    searchBar.showsCancelButton = false;
    [searchBar resignFirstResponder];
    
    searchBar.text = nil;
    //[self filterContentForSearchBar:searchBar];
    [tableView removeFromSuperview];
    tableView = nil;
    
    [mask removeFromSuperview];
}

-(void) viewDidAppear:(BOOL)animated {
    //[self.navigationController setNavigationBarHidden:YES animated:NO];
}
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    //[self filterContentForSearchBar:searchBar];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
    @autoreleasepool {
        
    
    //searchBar.showsCancelButton = false;
    [searchBar resignFirstResponder];
        for(id subview in [searchBar subviews])
        {
            if ([subview isKindOfClass:[UIButton class]]) {
                [subview setEnabled:YES];
            }
        }
        
    NSString* scopeType = @"search";
    if (segment.selectedSegmentIndex != 0) {
        scopeType = @"net";
    }
    NSString* type = [NSString stringWithFormat:@"%@:%@", scopeType, _searchBar.text];
    CGFloat offy = segment.frame.size.height;
    CGFloat height = self.view.frame.size.height - segment.frame.size.height;
    CGRect frame = CGRectMake(0, offy, self.view.frame.size.width, height);
    if (tableView != nil) {
        [tableView removeFromSuperview];
        tableView = nil;
    }
    tableView = [[kkBookTableView alloc] initWithFrame:frame type:type];
    tableView.bookDelegate = self;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView];
        [tableView show];
    [MobClick event:@"search" label:scopeType];
    }
    
}

-(void) onBookSelected:(NSDictionary *)bookInfo tableView:(kkBookTableView *)tableView {
    //NSLog(@"the book:%@", bookInfo);
    @autoreleasepool {
        NSString* bookId = [bookInfo objectForKey:@"id"];
        if (bookId == nil) {
            return;
        }
        NSDictionary* dict = [[[kkFactory getInstance] getDBMgr] getBookByID:bookId];
        if (dict != nil) {
            KKBookInfoController* controller = [[KKBookInfoController alloc] initWithBookInfo:dict];
            [self.navigationController pushViewController:controller animated:YES];
        } else {
            NSString* urlstr = [NSString
                                stringWithFormat:
                                @"http://api.douban.com/v2/book/%@?apikey=00ae73c9110cc3b0020b5b5b33264b10",
                                bookId];
            NSURLRequest* urlrequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlstr]];
            KKNetworkLoadingView* loadingView = [[KKNetworkLoadingView alloc] initWithRequest:urlrequest delegate:self];
            [self.view addSubview:loadingView];
        }

    }
    
}


- (void) bookTableViewViewDidScroll:(kkBookTableView *)bookTableView {
    [searchBar resignFirstResponder];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (segment.selectedSegmentIndex == 0) {
        return 3;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* ccell = [_tableView dequeueReusableCellWithIdentifier:@"commoncell"];
    if (ccell == nil) {
        ccell = [[[NSBundle mainBundle]loadNibNamed:@"BookCommonCell" owner:self options:nil] objectAtIndex:0];
    }
    
    UILabel* title = (UILabel *) [ccell viewWithTag:1];
    title.textAlignment = NSTextAlignmentLeft;
    
    if ([indexPath row] == 0) {
        title.text = @"按作者查看";
    } else if ([indexPath row] == 1) {
        title.text = @"按标签查看";
    } else if ([indexPath row] == 2) {
        title.text = @"按自定义类别查看";
    }
    return ccell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] == 0) {
        [MobClick event:@"authorlist"];
        kkTagDisplayViewController* controller = [[kkTagDisplayViewController alloc] initWithType:@"author"];
        [self.navigationController pushViewController:controller animated:YES];
    } else if ([indexPath row] == 1) {
        [MobClick event:@"taglist"];
        kkTagDisplayViewController* controller = [[kkTagDisplayViewController alloc] initWithType:@"tag"];
        [self.navigationController pushViewController:controller animated:YES];
    } else if ([indexPath row] == 2) {
        [MobClick event:@"categorylist"];
        kkTagDisplayViewController* controller = [[kkTagDisplayViewController alloc] initWithType:@"category"];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

-(void) view:(KKNetworkLoadingView *) sender onFinishedLoading:(NSDictionary *) data {
    if ([data objectForKey:@"id"] == nil) {
        [self view:sender onFailedLoading:nil];
        return;
    }
    
    NSDictionary* normalData = [kkBookEntity doubanJSON2Dict:data];
    kkDBMgr* mgr = [[kkFactory getInstance] getDBMgr];
    [mgr save:normalData];
    KKBookInfoController* controller = [[KKBookInfoController alloc] initWithBookInfo:normalData];
    [self.navigationController pushViewController:controller animated:YES];
    
}

-(void) view:(KKNetworkLoadingView *) sender  onFailedLoading:(NSError *) error {
    
}


@end
