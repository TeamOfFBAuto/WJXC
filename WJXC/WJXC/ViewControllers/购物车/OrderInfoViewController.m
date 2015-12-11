//
//  OrderInfoViewController.m
//  WJXC
//
//  Created by lichaowei on 15/7/25.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "OrderInfoViewController.h"
#import "SelectCell.h"
#import "ProductCell.h"
#import "ConfirmInfoCell.h"
#import "ShoppingAddressController.h"//收货地址
#import "AddressModel.h"
#import "ProductModel.h"
#import "FBActionSheet.h"
#import "PayActionViewController.h"//支付页面

#import "RCDChatViewController.h"
#import "ConfirmOrderController.h"//确认订单
#import "AddCommentViewController.h"//评价晒图
#import "ProductDetailViewController.h"//订单详情
#import "TuiKuanViewController.h"//退款

#import "OrderModel.h"
#import "OrderOtherInfoCell.h"
#import "CouponModel.h"

#define ALIPAY @"支付宝支付"
#define WXPAY  @"微信支付"

#define ALERT_TAG_PHONE 100 //拨打电话
#define ALERT_TAG_CANCEL_ORDER 101 //取消订单
#define ALERT_TAG_DEL_ORDER 102 //删除订单
#define ALERT_TAG_RECIEVER_CONFIRM 103 //确认收货
#define ALERT_TAG_Delay_OK 104 //可以延长收货


@interface OrderInfoViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_table;
    NSArray *_titles;
    NSArray *_titlesSub;
    UITextField *_inputTf;//备注
    NSString *_selectAddressId;//选中的地址
    
    UIImageView *_nameIcon;//名字icon
    
    UILabel *_nameLabel;//收货人name
    UILabel *_phoneLabel;//收货人电话
    UILabel *_addressLabel;//收货地址
    UIImageView *_phoneIcon;//电话icon
    
    NSString *_payStyle;//支付类型
    
    UILabel *_priceLabel;//邮费加产品价格
    
    MBProgressHUD *_loading;//加载
    
    UILabel *_addressHintLabel;//收货地址提示
    OrderModel *_orderModel;//订单model
    
    NSArray *_couponList;//优惠劵列表
    CouponModel *_selectCoupon;//选中的优惠劵
}

@end

@implementation OrderInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"订单详情";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    _titles = @[@"商品清单",@"备注信息",@"优惠劵",@"价格清单"];

    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    _table.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    
    [self getOrderInfo];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.navigationController.navigationBarHidden = YES;
//    self.navigationController.navigationBarHidden = NO;
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 网络请求

/**
 *  切换购物地址时 更新邮费
 */
- (void)getOrderInfo
{
    NSString *authkey = [GMAPI getAuthkey];

    if ([self.order_id intValue] == 0) {
        
        [LTools showMBProgressWithText:@"查看订单无效" addToView:self.view];
        return;
    }
    
    NSDictionary *params = @{@"authcode":authkey,
                             @"order_id":self.order_id,
                             @"detail":[NSNumber numberWithInt:1]};
    
//    __weak typeof(_table)weakTable = _table;
    __weak typeof(self)weakSelf = self;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:ORDER_GET_ORDER_INFO parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSLog(@"获取订单详情%@ %@",result[RESULT_INFO],result);
        NSDictionary *info = result[@"info"];
        OrderModel *aModel = [[OrderModel alloc]initWithDictionary:info];
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:aModel.coupons.count];
        for (NSDictionary *aDic in aModel.coupons) {
            CouponModel *c_model = [[CouponModel alloc]initWithDictionary:aDic];
            [temp addObject:c_model];
        }
        aModel.couponsList = [NSArray arrayWithArray:temp];//订单使用的优惠券
        [weakSelf setViewsWithModel:aModel];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"获取订单详情 失败 %@",result[RESULT_INFO]);
        
    }];
    
}

#pragma mark - 事件处理

/**
 *  再次购买
 *
 *  @param sender
 */
