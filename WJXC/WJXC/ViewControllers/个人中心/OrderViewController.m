//
//  OrderViewController.m
//  WJXC
//
//  Created by lichaowei on 15/7/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "OrderViewController.h"
#import "OrderCell.h"
#import "OrderModel.h"
#import "PayActionViewController.h"//支付页面
#import "OrderInfoViewController.h"//订单详情
#import "ConfirmOrderController.h"//确认订单

#define kPadding_One 1000 //去支付
#define kPadding_Two 2000 //确认收货
#define kPadding_Three 3000 //评价晒单
#define kPadding_Four  4000 //再次购买

@interface OrderViewController ()<RefreshDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    int _buttonNum;//button个数
    UIView *_indicator;//指示器
    UIScrollView *_scroll;
}

@end

@implementation OrderViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"我的订单";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    NSArray *titles = @[@"待付款",@"配送中",@"待评价",@"已完成"];
    int count = (int)titles.count;
    CGFloat width = DEVICE_WIDTH / count;
    _buttonNum = count;
    
    _scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 40, DEVICE_WIDTH, DEVICE_HEIGHT - 64 - 40)];
    _scroll.delegate = self;
    _scroll.contentSize = CGSizeMake(DEVICE_WIDTH * count, _scroll.height);
    _scroll.showsHorizontalScrollIndicator = NO;
    _scroll.pagingEnabled = YES;
    [self.view addSubview:_scroll];
    
    //scrollView 和 系统手势冲突问题
    [_scroll.panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    
    for (int i = 0; i < count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [self.view addSubview:btn];
        btn.tag = 100 + i;
        btn.frame = CGRectMake(width * i, 0, width, 40);
        [btn setTitleColor:[UIColor colorWithHexString:@"646464"] forState:UIControlStateNormal];
        [btn setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateSelected];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [btn addTarget:self action:@selector(clickToSelect:) forControlEvents:UIControlEventTouchUpInside];
        btn.selected = YES;
        
        RefreshTableView *_table = [[RefreshTableView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH * i, 0, DEVICE_WIDTH,_scroll.height)];
        _table.refreshDelegate = self;
        _table.dataSource = self;
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_scroll addSubview:_table];
        _table.tag = 200 + i;
        
        [_table showRefreshHeader:YES];
        
    }
    
    _indicator = [[UIView alloc]initWithFrame:CGRectMake(0, 38, width, 2)];
    _indicator.backgroundColor = DEFAULT_TEXTCOLOR;
    [self.view addSubview:_indicator];
    
    //默认选中第一个
    [self controlSelectedButtonTag:100];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForPaySuccess:) name:NOTIFICATION_PAY_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForRecieveConfirm:) name:NOTIFICATION_RECIEVE_CONFIRM object:nil];//确认收货
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForCancelOrder:) name:NOTIFICATION_ORDER_CANCEL object:nil];//取消订单
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForDelOrder:) name:NOTIFICATION_ORDER_DEL object:nil];//删除订单
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark 通知处理

/**
 *  支付成功通知
 *
 *  @param notify
 */
- (void)notificationForPaySuccess:(NSNotification *)notify
{
    //支付成功 更新
    
    [[self refreshTableForIndex:0]showRefreshHeader:YES];//待付款
    [[self refreshTableForIndex:1]showRefreshHeader:YES];//配送中
}

/**
 *  确认收货通知
 */
- (void)notificationForRecieveConfirm:(NSNotification *)notify
{
    [[self refreshTableForIndex:1]showRefreshHeader:YES];//待配送
    [[self refreshTableForIndex:2]showRefreshHeader:YES];//待评价
}

/**
 *  取消订单通知
 */
- (void)notificationForCancelOrder:(NSNotification *)notify
{
    [[self refreshTableForIndex:0]showRefreshHeader:YES];//待付款
    [[self refreshTableForIndex:1]showRefreshHeader:YES];//配送中
}

/**
 *  删除订单通知
 */
- (void)notificationForDelOrder:(NSNotification *)notify
{
    [[self refreshTableForIndex:2]showRefreshHeader:YES];//待评价
    [[self refreshTableForIndex:3]showRefreshHeader:YES];//已完成
}

