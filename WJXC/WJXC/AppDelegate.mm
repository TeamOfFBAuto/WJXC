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

#import "BMapKit.h"//百度地图

#import "SimpleMessage.h"

#import "APService.h"//极光推送

#import "ProductDetailViewController.h"//单品详情
#import "HuodongViewController.h"//活动详情
#import "OrderInfoViewController.h" //订单详情

#define kTag_active 100 //正在前台

@interface AppDelegate ()<UMFeedbackDataDelegate,GgetllocationDelegate,BMKGeneralDelegate,WXApiDelegate,RCIMReceiveMessageDelegate,RCIMUserInfoDataSource>
{
    GMAPI *mapApi;
    LocationBlock _locationBlock;
    BMKMapManager* _mapManager;
    CLLocationManager *_locationManager;
    
    int _getRongTokenTime;//获取融云token次数
    NSTimer *_getRongTokenTimer;//获取融云token计时器
    
    NSDictionary *_remoteMessageDic;//远程推送消息
}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //微信支付
    NSString *version = [[NSString alloc] initWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    NSString *name = [NSString stringWithFormat:@"万聚鲜城%@",version];
    [WXApi registerApp:WXAPPID withDescription:name];
    
//    https://itunes.apple.com/cn/app/yi-jia-yi-fa-xian-mei-li-wei/id951259287?mt=8
    [[LTools shareInstance]versionForAppid:@"1026846736" Block:^(BOOL isNewVersion, NSString *updateUrl, NSString *updateContent) {
        
        if (isNewVersion) {
            
            DDLOG(@"新版本");
        }else
        {
            DDLOG(@"没有现版本");
        }
        
    }];
    
#pragma - mark 融云
    //融云
    
    [[RCIM sharedRCIM] initWithAppKey:RONGCLOUD_IM_APPKEY];
    
    [[RCIM sharedRCIM]setReceiveMessageDelegate:self];
    
    [[RCIM sharedRCIM]setUserInfoDataSource:self];//用户信息提供者
    
    //头像样式
    [[RCIM sharedRCIM] setGlobalMessageAvatarStyle:RC_USER_AVATAR_CYCLE];
    
    //SDK 初始化方法 initWithAppKey 之后后注册消息类型
    [[RCIMClient sharedRCIMClient]registerMessageType:SimpleMessage.class];
    
    //开始融云登录
    [self startLoginRongTimer];
    
    //监控登录通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(startLoginRongTimer) name:NOTIFICATION_LOGIN object:nil];
    
#pragma mark 友盟
    [self umengShare];
    
    [self uploadHeadImage];//上传头像
    
    RootViewController *root = [[RootViewController alloc]init];
    self.window.rootViewController = root;
    
#pragma mark JPush远程通知
    
//    [APService crashLogON];
    
    // Required
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound |
                                                       UIUserNotificationTypeAlert)
                                           categories:nil];
    } else {
        //categories 必须为nil
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
    
    // Required
    [APService setupWithOption:launchOptions];
    
    //UIApplicationLaunchOptionsRemoteNotificationKey,判断是通过推送消息启动的
    
    NSDictionary *userInfo = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    if (userInfo)
    {
        //test
        DDLOG(@"didFinishLaunch : userInfo %@",userInfo);
        
        NSString *type = userInfo[@"type"];
        NSString *theme_id = userInfo[@"theme_id"];
        
        [self pushToMessageDetail:[type intValue] detailId:theme_id];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForDidSetupNotification:) name:kJPFNetworkDidSetupNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForDidCloseNotification:) name:kJPFNetworkDidCloseNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForDidRegisterNotification:) name:kJPFNetworkDidRegisterNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForDidLoginNotification:) name:kJPFNetworkDidLoginNotification object:nil];
    
    //非APNS消息
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForDidReceiveMessageNotification:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
    //错误提示
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForErrorNotification:) name:kJPFServiceErrorNotification object:nil];
    