- (void)buyAgain:(OrderModel *)order
{
    //先返回购物车,然后
    
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:order.products.count];
    for (NSDictionary *aDic in order.products) {
        
        ProductModel *aModel = [[ProductModel alloc]initWithDictionary:aDic];
        [temp addObject:aModel];
    }
    NSArray *productArr = temp;
    ConfirmOrderController *confirm = [[ConfirmOrderController alloc]init];
    confirm.productArray = productArr;
    confirm.sumPrice = [order.total_fee floatValue];
    [self.navigationController pushViewController:confirm animated:YES];
    
}


/**
 *  事件处理
 *
 *  @param sender
 */
- (void)clickToAction:(UIButton *)sender
{
    NSString *text = sender.titleLabel.text;
    NSLog(@"text %@",text);
    
    if ([text isEqualToString:@"去支付"]) {
        
        //去支付
        [self pushToPayPageWithOrderId:_orderModel.order_id orderNum:_orderModel.order_no];
        
    }else if ([text isEqualToString:@"取消订单"]){
        
        NSString *msg = [NSString stringWithFormat:@"是否确定取消订单"];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = ALERT_TAG_CANCEL_ORDER;
        [alert show];
        
    }else if ([text isEqualToString:@"确认收货"]){
        
        NSString *msg = [NSString stringWithFormat:@"收货成功之后再确定,避免不必要损失!"];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"确认收货" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = ALERT_TAG_RECIEVER_CONFIRM;
        [alert show];
        
    }else if ([text isEqualToString:@"延长收货"]){
        
        //延长收货
        OrderModel *aModel = _orderModel;
        if ([aModel.show_delay_receive intValue] == 0) {
            
            NSString *msg = [NSString stringWithFormat:@"您已进行延长收货操作"];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"延长收货" message:msg delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alert show];
        }else
        {
            NSString *msg = [NSString stringWithFormat:@"订单只能延长收货一次"];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"延长收货" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = ALERT_TAG_Delay_OK;
            [alert show];
        }
        
    }else if ([text isEqualToString:@"再次购买"]){
        
        //再次购买通知
        [self buyAgain:_orderModel];
        
    }else if ([text isEqualToString:@"删除订单"]){
        
        NSString *msg = [NSString stringWithFormat:@"是否确定删除订单"];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = ALERT_TAG_DEL_ORDER;
        [alert show];
        
    }else if ([text isEqualToString:@"评价晒图"]){
        
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:_orderModel.products.count];
        for (NSDictionary *aDic in _orderModel.products) {
            
            ProductModel *aModel = [[ProductModel alloc]initWithDictionary:aDic];
//            aModel.is_recommend
            [temp addObject:aModel];
        }
        AddCommentViewController *addComment = [[AddCommentViewController alloc]init];
        addComment.dingdanhao = _orderModel.order_no;
        addComment.theModelArray = temp;
        [self.navigationController pushViewController:addComment animated:YES];
        
    }else if ([text isEqualToString:@"申请退款"]){
        
        //退款
        OrderModel *aModel = _orderModel;
        TuiKuanViewController *tuiKuan = [[TuiKuanViewController alloc]init];
        tuiKuan.tuiKuanPrice = [aModel.total_fee floatValue];
        tuiKuan.orderId = aModel.order_id;
        tuiKuan.lastVc = self;
        [self.navigationController pushViewController:tuiKuan animated:YES];
    }
}

/**
 *  跳转至支付页面
 */
- (void)pushToPayPageWithOrderId:(NSString *)orderId
                        orderNum:(NSString *)orderNum
{
    PayActionViewController *pay = [[PayActionViewController alloc]init];
    pay.orderId = orderId;
    pay.orderNum = orderNum;
    pay.sumPrice = [_orderModel.total_fee floatValue];
    pay.payStyle = [_orderModel.pay_type intValue];//支付类型
    pay.lastVc = self;
    pay.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:pay animated:YES];
}

- (void)clickToHidderkeyboard
{
    [_inputTf resignFirstResponder];
}

/**
 *  联系客服
 *
 *  @param sender
 */
