//
//  ConfirmOrderController.m
//  WJXC
//
//  Created by lichaowei on 15/7/18.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "ConfirmOrderController.h"
#import "SelectCell.h"
#import "ProductCell.h"
#import "ConfirmInfoCell.h"
#import "ShoppingAddressController.h"//收货地址
#import "AddressModel.h"
#import "ProductModel.h"
#import "FBActionSheet.h"
#import "PayActionViewController.h"//支付页面

#import "ProductDetailViewController.h"//单品详情
#import "CouponModel.h"//优惠劵
#import "CoupeView.h"//优惠劵view
#import "OrderOtherInfoCell.h"

#define ALIPAY @"支付宝支付"
#define WXPAY  @"微信支付"

@interface ConfirmOrderController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate,UITextFieldDelegate>
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
    
    float _expressFee;//邮费
    UILabel *_priceLabel;//邮费加产品价格
    CGFloat _realPrice;//记录最终支付价格
    
    MBProgressHUD *_loading;//加载
    
    UILabel *_addressHintLabel;//收货地址提示
    NSArray *_couponList;//优惠劵列表
    CouponModel *_selectCoupon;//选中的优惠劵
    
}

@end

@implementation ConfirmOrderController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBarHidden = NO;
    
    self.myTitle = @"确认订单";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"确认订单";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    _titles = @[@"商品清单",@"备注信息",@"优惠劵",@"价格清单"];

    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    _table.backgroundColor = DEFAULT_VIEW_BACKGROUNDCOLOR;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickToHidderkeyboard)];
    tap.delegate = self;
    [_table addGestureRecognizer:tap];
    
    _loading = [LTools MBProgressWithText:@"生成订单中..." addToView:self.view];
    
    [self getAddressAndFee];//获取收货地址和邮费
    
    [self getCouponList];//获取优惠劵
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 网络请求

/**
 *  切换购物地址时 更新邮费
 */
- (void)updateExpressFeeWithAddressId:(NSString *)addressId
{
    NSString *authkey = [GMAPI getAuthkey];
    
    float weight = [self sumWeight];//总重
    
    NSDictionary *params = @{@"authcode":authkey,
                             @"weight":[NSNumber numberWithFloat:weight],
                             @"address_id":addressId};
    
    __weak typeof(_table)weakTable = _table;
    __weak typeof(self)weakSelf = self;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:ORDER_GET_EXPRESS_FEE parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSLog(@"更新邮费%@ %@",result[RESULT_INFO],result);
        float fee = [result[@"fee"]floatValue];
        _expressFee = fee;
        [weakSelf updateExpressFeeAndSumPrice:fee];
        [weakTable reloadData];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"更新邮费 失败 %@",result[RESULT_INFO]);
        
    }];

}
/**
 *  获取可用优惠劵
 */
- (void)getCouponList
{
    NSString *authkey = [GMAPI getAuthkey];
    
    float weight = [self sumWeight];//总重
    
    NSDictionary *params = @{@"authcode":authkey,
                             @"total_price":[NSNumber numberWithFloat:self.sumPrice]};
    
    __weak typeof(_table)weakTable = _table;
    __weak typeof(self)weakSelf = self;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:ORDER_GET_USECOUPONLIST parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSLog(@"获取可用优惠劵%@ %@",result[RESULT_INFO],result);
        id coupon = [result objectForKey:@"coupon_list"];
        NSArray *coupon_list = nil;
        if ([coupon isKindOfClass:[NSDictionary class]]) {
            
            coupon_list = [coupon allValues];
        }else
        {
            coupon_list = coupon;
        }
        
        if (coupon_list) {
            NSMutableArray *temp = [NSMutableArray arrayWithCapacity:coupon_list.count];
            for (NSDictionary *aDic in coupon_list) {
                
                CouponModel *aModel = [[CouponModel alloc]initWithDictionary:aDic];
                [temp addObject:aModel];
            }
            _couponList = [NSArray arrayWithArray:temp];
            [weakTable reloadData];
        }
        
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"获取可用优惠劵 失败 %@",result[RESULT_INFO]);
        
    }];
}

/**
 *  获取收货地址和邮费
 */
