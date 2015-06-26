//
//  RegisterViewController.m
//  YiYiProject
//
//  Created by lichaowei on 14/12/13.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import "RegisterViewController.h"

static int seconds = 60;//计时60s

@interface RegisterViewController ()
{
    NSTimer *timer;
}

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.myTitleLabel.text = @"注册";
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
}

- (void)dealloc
{
    [timer invalidate];
    timer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 网络请求

#pragma mark - 事件处理 

- (void)startTimer
{
    [self.codeButton setTitle:@"" forState:UIControlStateNormal];
    
    self.codeLabel.hidden = NO;
    
    seconds = 60;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(calculateTime) userInfo:Nil repeats:YES];
    _codeButton.userInteractionEnabled = NO;
}

//计算时间
- (void)calculateTime
{
    NSString *title = [NSString stringWithFormat:@"%d秒",seconds];
    
    self.codeLabel.text = title;
    
    if (seconds != 0) {
        seconds --;
    }else
    {
        [self renewTimer];
    }
    
}
//计时器归零
- (void)renewTimer
{
    [timer invalidate];//计时器停止
    _codeButton.userInteractionEnabled = YES;
    [_codeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    _codeLabel.hidden = YES;
    seconds = 60;
}

- (IBAction)clickToClose:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

/**
 *  获取验证码
 */
- (IBAction)clickToSecurityCode:(UIButton *)sender {
    
//    get方式调取
//    参数解释依次为:
//    mobile(手机号) string
//    type(验证码用途 1=》注册 2=》商店短信验证 3=》找回密码 4⇒申请成为搭配师获取验证码 默认为1) int
//    返回:
//    {“errorcode”:0,“msg”:“\u5e97\u94fa\u521b\u5efa\u6210\u529f”,'code':123456} errorcode 0 成功 1失败 msg为失败或成功文案
    
    
    [self tapToHiddenKeyboard:nil];
    
    SecurityCode_Type type;//默认注册
    type = 1;
    
    NSString *mobile = self.phoneTF.text;
    
    if (![LTools isValidateMobile:mobile]) {
        
        [LTools alertText:ALERT_ERRO_PHONE viewController:self];
        return;
    }
    
     [self startTimer];
    
    __weak typeof(self)weakSelf = self;
    
    NSString *url = [NSString stringWithFormat:USER_GET_SECURITY_CODE,mobile,type,[LTools md5Phone:mobile]];
    
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"result %@ erro %@",result,erro);
        
        [LTools showMBProgressWithText:result[RESULT_INFO] addToView:self.view];

        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        NSLog(@"failDic %@ erro %@",failDic,erro);
        
        [weakSelf renewTimer];
        
    }];

}

/**
 *  注册
 */
- (IBAction)clickToRegister:(id)sender {
    
    //    get方式调取
    //    参数解释依次为:
    //    username(昵称,可不填，系统自动分配一个) string
    //    password（密码，必须大于等于6位，不能有中文）string
    //    gender(性别，1=》男 2=》女，可不填，默认为女) int
    //    type(注册类型，1=》手机注册 2=》邮箱注册，默认为手机注册) int
    //    code(验证码 6位数字) int
    //    mobile(手机号) string
    
    [self tapToHiddenKeyboard:nil];
    
    NSString *userName = @"";
    NSString *password = self.passwordTF.text;
    Gender sex = Gender_Girl;//默认女
    Register_Type type = Register_Phone;//默认手机号方式
    int code = [self.securityTF.text intValue];
    NSString *mobile = self.phoneTF.text;
    
    if (![LTools isValidateMobile:mobile]) {
        
        [LTools alertText:ALERT_ERRO_PHONE viewController:self];
        return;
    }
    
    if (![LTools isValidatePwd:password]) {
        
        [LTools alertText:ALERT_ERRO_PASSWORD viewController:self];
        return;
    }
    if (self.securityTF.text.length != 6) {
        
        [LTools alertText:ALERT_ERRO_SECURITYCODE viewController:self];
        return;
    }
    
    
    NSString *url = [NSString stringWithFormat:USER_REGISTER_ACTION,userName,password,sex,type,code,mobile];
    
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"result %@ erro %@",result,erro);
        
        [LTools showMBProgressWithText:result[RESULT_INFO] addToView:self.view];
        
        [self performSelector:@selector(clickToClose:) withObject:nil afterDelay:0.2];
        
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        NSLog(@"failDic %@ erro %@",failDic,erro);
        
    }];

}

- (IBAction)tapToHiddenKeyboard:(id)sender {
    
    [self.passwordTF resignFirstResponder];
    [self.securityTF resignFirstResponder];
    [self.phoneTF resignFirstResponder];
}

#pragma mark - 创建视图

#pragma mark - 代理

@end
