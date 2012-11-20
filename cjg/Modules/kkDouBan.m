//
//  kkDouBan.m
//  cjg
//
//  Created by Wang Jinggang on 12-10-27.
//  Copyright (c) 2012年 Wang Jinggang. All rights reserved.
//

#import "kkDouBan.h"
#import "SBJson.h"
#import "kkBookEntity.h"

@implementation kkDouBan

-(NSDictionary *) getBookInfo:(NSString*) isbn {
    NSString* urlstr = [NSString
                     stringWithFormat:
                     @"http://api.douban.com/v2/book/isbn/%@?apikey=00ae73c9110cc3b0020b5b5b33264b10",
                     isbn];
    NSURL* url = [NSURL URLWithString:urlstr];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (data == nil) {
        return nil;
    }
    
    return [kkBookEntity doubanJSON2Dict:[data JSONValue]];
}

-(NSArray *) searchBooks:(NSString *) query From:(NSInteger) from Num:(NSInteger) num{
    
    NSString * encodedString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
																				   NULL,
																				   (CFStringRef)query,
																				   NULL,
																				   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																				   kCFStringEncodingUTF8 );
    
    NSString* urlstr = [NSString
                        stringWithFormat:
                        @"https://api.douban.com/v2/book/search?q=%@&start=%d&count=%d&apikey=00ae73c9110cc3b0020b5b5b33264b10",
                            encodedString, from, num];
    NSURL* url = [NSURL URLWithString:urlstr];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (data == nil) {
        return nil;
    }
    NSDictionary* dict = [data JSONValue];
    NSArray* books = [dict objectForKey:@"books"];
    if (books == nil) {
        return nil;
    }
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for (int i = 0; i < [books count]; i++) {
        [result addObject:[kkBookEntity doubanJSON2Dict:[books objectAtIndex:i]]];
    }
    return result;
}
@end
