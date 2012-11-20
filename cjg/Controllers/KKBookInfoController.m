//
//  KKBookInfoController.m
//  ishelf
//
//  Created by Wang Jinggang on 11-9-5.
//  Copyright 2011年 tencent. All rights reserved.
//

#import "KKBookInfoController.h"
#import "UIImageView+ASYNC.h"
#import "KKTextController.h"
#import "kkFactory.h"
#import "kkAppDelegate.h"
#import "kkAudioRecordController.h"
#import <AVFoundation/AVFoundation.h>
#import "kkWebViewController.h"
#import "kkCategoryPickupSheet.h"
#import "MobClick.h"

@implementation KKBookInfoController


@synthesize info;
@synthesize bookId;
@synthesize isbn;

-(id) initWithBookInfo:(NSDictionary *) _info {
    self = [super init];
    if (self) {
        self.info = [[NSMutableDictionary alloc] initWithDictionary:_info];
    }
    return self;
}

-(id) initWithBookId:(NSString *) _bookId {
    self = [super init];
    if (self) {
        //self.info = _info;
        self.info = nil;
        self.bookId = _bookId;
        self.isbn = nil;
    }
    return self;
}

-(id) initWithBookISBN:(NSString *) _isbn {
    self = [super init];
    if (self) {
        //self.info = _info;
        self.info = nil;
        self.isbn = _isbn;
        self.bookId = nil;
    }
    return self;
}

-(void) viewDidAppear:(BOOL)animated {
    //self.navigationController.navigationBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [tableView reloadData];
}

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


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    [super loadView];
    
    self.navigationItem.title = @"书籍信息";
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview:tableView];
    //[tableView release];

    
    tip = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    // #FFF68F
    tip.backgroundColor = [UIColor colorWithRed:1 green:246./255. blue:143./255. alpha:1];
    tip.alpha = 1;
    tip.textColor = [UIColor blackColor];
    tip.text = @"正在录音...";
    tip.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tip];
    tip.hidden = YES;
    
    
    // load the cells
    titleCell = [[[NSBundle mainBundle]loadNibNamed:@"BookTitleCell" owner:self options:nil] objectAtIndex:0];
    categoryCell = [[[NSBundle mainBundle]loadNibNamed:@"CategoryView" owner:self options:nil] objectAtIndex:0];
    
    bookInfoCell = [[[NSBundle mainBundle]loadNibNamed:@"BookDetailCell" owner:self options:nil] objectAtIndex:0];
    buttonCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    UIButton* button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button1.tag = 1;
    [buttonCell addSubview:button1];
    button1.frame = CGRectMake(30, 7, 120, 30);
    
    UIButton* button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button2.tag = 2;
    [buttonCell addSubview:button2];
    button2.frame = CGRectMake(290 - 120, 7, 120, 30);
    
    talkCell = [[[NSBundle mainBundle]loadNibNamed:@"BookTalkCell" owner:self options:nil] objectAtIndex:0];
    //talkCell.backgroundColor = [UIColor clearColor];
    GradientButton* talkButton = (GradientButton*) [talkCell viewWithTag:1];
    [talkButton useWhiteStyle];
    
    [talkButton addTarget:self action:@selector(beginTalk:) forControlEvents:UIControlEventTouchDown];
    [talkButton addTarget:self action:@selector(endTalk:) forControlEvents:UIControlEventTouchUpInside];
    [talkButton addTarget:self action:@selector(endTalk:) forControlEvents:UIControlEventTouchUpOutside];
    
    talkCellWithComment = [[[NSBundle mainBundle]loadNibNamed:@"BookTalkWithComment" owner:self options:nil] objectAtIndex:0];
    //talkCellWithComment.backgroundColor = [UIColor clearColor];
    GradientButton* talkButton2 = (GradientButton*) [talkCellWithComment viewWithTag:1];
    [talkButton2 useWhiteStyle];
    
    [talkButton2 addTarget:self action:@selector(beginTalk:) forControlEvents:UIControlEventTouchDown];
    [talkButton2 addTarget:self action:@selector(endTalk:) forControlEvents:UIControlEventTouchUpInside];
    [talkButton2 addTarget:self action:@selector(endTalk:) forControlEvents:UIControlEventTouchUpOutside];
    
    progressBar = (UIProgressView *) [talkCellWithComment viewWithTag:2];
    playButton = (UIImageView *) [talkCellWithComment viewWithTag:3];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPlay:)];
    [playButton addGestureRecognizer:tap];
    
    UIImageView* badge = (UIImageView*) [talkCellWithComment viewWithTag:4];
    UITapGestureRecognizer* tapBadge = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBadge:)];
    [badge addGestureRecognizer:tapBadge];
    currentPlayingFile = nil;
    // [tableView reloadData];
    
    Categorysheet = [[kkCategoryPickupSheet alloc] initTogether:[info objectForKey:@"category"]];
    Categorysheet.sheetDelegate = self;
    
}

