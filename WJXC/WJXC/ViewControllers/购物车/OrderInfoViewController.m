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

#import "OrderModel.h"

#define ALIPAY @"支付宝支付"
#define WXPAY  @"微信支付"

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
}

@end

@implementation OrderInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"订单详情";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
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
    self.navigationController.navigationBarHidden = NO;
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
    
    
    NSDictionary *params = @{@"authcode":authkey,
                             @"order_id":self.order_id,
                             @"detail":[NSNumber numberWithInt:1]};
    
    __weak typeof(_table)weakTable = _table;
    __weak typeof(self)weakSelf = self;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:ORDER_GET_ORDER_INFO parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSLog(@"获取订单详情%@ %@",result[RESULT_INFO],result);
        NSDictionary *info = result[@"info"];
        OrderModel *aModel = [[OrderModel alloc]initWithDictionary:info];
        [weakSelf setViewsWithModel:aModel];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"获取订单详情 失败 %@",result[RESULT_INFO]);
        
    }];
    
}

#pragma mark - 事件处理

/**
 *  跳转至支付页面
 */
- (void)pushToPayPageWithOrderId:(NSString *)orderId
                        orderNum:(NSString *)orderNum
{
    PayActionViewController *pay = [[PayActionViewController alloc]init];
    pay.orderId = orderId;
    pay.orderNum = orderNum;
//    pay.sumPrice = self.sumPrice + _expressFee;
    pay.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:pay animated:YES];
    
    //    self.navigationController.viewControllers
}

- (void)clickToHidderkeyboard
{
    [_inputTf resignFirstResponder];
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
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0.5f)];
    line.backgroundColor = [UIColor colorWithHexString:@"e4e4e4"];
    [bottom addSubview:line];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 36, 50) title:@"合计:" font:15 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"303030"]];
    [bottom addSubview:label];
    
    //产品加邮费
    NSString *price = [NSString stringWithFormat:@"￥%.2f",0.01];
    
    _priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.right + 10, 0, 100, 50) title:price font:12 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"f98700"]];
    [bottom addSubview:_priceLabel];
    
    UIButton *sureButton = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - 15 - 100, 10, 100, 30) buttonType:UIButtonTypeRoundedRect normalTitle:@"提交订单" selectedTitle:nil target:self action:@selector(clickToConfirmOrder:)];
    [sureButton addCornerRadius:3.f];
    [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sureButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    sureButton.backgroundColor = [UIColor colorWithHexString:@"f98700"];
    [bottom addSubview:sureButton];
}

- (void)tableViewFooter
{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 61)];
    footerView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    _table.tableFooterView = footerView;
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 31)];
    bgView.backgroundColor = [UIColor whiteColor];
    [footerView addSubview:bgView];
    
    UIButton *chatBtn = [[UIButton alloc]initWithframe:CGRectMake(0, 0, DEVICE_WIDTH/2.f, 31) buttonType:UIButtonTypeCustom normalTitle:@"联系商家" selectedTitle:nil target:self action:@selector(clickToChat:)];
    [bgView addSubview:chatBtn];
    [chatBtn setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
    [chatBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    chatBtn.backgroundColor = [UIColor whiteColor];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(chatBtn.right, 5, 0.5, 21)];
    line.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    [bgView addSubview:line];
    
    UIButton *phoneBtn = [[UIButton alloc]initWithframe:CGRectMake(line.right, 0, DEVICE_WIDTH/2.f, 31) buttonType:UIButtonTypeCustom normalTitle:@"拨打电话" selectedTitle:nil target:self action:@selector(clickToPhone:)];
    [bgView addSubview:phoneBtn];
    [phoneBtn setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
    [phoneBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    phoneBtn.backgroundColor = [UIColor whiteColor];

}

- (void)clickToChat:(UIButton *)sender
{
    
}

- (void)clickToPhone:(UIButton *)sender
{
    
}

/**
 *  所有视图赋值
 *
 *  @param aModel
 */
- (void)setViewsWithModel:(OrderModel *)aModel
{
    _orderModel = aModel;
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
    
    NSLog(@"点击商品name = ");
    
    if (indexPath.section == 1) {
        
//        ProductModel *aModel = [self.productArray objectAtIndex:indexPath.row];
        
//        NSLog(@"点击商品name = %@",aModel.product_name);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 2) {
        return 30;
    }
    if (indexPath.section == 1) {
        return 85;
    }
    
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 37.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 37.5)];
    
    NSString *title = nil;
    
    if (section == 0) {
        
        title = @"支付信息";
    }else if (section == 1){
        title = @"商品清单";
    }else if (section == 2){
        title = @"价格清单";
    }
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, view.height) title:title font:12 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"9d9d9d"]];
    [view addSubview:label];
    view.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    
    return view;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        
        return 1;
    }
    if (section == 1) {
        
        return _orderModel.products.count;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        static NSString *identify = @"ProductCell";
        ProductCell *cell = (ProductCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
        
        ProductModel *aModel = [[ProductModel alloc]initWithDictionary:[_orderModel.products objectAtIndex:indexPath.row]] ;
        [cell setCellWithModel:aModel];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
    }
    
    if (indexPath.section == 2) {
        
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
    
    static NSString *identify = @"SelectCell";
    SelectCell *cell = (SelectCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
    cell.arrowImageView.hidden = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (indexPath.section == 0) {
        cell.nameLabel.text = @"支付方式";
        cell.contentLabel.left = DEVICE_WIDTH - cell.contentLabel.width - 20;
        if (indexPath.row == 0) {
            
            if ([_orderModel.pay_type intValue] == 1) {
                
                cell.contentLabel.text = @"支付宝支付";
            }else
            {
                cell.contentLabel.text = @"微信支付";
            }
        }
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}


@end
