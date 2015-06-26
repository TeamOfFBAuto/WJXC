//
//  ForgetPwdController.m
//  YiYiProject
//
//  Created by lichaowei on 14/12/13.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import "ForgetPwdController.h"


static int seconds = 60;//计时60s

@interface ForgetPwdController ()
{
    NSTimer *timer;
}

@end

@implementation ForgetPwdController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.myTitleLabel.text = @"忘记密码";
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [timer invalidate];
    timer = nil;
}

#pragma mark - 事件处理

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


#pragma mark - 网络请求

- (IBAction)tapToHiddenKeyboard:(id)sender {
    
    [self.passwordTF resignFirstResponder];
    [self.securityTF resignFirstResponder];
    [self.phoneTF resignFirstResponder];
    [self.secondPassword resignFirstResponder];
}


/**
 *  获取验证码
 */
- (IBAction)clickToSecurityCode:(id)sender {
    
    SecurityCode_Type type = SecurityCode_FindPWD;//找回密码
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


- (IBAction)clickToCommit:(id)sender {
    
    
//    get方式调取
//    参数解释依次为:
//    mobile(手机号) string
//    code（验证码）int
//    new_password(新密码) str
    
    
    NSString *password = self.passwordTF.text;
    NSString *secondPassword = self.secondPassword.text;
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
    
    if (![self.passwordTF.text isEqualToString:self.secondPassword.text]) {
        
        [LTools alertText:ALERT_ERRO_SECURITYCODE viewController:self];
        
        return;
    }
    
    if (self.securityTF.text.length != 6) {
        
        [LTools alertText:ALERT_ERRO_SECURITYCODE];
        return;
    }
    
    
    NSString *url = [NSString stringWithFormat:USER_GETBACK_PASSWORD,mobile,code,password,secondPassword];
    
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"result %@ erro %@",result,erro);
        
        [LTools showMBProgressWithText:result[RESULT_INFO] addToView:self.view];
        
        
        [self performSelector:@selector(clickToClose:) withObject:nil afterDelay:1];
        
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        NSLog(@"failDic %@ erro %@",failDic,erro);
        
    }];
    
}

- (void)clickToClose:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
