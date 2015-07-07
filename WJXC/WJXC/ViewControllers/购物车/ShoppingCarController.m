//
//  ShoppingCarController.m
//  WJXC
//
//  Created by lichaowei on 15/6/25.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "ShoppingCarController.h"
#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"

@interface ShoppingCarController ()

@end

@implementation ShoppingCarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"购物车";
    
    UIButton *btn = [[UIButton alloc]initWithframe:CGRectMake(100, 200, 100, 50) buttonType:UIButtonTypeCustom normalTitle:@"结算" selectedTitle:nil target:self action:@selector(clickToOrder:)];
    btn.backgroundColor = [UIColor orangeColor];
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
    /*
     *点击获取prodcut实例并初始化订单信息
     */
//    Product *product = [self.productList objectAtIndex:indexPath.row];
    
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */
    
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *partner = @"111111";
    NSString *seller = @"22222";
    NSString *privateKey = @"333333";
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSString *productName = @"单品name";
    NSString *productDescription = @"描述";
    NSString *price = @"0.01";//商品价格
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = @"123456789"; //订单ID（由商家自行制定）
    order.productName = productName; //商品标题
    order.productDescription = productDescription; //商品描述
    order.amount = price; //商品价格
    order.notifyURL =  @"http://www.alayy.com"; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"com.wjxc.wjxc";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    

    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    //id<DataSigner> signer = CreateRSADataSigner(privateKey);
    //NSString *signedString = [signer signString:orderSpec];
    
    
    NSString *signedString = @"";//签名信息
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
            
            
            
        }];
        
    }

}

@end
