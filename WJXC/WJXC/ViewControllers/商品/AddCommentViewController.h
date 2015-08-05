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


//必传
@property(nonatomic,strong)NSString *dingdanhao;//订单号
@property(nonatomic,strong)NSArray *theModelArray;//商品model数组 ：productModel modle里要有is_recommend是否评价的字段

-(void)updateView_pingjiaSuccessWithIndex:(NSInteger)index_row;

@end
