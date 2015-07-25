//
//  PayResultViewController.h
//  WJXC
//
//  Created by lichaowei on 15/7/24.
//  Copyright (c) 2015年 lcw. All rights reserved.
//
/**
 *  支付结果处理页面
 */
#import "MyViewController.h"

@interface PayResultViewController : MyViewController

@property(nonatomic,retain)NSString *orderId;
@property(nonatomic,retain)NSString *orderNum;
@property(nonatomic,assign)CGFloat sumPrice;
@property(nonatomic,assign)BOOL isPaySuccess;//是否支付成

@end