#pragma - mark 网络请求

/**
 *  获取订单列表
 *
 *  @param orderType 不同的订单状态
 */
- (void)getOrderListWithStatus:(ORDERTYPE)orderType
{
//    authcode
//    status 我的订单状态（no_pay待付款，deliver配送中，no_comment待评价，complete已完成）
    NSString *authey = [GMAPI getAuthkey];
    if (authey.length == 0) {
        return;
    }
    NSString *status = nil;
    switch (orderType) {
        case ORDERTYPE_DaiFu:
            status = @"no_pay";
            break;
        case ORDERTYPE_PeiSong:
            status = @"deliver";
            break;
        case ORDERTYPE_DaiPingJia:
            status = @"no_comment";
            break;
        case ORDERTYPE_WanCheng:
            status = @"complete";
            break;
        default:
            break;
    }
    __weak typeof(RefreshTableView)*weakTable = [self refreshTableForIndex:orderType - 1];
    
    NSDictionary *params = @{@"authcode":authey,
                             @"status":status,
                             @"per_page":[NSNumber numberWithInt:20]};
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:ORDER_GET_MY_ORDERS parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSArray *list = result[@"list"];
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:list.count];
        for (NSDictionary *aDic in list) {
            
            OrderModel *aModel = [[OrderModel alloc]initWithDictionary:aDic];
            [temp addObject:aModel];
        }
        [weakTable reloadData:temp pageSize:20];
        
    } failBlock:^(NSDictionary *result) {
        
        [weakTable loadFail];
    }];
}

#pragma - mark 事件处理

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
 *  去支付 确认收货 评价 再次购买
 *
 *  @param sender
 */
- (void)clickToAction:(UIButton *)sender
{
    int index = (int)sender.tag;
    
    int kadding = 0;
    
    if (index >= kPadding_Four) {
        //再次购买
        kadding = kPadding_Four;
        OrderModel *aModel = [[self refreshTableForIndex:3].dataArray objectAtIndex:index - kadding];
        [self buyAgain:aModel];
        
    }else if (index >= kPadding_Three){
        //评价晒单
        kadding = kPadding_Three;
        
        
    }else if (index >= kPadding_Two){
        //确认收货
        kadding = kPadding_Two;
        
        NSString *authey = [GMAPI getAuthkey];
        if (authey.length == 0) {
            return;
        }
        
        OrderModel *aModel = [[self refreshTableForIndex:1].dataArray objectAtIndex:index - kadding];

        __weak typeof(RefreshTableView)*weakTable = [self refreshTableForIndex:1];
        __weak typeof(RefreshTableView)*weakTable2 = [self refreshTableForIndex:2];

        NSDictionary *params = @{@"authcode":authey,
                                 @"order_id":aModel.order_id};
        [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:ORDER_RECEIVING_CONFIRM parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
            
            NSLog(@"result确认收货 %@",result);
            
            //刷新配送中列表
            [weakTable showRefreshHeader:YES];
            
            //刷新待评价列表
            [weakTable2 showRefreshHeader:YES];
            
        } failBlock:^(NSDictionary *result) {
            
            
        }];

        
    }else if (index >= kPadding_One){
        //支付
        kadding = kPadding_One;
        OrderModel *aModel = [[self refreshTableForIndex:0].dataArray objectAtIndex:index - kPadding_One];
        [self pushToPayPageWithOrderId:aModel.order_id orderNum:aModel.order_no sumPrice:[aModel.total_fee floatValue] payStyle:[aModel.pay_type intValue]];
        
    }
    
}

/**
 *  跳转至支付页面
 */
- (void)pushToPayPageWithOrderId:(NSString *)orderId
                        orderNum:(NSString *)orderNum
                        sumPrice:(CGFloat)sumPrice
                        payStyle:(int)payStyle
{
    PayActionViewController *pay = [[PayActionViewController alloc]init];
    pay.orderId = orderId;
    pay.orderNum = orderNum;
    pay.sumPrice = sumPrice;
    pay.payStyle = payStyle;
    [self.navigationController pushViewController:pay animated:YES];
}

