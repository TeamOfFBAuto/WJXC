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

#endif