- (void)clickToChat:(UIButton *)sender
{
//    NSString *product = [NSString stringWithFormat:WEB_ORDERDETAIL,_orderModel.order_id];
//    NSString *productId = [NSString stringWithFormat:@"%@%@",SERVER_URL,product];
//    
//    NSString *text = [NSString stringWithFormat:@"订单编号:%@",_orderModel.order_no];
//    RCTextMessage *msg = [[RCTextMessage alloc]init];
//    msg.content = text;
//    msg.extra = productId;
//    
//    [[RCIMClient sharedRCIMClient]sendMessage:ConversationType_CUSTOMERSERVICE targetId:SERVICE_ID content:msg pushContent:@"客服消息" success:^(long messageId) {
//        NSLog(@"messageid %ld",messageId);
//    } error:^(RCErrorCode nErrorCode, long messageId) {
//        NSLog(@"nErrorCode %ld",nErrorCode);
//        
//    }];
    
    
    [self sendProductDetailMessage];
    
    RCDChatViewController *chatService = [[RCDChatViewController alloc] init];
    chatService.userName = @"客服";
    chatService.targetId = SERVICE_ID;
    chatService.conversationType = ConversationType_CUSTOMERSERVICE;
    chatService.title = chatService.userName;
    [self.navigationController pushViewController:chatService animated:YES];
}


-(void)sendProductDetailMessage
{
    NSString *imageUrl = @"http://123.57.51.27:86/order.jpg";
    NSString *digest = @"";
    
    NSString *product = [NSString stringWithFormat:WEB_ORDERDETAIL,_orderModel.order_id];
    NSString *productId = [NSString stringWithFormat:@"%@%@",SERVER_URL,product];
    
    NSString *title = [NSString stringWithFormat:@"订单编号:%@",_orderModel.order_no];
    
    RCRichContentMessage *msg = [RCRichContentMessage messageWithTitle:title digest:digest imageURL:imageUrl extra:productId];
    [[RCIMClient sharedRCIMClient]sendMessage:ConversationType_CUSTOMERSERVICE targetId:SERVICE_ID content:msg pushContent:@"客服消息" success:^(long messageId) {
        NSLog(@"messageid %ld",messageId);
    } error:^(RCErrorCode nErrorCode, long messageId) {
        NSLog(@"nErrorCode %ld",nErrorCode);
        
    }];
}

/**
 *  拨打电话
 *
 *  @param sender
 */
- (void)clickToPhone:(UIButton *)sender
{
    NSString *msg = [NSString stringWithFormat:@"拨打:%@",_orderModel.merchant_phone];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}


#pragma mark - 创建视图


/**
 *  底部工具条
 */
