//
//  TuiKuanViewController.h
//  YiYiProject
//
//  Created by lichaowei on 15/9/14.
//  Copyright (c) 2015年 lcw. All rights reserved.
//
/**
 *  退款说明
 */
#import "MyViewController.h"
@interface TuiKuanViewController : MyViewController

@property(nonatomic,assign)CGFloat tuiKuanPrice;
@property(nonatomic,retain)NSString *orderId;//订单id
@property(nonatomic,retain)UIViewController *lastVc;

@end