-(void) tapBadge:(id) sender {
    kkAudioRecordController* controller = [[kkAudioRecordController alloc] initWithComments:[info objectForKey:@"comments"]];
    [self.navigationController pushViewController:controller animated:YES];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

-(void) viewDidDisappear:(BOOL)animated {
    currentPlayingFile = nil;
    [player stop];
    player = nil;
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath row] == 0 && [indexPath section] == 0) {
        return 45;
    } else if ([indexPath row] == 1 && [indexPath section] == 0) {
        return 130;
    } else if ([indexPath row] == 2 && [indexPath section] == 0) {
        return 45;
    } else if ([indexPath row] == 3 && [indexPath section] == 0) {
        return 45;
    }
    
    NSDictionary* last_comment = [info objectForKey:@"latest_comment"];
    if (last_comment != nil && [indexPath section] == 1 && [indexPath row] == 0) {
        return 126;
    }
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    } else if (section == 1) {
        return 1;
    } else if (section == 2) {
        return 3;
    } 
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([indexPath row] == 0 && [indexPath section] == 0) {
        [(UILabel *) [titleCell viewWithTag:1] setText:[self.info objectForKey:@"title"]];
        return titleCell;
    } else if ([indexPath row] == 1 && [indexPath section] == 0) {
        UIImageView* imageView = (UIImageView *) [bookInfoCell viewWithTag:1];
        UILabel* authorLabel = (UILabel *) [bookInfoCell viewWithTag:2];
        UILabel* pubLabel = (UILabel *) [bookInfoCell viewWithTag:3];
        UILabel* pubdateLabel = (UILabel *) [bookInfoCell viewWithTag:4];
        UILabel* priceLabel = (UILabel *) [bookInfoCell viewWithTag:5];
        UILabel* isbnLabel = (UILabel *) [bookInfoCell viewWithTag:6];
        UILabel* rateLabel = (UILabel *) [bookInfoCell viewWithTag:7];
        
		NSString* url = [self.info objectForKey:@"image"];
        if (url == nil || [url isEqualToString:@""]) {
            imageView.image = [UIImage imageNamed:@"noimage.png"];
        } else {
             NSMutableDictionary* imageInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1", @"id", indexPath, @"indexPath",nil];
            
            [imageView loadImageWithURL:url tmpImage:[UIImage imageNamed:@"noimage.png"] cache:YES delegate:nil withObject:imageInfo];
        }
        
        authorLabel.text = [NSString stringWithFormat:@"作者: %@", [self.info objectForKey:@"author"]];
        
        pubLabel.text = [NSString stringWithFormat:@"出版社: %@", [self.info objectForKey:@"publisher"] == nil ? @"无" : [self.info objectForKey:@"publisher"]];
        
        pubdateLabel.text = [NSString stringWithFormat:@"出版日期: %@", [self.info objectForKey:@"pubdate"] == nil ? @"无" : [self.info objectForKey:@"pubdate"]];
        
        priceLabel.text = [NSString stringWithFormat:@"定价: %@", [self.info objectForKey:@"price"]];
        
        isbnLabel.text = [NSString stringWithFormat:@"ISBN: %@", [self.info objectForKey:@"isbn"]];
        
        rateLabel.text = [NSString stringWithFormat:@"评分: %.1lf分", [self.info objectForKey:@"rating"] == nil ? 0 : [((NSNumber *)[self.info objectForKey:@"rating"]) doubleValue]];
        
        
        return bookInfoCell;
    } else if ([indexPath row] == 2 && [indexPath section] == 0) {
        UIButton* button1 = (UIButton *)[buttonCell viewWithTag:1];
        UIButton* button2 = (UIButton *)[buttonCell viewWithTag:2];
        NSString* status = [self.info objectForKey:@"status"];
        if (status == nil || [status isEqualToString:@"none"]) {
            [button1 setTitle:@"加入藏经阁" forState:UIControlStateNormal];
            [button2 setTitle:@"加入购书单" forState:UIControlStateNormal];
            [button1 addTarget:self action:@selector(addToShelf:) forControlEvents:UIControlEventTouchUpInside];
            [button2 addTarget:self action:@selector(addToBuylist:) forControlEvents:UIControlEventTouchUpInside];
            
        } else if ([status isEqualToString:@"buylist"]) {
            [button1 setTitle:@"加入藏经阁" forState:UIControlStateNormal];
            [button2 setTitle:@"从购书单中删除" forState:UIControlStateNormal];
            [button1 addTarget:self action:@selector(addToShelf:) forControlEvents:UIControlEventTouchUpInside];
            [button2 addTarget:self action:@selector(removeFromBuylist:) forControlEvents:UIControlEventTouchUpInside];
        } else if ([status isEqualToString:@"unread"]) {
            [button1 setTitle:@"状态:未读" forState:UIControlStateNormal];
            [button2 setTitle:@"从藏经阁中删除" forState:UIControlStateNormal];
            [button1 addTarget:self action:@selector(showPickUpView:) forControlEvents:UIControlEventTouchUpInside];
             [button2 addTarget:self action:@selector(removeFromShelf:) forControlEvents:UIControlEventTouchUpInside];
        } else if ([status isEqualToString:@"reading"]) {
            [button1 setTitle:@"状态:在读" forState:UIControlStateNormal];
            [button2 setTitle:@"从藏经阁中删除" forState:UIControlStateNormal];
            [button1 addTarget:self action:@selector(showPickUpView:) forControlEvents:UIControlEventTouchUpInside];
            [button2 addTarget:self action:@selector(removeFromShelf:) forControlEvents:UIControlEventTouchUpInside];
        } else if ([status isEqualToString:@"read"]) {
            [button1 setTitle:@"状态:已读" forState:UIControlStateNormal];
            [button2 setTitle:@"从藏经阁中删除" forState:UIControlStateNormal];
            [button1 addTarget:self action:@selector(showPickUpView:) forControlEvents:UIControlEventTouchUpInside];
            [button2 addTarget:self action:@selector(removeFromShelf:) forControlEvents:UIControlEventTouchUpInside];
        }
        buttonCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return buttonCell;
    } else if ([indexPath section] == 2) {
        
        UITableViewCell* ccell = [_tableView dequeueReusableCellWithIdentifier:@"commoncell"];
        if (ccell == nil) {
            ccell = [[[NSBundle mainBundle]loadNibNamed:@"BookCommonCell" owner:self options:nil] objectAtIndex:0];
        }
        
        UILabel* title = (UILabel *) [ccell viewWithTag:1];
        if ([indexPath row] == 0) {
            [title setText:@"内容简介"];
        } else if ([indexPath row] == 1) {
            [title setText:@"作者简介"];
        } else if ([indexPath row] == 2) {
            [title setText:@"上豆瓣看看"];
        }
        ccell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return ccell;
        
    } else if ([indexPath row] == 0 && [indexPath section] == 1) {
        
        NSDictionary* latestComment = [info objectForKey:@"latest_comment"];
        if (latestComment == nil) {
            return talkCell;
        }
        
        UILabel* numLabel = (UILabel *) [talkCellWithComment viewWithTag:6];
        int num = [[info objectForKey:@"comments"] count];
        if (num > 9) {
            numLabel.text = @"9+";
        } else {
            numLabel.text = [NSString stringWithFormat:@"%d", num];
        }
        if ([[latestComment objectForKey:@"file"] isEqualToString:currentPlayingFile]) {
            // return directly
            return talkCellWithComment;
        }
        
        kkAppDelegate* currentDelegate = (kkAppDelegate *)[[UIApplication sharedApplication] delegate];
        currentPlayingFile = [latestComment objectForKey:@"file"];
        NSURL *newURL = [NSURL fileURLWithPath:[[currentDelegate applicationDocumentsDirectory] stringByAppendingPathComponent:currentPlayingFile]];
        
        player =
        [[AVAudioPlayer alloc] initWithContentsOfURL: newURL
                                               error: nil];
        //NSLog(@"the file:%@, duration:%.3lf", newURL.absoluteString, player.duration);
        player.delegate = self;
        progressBar.progress = 0;
        playButton.image = [UIImage imageNamed:@"play1.png"];
        return talkCellWithComment;
        
        
    }  else if ([indexPath row] == 3 && [indexPath section] == 0) {
        UIButton* talkButton = (UIButton *) [categoryCell viewWithTag:1];
        NSString* category = [info objectForKey:@"category"];
        if (category == nil) {
            category = @"默认分类";
        }
        
        [talkButton setTitle:[NSString stringWithFormat:@"类别:%@", category] forState:UIControlStateNormal];
        
        [talkButton addTarget:self action:@selector(showCategorySheet) forControlEvents:UIControlEventTouchUpInside];
        return categoryCell;
    }

    return cell;
}

