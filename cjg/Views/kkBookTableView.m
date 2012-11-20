//
//  kkBookTableView.m
//  cjg
//
//  Created by Wang Jinggang on 12-11-3.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import "kkBookTableView.h"
#import "UIImageView+ASYNC.h"
#import "kkFactory.h"
#import "KKNetworkLoadingView.h"
#import "kkBookEntity.h"

@implementation kkBookTableView

@synthesize bookNum;
@synthesize bookDelegate;

- (id)initWithFrame:(CGRect)frame type:(NSString*) _type {
    self = [super initWithFrame:frame];
    if (self) {
        
        super.delegate = self;
        super.dataSource = self;
        //super.super.delegate = self;
        perPageNum = 50;
        type = _type;
        
        
        
        
    }
    return self;
}

-(void) show {
    [self setType:type];
}

-(void) bookStatusChanged:(id) obj {
    if (mode == 1) {
        return;
    }
    
    [self typeChanged];
    if (bookDelegate != nil && [bookDelegate respondsToSelector:@selector(onTableStatusChanged)]) {
        [bookDelegate onTableStatusChanged];
    }
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) typeChanged {
    if ([type hasPrefix:@"net:"]) {
        mode = 1;
    } else {
        mode = 0;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (mode == 0) {
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(bookStatusChanged:) name:@"bookStatusChanged" object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
    if (mode == 0) {
            int currentNum = bookList.count;
        if (currentNum < perPageNum) {
            currentNum = perPageNum;
        }
            bookList = [NSMutableArray arrayWithArray:[[[kkFactory getInstance] getDBMgr] getBookListOfType:type from:0 Num:currentNum]];
            //NSLog(@"the number of book list:%d,type:%@", [bookList count], type);
        
            bookNum = [[[kkFactory getInstance] getDBMgr] countTheType:type];
            if (bookList.count == currentNum) {
                hasMore = YES;
            } else {
                hasMore = NO;
            }
            [self reloadData];
        
    } else {
        reqNum = bookList.count;
        if (reqNum < perPageNum) {
            reqNum = perPageNum;
        }
        NSString* query = [type substringFromIndex:4];
        NSString * encodedString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                                NULL,
                                                                                                (CFStringRef)query,
                                                                                                NULL,
                                                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                kCFStringEncodingUTF8 );
        
        NSString* urlstr = [NSString
                            stringWithFormat:
                            @"https://api.douban.com/v2/book/search?q=%@&start=%d&count=%d&apikey=00ae73c9110cc3b0020b5b5b33264b10",
                            encodedString, 0, reqNum];
        NSURL* url = [NSURL URLWithString:urlstr];
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        searchView = [[KKNetworkLoadingView alloc] initWithRequest:request delegate:self];
        [self.superview addSubview:searchView];
        //NSLog(@"super view:%@", self.superview);
    }
}

-(void) setType:(NSString*) _type {
    type = _type;
    currentPage = 0;
    @autoreleasepool {
        [self typeChanged];
    }
    
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame type:@"undefined"];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger ret = [bookList count];
    if (hasMore) {
        ret++;
    }
    return ret;
}

