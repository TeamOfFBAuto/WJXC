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


//获取商品详情
#define GET_PRODUCTDETAIL @"/index.php?d=api&c=products&m=get_product_detail"

//获取商品评论(参数product_id=1  商品id 必填 comment_level=1 选填 评论级别 1差评 2中评 3好评  0或不传将获取所有级别评论 page=1 当前评论页perpage=1 评论每页显示数目 order=comment_id   排序字段 direction=  排序顺序  [desc:降序   asc：升序])
#define GET_PRODUCT_COMMENT @"/index.php?d=api&c=products&m=get_product_comment"


#endif
