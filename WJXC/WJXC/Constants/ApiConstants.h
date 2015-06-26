//
//  ApiConstants.h
//  WJXC
//
//  Created by lichaowei on 15/6/25.
//  Copyright (c) 2015年 lcw. All rights reserved.
//
/**
 *  存放请求接口
 */
#ifndef WJXC_ApiConstants_h
#define WJXC_ApiConstants_h

#define SERVER_URL @"http://www119.alayy.com" //域名地址

//接口的去掉域名、去掉参数部分

//根据id获取用户信息 (参数:uid)
#define GET_USERINFO_WITHID @"/index.php?d=api&c=user_api&m=get_user_by_uid"

//单品 - 添加收藏 (参数:product_id、authcode)
#define HOME_PRODUCT_COLLECT_ADD @"/?d=api&c=products&m=favor"



//登录
#define USER_LOGIN_ACTION @"/index.php?d=api&c=user_api&m=login&type=%@&password=%@&thirdid=%@&nickname=%@&third_photo=%@&gender=%d&devicetoken=%@&mobile=%@&login_source=%@"

//退出登录
#define USER_LOGOUT_ACTION @"/index.php?d=api&c=user_api&m=login_out&authcode=%@"

//注册
#define USER_REGISTER_ACTION @"/index.php?d=api&c=user_api&m=register&username=%@&password=%@&gender=%d&type=%d&code=%d&mobile=%@"
//获取验证码
#define USER_GET_SECURITY_CODE @"/index.php?d=api&c=user_api&m=get_code&mobile=%@&type=%d&encryptcode=%@"
//找回密码
#define USER_GETBACK_PASSWORD @"/index.php?d=api&c=user_api&m=get_back_password&mobile=%@&code=%d&new_password=%@&confirm_password=%@"



#endif
