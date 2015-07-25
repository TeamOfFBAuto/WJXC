//
//  ProductModel.h
//  WJXC
//
//  Created by lichaowei on 15/7/16.
//  Copyright (c) 2015年 lcw. All rights reserved.
//
/**
 *  商品model
 */
#import "BaseModel.h"

@interface ProductModel : BaseModel

@property (nonatomic,retain)NSString *product_id;
@property (nonatomic,retain)NSString *category_p_id;
@property (nonatomic,retain)NSString *category_id;
@property (nonatomic,retain)NSString *original_price;
@property (nonatomic,retain)NSString *current_price;
@property (nonatomic,retain)NSString *discount;
@property (nonatomic,retain)NSString *stock;
@property (nonatomic,retain)NSString *is_hot;
@property (nonatomic,retain)NSString *is_new;
@property (nonatomic,retain)NSString *is_seckill;
@property (nonatomic,retain)NSString *is_recommend;
@property (nonatomic,retain)NSString *status;
@property (nonatomic,retain)NSString *product_desc;
@property (nonatomic,retain)NSString *shelf_status;
@property (nonatomic,retain)NSString *up_shelf_time;
@property (nonatomic,retain)NSString *down_shelf_time;
@property (nonatomic,retain)NSString *edit_time;
@property (nonatomic,retain)NSString *view_num;
@property (nonatomic,retain)NSString *favor_num;
@property (nonatomic,retain)NSString *comment_num;
@property (nonatomic,retain)NSString *good_comment_num;
@property (nonatomic,retain)NSString *normal_comment_num;
@property (nonatomic,retain)NSString *bad_comment_num;
@property (nonatomic,retain)NSString *cover_pic;
@property (nonatomic,retain)NSString *cover_picsize;
@property (nonatomic,retain)NSString *cover_width;
@property (nonatomic,retain)NSString *cover_height;
@property (nonatomic,retain)NSString *star_level;

@property (nonatomic,retain)NSString *weight;//重量

//购物车相关
@property (nonatomic,retain)NSString *add_time;//购物车也用到
@property (nonatomic,retain)NSString *product_name;//购物车也用到

@property (nonatomic,retain)NSString *cart_pro_id;
@property (nonatomic,retain)NSString *uid;
@property (nonatomic,retain)NSString *product_num;

//额外添加

@property(nonatomic,assign)BOOL selected;//是否被选择

//收藏相关
@property(nonatomic,retain)NSString *favor_id;
@property(nonatomic,retain)NSString *product_pic;//产品图片
@property(nonatomic,retain)NSString *product_pic_width;//图片宽度
@property(nonatomic,retain)NSString *product_pic_height;


@end
