//
//  ShoppingCarController.m
//  WJXC
//
//  Created by lichaowei on 15/6/25.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "ShoppingCarController.h"
#import <AlipaySDK/AlipaySDK.h>

@interface ShoppingCarController ()

@end

@implementation ShoppingCarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *btn = [[UIButton alloc]initWithframe:CGRectMake(100, 200, 100, 50) buttonType:UIButtonTypeCustom normalTitle:@"结算" selectedTitle:nil target:self action:@selector(clickToOrder:)];
    [self.view addSubview:btn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark 事件处理

/**
 *  点击生成订单支付
 *
 *  @param sender
 */
- (void)clickToOrder:(UIButton *)sender
{
    
}

@end
