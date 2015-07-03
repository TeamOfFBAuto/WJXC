//
//  NSDate+Additons.h
//  YiYiProject
//
//  Created by lichaowei on 15/5/18.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Additons)

/**
 *  时间间隔天数
 *
 *  @param toDate 比较的时间
 *
 *  @return 返回天数
 */
- (NSInteger)hoursBetweenDate:(NSDate *)toDate;

@end