- (UITableViewCell *)tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] >= [bookList count]) {
        UITableViewCell* msgCell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"morecell"];
        if (msgCell == nil) {
            msgCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"morecell"];
            msgCell.selectionStyle = UITableViewCellSelectionStyleNone;
            //msgCell.textLabel.text = @"more ...";
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 40)];
            [msgCell addSubview:label];
            label.text = @"点击加载更多";
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor grayColor];
            //msgCell.backgroundColor = [UIColor lightGrayColor];
        }
        return msgCell;
    }
    
    NSDictionary* data = [bookList objectAtIndex:[indexPath row]];
    static NSString* identifier = @"KKBookListViewCell";
	UITableViewCell* msgCell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:identifier];
	if (msgCell == nil) {
		msgCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		msgCell.selectionStyle = UITableViewCellSelectionStyleNone;
		UIImageView* bookImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 3, 60, 84)];
		bookImageView.tag = 321;
		[msgCell addSubview:bookImageView];
		//[bookImageView release];
        
        UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(72, 8, 196, 18)];
        title.tag = 11111;
        [msgCell addSubview:title];
        //[title release];
        title.font = [UIFont boldSystemFontOfSize:16];
        //title.backgroundColor = [UIColor redColor];
        
        UILabel* status = [[UILabel alloc] initWithFrame:CGRectMake(270, 8, 40, 18)];
        status.tag = 88888;
        [msgCell addSubview:status];
        //[status release];
        status.font = [UIFont systemFontOfSize:14];
        // status.backgroundColor = [UIColor blueColor];
        // title.text = [data objectForKey:@"title"];
        
        UILabel* author = [[UILabel alloc] initWithFrame:CGRectMake(72, 30, 300 - 72, 16)];
        author.tag = 22222;
        author.textColor = [UIColor grayColor];
        [msgCell addSubview:author];
        //[author release];
        //author.text = [data objectForKey:@"author"];
        author.font = [UIFont systemFontOfSize:14];
        
        
        UILabel* pubInfo = [[UILabel alloc] initWithFrame:CGRectMake(72, 48, 300 - 72, 16)];
        pubInfo.tag = 33333;
        [msgCell addSubview:pubInfo];
        //[pubInfo release];
        //author.text = [data objectForKey:@"author"];
        pubInfo.textColor = [UIColor grayColor];
        pubInfo.font = [UIFont systemFontOfSize:14];
		
        UILabel* rating = [[UILabel alloc] initWithFrame:CGRectMake(72, 66, 300 - 72, 16)];
        rating.tag = 44444;
        [msgCell addSubview:rating];
        //[rating release];
        //author.text = [data objectForKey:@"author"];
        rating.textColor = [UIColor grayColor];
        rating.font = [UIFont systemFontOfSize:14];
        
        /*
         bookImageView.layer.masksToBounds = YES;
         bookImageView.layer.cornerRadius = 4.0;
         bookImageView.layer.borderWidth = 0.0;
         bookImageView.layer.borderColor = [[UIColor clearColor] CGColor];
         bookImageView.userInteractionEnabled = YES;
         */
        /*
         UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(120, 15, 320 - 120, 25)];
         label.font = [UIFont boldSystemFontOfSize:16.0f];
         label.tag = 100;
         [msgCell addSubview:label];
         [label release];
         
         UILabel* namelabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 50, 320 - 120, 20)];
         namelabel.font = [UIFont systemFontOfSize:18.0f];
         namelabel.tag = 101;
         namelabel.textColor = [UIColor grayColor];
         [msgCell addSubview:namelabel];
         [namelabel release];
         */
	}
	
    msgCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	UIImageView* bookImageView = (UIImageView *) [msgCell viewWithTag:321];
	NSString* msgId = [data objectForKey:@"id"];
	NSMutableDictionary* imageInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:msgId, @"id", indexPath, @"indexPath", nil];
    
    NSString* url = [data objectForKey:@"image"];
	[bookImageView loadImageWithURL:url tmpImage:[UIImage imageNamed:@"noimage.png"] cache:YES delegate:nil withObject:imageInfo];
    UILabel* title = (UILabel *) [msgCell viewWithTag:11111];
    title.text = [data objectForKey:@"title"];
    UILabel* author = (UILabel *) [msgCell viewWithTag:22222];
    author.text = [data objectForKey:@"author"];
    
    UILabel* pubInfo = (UILabel *) [msgCell viewWithTag:33333];
    NSString* pubStr = [NSString stringWithFormat:@"%@ / %@", [data objectForKey:@"pubdate"] == nil ? @"" : [data objectForKey:@"pubdate"], [data objectForKey:@"publisher"] == nil ? @"" : [data objectForKey:@"publisher"]];
    pubInfo.text = pubStr;
    
    
    UILabel* rating = (UILabel *) [msgCell viewWithTag:44444];
    double ratingV = [data objectForKey:@"rating"] == nil ? 0 :
    [(NSNumber *)[data objectForKey:@"rating"] doubleValue];
    if (ratingV > 0.01) {
        NSString* ratingStr = [NSString stringWithFormat:@"评分: %.1lf分", ratingV
                           ];
    
        rating.text = ratingStr;
    } else {
        rating.text = @"";
    }
    
    UILabel* status = (UILabel *) [msgCell viewWithTag:88888];
    NSString* statusStr = @"";
    NSString* tstr = [data objectForKey:@"status"];
    if ([tstr isEqualToString:@"reading"]) {
        status.textColor = [UIColor colorWithRed:0 / 256. green:(8 * 16 + 11) / 256. blue:0 / 256. alpha:1.0];
        //status.textColor = [UIColor greenColor];
        statusStr = @"在读";
    } else if ([tstr isEqualToString:@"unread"]) {
        status.textColor = [UIColor grayColor];
        statusStr = @"未读";
    } else if ([tstr isEqualToString:@"read"]) {
        //status.textColor = [UIColor blueColor];
        status.textColor = [UIColor colorWithRed:(8 * 16 + 11) / 256. green:0. / 256. blue:0 / 256. alpha:1.0];
        statusStr = @"已读";
    }
    status.text = statusStr;
	/*
     UILabel* label = (UILabel *) [msgCell viewWithTag:100];
     //NSLog(@"the description:%@", data);
     label.text = [data objectForKey:@"description"];
     
     UILabel* namelabel = (UILabel *) [msgCell viewWithTag:101];
     //namelabel.text = [NSString stringWithFormat:@"(%.3lf, %.3lf)", [lng doubleValue] , [lat doubleValue]];
     namelabel.text = @"";
     */
	return msgCell;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] >= [bookList count]) {
        return 60;
    }
    return 90;
}

