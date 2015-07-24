//
//  PayActionViewController.m
//  WJXC
//
//  Created by lichaowei on 15/7/22.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "PayActionViewController.h"
#import "Order.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApiObject.h"
#import "WXApi.h"

@interface PayActionViewController ()
{
    UIButton *wxButton;//选择微信支付
    UIButton *aliButton;//支付宝支付
}

@end

@implementation PayActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"收银台";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    [self createViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark 网络请求

/**
 *  获取签名信息
 *
 *  @param signType ali 或者 weixin
 */
- (void)getOrderSignWithType:(NSString *)signType
{
    
    NSString *authkey = [GMAPI getAuthkey];

    if ([signType isEqualToString:@"ali"]) {
        
        NSDictionary *params = @{@"authcode":authkey,
                                 @"order_id":self.orderId,
                                 @"sign_type":signType};
        
        __weak typeof(self)weakSelf = self;
        [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:ORDER_GET_SIGN parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
            
            NSLog(@"获取签名信息 %@ %@",result,result[RESULT_INFO]);
            
            NSString *data_str = result[@"data_str"];
            NSString *sign = result[@"sign"];
            
            [weakSelf alipayWithSingString:sign orderDes:data_str];
            
        } failBlock:^(NSDictionary *result) {
            
            NSLog(@"获取签名信息 失败 %@ %@",result,result[RESULT_INFO]);
            
        }];
        
        return;
    }
    
    //微信支付
    
    NSDictionary *params = @{@"authcode":authkey,
                             @"order_id":self.orderId};
    
    __weak typeof(self)weakSelf = self;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:ORDER_CREATE_WEIXIN_ORDER parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSLog(@"获取微信签名信息 %@ %@",result,result[RESULT_INFO]);
        
        NSDictionary *preOrderResult = result[@"pre_order_info"];
        [weakSelf weiXinWithPreOrderInfo:preOrderResult];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"获取微信签名信息 失败 %@ %@",result,result[RESULT_INFO]);
        
    }];
    
}

/**
 *  支付宝支付
 *
 *  @param signString 签名字符串
 *  @param orderDes   未签名描述
 */
- (void)alipayWithSingString:(NSString *)signString
                    orderDes:(NSString *)orderDes
{
    NSLog(@"orderDes = %@ \nsign = %@",orderDes,signString);
    
    //将商品信息拼接成字符串
    NSString *orderSpec = orderDes;
    NSString *signedString = signString;//签名信息
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"com.wjxc.wjxc";
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
            
            /**
             *  支付成功 服务端进行验证签名
             */
            
            //            reslut = {
            //                memo = "";
            //                result = "partner=\"2088911787623114\"&seller_id=\"yjy@alayy.com\"&out_trade_no=\"201507230025\"&subject=\"RNai\U7684\U8ba2\U5355\"&body=\"\U8d2d\U4e70 \U6fb3\U6d32\U5c0f\U867e\U7c73b1\U4efd\"&total_fee=\"0.01\"&notify_url=\"http://182.92.106.193:85/api/order/confirm_order_pay\"&service=\"mobile.securitypay.pay\"&payment_type=\"1\"&_input_charset=\"utf-8\"&it_b_pay=\"30m\"&show_url=\"m.alipay.com\"&success=\"true\"&sign_type=\"RSA\"&sign=\"Djzd2Bh3l3cNwtx1vAcZ0jpR/1hEwrRZu5/23xLhQxZTL0Oj4LitZB5B4qQvDx+KFcWOldq3ffGS+NZzJGzNCNhgt4w5Ebu8qABSZqah8YxWame3d63Bu/z73IqjRE3FLdP3CuiFNRDnlImoI/DEbh7FCe2GXEXYB+DduVoPbUI=\"";
            //                resultStatus = 9000;
            //            }
        }];
        
    }
    
}

/**
 *  支付宝支付
 *
 *  @param signString 签名字符串
 *  @param orderDes   未签名描述
 */
- (void)weiXinWithPreOrderInfo:(NSDictionary *)preOrderInfoResult
{
    NSDictionary *dict = preOrderInfoResult;
    
    //调起微信支付
    PayReq* req             = [[PayReq alloc] init];
    req.openID              = [dict objectForKey:@"appid"];
    req.partnerId           = [dict objectForKey:@"partnerid"];
    req.prepayId            = [dict objectForKey:@"prepayid"];
    req.nonceStr            = [dict objectForKey:@"noncestr"];
    req.timeStamp           = [[dict objectForKey:@"timestamp"] intValue];
    req.package             = [dict objectForKey:@"package"];
    req.sign                = [dict objectForKey:@"sign"];
    [WXApi sendReq:req];
    
    //日志输出
    NSLog(@"\nappid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",req.openID,req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );

}



#pragma - mark 创建视图

