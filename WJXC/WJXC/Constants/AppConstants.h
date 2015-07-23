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



//错误提示信息 

#define ALERT_ERRO_PHONE @"请输入有效手机号"
#define ALERT_ERRO_PASSWORD @"密码格式有误,请输入6~32位英文字母或数字"
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

#define USER_UPDATEHEADIMAGE @"updateHeadImage"//更新用户头像
#define USER_NEWHEADIMAGE @"newHeadImage"//新头像

//int 转 string
#define NSStringFromFloat(float) [NSString stringWithFormat:@"%f",(float)]
#define NSStringFromInt(int) [NSString stringWithFormat:@"%d",(int)]


/**
 *  测试
 */
#define UmengAppkey @"558d25c867e58e9366002e68"//正式 umeng后台：wjxc2015@qq.com wjxc2015

#define SinaAppKey @"2208620241" //正式审核通过 微博开放平台账号szkyaojiayou@163.com 密码：mobile2014
#define SinaAppSecret @"fe596bc4ac8c92316ad5f255fbc49432"
#define QQAPPID @"1104757360" //tencent1104757360 十六进制:QQ41d94270; 生成方法:NSString *str = [ [NSString alloc] initWithFormat:@"%x",1104757360];
#define QQAPPKEY @"m7DlzFpxeDxRBULc"
#define WXAPPID @"wx509a0740cca6f939"
#define WXAPPSECRET @"9a5909e5af9621847e80c1dc5bae52e3"
#define RedirectUrl @"http://sns.whalecloud.com/sina2/callback" //回调地址

/**
 *  支付宝支付
 */

//合作商户ID。用签约支付宝账号登录ms.alipay.com后，在账户信息页面获取。
#define Alipay_PartnerID @"2088911787623114"
//账户ID。用签约支付宝账号登录ms.alipay.com后，在账户信息页面获取。
#define Alipay_SellerID  @"yjy@alayy.com"

//PKCS8 商户私钥(建议放在服务端,并且由服务端进行签名和验签)
#define Alipay_PartnerPrivKey @"MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBAKLbSbvZjWcuxNwq9Zsg7Iu7cZADPW0uQJXd4BpJMuImbmed5z991NZMBVymUVsjiPJ1QsVVnPfInhmycHkhPc1rCkTX/VyigHxt6pGMqoGT+LR6+TF6O1glYJwY2zAETkRcg6QzJhhPUJFeNUgYZsYs6Q+01taeJ9Rz4JzH3BGVAgMBAAECgYBR6BpIaR1OFN6boNuP3to5WNe/x3FgdQ+0kDfC4Ke/x/ZlFKyWaTHfabKUq21lehTJZKJlXy6oDHU/lVguA8LxvQGAg33Q/r8+/4W2KFZTJToYxfUp+bzgyM0QikKt/M3yGdGxgcSJU3jIU8UTnToALUpbnP8kFC2ebxHHR9GsYQJBANCvnQE1csoCv1zb+cJqDGIo2/YTpEDG3FG+3aYJDpu7K5WOIFCd+ShSi46UHUP9eDPFrQwVFcqV2k+3DWHBYG0CQQDHx65o4vQZ5qFrNT4nTy4IAmROBGzOh/9b8oH9VNfSj2yBLyJaquSJW31IYkjgf9ksqp7xJxXircz252B9o0zJAkAC4BiStrDRNb57QhCr7BgllhiJyHV/6v2IJtAZBJDt9mNAWUf6tGKFerWvjjzk/e4VEIk03GmDdBMg/A20Jhz1AkAIhGDRI+vYNtbm5SwzLNL/kGqKUPH6lB2048/a5wUUevzbPREv4F1B5d6feWE2AP1XRCbmjQ4HzfURCag5cv7RAkBYfDvLxKNjag0OFIBwD8g1qpxKwwvVZv9u1EmsbmmfBKC6TooKF7vtIMQryK0q9+WEMuh3NSDQJSO2i+O9mCSP"


#endif
