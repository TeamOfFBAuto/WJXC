//
//  GRegisterViewController.h
//  WJXC
//
//  Created by gaomeng on 15/7/7.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

//注册

#import "MyViewController.h"

@interface GRegisterViewController : MyViewController

@property(nonatomic,strong)UIView *upThreeStepView;//上面三个步骤的view

@property(nonatomic,strong)UIView *downInfoView;//下方填写信息view

@property(nonatomic,strong)UITextField *phoneTF;//手机号

@property(nonatomic,strong)UITextField *yanzhengmaTf;//验证码

@property(nonatomic,strong)UITextField *mimaTf;//密码

@property(nonatomic,strong)UITextField *mima2Tf;//重复密码

@end
