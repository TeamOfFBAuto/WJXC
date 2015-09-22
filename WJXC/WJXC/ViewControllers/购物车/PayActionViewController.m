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
#import "PayResultViewController.h"
#import "OrderInfoViewController.h"

@interface PayActionViewController ()
{
    UIButton *wxButton;//选择微信支付
    UIButton *aliButton;//支付宝支付
    int _validateTime;//验证支付次数
    NSTimer *_validateTimer;//计时器
    MBProgressHUD *_loading;
}

@end

@implementation PayActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"收银台";
    self.rightString = @"查看订单";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeText];
    
    [self createViews];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForWxPay:) name:NOTIFICATION_PAY_WEIXIN_RESULT object:nil];
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
        
        if ([viewController isKindOfClass:NSClassFromString(@"ConfirmOrderController")]) {
            
            [viewController removeFromParentViewController];
        }
    }
    
}

#pragma - mark 通知处理

//微信支付通知
- (void)notificationForWxPay:(NSNotification *)notify
{
    BOOL result = [[notify.userInfo objectForKey:@"result"]boolValue];
    
    NSString *erroInfo = [notify.userInfo objectForKey:@"erroInfo"];
    if (result) {
        
        NSLog(@"微信支付成功");
        
        [self isPayValidate];
        
    }else
    {
        [self payResultSuccess:NO erroInfo:erroInfo];
    }
}

#pragma - mark 网络请求

/**
 *  验证订单支付结果，间隔5s,10次 报错的话就提示支付失败
 */
- (void)isPayValidate
{
    if (!_loading) {
        _loading = [LTools MBProgressWithText:@"支付结果确认中..." addToView:self.view];
    }

    [_loading show:YES];
    _validateTime = 10;//十次
    _validateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(networkForPayValidate) userInfo:nil repeats:YES];
}

- (void)stopTimer
{
    [_loading hide:YES];
    [_validateTimer invalidate];//干掉
    _validateTimer = nil;
    
    NSLog(@"停止计时");

}

- (void)networkForPayValidate
{
    if (_validateTime == 0) {
        
        [self stopTimer];
        
        return;
    }
    
    NSString *authkey = [GMAPI getAuthkey];
    NSDictionary *params = @{@"authcode":authkey,
                             @"order_id":self.orderId};
    __weak typeof(self)weakSelf = self;
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:ORDER_GET_ORDER_PAY parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"result %@",result);
        
        [weakSelf stopTimer];
        
        int pay = [result[@"pay"]intValue];
        if (pay == 1) {
            
            [weakSelf payResultSuccess:YES erroInfo:nil];
        }else
        {
            [weakSelf payResultSuccess:NO erroInfo:result[Erro_Info]];
        }
        
    } failBlock:^(NSDictionary *result) {
        NSLog(@"result fail %@",result);
        
        _validateTime --;
    }];
}



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
        
        if ([signType isEqualToString:@"ali"]) {
            
            NSString *data_str = result[@"data_str"];
            NSString *sign = result[@"sign"];
            
            [weakSelf alipayWithSingString:sign orderDes:data_str];
            
        }else if ([signType isEqualToString:@"weixin"]){
            
            NSDictionary *preOrderResult = result[@"pre_order_info"];
            [weakSelf weiXinWithPreOrderInfo:preOrderResult];
        }
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"获取签名信息 失败 %@ %@",result,result[RESULT_INFO]);
        
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
        
        __weak typeof(self)weakSelf = self;
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
            
            int resultStatus = [resultDic[@"resultStatus"]intValue];
            if (resultStatus == 9000) {
                
                //成功
                /**
                *  支付成功 服务端进行验证签名
                */
                
                NSLog(@"暂时未验证签名 支付成功");
                
                [weakSelf isPayValidate];
                
            }else
            {
                NSLog(@"支付失败");
                
                [weakSelf payResultSuccess:NO erroInfo:@"中途取消支付或者网络连接错误"];
//                8000
//                正在处理中
//                4000
//                订单支付失败
//                6001
//                用户中途取消
//                6002
//                网络连接出错
            }
            
        }];
        
    }
    
}

/**
 *  微信支付
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
    
    
    //默认选择支付宝支付
    
    if (self.payStyle == 2) {
        
        wxButton.selected = YES;
    }else
    {
        aliButton.selected = YES;
    }
    
    
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
- (void)payResultSuccess:(PAY_RESULT_TYPE)result
                erroInfo:(NSString *)erroInfo
{
    //更新购物车
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_UPDATE_TO_CART object:nil];
    
    //支付成功通知
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_PAY_SUCCESS object:nil];

//    PayResultViewController *result = [[PayResultViewController alloc]init];
//    result.orderId = self.orderId;
//    result.orderNum = self.orderNum;
//    result.sumPrice = self.sumPrice;
//    result.isPaySuccess = success;
//    result.erroInfo = erroInfo;
//    result.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:result animated:YES];
}

/**
 *  查看订单
 *
 *  @param sender
 */
-(void)rightButtonTap:(UIButton *)sender
{
    NSLog(@"查看订单");
    OrderInfoViewController *orderInfo = [[OrderInfoViewController alloc]init];
    orderInfo.order_id = self.orderId;
    [self.navigationController pushViewController:orderInfo animated:YES];
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
    
//    [self payResultSuccess:NO erroInfo:@"支付失败错误信息"];
////    [self isPayValidate];
//    return;
    
    
    if (aliButton.selected) {
        
        NSLog(@"支付宝支付");
        
        [self getOrderSignWithType:@"ali"];
        
    }else if (wxButton.selected){
        NSLog(@"微信支付");
        
        [self getOrderSignWithType:@"weixin"];
    }
}

@end
