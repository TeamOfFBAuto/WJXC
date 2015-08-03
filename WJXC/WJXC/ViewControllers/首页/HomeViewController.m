//
//  HomeViewController.m
//  WJXC
//
//  Created by lichaowei on 15/6/25.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "HomeViewController.h"
#import "ProductDetailViewController.h"
#import "LocationChooseViewController.h"
#import "GsearchViewController.h"
#import "ProductModel.h"
#import "GCycleScrollView.h"
#import "adverModel.h"
#import "HuodongViewController.h"


@interface HomeViewController ()<UITableViewDataSource,RefreshDelegate,GCycleScrollViewDelegate,GCycleScrollViewDatasource>
{
    NSDictionary *_locationDic;
    
    RefreshTableView *_tableView;
    
    CGFloat _cellHeight;//单元格高度
    
    GCycleScrollView *_gscrollView;
    
    NSMutableArray *_TopDataArray;
    
    
    UILabel *_daojishiLabel;//倒计时label
    
}
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    _cellHeight = DEVICE_WIDTH * 0.35;
    
    
    self.myTitle = @"万聚鲜城";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeNull WithRightButtonType:MyViewControllerRightbuttonTypeNull];

    
    self.leftLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
    self.leftLabel.textColor = RGBCOLOR(124, 172, 0);
    self.leftLabel.font = [UIFont systemFontOfSize:12];
    [self.leftLabel addTaget:self action:@selector(pushToLocationChoose) tag:0];
    
    
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc]initWithCustomView:self.leftLabel];
    self.navigationItem.leftBarButtonItem = leftBar;
    
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [searchBtn setFrame:CGRectMake(0, 0, 60, 30)];
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [searchBtn setImage:[UIImage imageNamed:@"homepage_top_search.png"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(pushToSearchVc) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn_right = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -18;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,btn_right];
    
    
    [self getjingweidu];
    
    
    [self getScrollviewNetData];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - RefreshDelegate

- (void)loadNewDataForTableView:(RefreshTableView *)tableView
{
    
    
    NSString *provinceStr = [_locationDic stringValueForKey:@"province"];
    
    NSString *province_id = [NSString stringWithFormat:@"%d",[GMAPI cityIdForName:[_locationDic stringValueForKey:@"province"]]];
    NSString *city_id = [NSString stringWithFormat:@"%d",[GMAPI cityIdForName:[_locationDic stringValueForKey:@"city"]]];
    
    if ([provinceStr isEqualToString:@"北京市"]) {
        city_id = @"0";
    }
    
    NSDictionary *parame = @{
                             @"is_recommend":@"1",
                             @"province_id":province_id,
                             @"city_id":city_id
                             };
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:GET_PRODUCTlIST parameters:parame constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"%@",result);
        
        NSArray *list = [result arrayValueForKey:@"list"];
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *dic in list) {
            ProductModel *model = [[ProductModel alloc]initWithDictionary:dic];
            [arr addObject:model];
        }
        
        [tableView reloadData:arr pageSize:20];
    } failBlock:^(NSDictionary *result) {
        
        [tableView loadFail];
        
    }];
    
    
    [self getScrollviewNetData];
    
    
    
}
- (void)loadMoreDataForTableView:(RefreshTableView *)tableView
{
    
    
    NSString *provinceStr = [_locationDic stringValueForKey:@"province"];
    
    NSString *province_id = [NSString stringWithFormat:@"%d",[GMAPI cityIdForName:[_locationDic stringValueForKey:@"province"]]];
    NSString *city_id = [NSString stringWithFormat:@"%d",[GMAPI cityIdForName:[_locationDic stringValueForKey:@"city"]]];
    
    if ([provinceStr isEqualToString:@"北京市"]) {
        city_id = @"0";
    }
    
    NSDictionary *parame = @{
                             @"is_recommend":@"1",
                             @"province_id":province_id,
                             @"city_id":city_id
                             };
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:GET_PRODUCTlIST parameters:parame constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSLog(@"%@",result);
        
        NSArray *list = [result arrayValueForKey:@"list"];
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *dic in list) {
            ProductModel *model = [[ProductModel alloc]initWithDictionary:dic];
            [arr addObject:model];
        }
        
        [tableView reloadData:arr pageSize:20];
    } failBlock:^(NSDictionary *result) {
        [tableView loadFail];
    }];
    
    
    
    
    
}


- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    ProductDetailViewController *cc = [[ProductDetailViewController alloc]init];
    ProductModel *model = _tableView.dataArray[indexPath.row];
    cc.product_id = model.product_id;
    cc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cc animated:YES];
}


- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    
    return _cellHeight;
}


-(CGFloat)heightForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    CGFloat height = 0;
    
    if (section == 0) {
        height = DEVICE_WIDTH*66.0/750;
    }
    
    return height;
}



- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView{
    
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identitfier = @"identfier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identitfier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identitfier];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    
    ProductModel *model = _tableView.dataArray[indexPath.row];
    UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, DEVICE_WIDTH-10, DEVICE_WIDTH*0.35 -5)];
    [imv sd_setImageWithURL:[NSURL URLWithString:model.cover_pic] placeholderImage:nil];
    [cell.contentView addSubview:imv];

    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    
    if (section == 0) {
        num = _tableView.dataArray.count;
    }
    return num;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UIView *)viewForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_WIDTH*66.0/750)];
    UIImageView *imv = [[UIImageView alloc]initWithFrame:view.bounds];
    [imv setImage:[UIImage imageNamed:@"homepage_jingxuan.png"]];
    [view addSubview:imv];
    

    return view;
}




#pragma mark - MyMethod

//创建循环滚动的scrollview
-(UIView*)creatGscrollView{
    _gscrollView = [[GCycleScrollView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 180)];
    _gscrollView.theGcycelScrollViewType = GCYCELNORMORL;
    [_gscrollView loadGcycleScrollView];
    _gscrollView.tag = 200;
    _gscrollView.delegate = self;
    _gscrollView.datasource = self;
    return _gscrollView;
}


-(void)getScrollviewNetData{
    NSDictionary *parame = @{
                             @"page":@"1",
                             @"perpage":@"10"
                             };
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:GET_HOMESCROLLVIEWDATA parameters:parame constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSLog(@"--------%@",result);
        NSArray *list = [result arrayValueForKey:@"list"];
        
        _TopDataArray = [NSMutableArray arrayWithCapacity:1];
        
        for (NSDictionary *dic in list) {
            adverModel *model = [[adverModel alloc]initWithDictionary:dic];
            [_TopDataArray addObject:model];
        }
        
        [_gscrollView reloadData];
        
    } failBlock:^(NSDictionary *result) {
        
    }];
}


#pragma mark - GCycleScrollViewDelegate && GCycleScrollViewDatasource

//滚动总共几页
- (NSInteger)numberOfPagesWithScrollView:(GCycleScrollView*)theGCycleScrollView
{
    
    NSInteger num = 0;
    if (theGCycleScrollView.tag == 200) {
        num = _TopDataArray.count;
    }
    return num;
    
}

