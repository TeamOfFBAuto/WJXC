//
//  ClassDetailViewController.m
//  WJXC
//
//  Created by gaomeng on 15/7/24.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "ClassDetailViewController.h"
#import "LocationChooseViewController.h"
#import "ProductModel.h"
#import "ClassCustomTableViewCell.h"
#import "ProductDetailViewController.h"
#import "Gbtn.h"

@interface ClassDetailViewController ()<UIScrollViewDelegate,RefreshDelegate,UITableViewDataSource>
{
    NSDictionary *_locationDic;
    int _buttonNum;//button个数
    UIView *_indicator;//指示器
    UIScrollView *_scroll;
    
    RefreshTableView *_tab0;
    RefreshTableView *_tab1;
    RefreshTableView *_tab2;
    
    Gbtn *_priceBtn;
    
    ClassCustomTableViewCell *_tmpCell;
    
}
@end

@implementation ClassDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    NSLog(@"----------%@",self.category_id);
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.myTitle = @"分类";
    
    NSString *tt1 = @"新品";
    NSString *tt2 = @"热卖";
    NSString *tt3 = @"价格";
    
    NSArray *titles = @[tt1,tt2,tt3];
    int count = (int)titles.count;
    CGFloat width = DEVICE_WIDTH / 3.0;
    
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
        //横滑上方的按钮
        
        if (i == 2) {
            _priceBtn = [Gbtn buttonWithType:UIButtonTypeCustom];
            [_priceBtn setTitle:titles[i] forState:UIControlStateNormal];
            [self.view addSubview:_priceBtn];
            _priceBtn.tag = 100 + i;
            _priceBtn.frame = CGRectMake(width * i, 0, width, 40);
            [_priceBtn setTitleColor:[UIColor colorWithHexString:@"646464"] forState:UIControlStateNormal];
            [_priceBtn setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateSelected];
            [_priceBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [_priceBtn addTarget:self action:@selector(clickToSelect:) forControlEvents:UIControlEventTouchUpInside];
            _priceBtn.selected = YES;
            _priceBtn.paixu = @"升序";
            
            [_priceBtn setImage:[UIImage imageNamed:@"classify_top_jt1.png"] forState:UIControlStateNormal];
            
            [_priceBtn setImageEdgeInsets:UIEdgeInsetsMake(0, width - 30, 0, 0)];
            
        }else{
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
        }
        
        
        
        
        RefreshTableView *_table = [[RefreshTableView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH * i, 0, DEVICE_WIDTH,_scroll.height)];
        _table.refreshDelegate = self;
        _table.dataSource = self;
        [_scroll addSubview:_table];
        _table.tag = 200 + i;
        
        if (_table.tag == 200) {
            _tab0 = _table;
            _tab0.separatorStyle = UITableViewCellSeparatorStyleNone;
            [_tab0 showRefreshHeader:YES];
        }else if (_table.tag == 201){
            _tab1 = _table;
            _tab1.separatorStyle = UITableViewCellSeparatorStyleNone;
            [_tab1 showRefreshHeader:YES];
        }else if (_table.tag == 202){
            _tab2 = _table;
            _tab2.separatorStyle = UITableViewCellSeparatorStyleNone;
            [_tab2 showRefreshHeader:YES];
        }
        
    }
  
    
    _indicator = [[UIView alloc]initWithFrame:CGRectMake(0, 38, width, 2)];
    _indicator.backgroundColor = DEFAULT_TEXTCOLOR;
    [self.view addSubview:_indicator];
    
    //默认选中第一个
    [self controlSelectedButtonTag:100];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma - mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    int page = floor((scrollView.contentOffset.x - DEVICE_WIDTH / 2) / DEVICE_WIDTH) + 1;//只要大于半页就算下一页
    NSLog(@"page %d",page);
    //选中状态
    [self controlSelectedButtonTag:page + 100];
    
}



#pragma mark - MyMethod


-(void)creatCustomView{
    
}

-(void)pushToLocationChoose{
    LocationChooseViewController *cc = [[LocationChooseViewController alloc]init];
    cc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cc animated:YES];
}

#pragma mark - 获取经纬度
-(void)getjingweidu{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusRestricted == status) {
        NSLog(@"kCLAuthorizationStatusRestricted 开启定位失败");
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"开启定位失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [al show];
        return;
    }else if (kCLAuthorizationStatusDenied == status){
        NSLog(@"请允许衣加衣使用定位服务");
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请允许衣加衣使用定位服务" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [al show];
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    
    [[GMAPI appDeledate]startDingweiWithBlock:^(NSDictionary *dic) {
        
        [weakSelf theLocationDictionary:dic];
    }];
    
    
    
    
}


