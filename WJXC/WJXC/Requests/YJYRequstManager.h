//
//  YJYRequstManager.h
//  YiYiProject
//
//  Created by lichaowei on 15/6/16.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

#define CUSTOM_REQUEST @"customRequest" //自定义请求

/**
 *  根据实际接口修改
 */
#define Erro_Info @"msg" //错误信息
#define Erro_Code @"errorcode" //错误code

typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);//上传图片时可以用
typedef void (^AFResultBlock)(NSDictionary *result);//请求数据返回结果block

typedef enum {
    
    YJYRequstMethodGet = 0,//get请求
    YJYRequstMethodPost,  //post请求
    YJYRequstMethodCustom //自定义请求
    
}YJYRequstMethod;

@interface YJYRequstManager : NSObject

+ (id)shareInstance;

/**
 *  网络请求
 *
 *  @param method            YJYRequstMethod get\post
 *  @param apiString         去掉域名,去掉参数部分
 *  @param paramsDic         参数字典
 *  @param constructingBlock 上传图片时需要在此处理
 *  @param completionBlock
 *  @param failBlock
 *
 *  @return AFHTTPRequestOperation
 */
- (AFHTTPRequestOperation *)requestWithMethod:(YJYRequstMethod)method
                      api:(NSString *)apiString
               parameters:(NSDictionary *)paramsDic
    constructingBodyBlock:(AFConstructingBlock)constructingBlock
               completion:(AFResultBlock)completionBlock
                failBlock:(AFResultBlock)failBlock;

/**
 *  记录网络请求
 *
 *  @param operation
 */
- (void)addOperation:(AFHTTPRequestOperation *)operation;

/**
 *  移除网络请求记录 网络请求cancel
 *
 *  @param operation
 */
- (void)removeOperation:(AFHTTPRequestOperation *)operation;

@end
