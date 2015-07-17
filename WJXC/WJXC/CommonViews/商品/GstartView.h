//
//  GstartView.h
//  CustomNewProject
//
//  Created by gaomeng on 14/12/8.
//  Copyright (c) 2014年 FBLIFE. All rights reserved.
//


//商家星级view

#import <UIKit/UIKit.h>

@interface GstartView : UIView

///星星的个数
@property(nonatomic,assign)float startNum;

///最多几个星星
@property(nonatomic,assign)int maxStartNum;

//初始化方法
-(GstartView*)initWithStartNum:(int)num Frame:(CGRect)theFrame;


//填充数据
-(void)updateStartNum;

@end
