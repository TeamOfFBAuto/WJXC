//
//  LoginViewController.m
//  OneTheBike
//
//  Created by lichaowei on 14/10/26.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "ForgetPwdController.h"
#import "UserInfo.h"
#import "WXApi.h"
#import "LTools.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([UIApplication sharedApplication].isStatusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
    
    //微信未安装或者不支持
    if (![WXApi isWXAppInstalled] || ![WXApi isWXAppSupportApi]) {
        
        self.thirdLoginView2.hidden = NO;
        self.thirdLoginView.hidden = YES;
    }else
    {
        self.thirdLoginView.hidden = NO;
        self.thirdLoginView2.hidden = YES;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
        
    self.myTitleLabel.text = @"登录";
    self.myTitleLabel.textColor = RGBCOLOR(253, 106, 157);
    self.rightString = @"注册";

    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeNull WithRightButtonType:MyViewControllerRightbuttonTypeText];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 事件处理

- (void)loginResultIsSuccess:(BOOL)isSuccess
{
    if (_aLoginBlock) {
        
        _aLoginBlock(isSuccess);
    }
}

- (void)setLoginBlock:(LoginBlock)aBlock
{
    _aLoginBlock = aBlock;
}

-(void)rightButtonTap:(UIButton *)sender
{
    [self clickToRegister:sender];
}

/**
 *  忘记密码
 */
- (IBAction)clickToForgetPwd:(id)sender {
    
    ForgetPwdController *forget = [[ForgetPwdController alloc]init];
    [self.navigationController pushViewController:forget animated:YES];
}

/**
 *  注册
 */
- (IBAction)clickToRegister:(id)sender {
    
    RegisterViewController *regis = [[RegisterViewController alloc]init];
    [self.navigationController pushViewController:regis animated:YES];
}

/**
 *  正常登录
 */
- (IBAction)clickToNormalLogin:(id)sender {
    
    [self tapToHiddenKeyboard:nil];
    
    if (![LTools isValidateMobile:self.phoneTF.text]) {
        
        [LTools alertText:ALERT_ERRO_PHONE viewController:self];
        return;
    }
    
    if (![LTools isValidatePwd:self.pwdTF.text]) {
        
        [LTools alertText:ALERT_ERRO_PASSWORD viewController:self];
        return;
    }
    
    
    [self loginType:Login_Normal thirdId:nil nickName:nil thirdphoto:nil gender:Gender_Girl password:self.pwdTF.text mobile:self.phoneTF.text];
    
}

-(void)leftButtonTap:(UIButton *)sender
{
    if (self.isSpecial) {
        
        [self.navigationController.view removeFromSuperview];
        [self.navigationController removeFromParentViewController];
        
        return;
    }
    
    [self loginResultIsSuccess:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)clickToSina:(id)sender {
    
    [self loginToPlat:UMShareToSina];
}

- (IBAction)clickToQQ:(id)sender {
    
    [self loginToPlat:UMShareToQQ];
}

- (IBAction)tapToHiddenKeyboard:(id)sender {
    
    [self.phoneTF resignFirstResponder];
    [self.pwdTF resignFirstResponder];
}

- (IBAction)clickToWeiXin:(id)sender {
    //微信
    NSLog(@"微信");
    [self loginToPlat:UMShareToWechatSession];
}


#pragma mark - 授权登录

- (void)loginToPlat:(NSString *)snsPlatName
{
    //此处调用授权的方法,你可以把下面的platformName 替换成 UMShareToSina,UMShareToTencent等
    
    __weak typeof(self)weakSelf = self;
    
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:snsPlatName];
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        NSLog(@"login response is %@",response);
        
        //获取微博用户名、uid、token等
        if (response.responseCode == UMSResponseCodeSuccess) {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:snsPlatName];
            NSLog(@"username is %@, uid is %@, token is %@",snsAccount.userName,snsAccount.usid,[UMSocialAccountManager socialAccountDictionary]);
            
            Login_Type type;
            if ([snsPlatName isEqualToString:UMShareToSina]) {
                type = Login_Sweibo;
            }else if ([snsPlatName isEqualToString:UMShareToQQ]) {
                type = Login_QQ;
            }else if ([snsPlatName isEqualToString:UMShareToWechatSession]) {
                type = Login_Weixin;
            }

            NSLog(@"name %@ photo %@",snsAccount.userName,snsAccount.iconURL);
            [weakSelf loginType:type thirdId:snsAccount.usid nickName:snsAccount.userName thirdphoto:snsAccount.iconURL gender:Gender_Girl password:nil mobile:nil];
        }
        
    });
}

#pragma mark - 事件处理

//清空原先数据
- (void)changeUser:(NSNotification *)notification
{
    
}

#pragma mark - 数据解析

#pragma mark - 网络请求

/**
 *  @param type       (登录方式，normal为正常手机登录，s_weibo、qq、weixin分别代表新浪微博、qq、微信登录) string
 *  @param thirdId    (第三方id，若为第三方登录需要该参数)
 *  @param nickName   (第三方昵称，若为第三方登录需要该参数)
 *  @param thirdphoto (第三方头像，若为第三方登录需要该参数)
 *  @param gender     (性别，若第三方登录可填写，也可不填写，1=》男 2=》女 默认为女) int
 */

- (void)loginType:(Login_Type)loginType
          thirdId:(NSString *)thirdId
             nickName:(NSString *)nickName
       thirdphoto:(NSString *)thirdphoto
           gender:(Gender)gender
         password:(NSString *)password
           mobile:(NSString *)mobile
{
    NSString *type;
    switch (loginType) {
        case Login_Normal:
        {
            type = @"normal";
        }
            break;
        case Login_Sweibo:
        {
            type = @"s_weibo";
        }
            break;
        case Login_QQ:
        {
            type = @"qq";
        }
            break;
        case Login_Weixin:
        {
           type = @"weixin";
        }
            break;
            
        default:
            break;
    }
    
    __weak typeof(self)weakSelf = self;
    
    NSString *token = [LTools cacheForKey:USER_DEVICE_TOKEN];
    
    token = @"test";
    
    
    NSDictionary *params = @{
                             @"type":type,
                             @"mobile":mobile,
                             @"password":password,
                             @"devicetoken":token
                             };
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:USER_LOGIN_ACTION parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSLog(@"%@",result);
        
        
        UserInfo *user = [[UserInfo alloc]initWithDictionary:result];
        
        //保存用户信息
        
        /**
         *  归档的方式保存userInfo
         */
        NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:user];
        
        [[NSUserDefaults standardUserDefaults]setObject:userData forKey:@"userInfo"];
        
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        
        [LTools cache:user.user_name ForKey:USER_NAME];
        [LTools cache:user.uid ForKey:USER_UID];
        [LTools cache:user.authcode ForKey:USER_AUTHOD];
        [LTools cache:user.photo ForKey:USER_HEAD_IMAGEURL];
        
        
        
        //保存登录状态 yes
        
        [LTools cacheBool:YES ForKey:LOGIN_SERVER_STATE];
        
        //        [LTools showMBProgressWithText:result[RESULT_INFO] addToView:self.view];
        
        [SVProgressHUD showInfoWithStatus:result[RESULT_INFO] maskType:SVProgressHUDMaskTypeClear];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_LOGIN object:nil];
        
        [weakSelf performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:0.2];
        
        [weakSelf loginResultIsSuccess:YES];
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"%@",result);
        [weakSelf loginResultIsSuccess:NO];
    }];
    
}


@end