- (void)getAddressAndFee
{
//    authcode
//     重量
    
    NSString *authkey = [GMAPI getAuthkey];
    
    float weight = [self sumWeight];//总重
    
    NSDictionary *params = @{@"authcode":authkey,
                             @"weight":[NSNumber numberWithFloat:weight]};

    __weak typeof(_table)weakTable = _table;
    __weak typeof(self)weakSelf = self;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:ORDER_GET_DEFAULT_ADDRESS parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSLog(@"获取收货地址和邮费 %@",result[RESULT_INFO]);
        
        NSDictionary *address = result[@"address"];
        
        AddressModel *aModel = [[AddressModel alloc]initWithDictionary:address];
        [weakSelf setViewsWithModel:aModel];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"获取收货地址和邮费 失败 %@",result[RESULT_INFO]);
        
    }];

}

/**
 *  生成订单
 */
- (void)postOrderInfo
{
    //    authcode \商品id 多个中间用英文逗号隔开\商品个数 多个中间用英文逗号隔开
    
    int num = (int)self.productArray.count;
    NSMutableArray *product_ids = [NSMutableArray arrayWithCapacity:num];
    NSMutableArray *product_nums = [NSMutableArray arrayWithCapacity:num];
    for (ProductModel *aModel in self.productArray) {
        
        [product_ids addObject:aModel.product_id];
        [product_nums addObject:aModel.product_num];
    }
    
    NSString *ids = [product_ids componentsJoinedByString:@","];
    NSString *nums = [product_nums componentsJoinedByString:@","];
    
    NSString *authkey = [GMAPI getAuthkey];
    
    NSString *note = _inputTf.text.length > 0 ? _inputTf.text : @"";//备注
    NSString *addressId = _selectAddressId;
    NSString *expressFee = [NSString stringWithFormat:@"%.2f",_expressFee];
    
    if (addressId.length == 0) {
        
        [LTools alertText:@"请选择有效收货地址" viewController:self];
        
        return;
    }
    
    [_loading show:YES];
    
    NSDictionary *params = nil;
    
    if (_selectCoupon.coupon_id) { //选择优惠劵
        
        params = @{@"authcode":authkey,
                   @"product_ids":ids,
                   @"product_nums":nums,
                   @"address_id":addressId,
                   @"express_fee":expressFee,
                   @"order_note":note,
                   @"coupon_id":_selectCoupon.coupon_id};
    }else
    {
        params = @{@"authcode":authkey,
                   @"product_ids":ids,
                   @"product_nums":nums,
                   @"address_id":addressId,
                   @"express_fee":expressFee,
                   @"order_note":note};
    }
    
//    __weak typeof(_table)weakTable = _table;
    __weak typeof(self)weakSelf = self;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:ORDER_SUBMIT parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSLog(@"提交订单成功 %@",result[RESULT_INFO]);
        
        [_loading hide:YES];
        
        NSString *orderId = result[@"order_id"];
        NSString *orderNum = result[@"order_no"];
        
        //生成订单成功,更新一下购物车
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_UPDATE_TO_CART object:nil];

        [weakSelf pushToPayPageWithOrderId:orderId orderNum:orderNum];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"提交订单失败 %@",result[RESULT_INFO]);
        
        [_loading hide:YES];

    }];
}


#pragma mark - 事件处理

/**
 *  更新价格 (更改优惠劵,价格跟着变)
 */
- (void)updateSumPrice
{
    CGFloat sum_minus = 0.f;

    CouponModel *c_model = _selectCoupon;
    if (c_model) {
        //1满减 2打折 3：新人优惠
        int type = [c_model.type intValue];
        if (type == 1) {
            
            //判断是否满足满减条件
            if (self.sumPrice  >= [c_model.full_money floatValue]) {
                
                sum_minus += [c_model.minus_money floatValue];//减掉
            }
            
        }else if (type == 2){
            
            sum_minus += (self.sumPrice *  (1 - [c_model.discount_num floatValue]));
        }
    }

    //判断是否有收单减优惠劵
//    NSString *other = @"";
//    if (_couponModel_first) {
//        
//        other = [NSString stringWithFormat:@"(首单立减￥%@)",_couponModel_first.newer_money];
//    }
    
    _priceLabel.text = [NSString stringWithFormat:@"￥%.2f",self.sumPrice - sum_minus + _expressFee];
    
    _realPrice = self.sumPrice - sum_minus + _expressFee;//记录支付价格
    
//    CGFloat minus_first = 0.f;
//    if (_couponModel_first) {
//        
//        minus_first = [_couponModel_first.newer_money floatValue];
//    }
//    
//    _sumPrice_pay = _priceSum - sum_minus - minus_first + _expressFee;//实际付款价格
}

