//
//  OrderModel.h
//  WJXC
//
//  Created by lichaowei on 15/7/30.
//  Copyright (c) 2015年 lcw. All rights reserved.
//
/**
 *  我的订单 订单model
 */
#import "BaseModel.h"
#import "ProductModel.h"
@interface OrderModel : BaseModel

@property(nonatomic,retain)NSString *order_id;
@property(nonatomic,retain)NSString *order_no;
@property(nonatomic,retain)NSString *total_fee;
@property(nonatomic,retain)NSString *address;
@property(nonatomic,retain)NSArray *products;

-(instancetype)initWithDictionary:(NSDictionary *)dic;

@end
