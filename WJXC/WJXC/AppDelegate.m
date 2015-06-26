//
//  AppDelegate.m
//  WJXC
//
//  Created by lichaowei on 15/6/25.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
#pragma mark 友盟
    [self umengShare];
    
    
    [self requestForPost];
    
    RootViewController *root = [[RootViewController alloc]init];
    self.window.rootViewController = root;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

/**
 这里处理新浪微博SSO授权进入新浪微博客户端后进入后台，再返回原来应用
 */
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [UMSocialSnsService  applicationDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/**
 这里处理新浪微博SSO授权之后跳转回来，和微信分享完成之后跳转回来
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
}




#pragma mark - 友盟分享

- (void)umengShare
{
    [UMSocialData setAppKey:UmengAppkey];
    
    //使用友盟统计
    [MobClick startWithAppkey:UmengAppkey];
    
    //打开调试log的开关
    [UMSocialData openLog:YES];
    
    //打开新浪微博的SSO开关
    [UMSocialSinaHandler openSSOWithRedirectURL:RedirectUrl];
    
    //设置分享到QQ空间的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:QQAPPID appKey:QQAPPKEY url:@"http://www.umeng.com/social"];
    
    //设置支持没有客户端情况下使用SSO授权
    [UMSocialQQHandler setSupportWebView:YES];
    
    //设置微信AppId，设置分享url，默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:WXAPPID appSecret:WXAPPSECRET url:@"http://www.umeng.com/social"];
    
    //    [UMSocialTencentWeiboHandler openSSOWithRedirectUrl:@"http://sns.whalecloud.com/tencent2/callback"];
    
}

#pragma - mark 网络请求例子

/**
 *  get请求
 */
- (void)requestForGet
{
    //网络请求例子
    
    //get
    
    NSDictionary *params = @{@"uid":@"11"};
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:GET_USERINFO_WITHID parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSLog(@"result %@ %@",result[Erro_Info],result);
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"result %@",result[Erro_Info]);
        
    }];
    
}

/**
 *  post请求
 */
- (void)requestForPost
{
//    参数:product_id、authcode
    
    NSDictionary *params = @{@"product_id":@"25",
                             @"authcode":@"WyQBeAd+B+FW7QeaXu4J3geiAOJTpgv6V3oHNlcyUWYBMlNhUzVUY1ViBT0DYQx8UWc="};
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:HOME_PRODUCT_COLLECT_ADD parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSLog(@"result %@ %@",result[Erro_Info],result);
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"result %@",result[Erro_Info]);
        
    }];
}

@end
