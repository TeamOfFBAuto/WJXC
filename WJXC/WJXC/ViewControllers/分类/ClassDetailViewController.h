//
//  ClassDetailViewController.h
//  WJXC
//
//  Created by gaomeng on 15/7/24.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassDetailViewController : MyViewController


@property(nonatomic,strong)NSString *category_p_id;//一级分类
@property(nonatomic,strong)NSString *category_id;//二级分类


@property(nonatomic,strong)UIButton *leftBtn;

@end
