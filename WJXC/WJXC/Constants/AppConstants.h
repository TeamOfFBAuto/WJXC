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


//错误提示信息 

#define ALERT_ERRO_PHONE @"请输入有效手机号"
#define ALERT_ERRO_PASSWORD @"密码格式有误,请输入6~15位英文字母或数字"
#define ALERT_ERRO_SECURITYCODE @"验证码格式有误,请输入6位数字"
#define ALERT_ERRO_FINDPWD @"两次密码不一致"

//保存用户信息设备信息相关

#define USER_INFO @"userInfo"//用户信息
#define USER_FACE @"userface"
#define USER_NAME @"username"
#define USER_PWD @"userPw"
#define USER_UID @"useruid"
#define USERINFO_MODEL @"USERINFO_MODEL" //存储在本地用户model

//两个登陆标识
#define LOGIN_SERVER_STATE @"user_login_state" //登陆衣加衣服务器 no是未登陆  yes是已登陆
#define LOGIN_RONGCLOUD_STATE @"rongcloudLoginState"//融云登陆状态

#define USER_AUTHOD @"user_authod"
#define USER_CHECKUSER @"checkfbuser"
#define USER_HEAD_IMAGEURL @"userHeadImageUrl"//头像url

#define USER_AUTHKEY_OHTER @"otherKey"//第三方key
#define USRR_AUTHKEY @"authkey"
#define USER_DEVICE_TOKEN @"DEVICE_TOKEN"

//int 转 string
#define NSStringFromFloat(float) [NSString stringWithFormat:@"%f",(float)]
#define NSStringFromInt(int) [NSString stringWithFormat:@"%d",(int)]


/**
 *  测试
 */
#define UmengAppkey @"558d25c867e58e9366002e68"//正式 umeng后台：wjxc2015@qq.com wjxc2015

#define SinaAppKey @"2208620241" //正式审核通过 微博开放平台账号szkyaojiayou@163.com 密码：mobile2014
#define SinaAppSecret @"fe596bc4ac8c92316ad5f255fbc49432"
#define QQAPPID @"1104065435" //十六进制:41CEB39B; 生成方法:echo 'ibase=10;obase=16;1104065435'|bc
#define QQAPPKEY @"UgVWGacRoeo9NtZy" //正式的账号
#define WXAPPID @"wx47f54e431de32846" //正式
#define WXAPPSECRET @"a71699732e3bef01aefdaf324e2f522c"
#define RedirectUrl @"http://sns.whalecloud.com/sina2/callback" //回调地址






#endif