- (void)theLocationDictionary:(NSDictionary *)dic{
    
    NSLog(@"%@",dic);
    _locationDic = dic;
    NSLog(@"%@",_locationDic);
    
    NSString *theString;
    
    if ([[dic stringValueForKey:@"province"]isEqualToString:@"北京市"] || [[dic stringValueForKey:@"province"]isEqualToString:@"上海市"] || [[dic stringValueForKey:@"province"]isEqualToString:@"天津市"] || [[dic stringValueForKey:@"province"]isEqualToString:@"重庆市"]) {
        theString = [dic stringValueForKey:@"province"];
    }else{
        theString = [dic stringValueForKey:@"city"];
        
        
    }
    
    [self.leftBtn setTitle:theString forState:UIControlStateNormal];
    int city_id = [GMAPI cityIdForName:theString];
    NSLog(@"city_id : %d",city_id);
    
    
//    [self creatTableView];
    
    [self creatCustomView];
    
    
}



#pragma - mark 网络请求

#pragma - mark 事件处理

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
    
    if (sender.tag == 102) {//价格
        
        if (sender.selected) {
            if ([_priceBtn.paixu isEqualToString:@"升序"]) {
                _priceBtn.paixu = @"降序";
                [_priceBtn setImage:[UIImage imageNamed:@"classify_top_jt2.png"] forState:UIControlStateNormal];
            }else if ([_priceBtn.paixu isEqualToString:@"降序"]){
                _priceBtn.paixu = @"升序";
                [_priceBtn setImage:[UIImage imageNamed:@"classify_top_jt1.png"] forState:UIControlStateNormal];
            }
            [_tab2 showRefreshHeader:YES];
        }
        
    }
    
    
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

- (void)loadNewDataForTableView:(RefreshTableView *)tableView
{
    NSLog(@"%s",__FUNCTION__);
    
    NSString *province_id = [GMAPI getCurrentProvinceId];
    NSString *city_id = [GMAPI getCurrentCityId];
    NSDictionary *parame;
    if (tableView.tag == 200) {//新品
        parame = @{
                   @"is_new":@"1",
                   @"province_id":province_id,
                   @"city_id":city_id,
                   @"category_p_id":self.category_p_id,
                   @"category_id":self.category_id,
                   @"page":[NSString stringWithFormat:@"%d",tableView.pageNum],
                   @"perpage":@"10"
                   };
    }else if (tableView.tag == 201){//热卖
        parame = @{
                   @"is_hot":@"1",
                   @"province_id":province_id,
                   @"city_id":city_id,
                   @"category_p_id":self.category_p_id,
                   @"category_id":self.category_id,
                   @"page":[NSString stringWithFormat:@"%d",tableView.pageNum],
                   @"perpage":@"10"
                   };
    }else if (tableView.tag == 202){//价格
        
        if ([_priceBtn.paixu isEqualToString:@"升序"]) {
            parame = @{
                       @"is_hot":@"1",
                       @"is_new":@"1",
                       @"province_id":province_id,
                       @"city_id":city_id,
                       @"category_p_id":self.category_p_id,
                       @"category_id":self.category_id,
                       @"page":[NSString stringWithFormat:@"%d",tableView.pageNum],
                       @"perpage":@"10",
                       @"order":@"product_price",
                       @"direction":@"asc"
                       };
        }else if ([_priceBtn.paixu isEqualToString:@"降序"]){
            parame = @{
                       @"is_hot":@"1",
                       @"is_new":@"1",
                       @"province_id":province_id,
                       @"city_id":city_id,
                       @"category_p_id":self.category_p_id,
                       @"category_id":self.category_id,
                       @"page":[NSString stringWithFormat:@"%d",tableView.pageNum],
                       @"perpage":@"10",
                       @"order":@"product_price",
                       @"direction":@"desc"
                       };
        }
        
        
    }
    
    
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:GET_PRODUCTlIST parameters:parame constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"%@",result);
        
        NSArray *list = [result arrayValueForKey:@"list"];
        NSMutableArray *productModelArray = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *dic in list) {
            ProductModel *amodel = [[ProductModel alloc]initWithDictionary:dic];
            [productModelArray addObject:amodel];
        }
        
        
        if (tableView.tag == 200) {
            [_tab0 reloadData:productModelArray pageSize:10];
        }else if (tableView.tag == 201){
            [_tab1 reloadData:productModelArray pageSize:10];
        }else if (tableView.tag == 202){
            [_tab2 reloadData:productModelArray pageSize:10];
        }
        
    } failBlock:^(NSDictionary *result) {
        [tableView loadFail];
    }];
    
    
    
}
- (void)loadMoreDataForTableView:(RefreshTableView *)tableView
{
    NSLog(@"%s",__FUNCTION__);
    NSString *province_id = [GMAPI getCurrentProvinceId];
    NSString *city_id = [GMAPI getCurrentCityId];
    NSDictionary *parame;
    if (tableView.tag == 200) {//新品
        parame = @{
                   @"is_new":@"1",
                   @"province_id":province_id,
                   @"city_id":city_id,
                   @"page":[NSString stringWithFormat:@"%d",tableView.pageNum],
                   @"perpage":@"10"
                   };
    }else if (tableView.tag == 201){//热卖
        parame = @{
                   @"is_new":@"1",
                   @"province_id":province_id,
                   @"city_id":city_id,
                   @"page":[NSString stringWithFormat:@"%d",tableView.pageNum],
                   @"perpage":@"10"
                   };
    }else if (tableView.tag == 202){//价格
        parame = @{
                   @"is_hot":@"1",
                   @"province_id":province_id,
                   @"city_id":city_id,
                   @"page":[NSString stringWithFormat:@"%d",tableView.pageNum],
                   @"perpage":@"10"
                   };
    }

    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:GET_PRODUCT_COMMENT parameters:parame constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSLog(@"%@",result);
        NSArray *list = [result arrayValueForKey:@"list"];
        NSMutableArray *productModelArray = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *dic in list) {
            ProductModel *amodel = [[ProductModel alloc]initWithDictionary:dic];
            [productModelArray addObject:amodel];
        }
        
        if (tableView.tag == 200) {
            [_tab0 reloadData:productModelArray pageSize:10];
        }else if (tableView.tag == 201){
            [_tab1 reloadData:productModelArray pageSize:10];
        }else if (tableView.tag == 202){
            [_tab2 reloadData:productModelArray pageSize:10];
        }
        
        
    } failBlock:^(NSDictionary *result) {
        [tableView loadFail];
    }];
    
}


