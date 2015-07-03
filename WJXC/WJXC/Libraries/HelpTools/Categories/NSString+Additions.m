//
//  NSString+Addtions.m
//  YiYiProject
//
//  Created by lichaowei on 15/6/11.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Addtions)

/**
 *  去掉末尾 .0
 *
 *  @return
 */
- (NSString *)stringByRemoveTrailZero
{
//    if ([self hasSuffix:@".0"] || [self hasSuffix:@".00"]) {
//        
//        NSMutableString *temp = [NSMutableString stringWithString:self];
//        [temp replaceOccurrencesOfString:@".0" withString:@"" options:0 range:NSMakeRange(0, temp.length)];
//        [temp replaceOccurrencesOfString:@".00" withString:@"" options:0 range:NSMakeRange(0, temp.length)];
//
//        return temp;
//    }
    
    
    if ([self hasSuffix:@".00"]) {
        NSMutableString *temp = [NSMutableString stringWithString:self];
        [temp replaceOccurrencesOfString:@".00" withString:@"" options:0 range:NSMakeRange(0, temp.length)];
        return temp;
    }else if ([self hasSuffix:@".0"]){
        NSMutableString *temp = [NSMutableString stringWithString:self];
        [temp replaceOccurrencesOfString:@".0" withString:@"" options:0 range:NSMakeRange(0, temp.length)];
        return temp;
    }
    
    
    return self;
}

@end
