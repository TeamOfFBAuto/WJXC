//
//  AppDelegate.m
//  WJXC
//
//  Created by lichaowei on 15/6/25.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"

#import <AlipaySDK/AlipaySDK.h>//支付宝
#import "UMFeedback.h"
#import "WXApi.h"
#import <RongIMKit/RongIMKit.h>

@interface AppDelegate ()<UMFeedbackDataDelegate,WXApiDelegate,RCIMClientReceiveMessageDelegate,RCIMUserInfoDataSource>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //微信支付
    NSString *version = [[NSString alloc] initWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    NSString *name = [NSString stringWithFormat:@"万聚鲜城 %@",version];
    [WXApi registerApp:WXAPPID withDescription:name];
    
    //融云
    
    [[RCIM sharedRCIM] initWithAppKey:RONGCLOUD_IM_APPKEY];

    [[RCIMClient sharedRCIMClient]setReceiveMessageDelegate:self object:nil];
    
    [[RCIM sharedRCIM]setUserInfoDataSource:self];//用户信息提供者
    
    //头像样式
    [[RCIM sharedRCIM] setGlobalMessageAvatarStyle:RC_USER_AVATAR_CYCLE];
    
    NSString *userToken = @"/Sz7uqK7aG1gU6EbC/qpUMW7g/8tugX5lVlJm8yP1kDNAYEW20rO9BtBJhTxqMKd4YdprT6mI1k=";
    
    [[RCIMClient sharedRCIMClient]connectWithToken:userToken success:^(NSString *userId) {
        
        NSLog(@"登录融云 userId %@",userId);
        
    } error:^(RCConnectErrorCode status) {
        
        NSLog(@"RCConnectErrorCode %ld",status);
        
    } tokenIncorrect:^{
        
        NSLog(@"token不对");
    }];
    
#pragma mark 友盟
    [self umengShare];
    
    [self uploadHeadImage];//上传头像
    
    RootViewController *root = [[RootViewController alloc]init];
    self.window.rootViewController = root;
    
#pragma mark 远程通知
    
    if (IOS7_OR_LATER) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 8.0)
    {
        if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                                 |UIRemoteNotificationTypeSound
                                                                                                 |UIRemoteNotificationTypeAlert) categories:nil];
            [application registerUserNotificationSettings:settings];
        }else{
            
            //注册推送, iOS 8
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
            [application registerUserNotificationSettings:settings];
        }
    }else
    {
        // 注册苹果推送，申请推送权限。
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
    
    
    //UIApplicationLaunchOptionsRemoteNotificationKey,判断是通过推送消息启动的
    
    NSDictionary *infoDic = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    if (infoDic)
    {
        //test
        NSLog(@"didFinishLaunch : infoDic %@",infoDic);
        
    }
    
    
    
    return YES;
}


#pragma mark 远程推送

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    // Register to receive notifications.
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    // Handle the actions.
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}

// 获取苹果推送权限成功。
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    
    NSLog(@"My token is: %@", deviceToken);
    
    
    
    NSString *string_pushtoken=[NSString stringWithFormat:@"%@",deviceToken];
    
    while ([string_pushtoken rangeOfString:@"<"].length||[string_pushtoken rangeOfString:@">"].length||[string_pushtoken rangeOfString:@" "].length) {
        string_pushtoken=[string_pushtoken stringByReplacingOccurrencesOfString:@"<" withString:@""];
        string_pushtoken=[string_pushtoken stringByReplacingOccurrencesOfString:@">" withString:@""];
        string_pushtoken=[string_pushtoken stringByReplacingOccurrencesOfString:@" " withString:@""];
        
    }
    NSLog(@"mytoken==%@",string_pushtoken);
    
    
    [LTools cache:string_pushtoken ForKey:USER_DEVICE_TOKEN];
    
    //给服务器token
    
    //融云服务器
    [[RCIMClient sharedRCIMClient]setDeviceToken:string_pushtoken];
    
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
    
    NSLog(@"openURL------ %@",url);
    
    //当支付宝客户端在操作时,商户 app 进程在后台被结束,只能通过这个 block 输出支付 结果。
    
#pragma mark - 支付宝支付回调
    
    //如果极简开发包不可用,会跳转支付宝钱包进行支付,需要将支付宝钱包的支付结果回传给开 发包
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url
                                                  standbyCallback:^(NSDictionary *resultDic) {
                                                      
                                                      NSLog(@"ali result = %@",resultDic);
                                                      
                                                      
                                                  }]; }
    
    if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回 authCode
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            
            NSLog(@"ali result = %@",resultDic);
            
        }];
    }
    
    //来自微信
    if ([url.host isEqualToString:@"pay"]) {
        
        return  [WXApi handleOpenURL:url delegate:self];

    }
    
    return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
}



- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [WXApi handleOpenURL:url delegate:self];
}

#pragma mark - UMFeedbackDataDelegate <NSObject>

- (void)getFinishedWithError: (NSError *)error
{
    
}
- (void)postFinishedWithError:(NSError *)error
{
    
}

#pragma mark - 微信支付回调

