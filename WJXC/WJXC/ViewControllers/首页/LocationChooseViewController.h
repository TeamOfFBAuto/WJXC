//
//  LocationChooseViewController.h
//  WJXC
//
//  Created by gaomeng on 15/7/19.
//  Copyright (c) 2015年 lcw. All rights reserved.
//



//首页点击右上角左侧进入的vc 选择城市

#import "MyViewController.h"
@class HomeViewController;

@interface LocationChooseViewController : MyViewController


@property(nonatomic,strong)UILabel *nowLocationLabel_c ;

@property(nonatomic,assign)HomeViewController *delegate;

@end