-(void) showCategorySheet {
    [Categorysheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] == 0 && [indexPath section] == 2) {
        KKTextController* controller = [[KKTextController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        [controller setText:[self.info objectForKey:@"summary"]];
        [controller setTitle:@"内容简介"];
        //[controller release];
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if ([indexPath row] == 1 && [indexPath section] == 2 ) {
        KKTextController* controller = [[KKTextController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        [controller setText:[self.info objectForKey:@"author_info"]];
        [controller setTitle:@"作者介绍"];
        //[controller release];
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if ([indexPath row] == 2 && [indexPath section] == 2) {
        NSString* urlstr = [self.info objectForKey:@"detail_url"];
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlstr]];
        kkWebViewController* controller = [[kkWebViewController alloc] initWithURL:urlstr];
        [self.navigationController pushViewController:controller animated:YES];
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    } 
}

-(void) statusUpdate:(NSString *) status {
    kkDBMgr* mgr = [[kkFactory getInstance] getDBMgr];
    
    [mgr updateStatus:status forBookId:[self.info objectForKey:@"id"]];
    [self.info setObject:status forKey:@"status"];
    [tableView reloadData];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"bookStatusChanged" object:nil];
}

-(void) addToShelf:(id) sender {
    [MobClick event:@"addcjg"];
    [self statusUpdate:@"unread"];
}

-(void) addToBuylist:(id) sender {
    [self statusUpdate:@"buylist"];
}

-(void) removeFromBuylist:(id) sender {
    [self statusUpdate:@"none"];
}

-(void) removeFromShelf:(id) sender {
    [self statusUpdate:@"none"];
}

-(void) view:(KKNetworkLoadingView *) sender  onFailedLoading:(NSError *) error {
    //[readerView start];
    NSLog(@"failed ...");
}


-(void) view:(KKNetworkLoadingView *) sender onFinishedLoading:(NSDictionary *) data {
    //NSLog(@"the dict:%@", data);
    if (![[data objectForKey:@"errno"] isEqualToString:@"0"]) {
        [self view:sender onFailedLoading:nil];
        return;
    }
    NSDictionary* detail = [data objectForKey:@"detail"];
    if (detail == nil || [detail objectForKey:@"status"] == nil) {
        [self view:sender onFailedLoading:nil];
    }
        //NSLog(@"before the dict:%@", detail);    
    if (sender.tag == 3456) {
        //NSLog(@"the dict:%@", detail);
        UIView* mask = [tableView viewWithTag:909];
        [mask removeFromSuperview];
        self.info = [[NSMutableDictionary alloc] initWithDictionary:detail];
    } else {
        [self.info setObject:[detail objectForKey:@"status"] forKey:@"status"];
        
        
        
    }
    //NSLog(@"%@", [self.info objectForKey:@"status"]);
    [tableView reloadData];
    
}

-(void) showPickUpView:(id) sender {
    NSString* spaceTitle = @"\n\n\n\n\n\n\n\n\n\n\n\n";
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:spaceTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"确认", nil];
    //[actionSheet showInView:self.view];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
    
    UIPickerView* pickerView = [[UIPickerView alloc] init];
    pickerView.tag = 101;
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.showsSelectionIndicator = YES;
    [actionSheet addSubview:pickerView];
    
    NSInteger row = 0;
    NSString* status = [self.info objectForKey:@"status"];
    if ([status isEqualToString:@"unread"]) {
        row = 0;
    } else if ([status isEqualToString:@"read"]) {
        row = 2;
    } else if ([status isEqualToString:@"reading"]) {
        row = 1;
    }
    [pickerView selectRow:row inComponent:0 animated:NO];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 3;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (row == 0) {
        return @"未读";
    } else if (row == 1) {
        return @"在读";
    } else if (row == 2) {
        return @"已读";
    }
    return @"";
}


-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        return;
    }
    UIPickerView* pickerView = (UIPickerView *) [actionSheet viewWithTag:101];
    NSInteger row = [pickerView selectedRowInComponent:0];
    if (row == 0) {
        [self statusUpdate:@"unread"];
    } else if (row == 1) {
        [self statusUpdate:@"reading"];
    } else if (row == 2) {
        [self statusUpdate:@"read"];
    }
    //[actionSheet release];
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder {
    NSLog(@"here");
}
-(void) beginTalk:(id) sender {
    //NSLog(@"begin to talk...");
    
    if (player.isPlaying) {
        [player stop];
    }
    tip.hidden = NO;
    kkAppDelegate* currentDelegate = (kkAppDelegate *)[[UIApplication sharedApplication] delegate];

    srand(time(NULL));
    soundId = [NSString stringWithFormat:@"%@_%d.caf",
                         (NSString *)[info objectForKey:@"id"], rand()];
    NSURL *newURL = [NSURL fileURLWithPath:[[currentDelegate applicationDocumentsDirectory] stringByAppendingPathComponent:soundId]];
    
    recording = NO;
    
    NSDictionary *recordSettings =
    [[NSDictionary alloc] initWithObjectsAndKeys:
     [NSNumber numberWithFloat: 44100.0], AVSampleRateKey,
     [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
     [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
     [NSNumber numberWithInt: AVAudioQualityMax],
     AVEncoderAudioQualityKey,
     nil];
    //NSLog(@"before new");
    AVAudioRecorder *newRecorder =
    [[AVAudioRecorder alloc] initWithURL: newURL
                                settings: recordSettings
                                   error: nil];
    
    soundRecorder = newRecorder;
    soundRecorder.delegate = self;
    
    [soundRecorder prepareToRecord];
    
    [soundRecorder record];
    
    
    recording = YES;
    beginTime = time(NULL);
}



-(void) endTalk:(id) sender {
    if (!recording) {
        return;
    }
    
    //NSLog(@"end talk ...");
    tip.hidden = YES;
    if (time(NULL) - beginTime < 1) {
        [soundRecorder stop];
        [soundRecorder deleteRecording];
    } else {
        [MobClick event:@"recordcomment"];
        [soundRecorder stop];
        //NSLog(@"saving to :%@", soundRecorder.url.absoluteString);
        kkDBMgr* mgr = [[kkFactory getInstance] getDBMgr];
        [mgr addComment:soundId toBook:[info objectForKey:@"id"]];
        self.info = [NSMutableDictionary dictionaryWithDictionary:[mgr getBookByID:[info objectForKey:@"id"]]];
        [tableView reloadData];
        
    }
    recording = NO;
    soundRecorder = nil;
    
}

-(void) updateProgressBar:(id) sender {
    progressBar.progress = player.currentTime / player.duration;
}

-(void) tapPlay:(UITapGestureRecognizer *) gesture {
    //NSLog(@"here...");
    if (player.isPlaying) {
        [player pause];
        [playButton setImage:[UIImage imageNamed:@"play1"]];
    } else {
        [MobClick event:@"playcomment"];
        [player play];
        [playButton setImage:[UIImage imageNamed:@"pause1"]];
        [playTimer invalidate];
        playTimer = nil;
        playTimer = [NSTimer scheduledTimerWithTimeInterval:0.10 target:self selector:@selector(updateProgressBar:) userInfo:nil repeats:YES];
    }    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [playButton setImage:[UIImage imageNamed:@"play1"]];
    [playTimer invalidate];
    playTimer = nil;
    progressBar.progress = 0;
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    //[tableView reloadData];
    
    NSLog(@"record result:%d", flag);
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags {
    [playButton setImage:[UIImage imageNamed:@"play1"]];
    [playTimer invalidate];
    playTimer = nil;
    progressBar.progress = 0;
}

-(void) onCategoryUpdate:(kkCategoryPickupSheet *) sheet name:(NSString*) name {
    [[[kkFactory getInstance] getDBMgr] updateCategory:name forBookId:[info objectForKey:@"id"]];
    [info setObject:name forKey:@"category"];
    [tableView reloadData];
    [MobClick event:@"change_category"];
}

@end
