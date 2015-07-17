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
#import "ShoppingCartCell.h"
#import "ProductModel.h"

#define kPadding_add 1000 //数量增加
#define kPadding_reduce 2000 //数量减少
#define kPadding_delete 3000 //删除
#define kPadding_alert  4000 //UIAlertView tag
#define kPadding_select  5000 //UIAlertView tag


@interface ShoppingCarController ()<RefreshDelegate,UITableViewDataSource,UIAlertViewDelegate>
{
    RefreshTableView *_table;
    
    BOOL _isSelectAll;//是否选择全部
    
    UIButton *_selectAllBtn;//选择全部按钮
    
    UILabel *_sumLabel;//总价label
    
    UIView *_bottom;//底部工具
    
    BOOL _isEditing;//是否处在编辑状态
    
    BOOL _isUpdateCart;//是否更新购物车
    
    NSMutableDictionary *_selectDic;//记录是否选择了
}

@end

@implementation ShoppingCarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"购物车";
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeNull WithRightButtonType:MyViewControllerRightbuttonTypeText];
    
    [self.my_right_button setTitle:@"编辑" forState:UIControlStateNormal];
    [self.my_right_button setTitle:@"完成" forState:UIControlStateSelected];
    
    _table = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH,DEVICE_HEIGHT - 64) showLoadMore:NO];
    _table.refreshDelegate = self;
    _table.dataSource = self;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_table];
    
    //监测数据源
    [_table addObserver:self forKeyPath:@"_dataArrayCount" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    //初始化 记录是否选择
    _selectDic = [NSMutableDictionary dictionary];
    
    NSString *authkey = [GMAPI getAuthkey];
    
    if (authkey.length) {
        
        [_table showRefreshHeader:YES];
    }else
    {
        //获取本地数据
        
        NSArray *array = [[DBManager shareInstance]QueryData];
        
        [_table reloadData:array isHaveMore:NO];

    }
    
    
    //监测购物车是否更新
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateCartNotification:) name:NOTIFICATION_UPDATE_TO_CART object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
    if (_isUpdateCart) {
        
        [_table showRefreshHeader:YES];
        _isUpdateCart = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 创建视图

/**
 *  创建购物车为空view
 */
- (UIView *)footerViewForNoProduct
{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, _table.height)];
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 235)];
//    bgView.backgroundColor = [UIColor orangeColor];
    [footerView addSubview:bgView];
    bgView.centerY = footerView.height/2.f;
    //图片
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 110, 105)];
    imageView.image = [UIImage imageNamed:@"shopping cart_icon"];
    [bgView addSubview:imageView];
    imageView.centerX = bgView.width/2.f - 10;
    
    //购物车还是空的
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, imageView.bottom + 22, DEVICE_WIDTH, 15) title:@"购物车还是空的" font:14 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"646464"]];
    [bgView addSubview:label];
    
    //快去挑几件喜欢的宝贝吧
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, label.bottom + 5, DEVICE_WIDTH, 15) title:@"快去挑几件喜欢的宝贝吧" font:14 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"e4e4e4"]];
    [bgView addSubview:label2];
    
    UIButton *btn = [[UIButton alloc]initWithframe:CGRectMake((DEVICE_WIDTH - 150) / 2.f, label2.bottom + 20, 150, 30) buttonType:UIButtonTypeRoundedRect normalTitle:@"去逛逛" selectedTitle:nil target:self action:@selector(clickToSelectProduct:)];
    [bgView addSubview:btn];
    btn.backgroundColor = DEFAULT_TEXTCOLOR;
    [btn addCornerRadius:3.f];
    btn.centerX = bgView.width/2.f;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    return footerView;
}

/**
 *  创建底部工具条
 */
