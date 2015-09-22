//
//  OrderInfoViewController.h
//  WJXC
//
//  Created by lichaowei on 15/7/25.
//  Copyright (c) 2015年 lcw. All rights reserved.
//
/**
 *  订单详情
 */
#import "MyViewController.h"

@interface OrderInfoViewController : MyViewController

@property (nonatomic,retain)NSString *order_id;
@property (nonatomic,retain)id orderModel;//订单model用于更新延长收货按钮状态

@end
