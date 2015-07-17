//
//  ProductCommentModel.h
//  WJXC
//
//  Created by gaomeng on 15/7/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//


//商品评论model

#import "BaseModel.h"

@interface ProductCommentModel : BaseModel



@property(nonatomic,strong)NSString *comment_id;
@property(nonatomic,strong)NSString *product_id;
@property(nonatomic,strong)NSString *uid;
@property(nonatomic,strong)NSString *content;
@property(nonatomic,strong)NSString *add_time;
@property(nonatomic,strong)NSString *star_level;
@property(nonatomic,strong)NSString *username;
@property(nonatomic,strong)NSString *avatar;
@property(nonatomic,strong)NSArray *comment_pic;
@property(nonatomic,strong)NSArray *comment_reply;

@end
