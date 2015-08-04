//
//  HuodongDetailModel.h
//  WJXC
//
//  Created by gaomeng on 15/8/5.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "BaseModel.h"

@interface HuodongDetailModel : BaseModel


@property(nonatomic,strong)NSArray *desc_format;
@property(nonatomic,strong)NSString *title;
@property(nonatomic,strong)NSString *desc;
@property(nonatomic,strong)NSString *cover_pic;
@property(nonatomic,strong)NSString *cover_picsize;
@property(nonatomic,strong)NSString *start_time;
@property(nonatomic,strong)NSString *end_time;
@property(nonatomic,strong)NSString *add_time;
@property(nonatomic,strong)NSString *cover_width;
@property(nonatomic,strong)NSString *cover_height;


@end