- (void)creatBottomTools
{
    _bottom = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT - 64 - 49 - 50, DEVICE_WIDTH, 50)];
    [self.view addSubview:_bottom];
    _bottom.backgroundColor = [UIColor whiteColor];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _bottom.width, 0.5)];
    line.backgroundColor = [UIColor colorWithHexString:@"e4e4e4"];
    [_bottom addSubview:line];
    
    _selectAllBtn = [[UIButton alloc]initWithframe:CGRectMake(0, 0, 40, _bottom.height) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"shopping cart_normal"] selectedImage:[UIImage imageNamed:@"shopping cart_selected"] target:self action:@selector(clickToSelectAll:)];
    [_bottom addSubview:_selectAllBtn];
    _selectAllBtn.selected = YES;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(_selectAllBtn.right, 0, 30, _bottom.height) title:@"全选" font:15 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"494949"]];
    [_bottom addSubview:label];
    
    UILabel *label_heJi = [[UILabel alloc]initWithFrame:CGRectMake(label.right + 10, 12, 30, 14) title:@"合计" font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"494949"]];
    [_bottom addSubview:label_heJi];
    
    UILabel *label_fei = [[UILabel alloc]initWithFrame:CGRectMake(label.right + 10 - 2, label_heJi.bottom + 5, 35, 8) title:@"不含运费" font:8 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"494949"]];
    [_bottom addSubview:label_fei];
    
    _sumLabel = [[UILabel alloc]initWithFrame:CGRectMake(label_heJi.right + 10, 0, 100, _bottom.height) title:@"￥0.00" font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"f88600"]];
    [_bottom addSubview:_sumLabel];
    
    [self updateSumPrice];//更新数据
    
    UIButton *payButton = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - 110, 0, 110, _bottom.height) buttonType:UIButtonTypeCustom normalTitle:@"去结算" selectedTitle:nil target:self action:@selector(clickToPay:)];
    [payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    payButton.backgroundColor = [UIColor colorWithHexString:@"f98700"];
    [_bottom addSubview:payButton];
    
}

#pragma mark - 监控通知

/**
 *  购物车更新通知
 *
 *  @param notification
 */
- (void)updateCartNotification:(NSNotification *)notification
{
    _isUpdateCart = YES;
}

#pragma mark - 事件处理

/**
 *  检测
 */
- (void)checkCartIsEmpty
{
    //购物车是空的
    if (_table.dataArray.count == 0) {
        
        _table.tableFooterView = [self footerViewForNoProduct];
        
        if (_bottom) {
            
            [_bottom removeFromSuperview];
            _bottom = nil;
        }
        
        self.my_right_button.hidden = YES;
        
        _table.height = DEVICE_HEIGHT - 64 - 49;
        
    }else
    {
        _table.tableFooterView = nil;
        
        if (!_bottom) {
            
            _isSelectAll = YES;
            [self creatBottomTools];
        }
        
        self.my_right_button.hidden = NO;

        _table.height = DEVICE_HEIGHT - 64 - 49 - 50;

    }
    
    [self updateSumPrice];
}

/**
 *  是否全部选中
 *
 *  @return
 */
- (BOOL)isAllSelected
{
    for (int i = 0; i < _table.dataArray.count; i ++) {
        
        ProductModel *aModel = [_table.dataArray objectAtIndex:i];
        if ([_selectDic[aModel.product_id] isEqualToString:@"no"]) {
            
            return NO;
        }
    }
    return YES;
}

/**
 *  计算总价
 *
 *  @return
 */
- (float)sumPrice
{
    float sum = 0.f;
    for (int i = 0; i < _table.dataArray.count; i ++) {
        
        ProductModel *aModel = [_table.dataArray objectAtIndex:i];
        
        if ([_selectDic[aModel.product_id] isEqualToString:@"yes"]) {
            
            sum += ([aModel.product_num floatValue] * [aModel.current_price floatValue]);
        }
    }
    
    return sum;
}

/**
 *  更新总价格
 */
- (void)updateSumPrice
{
    _sumLabel.text = [NSString stringWithFormat:@"￥%.2f",[self sumPrice]];
}

/**
 *  去选择商品
 *
 *  @param sender
 */
- (void)clickToSelectProduct:(UIButton *)sender
{
    
}

/**
 *  去结算
 *
 *  @param sender
 */
