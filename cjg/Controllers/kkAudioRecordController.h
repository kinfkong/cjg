//
//  kkAudioRecordController.h
//  cjg
//
//  Created by Wang Jinggang on 12-11-10.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface kkAudioRecordController : UIViewController <UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate> {
    IBOutlet UITableView* tableView;
    NSArray* comments;
    UITableViewCell* basicCell;
    NSInteger playingRow;
    AVAudioPlayer* player;
    NSTimer* playTimer;
}


-(id) initWithComments:(NSArray*) comments;

@end