-(void) loadMoreResult {
    @autoreleasepool {
        
    
    if (mode == 1) {
        NSString* query = [type substringFromIndex:4];
        NSString * encodedString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                                NULL,
                                                                                                (CFStringRef)query,
                                                                                                NULL,
                                                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                kCFStringEncodingUTF8 );
        
        NSString* urlstr = [NSString
                            stringWithFormat:
                            @"https://api.douban.com/v2/book/search?q=%@&start=%d&count=%d&apikey=00ae73c9110cc3b0020b5b5b33264b10",
                            encodedString, bookList.count,  perPageNum];
        NSURL* url = [NSURL URLWithString:urlstr];
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        moreSearchView = [[KKNetworkLoadingView alloc] initWithRequest:request delegate:self];
        [self.superview addSubview:moreSearchView];
    } else {
        NSArray* moreList = [[[kkFactory getInstance] getDBMgr] getBookListOfType:type from:bookList.count Num:perPageNum];
        if (moreList.count == perPageNum) {
            hasMore = YES;
        } else {
            hasMore = NO;
        }
        [bookList addObjectsFromArray:moreList];
        [self reloadData];
    }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] >= [bookList count]) {
        return [self loadMoreResult];
    }
    
    if (bookDelegate != nil && [bookDelegate respondsToSelector:@selector(onBookSelected:tableView:)]) {
        [bookDelegate onBookSelected:[bookList objectAtIndex:[indexPath row]] tableView:self];
    }
    /*
    KKBookInfoController* controller = [[KKBookInfoController alloc] initWithBookInfo:bookdata];
    [self.navigationController pushViewController:controller animated:YES];
     */
}

-(void) view:(KKNetworkLoadingView *) sender  onFailedLoading:(NSError *) error {
    
}

-(void) view:(KKNetworkLoadingView *) sender onFinishedLoading:(NSDictionary *) data {
    if ([data objectForKey:@"books"] == nil) {
        [self view:sender onFailedLoading:nil];
        return;
    }

    NSArray* books = [data objectForKey:@"books"];
    NSInteger totalNum = [(NSNumber *)[data objectForKey:@"total"] integerValue];
    NSMutableArray* cur = [[NSMutableArray alloc] init];
    for (int i = 0; i < books.count; i++) {
        [cur addObject:[kkBookEntity doubanJSON2Dict:[books objectAtIndex:i]]];
    }
    
    if (sender == searchView) {
        bookList = cur;
        if (bookList.count >= reqNum) {
            hasMore = YES;
        } else {
            hasMore = NO;
        }
        [self reloadData];
    } else if (sender == moreSearchView){
        NSArray* moreList = cur;
        //NSLog(@"more count[%d]", [moreList count]);
        [bookList addObjectsFromArray:moreList];
        if (bookList.count < totalNum) {
            hasMore = YES;
        } else {
            hasMore = NO;
        }
        
        [self reloadData];
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (bookDelegate != nil && [bookDelegate respondsToSelector:@selector(bookTableViewViewDidScroll:)]) {
        [bookDelegate bookTableViewViewDidScroll:self];
    }
}

@end
