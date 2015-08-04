//
//  PayResultViewController.m
//  WJXC
//
//  Created by lichaowei on 15/7/24.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "PayResultViewController.h"
#import "OrderInfoViewController.h"

@interface PayResultViewController ()

@end

@implementation PayResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"支付结果";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.isPaySuccess) {
        
        //成功
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((DEVICE_WIDTH - 141) / 2.f, 50, 104, 24)];
        imageView.image = [UIImage imageNamed:@"my_paySuccess"];
        [self.view addSubview:imageView];
        imageView.centerX = DEVICE_WIDTH / 2.f;
        
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, imageView.bottom + 28, DEVICE_WIDTH, 14) title:nil font:13 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"959595"]];
        [self.view addSubview:label1];
        NSString *price = [NSString stringWithFormat:@"%.2f",self.sumPrice];
        NSString *text = [NSString stringWithFormat:@"您成功付款%@元",price];
        NSAttributedString *string = [LTools attributedString:text keyword:price color:[UIColor orangeColor]];
        [label1 setAttributedText:string];
        
        text = [NSString stringWithFormat:@"订单编号:%@",self.orderNum];
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, label1.bottom + 7, DEVICE_WIDTH, 14) title:text font:13 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"959595"]];
        [self.view addSubview:label2];
        
        CGFloat btnWith = (DEVICE_WIDTH - 74 - 20) / 2.f;
        
        //查看订单
        UIButton *btn1 = [[UIButton alloc]initWithframe:CGRectMake(46, label2.bottom + 30, btnWith, 33) buttonType:UIButtonTypeCustom normalTitle:@"查看订单" selectedTitle:nil target:self action:@selector(clickToSeeOrderInfo:)];
        [self.view addSubview:btn1];
        [btn1 addCornerRadius:5.f];
        [btn1 setBorderWidth:0.5 borderColor:DEFAULT_TEXTCOLOR];
        [btn1.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [btn1 setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
        
        //继续购买
        UIButton *btn2 = [[UIButton alloc]initWithframe:CGRectMake(btn1.right + 20, label2.bottom + 30, btnWith, 33) buttonType:UIButtonTypeCustom normalTitle:@"继续购买" selectedTitle:nil target:self action:@selector(clickToGoShopping:)];
        [self.view addSubview:btn2];
        [btn2 addCornerRadius:5.f];
        [btn2 setBorderWidth:0.5 borderColor:[UIColor orangeColor]];
        [btn2.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [btn2 setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    }else
    {
        //失败
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((DEVICE_WIDTH - 141) / 2.f, 50, 104, 24)];
        imageView.image = [UIImage imageNamed:@"my_payFail"];
        [self.view addSubview:imageView];
        imageView.centerX = DEVICE_WIDTH / 2.f;
        
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, imageView.bottom + 28, DEVICE_WIDTH, 14) title:nil font:13 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"959595"]];
        [self.view addSubview:label1];
        NSString *text = [NSString stringWithFormat:@"%@",self.erroInfo];
        label1.text = text;
        
        CGFloat btnWith = (DEVICE_WIDTH - 74 - 20) / 2.f;
        
        //查看订单
        UIButton *btn1 = [[UIButton alloc]initWithframe:CGRectMake(46, label1.bottom + 30, btnWith, 33) buttonType:UIButtonTypeCustom normalTitle:@"查看订单" selectedTitle:nil target:self action:@selector(clickToSeeOrderInfo:)];
        [self.view addSubview:btn1];
        [btn1 addCornerRadius:5.f];
        [btn1 setBorderWidth:0.5 borderColor:DEFAULT_TEXTCOLOR];
        [btn1.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [btn1 setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
        
        //继续购买
        UIButton *btn2 = [[UIButton alloc]initWithframe:CGRectMake(btn1.right + 20, label1.bottom + 30, btnWith, 33) buttonType:UIButtonTypeCustom normalTitle:@"继续购买" selectedTitle:nil target:self action:@selector(clickToGoShopping:)];
        [self.view addSubview:btn2];
        [btn2 addCornerRadius:5.f];
        [btn2 setBorderWidth:0.5 borderColor:[UIColor orangeColor]];
        [btn2.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [btn2 setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBarHidden = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //在navigationController中移除 确认订单viewController
    
    //确认订单之后到支付页面,这时候不能再返回到确认订单页面
    
    NSArray *vcArray = self.navigationController.viewControllers;
    
    for (UIViewController *viewController in vcArray) {
        
        if ([viewController isKindOfClass:NSClassFromString(@"PayActionViewController")]) {
            
            [viewController removeFromParentViewController];
        }
    }
    
}

#pragma - mark 事件处理
/**
 *  查看订单
 *
 *  @param sender
 */
- (void)clickToSeeOrderInfo:(UIButton *)sender
{
    OrderInfoViewController *orderInfo = [[OrderInfoViewController alloc]init];
    orderInfo.order_id = self.orderId;
    [self.navigationController pushViewController:orderInfo animated:YES];
}

/**
 *  继续购买
 *
 *  @param sender
 */
- (void)clickToGoShopping:(UIButton *)sender
{
    [self.navigationController popToRootViewControllerAnimated:NO];

    UITabBarController *root = ROOTVIEWCONTROLLER;
    
    root.selectedIndex = 1;
}

@end
