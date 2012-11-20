//
//  kkCategoryPickupSheet.h
//  cjg
//
//  Created by Wang Jinggang on 12-11-10.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class kkCategoryPickupSheet;

@protocol kkCategoryPickupSheetDelegate <NSObject>

@optional
-(void) onCategoryUpdate:(kkCategoryPickupSheet *) sheet name:(NSString*) name;

@end

@interface kkCategoryPickupSheet : UIActionSheet <UIActionSheetDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    NSArray* categories;
    id<kkCategoryPickupSheetDelegate> sheetDelegate;

}

@property(nonatomic, retain) id<kkCategoryPickupSheetDelegate> sheetDelegate;
-(id) initTogether:(NSString *) currentCategory;

@end
