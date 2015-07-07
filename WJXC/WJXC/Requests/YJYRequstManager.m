//
//  YJYRequstManager.m
//  YiYiProject
//
//  Created by lichaowei on 15/6/16.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "YJYRequstManager.h"

@implementation YJYRequstManager
{
    AFHTTPRequestOperationManager *_requestManager;
    NSMutableDictionary *_requstRecordDictionary;//记录请求字典
}

+ (id)shareInstance
{
    static dispatch_once_t once_t;
    static YJYRequstManager *manager = nil;
    dispatch_once(&once_t, ^{
        
        manager = [[YJYRequstManager alloc]init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _requestManager = [AFHTTPRequestOperationManager manager];
        _requestManager.operationQueue.maxConcurrentOperationCount = 5;
        _requstRecordDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

/**
 *  网络请求
 *
 *  @param method            YJYRequstMethod get\post
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
                    failBlock:(AFResultBlock)failBlock
{
    NSString *baseUrl = [SERVER_URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    
    AFHTTPRequestOperation *requestOpertation;
    
    __weak typeof(self)weakSelf = self;
    
    //自定义请求
    if (method == YJYRequstMethodCustom) {
        
        NSURLRequest *request = paramsDic[CUSTOM_REQUEST];
        
        if (request && [request isKindOfClass:[NSURLRequest class]]) {
            
            requestOpertation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
            
            [requestOpertation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [weakSelf successOperation:operation completion:completionBlock failBlock:failBlock];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [weakSelf failureOperation:operation error:error failtBlock:failBlock];
            }];
            
            [manager.operationQueue addOperation:requestOpertation];
        }
        
    }else
    {
        baseUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,apiString];
        
        NSLog(@"urlString --- %@",baseUrl);
        NSLog(@"params --- %@",paramsDic);
        
        if (method == YJYRequstMethodGet) {
            
            requestOpertation = [manager GET:baseUrl parameters:paramsDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [weakSelf successOperation:operation completion:completionBlock failBlock:failBlock];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [weakSelf failureOperation:operation error:error failtBlock:failBlock];
            }];
            
        }else if (method == YJYRequstMethodPost){
            
            if (constructingBlock) {
                
                requestOpertation = [manager POST:baseUrl parameters:paramsDic
                                     
                          constructingBodyWithBlock:constructingBlock
                                     
                                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                
                                                [weakSelf successOperation:operation completion:completionBlock failBlock:failBlock];
                                                
                                            }
                                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                
                                                [weakSelf failureOperation:operation error:error failtBlock:failBlock];
                                                
                                            }];
            }else
            {
                requestOpertation = [manager POST:baseUrl parameters:paramsDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    [weakSelf successOperation:operation completion:completionBlock failBlock:failBlock];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    [weakSelf failureOperation:operation error:error failtBlock:failBlock];
                    
                }];
            }
            
        }

    }
    
    [self addOperation:requestOpertation];
    
    return requestOpertation;
}

/**
 *  处理请求success结果
 *
 *  @param operation       AFHTTPRequestOperation
 *  @param completionBlock 成功Block
 *  @param failBlock       失败Block
 */
- (void)successOperation:(AFHTTPRequestOperation *)operation
              completion:(AFResultBlock)completionBlock
               failBlock:(AFResultBlock)failBlock
{
    NSString *key = [self requestHashKey:operation];
    _requstRecordDictionary[key] = operation;
    
    NSData *data = operation.responseData;
    if (data.length == 0){
        
        NSDictionary *failDic = @{Erro_Info:@"获取数据异常",Erro_Code:@"999"};
        
        failBlock(failDic);
        
        NSLog(@"---->获取数据异常 :response %@",operation.responseString);

        return;
    }

    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    if ([result isKindOfClass:[NSDictionary class]]) {
        
        int erroCode = [[result objectForKey:@"errorcode"]intValue];
        NSString *erroInfo = [result objectForKey:@"msg"];
        
        if (erroCode == 0) { //无错误,请求数据成功
            
            completionBlock(result);

        }else //代表请求结果有错误,或者特殊操作结果
        {
            //大于2000的可以正常提示错误,小于2000的为内部错误 参数错误等
            if (erroCode > 2000) {
                
                NSDictionary *result = @{Erro_Info:erroInfo,
                                         Erro_Code:[NSString stringWithFormat:@"%d",erroCode]};
                failBlock(result);
                
                [self showErroInfo:erroInfo];
                
                
            }else
            {
                NSLog(@"errcode:%d erroInfo:%@",erroCode,erroInfo);
                
                NSDictionary *result = @{Erro_Info:@"获取数据异常",
                                         Erro_Code:[NSString stringWithFormat:@"%d",erroCode]};
                failBlock(result);
                
                NSLog(@"---->获取数据异常 :response %@",operation.responseString);

            }

        }
        
    }
    
    
    [self removeOperation:operation];
//    completionBlock = nil;
//    failBlock = nil;
}

/**
 *  处理请求failure结果
 *
 *  @param operation AFHTTPRequestOperation
 *  @param error     错误NSError
 *  @param failBlock 失败Block
 */
- (void)failureOperation:(AFHTTPRequestOperation *)operation
                    error:(NSError *)error
              failtBlock:(AFResultBlock)failBlock
{
    NSString *errInfo = @"网络有问题,请检查网络";
    switch (error.code) {
        case NSURLErrorNotConnectedToInternet:
            
            errInfo = @"无网络连接";
            break;
        case NSURLErrorTimedOut:
            
            errInfo = @"网络连接超时";
            break;
        default:
            break;
    }
    
    NSDictionary *failDic = @{Erro_Info: errInfo};
    failBlock(failDic);
}


/**
 *  显示错误提示
 *
 *  @param errInfo
 */
- (void)showErroInfo:(NSString *)errInfo
{
    
}

/**
 *  获取operation的hash值
 *
 *  @param operation LTools 对象
 *
 *  @return 返回一个字符串作为可以
 */
- (NSString *)requestHashKey:(id)operation {
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)[operation hash]];
    return key;
}

/**
 *  记录网络请求
 *
 *  @param operation
 */
- (void)addOperationOther:(id)operation {
    if (operation != nil) {
        NSString *key = [self requestHashKey:operation];
        @synchronized(self) {
            _requstRecordDictionary[key] = operation;
        }
    }
}

/**
 *  移除网络请求
 *
 *  @param operation
 */
- (void)removeOperationOther:(id)operation {
    NSString *key = [self requestHashKey:operation];
    @synchronized(self) {
        AFHTTPRequestOperation *operation = _requstRecordDictionary[key];
        [operation cancel];
        [_requstRecordDictionary removeObjectForKey:key];
    }
}


/**
 *  记录网络请求
 *
 *  @param operation
 */
- (void)addOperation:(AFHTTPRequestOperation *)operation {
    if (operation != nil) {
        NSString *key = [self requestHashKey:operation];
        @synchronized(self) {
            _requstRecordDictionary[key] = operation;
        }
    }
}

/**
 *  移除网络请求
 *
 *  @param operation
 */
- (void)removeOperation:(AFHTTPRequestOperation *)operation {
    NSString *key = [self requestHashKey:operation];
    @synchronized(self) {
        
        AFHTTPRequestOperation *operation = _requstRecordDictionary[key];
        [operation cancel];
        [_requstRecordDictionary removeObjectForKey:key];
    }
}

@end