- (void)updateExpressFeeAndSumPrice:(CGFloat)express
{
    //产品加邮费
    NSString *price = [NSString stringWithFormat:@"￥%.2f",self.sumPrice + _expressFee];
    _priceLabel.text = price;
}

/**
 *  计算总重量
 *
 *  @return
 */
- (float)sumWeight
{
    float sum = 0.f;
    int count = (int)self.productArray.count;
    for (int i = 0; i < count; i ++) {
        
        ProductModel *aModel = [self.productArray objectAtIndex:i];
        
        sum += ([aModel.weight floatValue] * [aModel.product_num floatValue]);
    }
    
    return sum;
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
    pay.sumPrice = _realPrice;
    pay.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:pay animated:YES];
    
//    self.navigationController.viewControllers
}

- (void)clickToHidderkeyboard
{
    [_table setContentOffset:CGPointZero animated:YES];

    [_inputTf resignFirstResponder];
}

/**
 *  确定订单
 *
 *  @param sender
 */
- (void)clickToConfirmOrder:(UIButton *)sender
{
    //去生成订单
    [self postOrderInfo];
}

/**
 *  选择购物地址
 *
 *  @param sender
 */
- (void)clickToSelectAddress:(UIButton *)sender
{
    __weak typeof(self)wealSelf = self;
    ShoppingAddressController *address = [[ShoppingAddressController alloc]init];
    address.isSelectAddress = YES;
    address.selectAddressId = _selectAddressId;
    address.selectAddressBlock = ^(AddressModel *aModel){
        _selectAddressId = aModel.address_id;
        [wealSelf updateAddressInfoWithModel:aModel];//更新收货地址显示
        [wealSelf updateExpressFeeWithAddressId:aModel.address_id];//更新邮费
    };
    
    [self.navigationController pushViewController:address animated:YES];
}

/**
 *  更新收货地址信息
 *
 *  @param aModel 
 
 */
- (void)updateAddressInfoWithModel:(AddressModel *)aModel
{
    NSLog(@"---address %@",aModel.address);
    
//    UILabel *_nameLabel;//收货人name
//    UILabel *_phoneLabel;//收货人电话
//    UILabel *_addressLabel;//收货地址
    
    _nameLabel.text = aModel.receiver_username;
    
    CGFloat width = [LTools widthForText:_nameLabel.text font:15];
    _nameLabel.width = width;
    
    _phoneIcon.left = _nameLabel.right + 10;
    _phoneLabel.left = _phoneIcon.right + 10;
    _phoneLabel.text = aModel.mobile;
    _addressLabel.text = aModel.address;

    _phoneIcon.hidden = NO;
    _nameIcon.hidden = NO;
    
    if (_addressHintLabel) {
        [_addressHintLabel removeFromSuperview];
        _addressHintLabel = nil;
    }
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
    NSString *price = [NSString stringWithFormat:@"￥%.2f",self.sumPrice + _expressFee];
    
    _realPrice = self.sumPrice +_expressFee;//初始支付价格
    
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
}

/**
 *  所有视图赋值
 *
 *  @param aModel
 */
- (void)setViewsWithModel:(AddressModel *)aModel
{
    _selectAddressId = aModel.address_id;
    _expressFee = [aModel.fee floatValue];//邮费
    [self tableHeaderViewWithAddressModel:aModel];
    [self tableViewFooter];
    [self createBottomView];
}

