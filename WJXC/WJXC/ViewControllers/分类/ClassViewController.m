//
//  ClassViewController.m
//  WJXC
//
//  Created by lichaowei on 15/6/25.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "ClassViewController.h"
#import "ProductModel.h"

#import "GtopScrollView.h"
#import "ClassView.h"
#import "ClassDetailViewController.h"


@interface ClassViewController ()<RefreshDelegate,UITableViewDataSource,UITableViewDelegate>
{
    RefreshTableView *_table;
    
    NSArray *_dataArray;//数据源
    
    GtopScrollView *_topScrollView;//楼层选择view
    
    UITableView *_tabelView;
    
    NSInteger _selectRow;
    
    
    UIScrollView *_rightView;
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
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _selectRow = 0;
    
    
    [self prepareNetData];
  
    
    
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

#pragma mark - 网络请求

- (void)getProductList
{
//    25、获取商品列表
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
    NSString *province_id = [GMAPI getCurrentProvinceId];
    NSString *city_id = [GMAPI getCurrentCityId];
    NSDictionary *params = @{@"province_id":province_id,
                             @"category_id":@"3",
                             @"city_id":city_id,
                             @"page":[NSNumber numberWithInt:_table.pageNum],
                             @"perpage":[NSNumber numberWithInt:20]};
    
    __weak typeof(_table)weakTable = _table;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:PRODUCT_LIST parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        DDLOG(@"completion:%@",result);
        NSArray *list = result[@"list"];
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:list.count];
        for (NSDictionary *aDic in list) {
            
            ProductModel *aModel = [[ProductModel alloc]initWithDictionary:aDic];
            [temp addObject:aModel];
        }
        [weakTable reloadData:temp pageSize:20];
        
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"failBlock:%@",result);
        [weakTable loadFail];

    }];
}


#pragma mark - MyMethod
-(void)prepareNetData{
    
    
    NSDictionary *parameters = @{
                                 
                                 };
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:GET_PRODUCT_CLASS parameters:parameters constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        DDLOG(@"%@",result);
        
        NSArray *list = [result arrayValueForKey:@"list"];
        _dataArray = list;
        
        
        _tabelView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 80, DEVICE_HEIGHT-64-44) style:UITableViewStylePlain];
        _tabelView.backgroundColor = RGBCOLOR(241, 240, 245);
        _tabelView.delegate = self;
        _tabelView.dataSource = self;
        [self.view addSubview:_tabelView];
        _tabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        
        _rightView = [[UIScrollView alloc]initWithFrame:CGRectMake(80, 0, DEVICE_WIDTH - 80, DEVICE_HEIGHT - 64- 44)];
        _rightView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_rightView];
        
        [self reloadRightViewWithTag:0];
    
        
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}


-(void)reloadRightViewWithTag:(NSInteger)theTag{
    NSDictionary *dic = _dataArray[theTag];
    NSArray *child = [dic arrayValueForKey:@"child"];
    
    for (UIView *view in _rightView.subviews) {
        [view removeFromSuperview];
    }
    
    
    NSInteger num_oneRow = 3;
    CGFloat viewJiange = 10;
    CGFloat viewWidth = (_rightView.frame.size.width - 4*viewJiange)/num_oneRow;
    CGFloat viewHeight = viewWidth + 20;
    
    CGFloat height = 0;
    
    for (int i = 0; i<child.count; i++) {
        NSDictionary *dic = child[i];
        ClassView *view = [[ClassView alloc]initWithFrame:CGRectMake(10+i%3*(viewWidth+viewJiange), 10+i/3*(viewHeight+viewJiange), viewWidth, viewHeight)];
        [_rightView addSubview:view];
        view.section = theTag;
        view.row = i;
        
        UITapGestureRecognizer *tt = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(smallClassViewClickedWithIndexPath:)];
        [view addGestureRecognizer:tt];
        
        
        NSString *imgUrl = [dic stringValueForKey:@"cover_pic"];
        UIImageView *imagev = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, viewWidth, viewWidth)];
        [imagev sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"default.png"]];
        [view addSubview:imagev];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(imagev.frame), viewWidth, 20)];
        titleLabel.text = [dic stringValueForKey:@"category_name"];
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [view addSubview:titleLabel];
        
        height = CGRectGetMaxY(view.frame)+10;
    }
    
    
    _rightView.contentSize = CGSizeMake(DEVICE_WIDTH - 80, height);
//    _rightView.frame = CGRectMake(80, 0, DEVICE_WIDTH - 80,height);
//    _rightView.backgroundColor = [UIColor redColor];
    
    
}



-(void)smallClassViewClickedWithIndexPath:(UITapGestureRecognizer*)sender{
    ClassView *cc = (ClassView*)sender.view;
    NSInteger section = cc.section;
    NSInteger row = cc.row;
    
    NSDictionary *dic = _dataArray[section];
    
    NSString *category_p_id = [dic stringValueForKey:@"category_id"];//一级分类
    
    NSArray *child = [dic arrayValueForKey:@"child"];
    NSDictionary *detail = child[row];
    
    NSString *category_id = [detail stringValueForKey:@"category_id"];//二级分类
    
    ClassDetailViewController *ccc = [[ClassDetailViewController alloc]init];
    ccc.category_p_id = category_p_id;
    ccc.category_id = category_id;
    ccc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:ccc animated:YES];
    
}



#pragma mark - UITableViewDelegate && UITableViewDatasource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    NSDictionary *dic = _dataArray[indexPath.row];
    
    NSString *title = [dic stringValueForKey:@"category_name"];
    
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 80, 50)];
    [btn setBackgroundImage:[UIImage imageNamed:@"gbtnGray.png"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"gbtnWhite.png"] forState:UIControlStateSelected];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.tag = indexPath.row+10;
    [btn addTarget:self action:@selector(classClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btn];
    
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(79.5, 0, 0.5, 50)];
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 49.5, 80, 0.5)];
    line1.backgroundColor = RGBCOLOR(226, 226, 226);
    line2.backgroundColor = RGBCOLOR(226, 226, 226);
    
    [cell.contentView addSubview:line1];
    [cell.contentView addSubview:line2];
    
    
    if (indexPath.row == _selectRow) {
        line1.hidden = YES;
        btn.selected = YES;
    }else{
        line1.hidden = NO;
        btn.selected = NO;
    }
    
    
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}


-(void)classClicked:(UIButton *)sender{
    
    
    NSInteger index = sender.tag - 10;
    if (index == _selectRow) {
        
    }else{
        _selectRow = index;
        sender.selected = YES;
        
        [self reloadRightViewWithTag:_selectRow];
        [_tabelView reloadData];
    }
    
    
    
}



@end
