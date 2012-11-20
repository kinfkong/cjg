//
//  KKZBarController.m
//  ishelf
//
//  Created by Wang Jinggang on 11-9-5.
//  Copyright 2011年 tencent. All rights reserved.
//

#import "KKZBarController.h"
#import "KKBookInfoController.h"
#import "kkBookEntity.h"
#import "kkFactory.h"
#import "MobClick.h"

@implementation KKZBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
-(void) loadView {
    [super loadView];
    //NSLog(@"the height:%.3lf", self.view.frame.size.height);
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.

-(void) viewDidLoad {
    [super viewDidLoad];

    CGFloat height = self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height - self.navigationController.navigationBar.frame.size.height;
    CGFloat camHeight = 200;
    
    self.navigationItem.title = @"扫描书籍条型码";
    
    ZBarImageScanner* scanner = [[ZBarImageScanner alloc] init];
    [scanner setSymbology: ZBAR_QRCODE
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    readerView = [[ZBarReaderView alloc] initWithImageScanner:scanner];
    readerView.readerDelegate = self;
    //NSLog(@"the height:%.3lf", self.view.frame.size.height);
    readerView.frame = CGRectMake(0, 0, self.view.frame.size.width, height);
    [readerView setZoom:1.0 animated:YES];
    readerView.tracksSymbols = NO;
    //[scanner release];
    //readerView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:readerView];

    CGFloat lineWidth = 260;
    UIView* redLine = [[UIView alloc] initWithFrame:CGRectMake((320 - lineWidth) / 2, height / 2, lineWidth, 1)];
    redLine.backgroundColor = [UIColor redColor];
    [self.view addSubview:redLine];
    //[redLine release];
    
    
    UIView* upperMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, (height - camHeight) / 2)];
    upperMask.backgroundColor = [UIColor blackColor];
    upperMask.alpha = 0.6;
    [self.view addSubview:upperMask];
    //[upperMask release];
    UIView* lowerMask = [[UIView alloc] initWithFrame:CGRectMake(0, (height - camHeight) / 2 + camHeight, self.view.frame.size.width, (height - camHeight) / 2)];
    lowerMask.backgroundColor = [UIColor blackColor];
    lowerMask.alpha = 0.6;
    [self.view addSubview:lowerMask];
    //[lowerMask release];
    

    UILabel* tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, (height - camHeight) / 2)];
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.text = @"与条形码间距10cm左右，避免反光和阴影";
    tipLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:tipLabel];
    [readerView start];
}
/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/
-(void) viewDidAppear:(BOOL)animated {
    [readerView start];
}

-(void) viewDidDisappear:(BOOL)animated {
    [readerView stop];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) readerView: (ZBarReaderView*) _readerView
     didReadSymbols: (ZBarSymbolSet*) symbols
          fromImage: (UIImage*) image {
    ZBarSymbol *symbol = nil;
    for (symbol in symbols) {
        break;
    }
    [readerView stop];
    NSString* isbn = symbol.data;
    //NSLog(@"isbn:%@", isbn);
    kkDBMgr* mgr = [[kkFactory getInstance] getDBMgr];
    NSDictionary* dict = [mgr getBookByISBN:isbn];
    if (dict != nil) {
        KKBookInfoController* controller = [[KKBookInfoController alloc] initWithBookInfo:dict];
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        NSString* urlstr = [NSString
                        stringWithFormat:
                        @"http://api.douban.com/v2/book/isbn/%@?apikey=00ae73c9110cc3b0020b5b5b33264b10",
                        isbn];
        NSURLRequest* urlrequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlstr]];
        KKNetworkLoadingView* loadingView = [[KKNetworkLoadingView alloc] initWithRequest:urlrequest delegate:self];
        [self.view addSubview:loadingView];
    }
	//[loadingView release];
    
}

-(void) view:(KKNetworkLoadingView *) sender onFinishedLoading:(NSDictionary *) data {
    if ([data objectForKey:@"id"] == nil) {
        [self view:sender onFailedLoading:nil];
        return;
    }
    [MobClick event:@"scanbook" label:@"succeeded"];
    NSDictionary* normalData = [kkBookEntity doubanJSON2Dict:data];
    kkDBMgr* mgr = [[kkFactory getInstance] getDBMgr];
    [mgr save:normalData];
    KKBookInfoController* controller = [[KKBookInfoController alloc] initWithBookInfo:normalData];
    [self.navigationController pushViewController:controller animated:YES];

}

-(void) view:(KKNetworkLoadingView *) sender  onFailedLoading:(NSError *) error {
    [MobClick event:@"scanbook" label:@"failed"];
    [readerView start];
}

@end