//    if (IOS7_OR_LATER) {
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
//        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
//    }
//    
//    if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 8.0)
//    {
//        if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
//            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
//                                                                                                 |UIRemoteNotificationTypeSound
//                                                                                                 |UIRemoteNotificationTypeAlert) categories:nil];
//            [application registerUserNotificationSettings:settings];
//        }else{
//            
//            //注册推送, iOS 8
//            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
//            [application registerUserNotificationSettings:settings];
//        }
//    }else
//    {
//        // 注册苹果推送，申请推送权限。
//        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
//    }

    
#pragma mark 百度地图相关
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 8.0)
    {
        //设置定位权限 仅ios8有意义
        [_locationManager requestWhenInUseAuthorization];// 前台定位
        
        //  [locationManager requestAlwaysAuthorization];// 前后台同时定位
    }
    [_locationManager startUpdatingLocation];
    
    
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:baiduMapAk  generalDelegate:self];
    if (!ret) {
        DDLOG(@"manager start failed!");
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
    NSString *string_pushtoken=[NSString stringWithFormat:@"%@",deviceToken];
    
    while ([string_pushtoken rangeOfString:@"<"].length||[string_pushtoken rangeOfString:@">"].length||[string_pushtoken rangeOfString:@" "].length) {
        string_pushtoken=[string_pushtoken stringByReplacingOccurrencesOfString:@"<" withString:@""];
        string_pushtoken=[string_pushtoken stringByReplacingOccurrencesOfString:@">" withString:@""];
        string_pushtoken=[string_pushtoken stringByReplacingOccurrencesOfString:@" " withString:@""];
        
    }
    NSLog(@"deviceToken==%@",string_pushtoken);
    
    [LTools cache:string_pushtoken ForKey:USER_DEVICE_TOKEN];
    
    //融云服务器
    [[RCIMClient sharedRCIMClient]setDeviceToken:string_pushtoken];
    [APService registerDeviceToken:deviceToken];
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
    
    DDLOG(@"openURL------ %@",url);
    
    //当支付宝客户端在操作时,商户 app 进程在后台被结束,只能通过这个 block 输出支付 结果。
    
#pragma mark - 支付宝支付回调
    
    //如果极简开发包不可用,会跳转支付宝钱包进行支付,需要将支付宝钱包的支付结果回传给开 发包
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url
                                                  standbyCallback:^(NSDictionary *resultDic) {
                                                      
                                                      DDLOG(@"ali result = %@",resultDic);
                                                      
                                                      
                                                  }]; }
    
    if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回 authCode
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            
            DDLOG(@"ali result = %@",resultDic);
            
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

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [LTools updateTabbarUnreadMessageNumber];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    //未读消息
    int unreadMsgCount = [[RCIMClient sharedRCIMClient]getUnreadCount: @[@(ConversationType_CUSTOMERSERVICE)]];
    
    if (![LTools isLogin]) {
        unreadMsgCount = 0;
    }
    application.applicationIconBadgeNumber = unreadMsgCount;
    
    
//    NSString *userId = [GMAPI getUid];
//    int unreadMsgCount = [[RCIMClient sharedRCIMClient]getUnreadCount:ConversationType_CUSTOMERSERVICE targetId:userId];
//    application.applicationIconBadgeNumber = unreadMsgCount;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // IOS 7 Support Required
    
    [self actionForApplication:application notificationUserInfo:userInfo];
    
    completionHandler(UIBackgroundFetchResultNewData);
    
    NSLog(@"JPush1 remote %@",userInfo);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self actionForApplication:application notificationUserInfo:userInfo];

}

/**
 *  处理远程通知消息
 *
 *  @param application 用于判断程序状态
 *  @param userInfo    通知内容
 */