- (void)createBottomView
{
    UIView *bottom = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT - 64 - 50, DEVICE_WIDTH, 50)];
    bottom.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottom];
    
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 36, 50) title:@"合计:" font:15 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"303030"]];
    [bottom addSubview:label];
    
    //产品加邮费
    NSString *price = [NSString stringWithFormat:@"￥%.2f",[_orderModel.total_fee floatValue]];
    _priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.right + 10, 0, 100, 50) title:price font:12 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"f98700"]];
    [bottom addSubview:_priceLabel];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0.5f)];
    line.backgroundColor = [UIColor colorWithHexString:@"e4e4e4"];
    [bottom addSubview:line];
    
    NSString *text1 = nil;
    NSString *text2 = nil;
    
    //订单状态 1=》待付款 2=》已付款 3=》已发货 4=》已送达（已收货） 5=》已取消 6=》已删除
    //退单状态 0=>未申请退款 1=》用户已提交申请退款 2=》同意退款（已提交微信/支付宝）3=》同意退款（退款成功） 4=》同意退款（退款失败） 5=》拒绝退款
    
    //    待付款：取消订单、去付款
    //    待发货：申请退款
    //    配送中:  确认收货
    //    已完成: 删除订单、再次购买
    //    退换：退款中、退款成功、退款失败
    
    int refund_status = [_orderModel.refund_status intValue];
    
    //代表有退款状态
    if (refund_status > 0) {
        
        if (refund_status == 1 || refund_status == 2) {
            text1 = @"退款中";
        }else if (refund_status == 3){
            text1 = @"退款成功";
        }else if (refund_status == 4 || refund_status == 5){
            text1 = @"退款失败";
        }
        
    }else
    {
        int status = [_orderModel.status intValue];
        
        if (status == 1) {
            //待支付
            text1 = @"去支付";
            text2 = @"取消订单";
        }else if (status == 2){ //已付款就是待发货
            //待发货
            text1 = @"申请退款";
            
        }else if (status == 3){
            //配送中
            text1 = @"确认收货";
            text2 = @"延长收货";
            
        }else if (status == 4){
            
            int is_comment = [_orderModel.is_comment intValue];
            if (is_comment == 0)//待评价
            {
                text1 = @"再次购买";
                text2 = @"评价晒图";
                
            }else //已评价
            {
                //已完成
                text1 = @"再次购买";
                text2 = @"删除订单";
            }
        }
    }
    
    CGFloat btn_width = 70;
    CGFloat btn_height = 30;
    CGFloat top = (bottom.height - btn_height)/2.f;
    UIButton *button1 = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - 15 - btn_width, top, btn_width, btn_height) buttonType:UIButtonTypeRoundedRect normalTitle:text1 selectedTitle:nil target:self action:@selector(clickToAction:)];
    [button1 addCornerRadius:btn_height/2.f];
    [button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button1 setBackgroundColor:DEFAULT_TEXTCOLOR];
    [button1.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [button1 setBorderWidth:0.5f borderColor:DEFAULT_TEXTCOLOR];
    [bottom addSubview:button1];
    
    if (text2.length) {
        UIButton *button2 = [[UIButton alloc]initWithframe:CGRectMake(button1.left - 15 - btn_width, top, btn_width, btn_height) buttonType:UIButtonTypeRoundedRect normalTitle:text2 selectedTitle:nil target:self action:@selector(clickToAction:)];
        [button2 addCornerRadius:btn_height/2.f];
        [button2 setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
        [button2.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [button2 setBorderWidth:0.5f borderColor:DEFAULT_TEXTCOLOR];
        [bottom addSubview:button2];
    }
}

- (void)tableViewFooter
{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 61 + 30)];
    footerView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    _table.tableFooterView = footerView;
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0.5, DEVICE_WIDTH, 31)];
    bgView.backgroundColor = [UIColor whiteColor];
    [footerView addSubview:bgView];
    
    UIButton *chatBtn = [[UIButton alloc]initWithframe:CGRectMake(0, 0, DEVICE_WIDTH/2.f, 31) buttonType:UIButtonTypeCustom normalTitle:nil selectedTitle:nil target:self action:@selector(clickToChat:)];
    [bgView addSubview:chatBtn];
    [chatBtn setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
    [chatBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    chatBtn.backgroundColor = [UIColor whiteColor];
    [chatBtn setImage:[UIImage imageNamed:@"order_chat"] forState:UIControlStateNormal];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(chatBtn.right, 5, 0.5, 21)];
    line.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    [bgView addSubview:line];
    
    UIButton *phoneBtn = [[UIButton alloc]initWithframe:CGRectMake(line.right, 0, DEVICE_WIDTH/2.f, 31) buttonType:UIButtonTypeCustom normalTitle:nil selectedTitle:nil target:self action:@selector(clickToPhone:)];
    [bgView addSubview:phoneBtn];
    [phoneBtn setImage:[UIImage imageNamed:@"order_phone"] forState:UIControlStateNormal];
    [phoneBtn setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
    [phoneBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    phoneBtn.backgroundColor = [UIColor whiteColor];

}


#pragma - mark UIAlertViewDelegate <NSObject>

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ALERT_TAG_PHONE) {
        
        if (buttonIndex == 1) {
            
            NSString *phone = _orderModel.merchant_phone;
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phone]]];
        }
    }else if (alertView.tag == ALERT_TAG_CANCEL_ORDER){
        
        if (buttonIndex == 1) {
            
            NSString *authkey = [GMAPI getAuthkey];
            
            __weak typeof(self)weakSelf = self;
            NSDictionary *params = @{@"authcode":authkey,
                                     @"order_id":_orderModel.order_id,
                                     @"action":@"cancel"};
            [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:ORDER_HANDLE_ORDER parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
                
                NSLog(@"result取消订单 %@",result);
                
                //刷新配送中列表
                //刷新待评价列表
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_ORDER_CANCEL object:nil];
                
                [weakSelf.navigationController popViewControllerAnimated:YES];
                
            } failBlock:^(NSDictionary *result) {
                
                
            }];
        }
        
    }else if (alertView.tag == ALERT_TAG_DEL_ORDER){
        
        if (buttonIndex == 1) {
            NSString *authkey = [GMAPI getAuthkey];
            
            __weak typeof(self)weakSelf = self;
            NSDictionary *params = @{@"authcode":authkey,
                                     @"order_id":_orderModel.order_id,
                                     @"action":@"del"};
            [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:ORDER_HANDLE_ORDER parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
                
                NSLog(@"result删除订单 %@",result);
                
                //刷新配送中列表
                //刷新待评价列表
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_ORDER_DEL object:nil];
                
                [weakSelf.navigationController popViewControllerAnimated:YES];
                
            } failBlock:^(NSDictionary *result) {
                
                
            }];
        }

    }else if (alertView.tag == ALERT_TAG_RECIEVER_CONFIRM){
     
        if (buttonIndex == 1) {
            
            NSString *authkey = [GMAPI getAuthkey];
            
            __weak typeof(self)weakSelf = self;
            NSDictionary *params = @{@"authcode":authkey,
                                     @"order_id":_orderModel.order_id};
            [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:ORDER_RECEIVING_CONFIRM parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
                
                NSLog(@"result确认收货 %@",result);
                
                //刷新配送中列表
                //刷新待评价列表
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_RECIEVE_CONFIRM object:nil];
                
                [weakSelf.navigationController popViewControllerAnimated:YES];
                
            } failBlock:^(NSDictionary *result) {
                
                
            }];
        }

    }else if (alertView.tag == ALERT_TAG_Delay_OK){
        //延长收货
        if (buttonIndex == 1) {
            
            NSString *authey = [GMAPI getAuthkey];
            
            OrderModel *aModel = _orderModel;
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            NSDictionary *params = @{@"authcode":authey,
                                     @"order_id":aModel.order_id};
            __weak typeof(self)weakSelf = self;
            [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:ORDER_RECEIVING_Delay parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
                
                NSLog(@"result延长收货 %@",result);
                [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
                aModel.show_delay_receive = @"0";//不能再次延长收货
                OrderModel *lasetModel = weakSelf.orderModel;
                lasetModel.show_delay_receive = @"0";
                
            } failBlock:^(NSDictionary *result) {
                NSLog(@"result %@",result[RESULT_INFO]);
                [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
                
            }];
        }
        
    }
    
}


