//
//  kkTagDisplayViewController.m
//  cjg
//
//  Created by Wang Jinggang on 12-11-3.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import "kkTagDisplayViewController.h"
#import "kkFactory.h"
#import "kkBookListBaseViewController.h"

@interface kkTagDisplayViewController ()

@end

@implementation kkTagDisplayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithType:(NSString *) _type {
    self = [super init];
    if (self) {
        type = _type;
    }
    return self;
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    /*
    NSMutableArray* test = [[NSMutableArray alloc] init];
    for (int i = 0; i < 1000; i++) {
        NSString* name = [NSString stringWithFormat:@"tag_%d", i];
        NSNumber* num = [NSNumber numberWithInt:i];
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:name, @"name", num, @"num", nil];
        [test addObject:dict];
    }*/
    if ([type isEqualToString:@"tag"]) {
        NSArray* tags = [[[kkFactory getInstance] getDBMgr] groupByTags];
        [self setSimpleDataArray:tags];
        self.navigationItem.title = @"标签";
    } else if ([type isEqualToString:@"author"]) {
        NSArray* tags = [[[kkFactory getInstance] getDBMgr] groupByAuthors];
        [self setSimpleDataArray:tags];
        self.navigationItem.title = @"作者";
    } else if ([type isEqualToString:@"category"]) {
        NSArray* categories = [[[kkFactory getInstance] getDBMgr] groupByCategories];
        [self setSimpleDataArray:categories];
        self.navigationItem.title = @"自定义类别";
    }
    
    tableView.dataSource = self;
    tableView.delegate = self;
}

-(void) setSimpleDataArray:(NSArray *) data {
    if ([data count] == 0) {
        return;
    }
    NSArray *sortedArray = [data sortedArrayUsingComparator:^(id obj1, id obj2) {
        int num1 = [[obj1 objectForKey:@"num"] intValue];
        int num2 = [[obj2 objectForKey:@"num"] intValue];
        if (num1 < num2) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if (num1 > num2) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    int num = [sortedArray count];
    if (num > 2000) {
        num = 2000;
    }
    dataSourceArray = [sortedArray subarrayWithRange:NSMakeRange(0, num)];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *) getStrByV1:(int) value1 V2:(int) value2  V3:(int) value3 dict:(NSDictionary*) obj index:(int) index {
    int num = [[obj objectForKey:@"num"] intValue];
    NSString* name = [obj objectForKey:@"name"];
    NSString* className = nil;
    if (index <= value1) {
        className = @"class1";
    } else if (index <= value2) {
        className = @"class2";
    } else if (index <= value3) {
        className = @"class3";
    } else {
        className = @"class4";
    }
    
    return [NSString stringWithFormat:@"<div class=\"%@\">%@ (%d)</div>", className, name, num];
}
-(void) setDataArray:(NSArray *) data {
    //NSLog(@"%@", data);
    if ([data count] == 0) {
        return;
    }
    NSArray *sortedArray = [data sortedArrayUsingComparator:^(id obj1, id obj2) {
        int num1 = [[obj1 objectForKey:@"num"] intValue];
        int num2 = [[obj2 objectForKey:@"num"] intValue];
        if (num1 < num2) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if (num1 > num2) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    int num = [sortedArray count];
    if (num > 2000) {
        num = 2000;
    }
    
    int index1 = num / 15;
    int index2 = num * ( 1 + 2) / 15;
    int index3 = num * (1 + 2 + 4) / 15;
    
    //int v1 = [[[sortedArray objectAtIndex:index1] objectForKey:@"num"] intValue];
    //int v2 = [[[sortedArray objectAtIndex:index2] objectForKey:@"num"] intValue];
    //int v3 = [[[sortedArray objectAtIndex:index3] objectForKey:@"num"] intValue];
    //NSLog(@"%d,%d,%d", v1, v2, v3);
    
    int* used = malloc(sizeof(int) * num);
    for (int i = 0; i < num; i++) {
        used[i] = 0;
    }
    NSMutableString* html = [[NSMutableString alloc] init];
    srand(0);
    for (int i = 0; i < num; i++) {
        @autoreleasepool {
           
        if (used[i]) {
            continue;
        }
        used[i] = 1;
        NSString* str = [self getStrByV1:index1 V2:index2 V3:index3 dict:[sortedArray objectAtIndex:i] index:i];
        [html appendString:str];
        if (i < num - 1) {
            int j = (rand() % (num - i - 1)) + i + 1;
            int k = (rand() % (num - i - 1)) + i + 1;
            if (used[j] == 0) {
                used[j] = 1;
                str = [self getStrByV1:index1 V2:index2 V3:index3 dict:[sortedArray objectAtIndex:j] index:j];
                [html appendString:str];
            }
            if (used[k] == 0 && j != k) {
                str = [self getStrByV1:index1 V2:index2 V3:index3 dict:[sortedArray objectAtIndex:k] index:k];
                [html appendString:str];
                used[k] = 1;
            }
        }
            
        }
    }
    free(used);
    /*
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"template" ofType:@"html"];
    NSString* htmlFile = [NSString stringWithContentsOfFile:htmlPath usedEncoding:nil error:nil];
    NSString* realHtml = [NSString stringWithFormat:htmlFile, html];*/
    //[webView loadHTMLString:realHtml baseURL:nil];
    //NSLog(@"the html:%@", realHtml);
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSourceArray count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* ccell = [_tableView dequeueReusableCellWithIdentifier:@"commoncell"];
    if (ccell == nil) {
        ccell = [[[NSBundle mainBundle]loadNibNamed:@"BookCommonCell" owner:self options:nil] objectAtIndex:0];
    }
    
    UILabel* title = (UILabel *) [ccell viewWithTag:1];
    title.textAlignment = NSTextAlignmentLeft;
    NSDictionary* info = [dataSourceArray objectAtIndex:[indexPath row]];
    title.text = [NSString stringWithFormat:@"%@(%@)", [info objectForKey:@"name"], [info objectForKey:@"num"]];
    return ccell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* data = [dataSourceArray objectAtIndex:[indexPath row]];
    NSString* name = [data objectForKey:@"name"];
    kkBookListBaseViewController* controller = [[kkBookListBaseViewController alloc] initWithType:[NSString stringWithFormat:@"%@:%@", type, name]];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
