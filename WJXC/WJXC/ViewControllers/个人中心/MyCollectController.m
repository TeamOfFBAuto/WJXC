//
//  MyCollectController.m
//  WJXC
//
//  Created by lichaowei on 15/7/7.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "MyCollectController.h"
#import "CollectCell.h"
#import "ProductModel.h"
#import "ProductDetailViewController.h"

@interface MyCollectController ()<RefreshDelegate,UITableViewDataSource>
{
    RefreshTableView *_table;
}

@end

@implementation MyCollectController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"我的收藏";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    _table = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH,DEVICE_HEIGHT - 64)];
    _table.refreshDelegate = self;
    _table.dataSource = self;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_table];
    
    [_table showRefreshHeader:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 网络请求

- (void)getCollectionList
{
    //get方式
//    参数：
//    product_id=1   评论id 必填
//    authcode=xxx 或uid=xxx  二者任选其一  uid权重高
    
    NSString *authkey = [GMAPI getAuthkey];
    NSDictionary *params = @{@"authcode":authkey,
                             @"per_page":[NSNumber numberWithInt:20],
                             @"page":[NSNumber numberWithInt:_table.pageNum]};
    
    __weak typeof(_table)weakTable = _table;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:PRODUCT_COLLECT_LIST parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSArray *list = result[@"list"];
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:list.count];
        for (NSDictionary *aDic in list) {
            
            ProductModel *aModel = [[ProductModel alloc]initWithDictionary:aDic];
            [temp addObject:aModel];
        }
        
        [weakTable reloadData:temp pageSize:20];
        
    } failBlock:^(NSDictionary *result) {
        [weakTable loadFail];
    }];
}

- (void)clickToAddProductToShoppingCar:(UIButton *)sender
{
    ProductModel *aModel = _table.dataArray[sender.tag - 100];
    
    int product_num = 1;//测试
    NSString *authcode = [GMAPI getAuthkey];
    
    if (authcode.length == 0) {
        
        [[DBManager shareInstance]insertProduct:aModel];
        
        [LTools showMBProgressWithText:@"添加购物车成功" addToView:self.view];
        
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

/**
 *  取消收藏
 */
-(void)cancelCollectionWithProductId:(NSString *)productId{
    
    if (!productId) {
        return;
    }
    NSDictionary *dic = @{
                          @"product_id":productId,
                          @"authcode":[GMAPI getAuthkey],
                          };
    __weak typeof(self)weakSelf = self;
    __weak typeof(_table)weakTable = _table;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:QUXIAOSHOUCANG parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];

        
        [GMAPI showAutoHiddenMBProgressWithText:[result stringValueForKey:@"msg"] addToView:weakSelf.view];
        
        weakTable.isReloadData = YES;
        weakTable.pageNum = 1;
        [weakSelf getCollectionList];
        
    } failBlock:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];

    }];
}


#pragma mark - 代理

#pragma mark - RefreshDelegate

- (void)loadNewData
{
    [self getCollectionList];
}
- (void)loadMoreData
{
    [self getCollectionList];

}

- (void)loadNewDataForTableView:(UITableView *)tableView
{
    
}
- (void)loadMoreDataForTableView:(UITableView *)tableView
{
    
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"单品详情");
    
    
    ProductDetailViewController *cc = [[ProductDetailViewController alloc]init];
    ProductModel *model = _table.dataArray[indexPath.row];
    cc.product_id = model.product_id;
    [self.navigationController pushViewController:cc animated:YES];
    
    
}

- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath
{
    return 86.f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //todo
        
        ProductModel *model = _table.dataArray[indexPath.row];
        [self cancelCollectionWithProductId:model.product_id];
    }
}
    

// 这里默认删除的按钮为英文，想要改变成中文，需要再实现一个方法。
    
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0){
    
    return @"删除";
}
    
    



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _table.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"CollectCell";
    CollectCell *cell = (CollectCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ProductModel *aModel = _table.dataArray[indexPath.row];
    [cell setCellWithModel:aModel];
    cell.carButton.tag = 100 + indexPath.row;
    [cell.carButton addTarget:self action:@selector(clickToAddProductToShoppingCar:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

@end