- (void)createViews
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 60)];
    headerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headerView];
    
    NSString *title = [NSString stringWithFormat:@"订单编号:%@",self.orderNum];
    //订单编号
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH - 20, 30) title:title font:13 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"636363"]];
    [headerView addSubview:label];
    
    NSString *title2 = [NSString stringWithFormat:@"支付金额:%.2f元",self.sumPrice];
    //支付金额
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(10, label.bottom, label.width, label.height) title:title2 font:13 align:NSTextAlignmentLeft textColor:DEFAULT_TEXTCOLOR];
    [headerView addSubview:label2];
    
    //支付方式
    
    UIView *secondView = [[UIView alloc]initWithFrame:CGRectMake(0, headerView.bottom + 5, DEVICE_WIDTH, 140)];
    secondView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:secondView];
    
    //支付方式
    UILabel *payStyleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH - 20, 33) title:@"支付方式:" font:13 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"636363"]];
    [secondView addSubview:payStyleLabel];
    
    //线
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, payStyleLabel.bottom, DEVICE_WIDTH, 0.5)];
    line1.backgroundColor = DEFAULT_LINECOLOR;
    [secondView addSubview:line1];
    
    //支付宝
    //图标
    
    UIImageView *alipayIcon = [[UIImageView alloc]initWithFrame:CGRectMake(10, line1.bottom + 10, 32, 32)];
    alipayIcon.image = [UIImage imageNamed:@"my_zhifubao"];
    [secondView addSubview:alipayIcon];
    
    UILabel *aliLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(alipayIcon.right + 10, line1.bottom + 12, 100, 16) title:@"支付宝支付" font:13 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"636363"]];
    [secondView addSubview:aliLabel1];
    
    UILabel *aliLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(aliLabel1.left, aliLabel1.bottom, 100, 16) title:@"支付宝快捷支付" font:11 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"636363"]];
    [secondView addSubview:aliLabel2];
    
    aliButton = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - 50, line1.bottom, 50, 50) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"shopping cart_normal"] selectedImage:[UIImage imageNamed:@"shopping cart_selected"] target:self action:@selector(clickToSelectStyle:)];
    [secondView addSubview:aliButton];
    
    //默认选择支付宝支付
    
    aliButton.selected = YES;
    
    //线
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, aliButton.bottom, DEVICE_WIDTH, 0.5)];
    line2.backgroundColor = DEFAULT_LINECOLOR;
    [secondView addSubview:line2];
    
    //微信支付
    //图标
    
    UIImageView *wxpayIcon = [[UIImageView alloc]initWithFrame:CGRectMake(10, line2.bottom + 10, 32, 32)];
    wxpayIcon.image = [UIImage imageNamed:@"my_weixin"];
    [secondView addSubview:wxpayIcon];
    
    UILabel *wxLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(wxpayIcon.right + 10, line2.bottom + 12, 100, 16) title:@"微信支付" font:13 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"636363"]];
    [secondView addSubview:wxLabel1];
    
    UILabel *wxLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(wxLabel1.left, wxLabel1.bottom, 100, 16) title:@"微信安全支付" font:11 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"636363"]];
    [secondView addSubview:wxLabel2];
    
    wxButton = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - 50, line2.bottom, 50, 50) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"shopping cart_normal"] selectedImage:[UIImage imageNamed:@"shopping cart_selected"] target:self action:@selector(clickToSelectStyle:)];
    [secondView addSubview:wxButton];
    
    
    //立即支付按钮
    UIButton *payButton = [[UIButton alloc]initWithframe:CGRectMake(10, secondView.bottom + 30, DEVICE_WIDTH - 20, 33) buttonType:UIButtonTypeRoundedRect normalTitle:@"立即支付" selectedTitle:nil target:self action:@selector(clickToPay:)];
    [self.view addSubview:payButton];
    payButton.backgroundColor = DEFAULT_TEXTCOLOR;
    [payButton addCornerRadius:5.f];
    [payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

#pragma - mark 事件处理

/**
 *  支付成功
 */
- (void)paySuccessAction
{
    //更新购物车
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_UPDATE_TO_CART object:nil];
}

- (UIButton *)buttonForTag:(NSInteger)tag
{
    return (UIButton *)[self.view viewWithTag:tag];
}

- (void)clickToSelectStyle:(UIButton *)sender
{
    aliButton.selected = sender == aliButton ? YES : NO;
    wxButton.selected = !aliButton.selected;
}

/**
 *  立即支付 -- 根据选择支付方式去启动不同支付
 *
 *  @param sender
 */
- (void)clickToPay:(UIButton *)sender
{
    if (aliButton.selected) {
        
        NSLog(@"支付宝支付");
        
        [self getOrderSignWithType:@"ali"];
        
    }else if (wxButton.selected){
        NSLog(@"微信支付");
        
        [self getOrderSignWithType:@"weixin"];
    }
}

@end
