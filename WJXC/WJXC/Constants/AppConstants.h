//
//  AppConstants.h
//  WJXC
//
//  Created by lichaowei on 15/6/25.
//  Copyright (c) 2015年 lcw. All rights reserved.
//
/**
 *  存放整个系统会用到的一些常量
 */

#ifndef WJXC_AppConstants_h
#define WJXC_AppConstants_h

///屏幕宽度
#define DEVICE_WIDTH  [UIScreen mainScreen].bounds.size.width
///屏幕高度
#define DEVICE_HEIGHT [UIScreen mainScreen].bounds.size.height

//系统7.0之后
#define IOS7_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )

#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone6PLUS ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)


/**
 *  导航栏背景图
 */
#define IOS7DAOHANGLANBEIJING_PUSH @"navigationBarBackground_1" //导航栏背景
#define IOS6DAOHANGLANBEIJING @"sliderBBSNavigationBarImage_ios6.png"

/**
 *  返回按钮
 */
#define BACK_DEFAULT_IMAGE [UIImage imageNamed:@"back"]

/**
 *  默认头像
 */

#define DEFAULT_HEADIMAGE [UIImage imageNamed:@"grzx150_150"] //默认头像
#define DEFAULT_BANNER_IMAGE [UIImage imageNamed:@"my_bg.png"] //默认banner

#define DEFAULT_YIJIAYI [UIImage imageNamed:@"default_yijiayi"] //默认衣加衣图标

#endif
