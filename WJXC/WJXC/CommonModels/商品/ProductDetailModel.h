//
//  ProductDetailModel.h
//  WJXC
//
//  Created by gaomeng on 15/7/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//


//商品详细model

#import "BaseModel.h"

@interface ProductDetailModel : BaseModel


@property(nonatomic,strong)NSString *product_id;
@property(nonatomic,strong)NSString *product_name;
@property(nonatomic,strong)NSString *original_price;
@property(nonatomic,strong)NSString *current_price;
@property(nonatomic,strong)NSString *comment_num;
@property(nonatomic,strong)NSString *good_comment_num;
@property(nonatomic,strong)NSString *normal_comment_num;
@property(nonatomic,strong)NSString *bad_comment_num;
@property(nonatomic,strong)NSArray *product_desc;
@property(nonatomic,strong)NSArray *image;
@property(nonatomic,strong)NSString *add_time;
@property(nonatomic,strong)NSString *discount;
@property(nonatomic,strong)NSString *cover_pic;
@property(nonatomic,strong)NSString *is_favor;
@property(nonatomic,strong)NSString *merchant_phone;//联系电话

@property(nonatomic,retain)NSDictionary *seckill_info;//秒杀信息 end_time
@property(nonatomic,retain)NSString *is_seckill;//是否是秒杀


@end
