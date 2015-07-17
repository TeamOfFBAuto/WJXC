//
//  AddAddressController.h
//  WJXC
//
//  Created by lichaowei on 15/7/14.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

/**
 *  添加或者编辑地址
 */

#import "MyViewController.h"
#import "AddressModel.h"

@interface AddAddressController : MyViewController

@property(nonatomic,assign)BOOL isEditAddress;//是否是编辑地址
@property(nonatomic,retain)AddressModel *addressModel;//地址model

@end
