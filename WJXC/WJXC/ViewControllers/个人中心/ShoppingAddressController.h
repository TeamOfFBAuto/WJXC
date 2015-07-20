//
//  ShoppingAddressController.h
//  WJXC
//
//  Created by lichaowei on 15/7/7.
//  Copyright (c) 2015年 lcw. All rights reserved.
//
/**
 *  收货地址
 */
#import "MyViewController.h"

typedef void(^SelectAddressBlock)(id address);

@interface ShoppingAddressController : MyViewController

@property(nonatomic,assign)BOOL isSelectAddress;//是否是来选择收货地址
@property(nonatomic,copy)SelectAddressBlock selectAddressBlock;//选择地址
@property(nonatomic,retain)NSString *selectAddressId;//选中的地址id


@end