- (void)actionForApplication:(UIApplication *)application
        notificationUserInfo:(NSDictionary *)userInfo
{
    
    [LTools updateTabbarUnreadMessageNumber];
    
    //极光推送
    [APService handleRemoteNotification:userInfo];
    
    DDLOG(@"JPush2 remote %@",userInfo);
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateInactive){
        DDLOG(@"UIApplicationStateInactive %@",userInfo);
        //程序在后台运行 点击消息进入走此处,做相应处理
        
        NSDictionary *aps = userInfo[@"aps"];
        NSString *alert = aps[@"alert"];
        alert = [NSString stringWithFormat:@"Inactive:%@",alert];
        
        //直接查看
        
        NSString *type = userInfo[@"type"];
        NSString *theme_id = userInfo[@"theme_id"];
        
        [self pushToMessageDetail:[type intValue] detailId:theme_id];
        
    }
    if (state == UIApplicationStateActive) {
        DDLOG(@"UIApplicationStateActive %@",userInfo);
        //程序就在前台
        
        _remoteMessageDic = userInfo;
        
        NSDictionary *aps = userInfo[@"aps"];
        NSString *alertMessage = aps[@"alert"];//消息内容
        
        //提示之后再查看
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"消息通知" message:alertMessage delegate:self cancelButtonTitle:@"忽略" otherButtonTitles:@"查看", nil];
        alertView.tag = kTag_active;
        [alertView show];
    }
    if (state == UIApplicationStateBackground)
    {
        DDLOG(@"UIApplicationStateBackground %@",userInfo);
    }
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
        NSString *errInfo = nil;
        switch (response.errCode) {
            case WXSuccess:
            {
                //服务器端查询支付通知或查询API返回的结果再提示成功
                DDLOG(@"支付成功");
                errInfo = @"支付成功";
                result = YES;
            }
                break;
            case WXErrCodeCommon:
            case WXErrCodeSentFail:
            {
                DDLOG(@"1、可能的原因：签名错误、未注册APPID、项目设置APPID不正确、注册的APPID与设置的不匹配、其他异常等.\n2、发送失败");
                errInfo = @"微信支付异常";
            }
                break;
            case WXErrCodeUserCancel:
                DDLOG(@"用户取消支付");
                errInfo = @"用户取消支付";

                break;
            case WXErrCodeAuthDeny:

                DDLOG(@"授权失败");
                errInfo = @"微信支付授权失败";
                break;
            default:
                DDLOG(@"支付失败， retcode=%d",resp.errCode);
                
                errInfo = @"微信支付失败";
                break;
        }
        //微信支付通知
        NSDictionary *params = @{@"result":[NSNumber numberWithBool:result],@"erroInfo":errInfo};
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_PAY_WEIXIN_RESULT object:nil userInfo:params];
    }
}


- (void)isZero:(double) d
{
    if (d >= -DBL_EPSILON && d <= DBL_EPSILON)
    {
        //d是0处理
    }
}

#pragma mark - 友盟分享


- (void)umengShare
{
    //使用友盟统计
    [MobClick startWithAppkey:UmengAppkey reportPolicy:BATCH channelId:nil];
//    [MobClick setLogEnabled:YES];
//    [MobClick setCrashReportEnabled:YES];
    
    //友盟反馈
    
    [UMFeedback setAppkey:UmengAppkey];
    
    [UMSocialData setAppKey:UmengAppkey];
    
    //打开调试log的开关
    [UMSocialData openLog:NO];
    
    //打开新浪微博的SSO开关
    [UMSocialSinaHandler openSSOWithRedirectURL:RedirectUrl];
    
    //设置分享到QQ空间的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:QQAPPID appKey:QQAPPKEY url:@"http://a.app.qq.com/o/simple.jsp?pkgname=com.epe.wjxc"];
    
    //设置支持没有客户端情况下使用SSO授权
    [UMSocialQQHandler setSupportWebView:YES];
    
    //设置微信AppId，设置分享url，默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:WXAPPID appSecret:WXAPPSECRET url:@"http://a.app.qq.com/o/simple.jsp?pkgname=com.epe.wjxc"];
    
    //    [UMSocialTencentWeiboHandler openSSOWithRedirectUrl:@"http://sns.whalecloud.com/tencent2/callback"];
    
    NSArray *snsNames = @[UMShareToWechatTimeline,UMShareToQzone,UMShareToWechatSession,UMShareToQQ];
    //UMShareToSina
     [UMSocialConfig hiddenNotInstallPlatforms:snsNames];
    
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
        
        DDLOG(@"不需要更新头像");
        
        return;
    }else
    {
        DDLOG(@"需要更新头像");

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
        
        DDLOG(@"completion result %@",result[Erro_Info]);
        
        [LTools cacheBool:NO ForKey:USER_UPDATEHEADIMAGE];//不需要更新头像
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_UPDATEHEADIMAGE_SUCCESS object:nil];//更新头像成功
        
    } failBlock:^(NSDictionary *result) {
        
        DDLOG(@"failBlock result %@",result[Erro_Info]);
        
    }];
}

#pragma - mark RCIMReceiveMessageDelegate <NSObject>
/**
 接收消息到消息后执行。
 
 @param message 接收到的消息。
 @param left    剩余消息数.
 */
- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left
{
    DDLOG(@"RCIMReceiveMessageDelegate %d",left);
    //接受到消息 更新未读消息
    
    if (0 == left) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber+1;
            
            [LTools updateTabbarUnreadMessageNumber];
            
        });
        
    }
}

#pragma - mark RCIMClientReceiveMessageDelegate

//- (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object
//{
//    NSLog(@"RCIMClientReceiveMessageDelegate %d",nLeft);
//    //接受到消息 更新未读消息
//    
//    if (0 == nLeft) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber+1;
//            
//            [LTools updateTabbarUnreadMessageNumber];
//            
//        });
//        
//    }
//    
//}


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

    DDLOG(@"userId %@ userIcon %@",userId,userIcon);

    if ([userId isEqualToString:[GMAPI getUid]]) {
        
        userName = [GMAPI getUsername];
    }
    
    DDLOG(@"----->|%@|",userName);
    
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



#pragma mark - MyMethod

#pragma mark - 获取坐标

- (void)startDingweiWithBlock:(LocationBlock)location
{
    _locationBlock = location;
    
    //定位获取坐标
    mapApi = [GMAPI sharedManager];
    mapApi.delegate = self;
    
    [mapApi startDingwei];
    
}



#pragma mark - 定位Delegate

- (void)theLocationDictionary:(NSDictionary *)dic{
    
    DDLOG(@"定位成功------>%@",dic);
    
    if (_locationBlock) {
        
        _locationBlock(dic);
    }
    
    [GMAPI sharedManager].theLocationDic = [dic copy];
}


-(void)theLocationFaild:(NSDictionary *)dic{
    
    DDLOG(@"定位失败----->%@",dic);
    
    if (_locationBlock) {
        _locationBlock(dic);
    }
}


#pragma - mark 获取融云token

- (void)getRongCloudToken
{
    if (_getRongTokenTime == 0) {
        
        [self stopRongTimer];
        
        return;
    }
    
    _getRongTokenTime --;
    
    NSString *userToken = [LTools cacheForKey:USER_RONGCLOUD_TOKEN];
    
    if (userToken.length) {
        
        [self loginRongCloudWithToken:userToken];
        
        return;
    }

    NSString *user_id = [GMAPI getUid];
    
    if (!user_id || user_id.length == 0 || [user_id isEqualToString:@"(null)"] || [user_id isKindOfClass:[NSNull class]]) {
        
        [self stopRongTimer];
        
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    NSString *user_name = [GMAPI getUsername];
    NSString *icon = [GMAPI getUerHeadImageUrl];
    
    icon = icon.length > 0 ? icon : @"default";
    
    NSDictionary *params = @{@"user_id":user_id,
                             @"name":user_name,
                             @"portrait_uri":icon};
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:USER_GET_TOKEN parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSString *token = result[@"token"];
        
        [LTools cache:token ForKey:USER_RONGCLOUD_TOKEN];
        
        [weakSelf loginRongCloudWithToken:token];
        
    } failBlock:^(NSDictionary *result) {
        
        
    }];
}

- (void)loginRongCloudWithToken:(NSString *)userToken
{
    if (userToken.length) {
        
        __weak typeof(self)weakSelf = self;

        [[RCIMClient sharedRCIMClient]connectWithToken:userToken success:^(NSString *userId) {
            
            DDLOG(@"登录成功融云 userId %@",userId);
            
            [weakSelf stopRongTimer];//停止计时
            
        } error:^(RCConnectErrorCode status) {
            
            DDLOG(@"RCConnectErrorCode %ld",status);
            
        } tokenIncorrect:^{
            
            DDLOG(@"token不对");
            
            [LTools cache:nil ForKey:USER_RONGCLOUD_TOKEN];
        }];
    }else
    {
        [self getRongCloudToken];
    }

}

- (void)startLoginRongTimer
{
    _getRongTokenTime = 5;
    [self getRongCloudToken];//先登录一次
    _getRongTokenTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(getRongCloudToken) userInfo:nil repeats:YES];
}

- (void)stopRongTimer
{
    [_getRongTokenTimer invalidate];
    _getRongTokenTimer = nil;
}

#pragma - mark 极光推送

