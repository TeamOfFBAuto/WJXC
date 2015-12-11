//
//  PayActionViewController.h
//  WJXC
//
//  Created by lichaowei on 15/7/22.
//  Copyright (c) 2015年 lcw. All rights reserved.
//
/**
 *  支付页面
 */
#import "MyViewController.h"

@interface PayActionViewController : MyViewController

@property(nonatomic,retain)NSString *orderId;//订单号 实际可用
@property(nonatomic,retain)NSString *orderNum;//展示用
@property(nonatomic,assign)float sumPrice;//总价格

@property(nonatomic,assign)int payStyle;//1 支付宝 2 为微信
@property(nonatomic,retain)UIViewController *lastVc;//上一个页面

@end
