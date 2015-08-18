//
//  adverModel.h
//  WJXC
//
//  Created by gaomeng on 15/7/28.
//  Copyright (c) 2015年 lcw. All rights reserved.
//


//首页轮播图model

#import "BaseModel.h"

@interface adverModel : BaseModel

@property(nonatomic,strong)NSString *adver_id;
@property(nonatomic,strong)NSString *type;
@property(nonatomic,strong)NSString *title;
@property(nonatomic,strong)NSString *status;
@property(nonatomic,strong)NSString *add_time;
@property(nonatomic,strong)NSString *relative_id;//活动id
@property(nonatomic,strong)NSString *cover_pic;
@property(nonatomic,strong)NSString *cover_picsize;
@property(nonatomic,strong)NSString *display_order;
@property(nonatomic,strong)NSString *cover_width;
@property(nonatomic,strong)NSString *cover_height;
@property(nonatomic,strong)NSDictionary *relative_info;

@end
