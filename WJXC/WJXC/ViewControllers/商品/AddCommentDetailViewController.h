//
//  AddCommentDetailViewController.h
//  WJXC
//
//  Created by gaomeng on 15/8/4.
//  Copyright (c) 2015年 lcw. All rights reserved.
//


//添加商品评价详细界面

#import "MyViewController.h"
#import "ProductModel.h"

@interface AddCommentDetailViewController : MyViewController

//必传
@property(nonatomic,strong)ProductModel *theModel;//商品model
@property(nonatomic,strong)NSString *dingdanhao;//订单号

@end
