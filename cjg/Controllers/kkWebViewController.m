//
//  kkWebViewController.m
//  cjg
//
//  Created by Wang Jinggang on 12-11-10.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import "kkWebViewController.h"

@interface kkWebViewController ()

@end

@implementation kkWebViewController

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
    NSURL* theurl = [NSURL URLWithString:url];
    NSURLRequest* request = [NSURLRequest requestWithURL:theurl];
    webView.delegate = self;
    [webView loadRequest:request];

    [aview startAnimating];
    
    self.navigationItem.title = @"网页浏览";
}

-(id) initWithURL:(NSString *) _url {
    self = [super init];
    if (self) {
        url = _url;
    }
    return self;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [aview stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