- (void)clickToPay:(UIButton *)sender
{
    for (int i = 0; i < _table.dataArray.count; i ++) {
        
        ProductModel *aModel = [_table.dataArray objectAtIndex:i];
        
        if ([_selectDic[aModel.product_id] isEqualToString:@"yes"]) {
            
            NSLog(@"购买:%@ 单价:%@ 数量:%@",aModel.product_name,aModel.current_price,aModel.product_num);

        }

    }
    NSLog(@"总价: %f",[self sumPrice]);
}

- (void)clickToSelect:(UIButton *)sender
{
    _isSelectAll = NO;
    
    ProductModel *aModel = [_table.dataArray objectAtIndex:sender.tag - kPadding_select];
    
    //默认 yes
    
    if (!sender.selected) {
        
        [_selectDic setObject:@"yes" forKey:aModel.product_id];

    }else
    {
        [_selectDic setObject:@"no" forKey:aModel.product_id];
    }
    
    //注意顺序,一定要先设置 yes or no再做如下操作
    sender.selected = !sender.selected;

    
    _selectAllBtn.selected = [self isAllSelected];

}

- (void)clickToSelectAll:(UIButton *)sender
{
    sender.selected = !sender.selected;

    _isSelectAll = YES;
    
    if (sender.selected) {
        
        for (int i = 0; i < _table.dataArray.count; i ++) {
            
            ProductModel *aModel = [_table.dataArray objectAtIndex:i];
            [_selectDic setObject:@"yes" forKey:aModel.product_id];
        }
    }else
    {
        [_selectDic removeAllObjects];

    }
    
    [_table reloadData];
    
    [self updateSumPrice];
}

/**
 *  添加数量
 *
 *  @param sender
 */
- (void)clickToAdd:(UIButton *)sender
{
    NSInteger index = sender.tag - kPadding_add;
    ProductModel *aModel = _table.dataArray[index];
    
    [self updateProductByNum:1 cell:nil productModel:aModel];
}

/**
 *  减少数量
 *
 *  @param sender
 */
- (void)clickToReduce:(UIButton *)sender
{
    NSInteger index = sender.tag - kPadding_reduce;
    ProductModel *aModel = _table.dataArray[index];
    
    [self updateProductByNum:-1 cell:nil productModel:aModel];

}

/**
 *  删除购物车某个产品
 *
 *  @param sender
 */
- (void)clickToDelete:(UIButton *)sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"确认要删除这个宝贝吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alert.tag = sender.tag + kPadding_alert;
    [alert show];
}

//右边按钮点击

-(void)rightButtonTap:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    _isEditing = sender.selected;
    
    [_table reloadData];
}


#pragma mark - 网络请求

/**
 *  删除购物车某条记录
 *
 *  @param aModel <#aModel description#>
 */
- (void)deleteProduct:(ProductModel *)aModel index:(int)index
{
//    authcode
//    cart_pro_id 购物车商品id
    
    NSString *authkey = [GMAPI getAuthkey];
    NSDictionary *params = @{@"authcode":authkey,
                             @"cart_pro_id":aModel.cart_pro_id};
    
    __weak typeof(_table)weakTable = _table;
    __weak typeof(self)weakSelf = self;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:ORDER_DEL_CART_PRODUCT parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [weakTable.dataArray removeObjectAtIndex:index];
        [weakTable reloadData];
        [weakTable setValue:[NSNumber numberWithInteger:weakTable.dataArray.count] forKey:@"_dataArrayCount"];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"failBlock:%@",result);
        
    }];
}

/**
 *  更新单品数量
 *
 *  @param num    +1 或者 -1
 *  @param cell
 *  @param aModel
 */
- (void)updateProductByNum:(int)num
                      cell:(ShoppingCartCell *)cell
              productModel:(ProductModel *)aModel
{
    NSString *authkey = [GMAPI getAuthkey];
    
    if (authkey.length == 0) {
        
        [[DBManager shareInstance]increasProductId:aModel.product_id ByNum:num];
        aModel.product_num = [NSString stringWithFormat:@"%d",[aModel.product_num intValue] + num];
        [_table reloadData];
        [self updateSumPrice];
        
        return;
    }
    
    NSDictionary *params = @{@"authcode":authkey,
                             @"cart_pro_id":aModel.cart_pro_id,
                             @"product_num":[NSNumber numberWithInt:num]};
    
    __weak typeof(_table)weakTable = _table;
    __weak typeof(self)weakSelf = self;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:ORDER_EDIT_CART_PRODUCT parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        aModel.product_num = [NSString stringWithFormat:@"%d",[aModel.product_num intValue] + num];
        [weakTable reloadData];
        [weakSelf updateSumPrice];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"failBlock:%@",result);
        
    }];
}