#pragma mark - UITtableViewDatasource

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"aaa";
    ClassCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[ClassCustomTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }

    
    
    if (tableView.tag == 200) {
        cell.type = @"新品";
        ProductModel *amodel = _tab0.dataArray[indexPath.row];
        [cell loadCustomViewWithModel:amodel index:indexPath];
    }else if (tableView.tag == 201){
        cell.type = @"热卖";
        ProductModel *amodel = _tab1.dataArray[indexPath.row];
        [cell loadCustomViewWithModel:amodel index:indexPath];
    }else if (tableView.tag == 202){
        cell.type = @"价格";
        ProductModel *amodel = _tab2.dataArray[indexPath.row];
        [cell loadCustomViewWithModel:amodel index:indexPath];
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    __weak typeof (self)bself = self;
    [cell setGouwucheBlock:^(NSInteger index) {
        [bself clickToAddProductToShoppingCar:index];
    }];
    
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    RefreshTableView *refreshTable = (RefreshTableView *)tableView;
    return refreshTable.dataArray.count;
}

-(CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    CGFloat height = 0;
    if (!_tmpCell) {
        _tmpCell = [[ClassCustomTableViewCell alloc]init];
    }
    
    for (UIView *view in _tmpCell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    if (tableView.tag == 200) {
        ProductModel *amodel = _tab0.dataArray[indexPath.row];
        height = [_tmpCell loadCustomViewWithModel:amodel index:indexPath];
    }else if (tableView.tag == 201){
        ProductModel *amodel = _tab1.dataArray[indexPath.row];
        height = [_tmpCell loadCustomViewWithModel:amodel index:indexPath];
    }else if (tableView.tag == 202){
        ProductModel *amodel = _tab2.dataArray[indexPath.row];
        height = [_tmpCell loadCustomViewWithModel:amodel index:indexPath];
    }

    NSLog(@"-------------------%f",height);
    return height;
}


-(void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    ProductModel *amodel;
    if (tableView.tag == 200) {
        amodel = _tab0.dataArray[indexPath.row];
    }else if (tableView.tag == 201){
        amodel = _tab1.dataArray[indexPath.row];
    }else if (tableView.tag == 202){
        amodel = _tab2.dataArray[indexPath.row];
    }
    
    ProductDetailViewController *cc = [[ProductDetailViewController alloc]init];
    cc.product_id = amodel.product_id;
    cc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cc animated:YES];
}





- (void)clickToAddProductToShoppingCar:(NSInteger)index
{
    ProductModel *aModel;
    
    if (index>0) {//新品
        aModel = _tab0.dataArray[index - 300];
    }else if(index<0){
        aModel = _tab1.dataArray[-index - 300];
    }else if (index >100000){
        aModel = _tab2.dataArray[index - 100000 - 300];
    }
    
    
    
    int product_num = 1;//测试
    
    aModel.addNum = 1;
    
    NSString *authcode = [GMAPI getAuthkey];
    
    if (authcode.length == 0) {
        
        [[DBManager shareInstance]insertProduct:aModel];
        
        [LTools showMBProgressWithText:@"添加成功" addToView:self.view];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_UPDATE_TO_CART object:nil];
        
        
        return;
    }
    
    NSDictionary*dic = @{@"authcode":authcode,
                         @"product_id":aModel.product_id,
                         @"product_num":[NSNumber numberWithInt:product_num]};
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:ORDER_ADD_TO_CART parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [LTools showMBProgressWithText:result[RESULT_INFO] addToView:self.view];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_UPDATE_TO_CART object:nil];
        
    } failBlock:^(NSDictionary *result) {
        
        
    }];
    
}






@end
