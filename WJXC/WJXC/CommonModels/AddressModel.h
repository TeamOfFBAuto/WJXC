//
//  AddressModel.h
//  WJXC
//
//  Created by lichaowei on 15/7/15.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "BaseModel.h"

@interface AddressModel : BaseModel

@property(nonatomic,retain)NSString *address_id;
@property(nonatomic,retain)NSString *uid;
@property(nonatomic,retain)NSString *pro_id;//省份id
@property(nonatomic,retain)NSString *city_id;//城市id
@property(nonatomic,retain)NSString *street;//所属街道地址
@property(nonatomic,retain)NSString *default_address;//是否是默认地址
@property(nonatomic,retain)NSString *receiver_username;//收货人
@property(nonatomic,retain)NSString *mobile;//手机号
@property(nonatomic,retain)NSString *phone;//电话
@property(nonatomic,retain)NSString *zip_code;//邮政编码
@property(nonatomic,retain)NSString *address;//详细地址如：北京市东城区东华门街道

@property(nonatomic,retain)NSString *fee;//邮费

@end
