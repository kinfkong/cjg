//
//  KKBookInfoController.h
//  ishelf
//
//  Created by Wang Jinggang on 11-9-5.
//  Copyright 2011年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKNetworkLoadingView.h"
#import "GradientButton.h"
#import <AVFoundation/AVFoundation.h>
#import "kkCategoryPickupSheet.h"


@interface KKBookInfoController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource, KKNetworkLoadingViewDelegate, AVAudioSessionDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, kkCategoryPickupSheetDelegate> {
    NSMutableDictionary* info;
    UITableView* tableView;
    NSString* bookId;
    NSString* isbn;
    UILabel* tip;
    //GradientButton* talkLabel;
    AVAudioRecorder *soundRecorder;
    AVAudioPlayer* player;
    BOOL playing;
    BOOL recording;
    int beginTime;
    NSString* soundId;
    
    UIImageView* playButton;
    NSTimer* playTimer;
    UIProgressView* progressBar;
    
    
    UITableViewCell* titleCell;
    UITableViewCell* bookInfoCell;
    UITableViewCell* buttonCell;
    UITableViewCell* talkCell;
    UITableViewCell* talkCellWithComment;
    UITableViewCell* categoryCell;
    NSString* currentPlayingFile;
    kkCategoryPickupSheet* Categorysheet;
    
}

@property (nonatomic, retain) NSMutableDictionary* info;
@property (nonatomic, retain) NSString* bookId;
@property (nonatomic, retain) NSString* isbn;

-(id) initWithBookInfo:(NSDictionary *) _info;

-(id) initWithBookId:(NSString *) _bookId;

-(id) initWithBookISBN:(NSString *) _isbn;

@end