//每一页
- (UIView *)pageAtIndex:(NSInteger)index ScrollView:(GCycleScrollView *)theGCycleScrollView
{
    
    
    if (theGCycleScrollView.tag == 200) {
        UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 180)];
        imv.userInteractionEnabled = YES;
        
        NSLog(@"%@",NSStringFromCGRect(imv.frame));
        
        adverModel *amodel = _TopDataArray[index];
        NSString *str = amodel.cover_pic;
        [imv sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:nil];
        
        if ([amodel.type intValue] == 2) {//秒杀
            
            CGFloat left_right = 30;
            CGFloat up_down = 30;
            
            
            NSDictionary *relative_info = amodel.relative_info;
            NSDictionary *product_info = [relative_info dictionaryValueForKey:@"product_info"];
            NSString *product_name = [product_info stringValueForKey:@"product_name"];
            NSString *miaoshajia = [NSString stringWithFormat:@"秒杀价:%@元",[product_info stringValueForKey:@"current_price"]];
            NSString *yuanjia = [NSString stringWithFormat:@"原价:%@元",[product_info stringValueForKey:@"original_price"]];
            
            
            
            
            UIImageView *backImv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 170)];
            backImv.center = CGPointMake(imv.center.x, imv.center.y - 15);
            [backImv setImage:[UIImage imageNamed:@"homepage_banner_miaosha.png"]];
            [imv addSubview:backImv];
            
            
            
            
            //商品分类
            UILabel *fenleiLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 15, backImv.frame.size.width, 20) title:@"挪威冰鲜" font:10 align:NSTextAlignmentCenter textColor:RGBCOLOR(193, 13, 19)];
            [backImv addSubview:fenleiLabel];
            
            //商品名称
            UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(fenleiLabel.frame)-5, backImv.frame.size.width, 40) title:product_name font:20 align:NSTextAlignmentCenter textColor:[UIColor redColor]];
            [backImv addSubview:nameLabel];
            

            //秒杀价
            UILabel *miaoshajiaLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(nameLabel.frame), backImv.frame.size.width, 24) title:miaoshajia font:15 align:NSTextAlignmentCenter textColor:[UIColor redColor]];
            [backImv addSubview:miaoshajiaLabel];
            //原价
            UILabel *yuanjiaLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(miaoshajiaLabel.frame)-3, backImv.frame.size.width, miaoshajiaLabel.frame.size.height) title:yuanjia font:15 align:NSTextAlignmentCenter textColor:[UIColor grayColor]];
            [backImv addSubview:yuanjiaLabel];

            //秒杀倒计时
            UILabel *miaoshaTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(yuanjiaLabel.frame), backImv.frame.size.width, 20) title:@"倒计时" font:12 align:NSTextAlignmentCenter textColor:[UIColor blackColor]];
            [backImv addSubview:miaoshaTitle];

            _daojishiLabel = [[UILabel alloc]initWithFrame:CGRectMake(miaoshaTitle.frame.origin.x, CGRectGetMaxY(miaoshaTitle.frame), miaoshaTitle.frame.size.width, miaoshaTitle.frame.size.height) title:@"4小时25分36秒" font:12 align:NSTextAlignmentCenter textColor:[UIColor redColor]];
            [backImv addSubview:_daojishiLabel];
            
            
            
        }
        
        return imv;
    }
    
    return [UIView new];
    
}

//点击的哪一页
- (void)didClickPage:(GCycleScrollView *)csView atIndex:(NSInteger)index
{
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"%d",index);
    
    adverModel *model = _TopDataArray[index];
    if ([model.type intValue] == 1) {//活动
        
        HuodongViewController *cc = [[HuodongViewController alloc]init];
        cc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:cc animated:YES];
        
        
        
    }else if ([model.type intValue] == 2){//秒杀
        ProductDetailViewController *cc = [[ProductDetailViewController alloc]init];
        
        NSDictionary *relative_info = model.relative_info;
        NSDictionary *product_info = [relative_info dictionaryValueForKey:@"product_info"];
        cc.product_id = [product_info stringValueForKey:@"product_id"];
        cc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:cc animated:YES];
    }
    
    
    
}




-(void)creatTableView{
    _tableView = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStyleGrouped];
    _tableView.refreshDelegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    UIView *tabHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_WIDTH *375.0/750)];
    tabHeaderView.backgroundColor = [UIColor orangeColor];
    _tableView.tableHeaderView = [self creatGscrollView];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView showRefreshHeader:YES];
    
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
    
    self.leftLabel.text = theString;
    int city_id = [GMAPI cityIdForName:theString];
    NSLog(@"city_id : %d",city_id);
    
    
    [self creatTableView];
    
    
}



-(void)pushToSearchVc{
    NSLog(@"%s",__FUNCTION__);
    
    GsearchViewController *cc = [[GsearchViewController alloc]init];
    cc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cc animated:YES];
    
}


-(void)pushToLocationChoose{
    LocationChooseViewController *cc = [[LocationChooseViewController alloc]init];
    cc.delegate = self;
    cc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cc animated:YES];
}



-(void)setLocationDataWithStr:(NSString *)city{
    self.leftLabel.text = city;
    
    
//    int cityId = [GMAPI findIdFromName:self.leftLabel.text];
    int cityId = [GMAPI cityIdForName:self.leftLabel.text];
    
    NSLog(@"我擦 %d",cityId);
    
    
}



@end
