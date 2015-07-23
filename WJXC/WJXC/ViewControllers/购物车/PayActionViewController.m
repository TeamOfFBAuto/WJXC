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
    NSString *partner = Alipay_PartnerID;
    NSString *seller = Alipay_SellerID; //支付宝收款账号
    NSString *privateKey = Alipay_PartnerPrivKey;//商户方私钥
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
    order.paymentType = @"1";//支付类型 默认1 商品购买
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
    
    
    /**
     *  服务端生成订单信息
     */
    
    NSString *signedString = @"";//签名信息
    
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
            
        }];
        
    }
    
}


@end