/**
 *  获取购物车数据
 */
- (void)getCartList
{
//    43、获取购物车记录
//http://182.92.106.193:85/index.php?d=api&c=order&m=get_cart_products&authcode=***
//    get方式
//    参数：
//    authcode
//    page 页码
//    per_page 每页多少条记录
    
    NSString *authkey = [GMAPI getAuthkey];
    NSDictionary *params = @{@"authcode":authkey,
                             @"page":[NSNumber numberWithInt:_table.pageNum],
                             @"perpage":[NSNumber numberWithInt:50]};
    
    __weak typeof(_table)weakTable = _table;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:ORDER_GET_CART_PRODCUTS parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSLog(@"completion:%@",result);
        NSArray *list = result[@"list"];
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:list.count];
        for (NSDictionary *aDic in list) {
            
            ProductModel *aModel = [[ProductModel alloc]initWithDictionary:aDic];
            [temp addObject:aModel];
            
            //默认 yes
            NSString *state = _selectDic[aModel.product_id];
            if (!state) {
                [_selectDic setObject:@"yes" forKey:aModel.product_id];
            }
        }
        [weakTable reloadData:temp pageSize:20];
        
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"failBlock:%@",result);
        
    }];
}

#pragma mark - 代理

#pragma mark - UIAlertViewDelegate <NSObject>

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        //确认删除
        NSInteger index = alertView.tag - kPadding_delete - kPadding_alert;
        ProductModel *aModel = _table.dataArray[index];
        
        [self deleteProduct:aModel index:(int)index];
        
    }
}

#pragma mark - RefreshDelegate

- (void)loadNewData
{
    [self getCartList];
}
- (void)loadMoreData
{
    [self getCartList];
}

- (void)loadNewDataForTableView:(UITableView *)tableView
{
    
}
- (void)loadMoreDataForTableView:(UITableView *)tableView
{
    
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath
{
    return 85.f;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _table.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"ShoppingCartCell";
    ShoppingCartCell *cell = (ShoppingCartCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
    
    ProductModel *aModel = [_table.dataArray objectAtIndex:indexPath.row];
    
    [cell setCellWithModel:aModel];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.selectedButton addTarget:self action:@selector(clickToSelect:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.addButton.tag = kPadding_add + indexPath.row;
    cell.reduceButton.tag = kPadding_reduce + indexPath.row;
    cell.deleteBtn.tag = kPadding_delete + indexPath.row;
    cell.selectedButton.tag = kPadding_select + indexPath.row;

    if (_isSelectAll) {
        
        cell.selectedButton.selected = _selectAllBtn.selected;
    }else
    {
        //默认 yes
        NSString *state = _selectDic[aModel.product_id];
        cell.selectedButton.selected = [state isEqualToString:@"yes"] ? YES : NO;
    }
    
    [cell.addButton addTarget:self action:@selector(clickToAdd:) forControlEvents:UIControlEventTouchUpInside];

    [cell.reduceButton addTarget:self action:@selector(clickToReduce:) forControlEvents:UIControlEventTouchUpInside];
    [cell.deleteBtn addTarget:self action:@selector(clickToDelete:) forControlEvents:UIControlEventTouchUpInside];
    
    //监控选中按钮状态以及数量
    [cell.selectedButton addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
//    [cell.numLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    cell.bgView.left = _isEditing ? -40 : 0;
    
    return cell;
}


#pragma - mark 通知处理

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if ([keyPath isEqualToString:@"selected"]) {
        [self updateSumPrice];

    }else if ([keyPath isEqualToString:@"_dataArrayCount"]){
        
        [self checkCartIsEmpty];
    }
    
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
