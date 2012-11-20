//
//  kkCategoryPickupSheet.m
//  cjg
//
//  Created by Wang Jinggang on 12-11-10.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import "kkCategoryPickupSheet.h"
#import "kkFactory.h"
#import "MobClick.h"

@implementation kkCategoryPickupSheet

@synthesize sheetDelegate;

-(id) initTogether:(NSString *) currentCategory {
    NSString* spaceTitle = @"\n\n\n\n\n\n\n\n\n\n\n\n";
    self = [super initWithTitle:spaceTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"确认", @"创建新类别", nil];
    if (self) {
        UIPickerView* pickerView = [[UIPickerView alloc] init];
        pickerView.tag = 101;
        pickerView.delegate = self;
        pickerView.dataSource = self;
        pickerView.showsSelectionIndicator = YES;
        categories = [[[kkFactory getInstance] getDBMgr] getAllCustomCategories];
        for (int i = 0; i < [categories count]; i++) {
            NSString* name = [categories objectAtIndex:i];
            if ([name isEqualToString:currentCategory]) {
                [pickerView selectRow:i inComponent:0 animated:NO];
                break;
            }
        }
        [self addSubview:pickerView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        /*
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
        [pickerView selectRow:row inComponent:0 animated:NO];*/
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [categories count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [categories objectAtIndex:row];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"请输入类别名称"
                                  message:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  otherButtonTitles:@"完成", nil];
        
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView show];
    } else if (buttonIndex == 0) {
        UIPickerView* pickerView = (UIPickerView *) [self viewWithTag:101];
        NSInteger row = [pickerView selectedRowInComponent:0];
        NSString* name = [categories objectAtIndex:row];
        if (sheetDelegate != nil && [sheetDelegate respondsToSelector:@selector(onCategoryUpdate:name:)]) {
            [sheetDelegate onCategoryUpdate:self name:name];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        // save it
        NSString* saveName = [[[kkFactory getInstance] getDBMgr] saveCustomCategory:textField.text];
        if (saveName == nil) {
            return;
        }
        UIPickerView* pickerView = (UIPickerView *) [self viewWithTag:101];
        // update the categories
        categories = [[[kkFactory getInstance] getDBMgr] getAllCustomCategories];
        [MobClick event:@"create_category"];
        [pickerView reloadAllComponents];
        
        if (sheetDelegate != nil && [sheetDelegate respondsToSelector:@selector(onCategoryUpdate:name:)]) {
            [sheetDelegate onCategoryUpdate:self name:saveName];
        }
    } 
}
@end
