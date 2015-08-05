//
//  AddCommentViewController.h
//  WJXC
//
//  Created by gaomeng on 15/8/4.
//  Copyright (c) 2015年 lcw. All rights reserved.
//



//评价晒单

#import "MyViewController.h"
#import "ProductModel.h"

@interface AddCommentViewController : MyViewController


@property(nonatomic,strong)NSString *dingdanhao;//订单号
@property(nonatomic,strong)NSArray *theModelArray;//商品model数组 ：productModel 

-(void)updateView_pingjiaSuccessWithIndex:(NSInteger)index_row;

@end