/**
 *  所有视图赋值
 *
 *  @param aModel
 */
- (void)setViewsWithModel:(OrderModel *)aModel
{
    _orderModel = aModel;
    _selectCoupon = [aModel.couponsList lastObject];//一个订单只能使用一张优惠劵
    [self tableHeaderViewWithAddressModel:aModel];
    [self tableViewFooter];
    [self createBottomView];
}

- (void)tableHeaderViewWithAddressModel:(OrderModel *)aModel
{
    NSString *name = aModel.receiver_username;
    NSString *phone = aModel.receiver_mobile;
    NSString *address = aModel.address;
    
    //是否有收货地址
    BOOL haveAddress = address ? YES : NO;
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 122)];
    headerView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    
    UIImageView *topImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, DEVICE_WIDTH, 3)];
    [headerView addSubview:topImage];
    topImage.image = [UIImage imageNamed:@"shopping cart_dd_top_line"];
    
    UIView *addressView = [[UIView alloc]initWithFrame:CGRectMake(0, topImage.bottom, DEVICE_WIDTH, 100)];
    addressView.backgroundColor = [UIColor colorWithHexString:@"fffaf4"];
    [headerView addSubview:addressView];
    
    //名字icon
    _nameIcon = [[UIImageView alloc]initWithFrame:CGRectMake(10, 13, 12, 17.5)];
    [addressView addSubview:_nameIcon];
    _nameIcon.image = [UIImage imageNamed:@"shopping cart_dd_top_name"];
    _nameIcon.hidden = !haveAddress;
    
    //名字
    CGFloat aWidth = [LTools widthForText:name font:15];
    _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(_nameIcon.right + 10, 13, aWidth, _nameIcon.height) title:name font:15.f align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
    [addressView addSubview:_nameLabel];
    
    //电话icon
    _phoneIcon = [[UIImageView alloc]initWithFrame:CGRectMake(_nameLabel.right + 10, 13, 12, 17.5)];
    [addressView addSubview:_phoneIcon];
    _phoneIcon.image = [UIImage imageNamed:@"shopping cart_dd_top_phone"];
    _phoneIcon.hidden = !haveAddress;
    
    //电话
    _phoneLabel = [[UILabel alloc]initWithFrame:CGRectMake(_phoneIcon.right + 10, 13, 120, _nameIcon.height) title:phone font:15.f align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
    [addressView addSubview:_phoneLabel];
    
    //地址
    _addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, _phoneIcon.bottom + 15, DEVICE_WIDTH - 10 * 2, 40) title:address font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"646462"]];
    [addressView addSubview:_addressLabel];
    _addressLabel.numberOfLines = 2;
    _addressLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    
    UIImageView *bottomImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, addressView.bottom, DEVICE_WIDTH, 3)];
    [headerView addSubview:bottomImage];
    bottomImage.image = [UIImage imageNamed:@"shopping cart_dd_top_line"];
    
    if (!haveAddress) {
        
        _addressHintLabel = [[UILabel alloc]initWithFrame:headerView.bounds title:@"请填写收货地址以确保商品顺利到达" font:13 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"646462"]];
        [headerView addSubview:_addressHintLabel];
    }
    
    
    _table.tableHeaderView = headerView;
    
    [_table reloadData];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        
    if (indexPath.section == 0) {

        ProductModel *aModel = [[ProductModel alloc]initWithDictionary:[_orderModel.products objectAtIndex:indexPath.row]] ;
        
        ProductDetailViewController *cc = [[ProductDetailViewController alloc]init];
        cc.product_id = aModel.product_id;
        [self.navigationController pushViewController:cc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = _titles[indexPath.section];
    if ([title isEqualToString:@"商品清单"]) {
        return 85;
    }else if ([title isEqualToString:@"备注信息"]){
        return 30;
    }else if ([title isEqualToString:@"优惠劵"]){
        return 50;
    }else if ([title isEqualToString:@"价格清单"]){
        return 30;
    }
    
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 37.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 37.5)];
    
    NSString *title = _titles[section];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, view.height) title:title font:12 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"9d9d9d"]];
    [view addSubview:label];
    view.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    
    return view;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *title = _titles[section];
    if ([title isEqualToString:@"商品清单"]) {
        return _orderModel.products.count;
    }else if ([title isEqualToString:@"备注信息"]){
        return 1;
    }else if ([title isEqualToString:@"优惠劵"]){
        return 1;
    }else if ([title isEqualToString:@"价格清单"]){
        return 2;
    }
    return 0;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = _titles[indexPath.section];
    if ([title isEqualToString:@"商品清单"]) {
        
        static NSString *identify = @"ProductCell";
        ProductCell *cell = (ProductCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        ProductModel *aModel = [[ProductModel alloc]initWithDictionary:[_orderModel.products objectAtIndex:indexPath.row]] ;
        [cell setCellWithModel:aModel];
        
        return cell;
        
    }else if ([title isEqualToString:@"备注信息"]){
        
        static NSString *identify = @"tableCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            _inputTf = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH - 20, 30)];
            _inputTf.placeholder = @"填写备注";
            _inputTf.font = [UIFont systemFontOfSize:12];
            [cell.contentView addSubview:_inputTf];
            _inputTf.userInteractionEnabled = NO;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *note = _orderModel.order_note;
        if (note) {
            _inputTf.text = note;
        }
        return cell;
        
        
    }else if ([title isEqualToString:@"优惠劵"]){
        
        static NSString *identify = @"OrderOtherInfoCell";
        OrderOtherInfoCell *cell = (OrderOtherInfoCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            cell = [[OrderOtherInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell setCellWithModel:_selectCoupon couponList:_orderModel.couponsList];
        cell.userInteractionEnabled = NO;
        
        return cell;
        
    }else if ([title isEqualToString:@"价格清单"]){
        
        static NSString *identify = @"ConfirmInfoCell";
        ConfirmInfoCell *cell = (ConfirmInfoCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
        if (indexPath.row == 0) {
            cell.nameLabel.text = @"商品总价";
            cell.priceLabel.text = [NSString stringWithFormat:@"￥%.2f",[_orderModel.total_price floatValue]];

        }else if (indexPath.row == 1){
            cell.nameLabel.text = @"运费";
            cell.priceLabel.text = [NSString stringWithFormat:@"￥%.2f",[_orderModel.express_fee floatValue]];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    static NSString *identify1 = @"SelectCell";
    SelectCell *cell1 = (SelectCell *)[LTools cellForIdentify:identify1 cellName:identify1 forTable:tableView];
    if (indexPath.section == 0) {
        cell1.nameLabel.text = @"支付方式";
        
        if (indexPath.row == 0) {
            
            cell1.contentLabel.text = _payStyle;
        }
    }
    cell1.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    return cell1;

    
//    if (indexPath.section == 1) {
//        static NSString *identify = @"ProductCell";
//        ProductCell *cell = (ProductCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
//        
//        ProductModel *aModel = [[ProductModel alloc]initWithDictionary:[_orderModel.products objectAtIndex:indexPath.row]] ;
//        [cell setCellWithModel:aModel];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//
//        return cell;
//    }
//    
//    if (indexPath.section == 2) {
//        
//        static NSString *identify = @"ConfirmInfoCell";
//        ConfirmInfoCell *cell = (ConfirmInfoCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
//        if (indexPath.row == 0) {
//            
//            cell.nameLabel.text = @"商品总价";
//            cell.priceLabel.text = [NSString stringWithFormat:@"￥%.2f",[_orderModel.total_price floatValue]];
//            
//        }else if (indexPath.row == 1){
//            cell.nameLabel.text = @"运费";
//            cell.priceLabel.text = [NSString stringWithFormat:@"￥%.2f",[_orderModel.express_fee floatValue]];
//        }
//        
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        
//        return cell;
//    }
//    
//    static NSString *identify = @"SelectCell";
//    SelectCell *cell = (SelectCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
//    cell.arrowImageView.hidden = YES;
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//
//    if (indexPath.section == 0) {
//        cell.nameLabel.text = @"支付方式";
//        cell.contentLabel.left = DEVICE_WIDTH - cell.contentLabel.width - 20;
//        if (indexPath.row == 0) {
//            
//            NSLog(@"支付方式 --- %@",_orderModel.pay_type);
//            
//            int type = [_orderModel.pay_type intValue];
//            if (type == 1) {
//                
//                cell.contentLabel.text = @"支付宝支付";
//            }else if(type == 2)
//            {
//                cell.contentLabel.text = @"微信支付";
//            }else
//            {
//                cell.contentLabel.text = @"未选择";
//            }
//        }
//    }
//    
//    if (indexPath.section == 3) {
//        
//        cell.nameLabel.text = @"订单编号";
//        cell.contentLabel.left = DEVICE_WIDTH - cell.contentLabel.width - 20;
//        cell.contentLabel.text = _orderModel.order_no;
//    }
//    
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    
//    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}


@end
