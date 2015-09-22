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

//根视图
#define ROOTVIEWCONTROLLER (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController

//图片比例

#define W_H_RATIO 200/320  //宽高比

//错误提示信息 

#define ALERT_ERRO_PHONE @"请输入有效手机号"
#define ALERT_ERRO_PASSWORD @"密码格式有误,请输入6~32位英文字母或数字"
#define ALERT_ERRO_SECURITYCODE @"验证码格式有误,请输入6位数字"
#define ALERT_ERRO_FINDPWD @"两次密码不一致"

//秒杀相关描述语
#define MIAOSHAO_END_TEXT @"秒杀已结束"
#define MIAOSHAO_PRE_TEXT @"秒杀结束倒计时:"

//保存用户信息设备信息相关

#define USER_INFO @"userInfo"//用户信息
#define USER_FACE @"userface"
#define USER_NAME @"username"
#define USER_PWD @"userPw"
#define USER_UID @"useruid"
#define USERINFO_MODEL @"USERINFO_MODEL" //存储在本地用户model

#define USERLocation @"locationInfo"

//两个登陆标识
#define LOGIN_SERVER_STATE @"user_login_state" //服务器 no是未登陆  yes是已登陆
#define LOGIN_RONGCLOUD_STATE @"rongcloudLoginState"//融云登陆状态

#define USER_AUTHOD @"user_authod"
#define USER_CHECKUSER @"checkfbuser"
#define USER_HEAD_IMAGEURL @"userHeadImageUrl"//头像url

#define USER_AUTHKEY_OHTER @"otherKey"//第三方key
#define USRR_AUTHKEY @"authkey"
#define USER_DEVICE_TOKEN @"DEVICE_TOKEN"

#define USER_RONGCLOUD_TOKEN @"RongCloudToken" //融云token


#define USER_UPDATEHEADIMAGE @"updateHeadImage"//更新用户头像
#define USER_NEWHEADIMAGE @"newHeadImage"//新头像

//int 转 string
#define NSStringFromFloat(float) [NSString stringWithFormat:@"%f",(float)]
#define NSStringFromInt(int) [NSString stringWithFormat:@"%d",(int)]


#define UmengAppkey @"558d25c867e58e9366002e68"//正式 umeng后台：wjxc2015@qq.com wjxc2015

#define SinaAppKey @"2480371284"
#define SinaAppSecret @"d0ff7ad37ad8014b207c2a1eced4fdd0"

#define QQAPPID @"1104757360" //tencent1104757360 十六进制:QQ41d94270; 生成方法:NSString *str = [ [NSString alloc] initWithFormat:@"%x",1104757360];
#define QQAPPKEY @"m7DlzFpxeDxRBULc"

#define WXAPPID @"wx509a0740cca6f939" //万鲜正式
#define WXAPPSECRET @"9a5909e5af9621847e80c1dc5bae52e3"
#define RedirectUrl @"http://sns.whalecloud.com/sina2/callback" //回调地址

/**
 *  融云
 */

////开发
//#define RONGCLOUD_IM_APPKEY    @"8luwapkvuf1nl" //融云账号 wjcx2015@qq.com
//#define RONGCLOUD_IM_APPSECRET @"bl6uUMP8HdpsU"
////融云客服id
//#define SERVICE_ID @"KEFU1438066005020"

//正式环境
#define RONGCLOUD_IM_APPKEY    @"8brlm7ufr42x3" //融云账号 wjcx2015@qq.com
#define RONGCLOUD_IM_APPSECRET @"PIKhQ5NndKx"
//融云客服id
#define SERVICE_ID @"KEFU1440670948804"


//百度地图
#define baiduMapAk @"bBsNsfsiH9MBaiYs4XtuNgID"


#endif