- (void)tableHeaderViewWithAddressModel:(AddressModel *)aModel
{
    NSString *name = aModel.receiver_username;
    NSString *phone = aModel.mobile;
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
    _addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, _phoneIcon.bottom + 15, DEVICE_WIDTH - 10 * 4, 40) title:address font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"646462"]];
    [addressView addSubview:_addressLabel];
    _addressLabel.numberOfLines = 2;
    _addressLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    //箭头
    UIImageView *arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 40, 0, 40, addressView.height)];
    [addressView addSubview:arrowImage];
    arrowImage.image = [UIImage imageNamed:@"shopping cart_dd_top_jt"];
    arrowImage.contentMode = UIViewContentModeCenter;
    
    UIImageView *bottomImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, addressView.bottom, DEVICE_WIDTH, 3)];
    [headerView addSubview:bottomImage];
    bottomImage.image = [UIImage imageNamed:@"shopping cart_dd_top_line"];
    
    if (!haveAddress) {
        
        _addressHintLabel = [[UILabel alloc]initWithFrame:headerView.bounds title:@"请填写收货地址以确保商品顺利到达" font:13 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"646462"]];
        [headerView addSubview:_addressHintLabel];
    }
    
    
    _table.tableHeaderView = headerView;
    
    //点击事件
    [headerView addTaget:self action:@selector(clickToSelectAddress:) tag:0];
    
    [_table reloadData];
}

#pragma mark - UITapGestureDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    NSString *touchViewString = NSStringFromClass([touch.view class]);
    if ([touchViewString isEqualToString:@"UITableViewCellContentView"]) {
        
        return NO;
    }
    
    return YES;
}

#pragma mark - UIScrollViewDelegate

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    [self clickToHidderkeyboard];
//}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"点击商品name = ");

    if (indexPath.section == 0) {
        
        ProductModel *aModel = [self.productArray objectAtIndex:indexPath.row];
        
        NSLog(@"点击商品name = %@",aModel.product_name);
        
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
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, view.height) title:_titles[section] font:12 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"9d9d9d"]];
    [view addSubview:label];
    view.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    
    return view;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *title = _titles[section];
    if ([title isEqualToString:@"商品清单"]) {
        return _productArray.count;
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
        
        ProductModel *aModel = [self.productArray objectAtIndex:indexPath.row];
        
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
            _inputTf.clearButtonMode = UITextFieldViewModeWhileEditing;
            _inputTf.delegate = self;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;

        
    }else if ([title isEqualToString:@"优惠劵"]){
        
        static NSString *identify = @"OrderOtherInfoCell";
        OrderOtherInfoCell *cell = (OrderOtherInfoCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            cell = [[OrderOtherInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell setCellWithModel:_selectCoupon couponList:_couponList];
        
        __weak typeof(self)weakSelf = self;
        __weak typeof(tableView)weakTable = tableView;
        //更新优惠劵了
        cell.updateCouponBlock = ^(id model){
            
            _selectCoupon = model;
            //更新价格
            [weakSelf updateSumPrice];
            [weakTable reloadData];
        };
        
        return cell;
        
    }else if ([title isEqualToString:@"价格清单"]){
        
        static NSString *identify = @"ConfirmInfoCell";
        ConfirmInfoCell *cell = (ConfirmInfoCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
        if (indexPath.row == 0) {
            
            cell.nameLabel.text = @"商品总价";
            cell.priceLabel.text = [NSString stringWithFormat:@"￥%.2f",self.sumPrice];
            
        }else if (indexPath.row == 1){
            cell.nameLabel.text = @"运费";
            cell.priceLabel.text = [NSString stringWithFormat:@"￥%.2f",_expressFee];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    static NSString *identify = @"SelectCell";
    SelectCell *cell = (SelectCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
    if (indexPath.section == 0) {
        cell.nameLabel.text = @"支付方式";
        
        if (indexPath.row == 0) {
            
            cell.contentLabel.text = _payStyle;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _titles.count;
}

#pragma - mark UITextFieldDelegate <NSObject>

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    //避免键盘遮挡
    CGPoint origin = textField.frame.origin;
    CGPoint point = [textField.superview convertPoint:origin toView:_table];
    float navBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGPoint offset = _table.contentOffset;
    // Adjust the below value as you need
    offset.y = (point.y - navBarHeight - 100);
    [_table setContentOffset:offset animated:YES];
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
