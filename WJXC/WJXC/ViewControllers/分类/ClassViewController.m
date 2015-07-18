//
//  ClassViewController.m
//  WJXC
//
//  Created by lichaowei on 15/6/25.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "ClassViewController.h"
#import "ProductModel.h"

@interface ClassViewController ()<RefreshDelegate,UITableViewDataSource>
{
    RefreshTableView *_table;
}
@end

@implementation ClassViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"分类";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeNull WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
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

#pragma mark - 事件处理

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

#pragma mark - 网络请求

- (void)getProductList
{
//    25、获取商品列表
//http://182.92.106.193:85/index.php?d=api&c=products&m=get_product_list
//    get方式
//    参数：
//    =1000  省份id 必填
//    =1001城市id 必填
//    =1  商品分类id 选填
//    is_new=1   是否新品  选填
//    is_hot=1   是否热卖  选填
//    is_recommend=1  是否精品（推荐） 选填
//    is_seckill=0   是否秒杀  选填
//    order=product_id  排序字段
//    direction=desc   排序顺序  [desc:降序   asc：升序]
//    =1   当前页
//    =10  每页显示数量

    //@"":@"" 城市
    NSDictionary *params = @{@"province_id":@"1000",
                             @"category_id":@"3",
                             @"city_id":@"1001",
                             @"page":[NSNumber numberWithInt:_table.pageNum],
                             @"perpage":[NSNumber numberWithInt:20]};
    
    __weak typeof(_table)weakTable = _table;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:PRODUCT_LIST parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSLog(@"completion:%@",result);
        NSArray *list = result[@"list"];
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:list.count];
        for (NSDictionary *aDic in list) {
            
            ProductModel *aModel = [[ProductModel alloc]initWithDictionary:aDic];
            [temp addObject:aModel];
        }
        [weakTable reloadData:temp pageSize:20];
        
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"failBlock:%@",result);

    }];
}

#pragma mark - 代理

#pragma mark - RefreshDelegate

- (void)loadNewData
{
    [self getProductList];
}
- (void)loadMoreData
{
    [self getProductList];
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
    return 44.f;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _table.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"productCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify];
    }
    
    for (UIView *aView in cell.contentView.subviews) {
        
        if ([aView isKindOfClass:[UIButton class]]) {
            [aView removeFromSuperview];

        }
    }
    
    UIButton *buyBtn = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - 10 - 80, 7, 80, 30) buttonType:UIButtonTypeRoundedRect normalTitle:@"加入购物车+1" selectedTitle:nil target:self action:@selector(clickToAddProductToShoppingCar:)];
    [cell.contentView addSubview:buyBtn];
    [buyBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [buyBtn setBorderWidth:1.f borderColor:DEFAULT_TEXTCOLOR];
    buyBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    buyBtn.tag = 100 + indexPath.row;
    
    ProductModel *aModel = _table.dataArray[indexPath.row];
    cell.textLabel.text = aModel.product_name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"现价:%@",aModel.current_price];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:aModel.cover_pic] placeholderImage:DEFAULT_HEADIMAGE];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    return cell;
}


@end