/**
 *  获取button 根据tag
 */
- (UIButton *)buttonForTag:(int)tag
{
    return (UIButton *)[self.view viewWithTag:tag];
}

/**
 *  根据下标来获取tableView
 *
 *  @param index 下标 1，2，3，4
 */
- (RefreshTableView *)refreshTableForIndex:(int)index
{
    return (RefreshTableView *)[self.view viewWithTag:index + 200];
}

/**
 *  控制button选中状态
 */
- (void)controlSelectedButtonTag:(int)tag
{
    for (int i = 0; i < _buttonNum; i ++) {

        [self buttonForTag:100 + i].selected = (i + 100 == tag) ? YES : NO;
    }
    
    __weak typeof(_indicator)weakIndicator = _indicator;
    [UIView animateWithDuration:0.1 animations:^{
       
        weakIndicator.left = DEVICE_WIDTH / _buttonNum * (tag - 100);
    }];
}

/**
 *  点击button
 *
 *  @param sender
 */
- (void)clickToSelect:(UIButton *)sender
{
    [self controlSelectedButtonTag:(int)sender.tag];
    
    __weak typeof(_scroll)weakScroll = _scroll;
    [UIView animateWithDuration:0.1 animations:^{
       
        [weakScroll setContentOffset:CGPointMake(DEVICE_WIDTH * (sender.tag - 100), 0)];
    }];
}

- (void)clickToComment:(UIButton *)sender
{
    
}

#pragma - mark 视图创建

#pragma - 代理

#pragma mark - RefreshDelegate

- (void)loadNewDataForTableView:(UITableView *)tableView
{
    int tableTag = (int)tableView.tag - 200 + 1;
    
    [self getOrderListWithStatus:tableTag];
}
- (void)loadMoreDataForTableView:(UITableView *)tableView
{
    int tableTag = (int)tableView.tag - 200 + 1;
    
    [self getOrderListWithStatus:tableTag];
}

//新加
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    OrderModel *aModel = [((RefreshTableView *)tableView).dataArray objectAtIndex:indexPath.row];

    OrderInfoViewController *orderInfo = [[OrderInfoViewController alloc]init];
    orderInfo.order_id = aModel.order_id;
    [self.navigationController pushViewController:orderInfo animated:YES];
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    return 372/2.f;
}

- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

#pragma - mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    RefreshTableView *refreshTable = (RefreshTableView *)tableView;
    return refreshTable.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"OrderCell";
    OrderCell *cell = (OrderCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    int tableViewTag = (int)tableView.tag;
    switch (tableViewTag) {
        case 200:
        {
            [cell.commentButton setTitle:@"去支付" forState:UIControlStateNormal];
            cell.commentButton.tag = kPadding_One + indexPath.row;
        }
            break;
        case 201:
        {
            [cell.commentButton setTitle:@"确认收货" forState:UIControlStateNormal];
            cell.commentButton.tag = kPadding_Two + indexPath.row;

        }
            break;
        case 202:
        {
            [cell.commentButton setTitle:@"评价晒单" forState:UIControlStateNormal];
            cell.commentButton.tag = kPadding_Three + indexPath.row;

            
        }
            break;
        case 203:
        {
            [cell.commentButton setTitle:@"再次购买" forState:UIControlStateNormal];
            cell.commentButton.tag = kPadding_Four + indexPath.row;

            
        }
            break;
        default:
            break;
    }
    
    [cell.commentButton addTarget:self action:@selector(clickToAction:) forControlEvents:UIControlEventTouchUpInside];
    
    RefreshTableView *table = (RefreshTableView *)tableView;
    
    if (indexPath.row < table.dataArray.count) {
        
        OrderModel *aModel = [table.dataArray objectAtIndex:indexPath.row];
        [cell setCellWithModel:aModel];
    }
    
    
    return cell;
}

#pragma - mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
        
    int page = floor((scrollView.contentOffset.x - DEVICE_WIDTH / 2) / DEVICE_WIDTH) + 1;//只要大于半页就算下一页
    NSLog(@"page %d",page);
    //选中状态
    [self controlSelectedButtonTag:page + 100];
    
}


@end
