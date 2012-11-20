//
//  kkWebViewController.h
//  cjg
//
//  Created by Wang Jinggang on 12-11-10.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface kkWebViewController : UIViewController <UIWebViewDelegate> {
    IBOutlet UIWebView* webView;
    IBOutlet UIActivityIndicatorView* aview;
    NSString* url;
}

-(id) initWithURL:(NSString *) url;
@end
