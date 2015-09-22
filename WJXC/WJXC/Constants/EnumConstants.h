//
//  EnumConstants.h
//  WJXC
//
//  Created by lichaowei on 15/6/25.
//  Copyright (c) 2015年 lcw. All rights reserved.
//
/**
 *  常用的一些枚举
 */
#ifndef WJXC_EnumConstants_h
#define WJXC_EnumConstants_h

//登录类型 normal为正常手机登陆，sweibo、qq、weixin分别代表新浪微博、qq、微信登陆
typedef enum{
    Login_Normal = 0,
    Login_Sweibo,
    Login_QQ,
    Login_Weixin
}Login_Type;

//性别
typedef enum{
    Gender_Girl = 1,
    Gender_Boy
}Gender;

//注册类型，1=》手机注册 2=》邮箱注册，默认为手机注册
typedef enum{
    Register_Phone = 1,
    Register_Email
}Register_Type;

//验证码用途 1=》注册 2=》商店短信验证 3=》找回密码 4⇒申请成为搭配师获取验证码 默认为1) int
typedef enum{
    SecurityCode_Register = 1,
    SecurityCode_FindPWD,
    SecurityCode_Match
}SecurityCode_Type;

typedef enum{
    ORDERTYPE_DaiFu = 1, //待付款
    ORDERTYPE_DaiFaHuo,//待发货
    ORDERTYPE_PeiSong, //配送中
    ORDERTYPE_DaiPingJia, //待评价
    ORDERTYPE_WanCheng, //完成
    ORDERTYPE_TuiHuan //退换
}ORDERTYPE;

#endif
