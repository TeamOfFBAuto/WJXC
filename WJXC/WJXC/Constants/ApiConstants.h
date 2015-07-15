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

#define SERVER_URL @"http://182.92.106.193:85" //域名地址

//接口的去掉域名、去掉参数部分

//根据id获取用户信息 (参数: uid authcode)
#define GET_USERINFO_WITHID @"/index.php?d=api&c=user&m=get_user_info"

//单品 - 添加收藏 (参数:product_id、authcode)
#define HOME_PRODUCT_COLLECT_ADD @"/?d=api&c=products&m=favor"



//登录
#define USER_LOGIN_ACTION @"/index.php?d=api&c=user&m=login"

//退出登录
#define USER_LOGOUT_ACTION @"/index.php?d=api&c=user&m=login_out"

//注册
#define USER_REGISTER_ACTION @"/index.php?d=api&c=user&m=register"
//获取验证码
#define USER_GET_SECURITY_CODE @"/index.php?d=api&c=user&m=get_code"
//找回密码
#define USER_GETBACK_PASSWORD @"/index.php?d=api&c=user&m=get_back_password&mobile=%@&code=%d&new_password=%@&confirm_password=%@"
//修改密码
#define USER_UPDATE_PASSWORD @"/index.php?d=api&c=user&m=change_password"

//修改用户头像
#define USER_UPLOAD_HEADIMAGE @"/index.php?d=api&c=user&m=update_user_photo"

//修改用户名字
#define USER_UPDATE_USERNAME @"/index.php?d=api&c=user&m=update_user_info"

#define ABOUT_US_URL @"http://www.baidu.com"


//获取商品详情+评论
#define GET_PRODUCTDETAIL @"/index.php?d=api&c=products&m=get_product_detail"

//收货地址相关接口==================

//获取用户的收货地址列表(get参数调取参数：authcode page per_page)
#define USER_ADDRESS_LIST @"/index.php?d=api&c=user&m=get_user_address"

//16、添加用户的收货地址(post参数调取参数:authcode、pro_id省份id、city_id城市id、street具体的地址、receiver_username收货人姓名、mobile收货人手机号、phone收货人电话（可不填）、zip_code邮编（可不填）、default_address是否设为默认地址 1=》是 0=》不是)
#define USER_ADDRESS_ADD @"/index.php?d=api&c=user&m=add_user_address"

//17、编辑用户的收货地址(post参数调取参数:authcode、address_id收货地址id、pro_id省份id、city_id城市id、street具体的地址、receiver_username收货人姓名、mobile收货人手机号、phone收货人电话（可不填）、zip_code邮编（可不填）、default_address是否设为默认地址 1=》是 0=》不是)
#define USER_ADDRESS_EDIT @"/index.php?d=api&c=user&m=edit_user_address"

//设置默认地址
#define USER_ADDRESS_SETDEFAULT @"/index.php?d=api&c=user&m=set_default_address"

//删除地址
#define USER_ADDRESS_DELETE @"/index.php?d=api&c=user&m=del_user_address"


#endif
