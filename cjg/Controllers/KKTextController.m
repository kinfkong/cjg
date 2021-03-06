//
//  KKTextController.m
//  ishelf
//
//  Created by Wang Jinggang on 11-11-13.
//  Copyright 2011年 tencent. All rights reserved.
//

#import "KKTextController.h"


@implementation KKTextController

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

-(void) setTitle:(NSString *) title {
    self.navigationItem.title = title;
}
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    CGFloat offHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat height = self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height - offHeight;
    //[imageView release];
    textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
    textView.textColor = [UIColor blackColor];
    //textView.text = @"I am texting";
    textView.editable = NO;
    textView.font = [UIFont systemFontOfSize:15];
    textView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:textView];
    //[textView release];
}

-(void) setText:(NSString *) text {
    if (text == nil || [text isEqualToString:@""]) {
        text = @"暂无";
    }
    textView.text = text;
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

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

@end
