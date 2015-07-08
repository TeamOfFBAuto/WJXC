//
//  UpdatePWDController.m
//  WJXC
//
//  Created by lichaowei on 15/7/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "UpdatePWDController.h"

@interface UpdatePWDController ()

@end

@implementation UpdatePWDController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"修改密码";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    NSArray *titles = @[@"当前密码",@"新密码",@"确认新密码"];
    CGFloat top = 0.f;
    for (int i = 0; i < titles.count; i ++) {
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 20 + 65 * i, 100, 15)];
        titleLabel.text = titles[i];
        titleLabel.font = [UIFont systemFontOfSize:14.f];
        titleLabel.textColor = [UIColor colorWithHexString:@"323232"];
        [self.view addSubview:titleLabel];
        
        UITextField *tf = [[UITextField alloc]initWithFrame:CGRectMake(10, titleLabel.bottom + 15, DEVICE_WIDTH - 20, 28)];
        [self.view addSubview:tf];
        tf.secureTextEntry = YES;
        tf.tag = 100 + i;
        
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(tf.left - 2, tf.bottom - 10, tf.width + 4, 10)];
        [self.view addSubview:line];
        if (i == 0) {
            line.image = [UIImage imageNamed:@"my_password_line_green"];
        }else
        {
            line.image = [UIImage imageNamed:@"my_password_line_gray"];
        }
        
        top = tf.bottom;
    }
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, top + 10, DEVICE_WIDTH - 20, 15) title:@"密码长度至少6个字符,最多32个字符" font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"646464"]];
    [self.view addSubview:label];
    
    UIButton *sureButton = [[UIButton alloc]initWithframe:CGRectMake(10, label.bottom + 20, DEVICE_WIDTH - 20, 40) buttonType:UIButtonTypeCustom normalTitle:@"确认" selectedTitle:nil target:self action:@selector(clickToSure:)];
    [sureButton addCornerRadius:3.f];
    sureButton.backgroundColor = DEFAULT_TEXTCOLOR;
    [self.view addSubview:sureButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITextField *)textFieldForTag:(int)tag
{
    return (UITextField *)[self.view viewWithTag:tag];
}

#pragma - mark 事件处理

- (void)clickToSure:(UIButton *)sender
{
    NSString *password = [self textFieldForTag:100].text;//老密码
    NSString *newPWD = [self textFieldForTag:101].text;//新密码
    NSString *newPWD_second = [self textFieldForTag:102].text;//新密码确认


    if (![LTools isValidatePwd:password]) {
        
        [LTools alertText:ALERT_ERRO_PASSWORD viewController:self];
        return;
    }
    
    if (newPWD.length == 0) {

        [LTools alertText:@"新密码不能为空" viewController:self];
        return;
    }
    
    if (![LTools isValidatePwd:newPWD]) {
        
        [LTools alertText:@"新密码格式有误,请输入6~32位英文字母或数字" viewController:self];
        return;
    }
    
    if ([password isEqualToString:newPWD]) {
        
        [LTools alertText:@"新密码不能与旧密码一致" viewController:self];
        return;
    }
    
    if (![newPWD isEqualToString:newPWD_second]) {
        
        [LTools alertText:@"请确认新密码两次输入一致" viewController:self];
        
        return;
    }
    
    //同步服务器
    [self updatePassWord:newPWD confirmPassword:newPWD_second oldPwd:password];
}

/**
 *  更新密码
 *
 *  @param password        新密码
 *  @param passwordConfirm 新密码确认
 *  @param oldPwd          老密码
 */
- (void)updatePassWord:(NSString *)password
       confirmPassword:(NSString *)passwordConfirm
                oldPwd:(NSString *)oldPwd
{
    NSString *authcode = [LTools cacheForKey:USER_AUTHOD];
    if (!authcode || authcode.length == 0) {
        
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary *params = @{@"authcode":[LTools cacheForKey:USER_AUTHOD],
                             @"new_password":password,
                             @"confirm_password":passwordConfirm,
                             @"old_password":oldPwd};
    
    __weak typeof(self)weakSelf = self;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:USER_UPDATE_PASSWORD parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSLog(@"result %@ %@",result[Erro_Info],result);
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        int errorcode = [result[Erro_Code]intValue];
        if (errorcode == 0) {
            
            //修改成功
            
            [LTools showMBProgressWithText:result[Erro_Info] addToView:weakSelf.view];
            
            [weakSelf cleanUserInfo];

        }
        
    } failBlock:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];

        NSLog(@"result %@",result[Erro_Info]);
        
    }];
}

-(void)leftButtonTap:(UIButton *)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/**
 *  退出登录清空用户信息
 */
- (void)cleanUserInfo
{
    /**
     *  归档的方式保存userInfo
     */
    
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"userInfo"];
    
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    
    [LTools cache:nil ForKey:USER_NAME];
    [LTools cache:nil ForKey:USER_UID];
    [LTools cache:nil ForKey:USER_AUTHOD];
    [LTools cache:nil ForKey:USER_HEAD_IMAGEURL];
    
    //保存登录状态 yes
    
    [LTools cacheBool:NO ForKey:LOGIN_SERVER_STATE];
    
    /**
     *  退出登录通知
     */
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_LOGOUT object:nil];
    
    [self performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:0.5];
}
@end