- (void)onResp:(BaseResp *)resp {
    
    if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *response = (PayResp *)resp;
        
        BOOL result = NO;
        switch (response.errCode) {
            case WXSuccess:
            {
                //服务器端查询支付通知或查询API返回的结果再提示成功
                NSLog(@"支付成功");
                
                result = YES;
            }
                break;
            case WXErrCodeCommon:
            case WXErrCodeSentFail:
            {
                NSLog(@"1、可能的原因：签名错误、未注册APPID、项目设置APPID不正确、注册的APPID与设置的不匹配、其他异常等.\n2、发送失败");

            }
                break;
            case WXErrCodeUserCancel:
                NSLog(@"用户取消支付");
                break;
            case WXErrCodeAuthDeny:

                NSLog(@"授权失败");
                break;
            default:
                NSLog(@"支付失败， retcode=%d",resp.errCode);
                
                break;
        }
        //微信支付通知
        NSDictionary *params = @{@"result":[NSNumber numberWithBool:result]};
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_PAY_WEIXIN_RESULT object:nil userInfo:params];
    }
}


#pragma mark - 友盟分享


- (void)umengShare
{
    //友盟反馈
    
    [UMFeedback setAppkey:UmengAppkey];
    
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
//    [UMSocialWechatHandler setWXAppId:WXAPPID appSecret:WXAPPSECRET url:@"http://www.umeng.com/social"];
    
    //    [UMSocialTencentWeiboHandler openSSOWithRedirectUrl:@"http://sns.whalecloud.com/tencent2/callback"];
    
}

#pragma - mark 上传更新头像



/**
 *  上传头像
 *
 *  @param aImage
 */
- (void)uploadHeadImage
{
    //不需要更新,return
    if (![LTools cacheBoolForKey:USER_UPDATEHEADIMAGE]) {
        
        NSLog(@"不需要更新头像");
        
        return;
    }else
    {
        NSLog(@"需要更新头像");

    }
    
    NSString *authcode = [LTools cacheForKey:USER_AUTHOD];
    
    //没有authcode return
    if (authcode.length == 0) {
        
        return;
    }
    
    UIImage *image = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:USER_NEWHEADIMAGE];
    
    NSDictionary *params = @{@"authcode":authcode};
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:USER_UPLOAD_HEADIMAGE parameters:params constructingBodyBlock:^(id<AFMultipartFormData> formData) {
        
        if (image != nil) {
            NSData *imageData =UIImageJPEGRepresentation(image, 1.f);
            [formData appendPartWithFileData:imageData name:@"pic" fileName:@"myhead.jpg" mimeType:@"image/jpg"];
        }
        
    } completion:^(NSDictionary *result) {
        
        NSLog(@"completion result %@",result[Erro_Info]);
        
        [LTools cacheBool:NO ForKey:USER_UPDATEHEADIMAGE];//不需要更新头像
        
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"failBlock result %@",result[Erro_Info]);
        
    }];
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

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

    [LTools updateTabbarUnreadMessageNumber];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

    //未读消息
    int unreadMsgCount = [[RCIMClient sharedRCIMClient]getUnreadCount: @[@(ConversationType_CUSTOMERSERVICE)]];;
    application.applicationIconBadgeNumber = unreadMsgCount;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [LTools updateTabbarUnreadMessageNumber];
}

#pragma - mark RCIMClientReceiveMessageDelegate

- (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object
{
    NSLog(@"RCIMClientReceiveMessageDelegate %d",nLeft);
    //接受到消息 更新未读消息
    
    if (0 == nLeft) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber+1;
            
            [LTools updateTabbarUnreadMessageNumber];
            
        });
        
    }
    
}


#pragma - mark RCIMUserInfoDataSource <NSObject>

/**
 *  获取用户信息。
 *
 *  @param userId     用户 Id。
 *  @param completion 用户信息
 */
- (void)getUserInfoWithUserId:(NSString *)userId
                   completion:(void (^)(RCUserInfo *userInfo))completion
{
    //客服就不需要了
    if ([userId isEqualToString:SERVICE_ID]) {
        
        return;
    }
    
    NSString *userName = [LTools rongCloudUserNameWithUid:userId];
    NSString *userIcon = [LTools rongCloudUserIconWithUid:userId];

    NSLog(@"userId %@ userIcon %@",userId,userIcon);

    if ([userId isEqualToString:[GMAPI getUid]]) {
        
        userName = [GMAPI getUsername];
    }
    
    NSLog(@"----->|%@|",userName);
    
    //没有保存用户名 或者 更新时间超过一个小时
    if ([LTools isEmpty:userName] || [LTools isEmpty:userIcon]  || [LTools rongCloudNeedRefreshUserId:userId]) {
        
        NSDictionary *params = @{@"uid":userId};
        [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:GET_USERINFO_ONLY_USERID parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
            
            NSDictionary *dic = result[@"user_info"];
            if ([dic isKindOfClass:[NSDictionary class]]) {
                
                NSString *name = dic[@"user_name"];
                NSString *icon = dic[@"avatar"];
                
                //不为空
                if (![LTools isEmpty:name]) {
                    
                    [LTools cacheRongCloudUserName:name forUserId:userId];
                }
                
                [LTools cacheRongCloudUserIcon:icon forUserId:userId];
                
                RCUserInfo *userInfo = [[RCUserInfo alloc]initWithUserId:userId name:name portrait:icon];
                
                return completion(userInfo);
            }
            
        } failBlock:^(NSDictionary *result) {
            
        }];
    }
    
    NSLog(@"userId %@ %@",userId,userName);
    
    RCUserInfo *userInfo = [[RCUserInfo alloc]initWithUserId:userId name:userName portrait:userIcon];
    
    return completion(userInfo);
}

@end
