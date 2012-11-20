//
//  kkAudioRecordController.m
//  cjg
//
//  Created by Wang Jinggang on 12-11-10.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import "kkAudioRecordController.h"
#import "kkAppDelegate.h"

@interface kkAudioRecordController ()

@end

@implementation kkAudioRecordController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithComments:(NSArray*) _comments {
    self = [super init];
    if (self) {
        comments = [_comments sortedArrayUsingComparator:^(id obj1, id obj2) {
            NSDate* date1 = [obj1 objectForKey:@"create_time"];
            NSDate* date2 = [obj2 objectForKey:@"create_time"];
            return [date2 compare:date1];
        }];

        
        //comments = _comments;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    tableView.delegate = self;
    tableView.dataSource = self;
    
    basicCell = [[[NSBundle mainBundle]loadNibNamed:@"AudioRecordCell" owner:self options:nil] objectAtIndex:0];
    playingRow = -1;
    player = nil;
    self.navigationItem.title = @"语音评论";
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return basicCell.frame.size.height;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [comments count];
}
-(UITableViewCell *) tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"audiocell"];
    if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"AudioRecordCell" owner:self options:nil] objectAtIndex:0];
        UIImageView* imageView = (UIImageView *) [cell viewWithTag:1];
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPlay:)];
        [imageView addGestureRecognizer:tap];
    }
    UILabel* timeLabel = (UILabel *) [cell viewWithTag:3];
    NSDictionary* recordInfo = [comments objectAtIndex:[indexPath row]];
    NSDate* theTime = [recordInfo objectForKey:@"create_time"];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    timeLabel.text = [dateFormatter stringFromDate:theTime];
    UIImageView* imageView = (UIImageView *) [cell viewWithTag:1];
    UIProgressView* progressBar = (UIProgressView *) [cell viewWithTag:2];
    progressBar.progress = 0;
    imageView.image = [UIImage imageNamed:@"play1.png"];
    
    if ([indexPath row] == playingRow && player != nil) {
        [progressBar setProgress:player.currentTime / player.duration];
        if ([player isPlaying]) {
            imageView.image = [UIImage imageNamed:@"pause1.png"];
        }
    }
    //NSLog(@"create cell:%@", cell);
    return cell;
}

-(void) tapPlay:(id) sender {
    UIImageView* imageView = (UIImageView *) [(UIGestureRecognizer *)sender view];
    UITableViewCell* cell = (UITableViewCell *) [[imageView superview] superview];
    if (cell == nil) {
        return;
    }
   
    NSIndexPath* path = [tableView indexPathForCell:cell];
    if (path == nil) {
        //NSLog(@"path is nil");
        return;
    }
    NSInteger currentRow = [path row];
    if (currentRow == playingRow) {
        if ([player isPlaying]) {
            [player pause];
            imageView.image = [UIImage imageNamed:@"play1.png"];
        } else {
            [player play];
            imageView.image = [UIImage imageNamed:@"pause1.png"];
        }
    } else {
        [player stop];
        if (playingRow >= 0) {
            NSIndexPath* oldPath =[NSIndexPath indexPathForRow:playingRow inSection:0];
            UITableViewCell* oldCell = [tableView cellForRowAtIndexPath:oldPath];
            if (oldCell != nil) {
                UIImageView* oldImage = (UIImageView *) [oldCell viewWithTag:1];
                oldImage.image = [UIImage imageNamed:@"play1.png"];
                UIProgressView* progressBar = (UIProgressView *) [oldCell viewWithTag:2];
                progressBar.progress = 0;
            }
        }
        
        kkAppDelegate* currentDelegate = (kkAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString* file = [[comments objectAtIndex:currentRow] objectForKey:@"file"];
        NSURL *newURL = [NSURL fileURLWithPath:[[currentDelegate applicationDocumentsDirectory] stringByAppendingPathComponent:file]];
        
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:newURL error:nil];
        player.delegate = self;
        
        [player play];
        imageView.image = [UIImage imageNamed:@"pause1.png"];
        
        playingRow = currentRow;
        
        [playTimer invalidate];
        playTimer = nil;
        playTimer = [NSTimer scheduledTimerWithTimeInterval:0.10 target:self selector:@selector(updateProgressBar:) userInfo:nil repeats:YES];
        
    }
}

-(void) updateProgressBar:(id) sender {
    if (playingRow < 0) {
        return;
    }
    NSIndexPath* path =[NSIndexPath indexPathForRow:playingRow inSection:0];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:path];
    if (cell != nil && player != nil) {
        UIProgressView* progressBar = (UIProgressView *) [cell viewWithTag:2];
        progressBar.progress = [player currentTime] / [player duration];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (playingRow < 0) {
        return;
    }
    
    NSIndexPath* path =[NSIndexPath indexPathForRow:playingRow inSection:0];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:path];
    UIProgressView* progressBar = (UIProgressView *) [cell viewWithTag:2];
    progressBar.progress = 0;
    UIImageView* image = (UIImageView *) [cell viewWithTag:1];
    image.image = [UIImage imageNamed:@"play1.png"];
    
    playingRow = -1;
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)_player withOptions:(NSUInteger)flags {
    return [self audioPlayerDidFinishPlaying:_player successfully:NO];
}

-(void) viewDidAppear:(BOOL)animated {
    [player play];
}

-(void) viewDidDisappear:(BOOL)animated {
    [player pause];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
