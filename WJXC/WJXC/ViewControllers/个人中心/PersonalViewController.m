//
//  PersonalViewController.m
//  WJXC
//
//  Created by lichaowei on 15/6/25.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "PersonalViewController.h"
#import "LoginViewController.h"

@interface PersonalViewController ()

@end

@implementation PersonalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"登录" forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(100, 100, 100, 100)];
    btn.backgroundColor = [UIColor orangeColor];
    [btn addTarget:self action:@selector(presentLoginVc) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//跳出登录界面
-(void)presentLoginVc{
    LoginViewController *login = [[LoginViewController alloc]init];
    UINavigationController *unVc = [[UINavigationController alloc]initWithRootViewController:login];
    [self presentViewController:unVc animated:YES completion:nil];
}



@end