//建立连接
- (void)notificationForDidSetupNotification:(NSNotification *)notify
{
    DDLOG(@"建立连接 JPush %@ %@",notify.userInfo,notify.object);
}

//关闭连接
- (void)notificationForDidCloseNotification:(NSNotification *)notify
{
    DDLOG(@"关闭连接 JPush %@ %@",notify.userInfo,notify.object);
}

//注册成功
- (void)notificationForDidRegisterNotification:(NSNotification *)notify
{
    DDLOG(@"注册成功 JPush %@ %@",notify.userInfo,notify.object);
}

//登录成功
- (void)notificationForDidLoginNotification:(NSNotification *)notify
{
    DDLOG(@"登录成功 JPush %@ %@",notify.userInfo,notify.object);
    
    [self uploadRegisterId];
}

//收到消息(非APNS)
- (void)notificationForDidReceiveMessageNotification:(NSNotification *)notify
{
    DDLOG(@"收到消息(非APNS) JPush %@ %@",notify.userInfo,notify.object);
    
    NSDictionary *userInfo = _remoteMessageDic;
    
    //直接查看
    
//    NSString *type = userInfo[@"type"];
//    NSString *theme_id = userInfo[@"theme_id"];
}

//错误提示
- (void)notificationForErrorNotification:(NSNotification *)notify
{
    DDLOG(@"错误提示 JPush %@ %@",notify.userInfo,notify.object);

}

#pragma - mark UIAlertViewDelegate <NSObject>

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == kTag_active) {
        
        if (buttonIndex == 1) {
            //查看消息
            
            NSDictionary *userInfo = _remoteMessageDic;
            
            //直接查看
            
            NSString *type = userInfo[@"type"];
            NSString *theme_id = userInfo[@"theme_id"];
            
            [self pushToMessageDetail:[type intValue] detailId:theme_id];
            
        }else
        {
            DDLOG(@"忽略");
        }
    }
}

/**
 *  处理活动推送和抢购推送
 *
 *  @param type     判断消息类型
 *  @param detailId 消息id
 */
- (void)pushToMessageDetail:(int)type
                   detailId:(NSString *)detailId
{
    UITabBarController *root = (UITabBarController *)self.window.rootViewController;
    int selectIndex = (int)root.selectedIndex;
    UINavigationController *unVc = [root.viewControllers objectAtIndex:selectIndex];
    
    NSLog(@"unVc %@",unVc.viewControllers);
    
    int viewsCount = (int)unVc.viewControllers.count;
    
    //添加 和 修改活动
    if (type == 1 || type == 2) {
        //活动页面
        
        HuodongViewController *huodong = [[HuodongViewController alloc]init];
        huodong.huodongId = detailId;
        
        if (viewsCount == 1) {
            huodong.hidesBottomBarWhenPushed = YES;
        }
        [unVc pushViewController:huodong animated:YES];
        
    }else if (type == 3 || type == 4){
        //添加 和 修改 限时抢购或者秒杀
        
        if (detailId.length) {

            ProductDetailViewController *cc = [[ProductDetailViewController alloc]init];
            cc.product_id = detailId;
            if (viewsCount == 1) {
                cc.hidesBottomBarWhenPushed = YES;
            }
            [unVc pushViewController:cc animated:YES];
        }
    }else if (type == 5){ //订单相关推送消息
        
        OrderInfoViewController *orderInfo = [[OrderInfoViewController alloc]init];
        orderInfo.order_id = detailId;
        if (viewsCount == 1) {
            orderInfo.hidesBottomBarWhenPushed = YES;
        }
        [unVc pushViewController:orderInfo animated:YES];
        
    }
}

/**
 *  上传JPush registerId
 */
- (void)uploadRegisterId
{
    NSString *authkey = [GMAPI getAuthkey];
    if (authkey.length == 0) {
        
        return;
    }
    NSString *registration_id = [APService registrationID];
    if (!registration_id || registration_id.length == 0) {
        registration_id = @"JPush";
    }
    
    NSDictionary *params = @{@"authcode":authkey,
                             @"registration_id":registration_id};
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:USER_UPDATE_USEINFO parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        DDLOG(@"更新register_id%@",result);
    } failBlock:^(NSDictionary *result) {
        DDLOG(@"失败register_id%@",result);
    }];
}

@end
