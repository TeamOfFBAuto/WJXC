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
#import "GstartView.h"

//测试
#import "AddCommentViewController.h"

@interface HomeViewController ()<UITableViewDataSource,RefreshDelegate,GCycleScrollViewDelegate,GCycleScrollViewDatasource>
{
    NSDictionary *_locationDic;
    
    RefreshTableView *_tableView;
    
    CGFloat _cellHeight;//单元格高度
    
    GCycleScrollView *_gscrollView;
    
    NSMutableArray *_TopDataArray;
    
    
    UILabel *_daojishiLabel;//倒计时label
    
    NSTimer *_timer_daojishi;//倒计时timer
    
    NSString *_endTime;//结束时间
    
}
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    _cellHeight = 130;
    
    
    self.myTitle = @"万聚鲜城";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeNull WithRightButtonType:MyViewControllerRightbuttonTypeNull];

    
    self.leftLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
    self.leftLabel.textColor = RGBCOLOR(124, 172, 0);
    self.leftLabel.font = [UIFont systemFontOfSize:15];
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
    
    
    
    if ([GMAPI cacheForKey:USERLocation]) {
        
        NSDictionary *dic = [GMAPI cacheForKey:USERLocation];
        NSString *str;
        if ([[dic stringValueForKey:@"city"]intValue] == 0) {
            int theId = [[dic stringValueForKey:@"province"]intValue];
            str = [GMAPI cityNameForId:theId];
        }else{
            int theId = [[dic stringValueForKey:@"city"]intValue];
            str = [GMAPI cityNameForId:theId];
        }
        self.leftLabel.text = str;
        
        [self creatTableView];
    }else{
        
        [self getjingweidu];
        
    }
    
    
    
    
    
    
    
    
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
    
    NSString *city_id = [NSString stringWithFormat:@"%d",[GMAPI cityIdForName:[_locationDic stringValueForKey:@"city"]]];
    
    if ([provinceStr isEqualToString:@"北京市"]) {
        city_id = @"0";
    }
    
    
    NSDictionary *dic = [GMAPI cacheForKey:USERLocation];
    
    
    NSDictionary *parame = @{
                             @"is_recommend":@"1",
                             @"province_id":[dic stringValueForKey:@"province"],
                             @"city_id":[dic stringValueForKey:@"city"],
                             @"page":[NSString stringWithFormat:@"%d",_tableView.pageNum],
                             @"perpage":@"10"
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
    
    NSString *city_id = [NSString stringWithFormat:@"%d",[GMAPI cityIdForName:[_locationDic stringValueForKey:@"city"]]];
    
    if ([provinceStr isEqualToString:@"北京市"]) {
        city_id = @"0";
    }
    
    NSDictionary *dic = [GMAPI cacheForKey:USERLocation];
    
    NSDictionary *parame = @{
                             @"is_recommend":@"1",
                             @"province_id":[dic stringValueForKey:@"province"],
                             @"city_id":[dic stringValueForKey:@"city"],
                             @"page":[NSString stringWithFormat:@"%d",_tableView.pageNum],
                             @"perpage":@"10"
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
        height = 35;
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
    
    
    
    UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, DEVICE_WIDTH-10, 130 -5)];
    imv.backgroundColor = [UIColor whiteColor];
    [cell.contentView addSubview:imv];
    
    
    UIImageView *picImv = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, imv.frame.size.width*0.5, imv.frame.size.height)];
    [picImv sd_setImageWithURL:[NSURL URLWithString:model.cover_pic] placeholderImage:[UIImage imageNamed:@"default01.png"]];
    [cell.contentView addSubview:picImv];
    
    
    UIView *infoView = [[UIView alloc]initWithFrame:CGRectMake(imv.frame.size.width*0.5, 0, imv.frame.size.width*0.5-10, imv.frame.size.height)];
//    infoView.backgroundColor = [UIColor orangeColor];
    [imv addSubview:infoView];
    
    //产品名
    UILabel *ttLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, infoView.frame.size.width, 30) title:model.product_name font:12 align:NSTextAlignmentRight textColor:[UIColor blackColor]];
    ttLabel.numberOfLines = 2;
    [infoView addSubview:ttLabel];
    
    //价格
    NSString *pp = [NSString stringWithFormat:@"￥%@",model.current_price];
    UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(ttLabel.frame)+5, ttLabel.frame.size.width, ttLabel.frame.size.height*0.5) title:pp font:12 align:NSTextAlignmentRight textColor:RGBCOLOR(241, 113, 0)];
    [infoView addSubview:priceLabel];
    
    //评价星星
    GstartView *cc = [[GstartView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(priceLabel.frame)+5, 60, 13)];
    cc.maxStartNum = 5;
    cc.startNum = [model.star_level floatValue];
    [cc updateStartNum];
    [infoView addSubview:cc];
    
    //评价
    NSString *ping = [NSString stringWithFormat:@"已有%@人评价",model.comment_num];
    UILabel *pingjiaLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(cc.frame), cc.frame.origin.y, infoView.frame.size.width - cc.frame.size.width, 15) title:ping font:12 align:NSTextAlignmentRight textColor:RGBCOLOR(121,170,0)];
    CGFloat kuan = pingjiaLabel.frame.size.width;
    [pingjiaLabel setMatchedFrame4LabelWithOrigin:CGPointMake(CGRectGetMaxX(cc.frame), cc.frame.origin.y-1) height:15 limitMaxWidth:infoView.frame.size.width - cc.frame.size.width];
    CGFloat newKuan = pingjiaLabel.frame.size.width;
    
    [cc setLeft:cc.left+kuan-newKuan];
    [pingjiaLabel setLeft:CGRectGetMaxX(cc.frame)];
    
    [infoView addSubview:pingjiaLabel];
    
    
    
    
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
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 35)];
    view.backgroundColor = [UIColor whiteColor];
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(2.5, 6, 2, 30)];
    line.backgroundColor = RGBCOLOR(123, 170, 0);
    [view addSubview:line];
    UILabel *tt = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(line.frame)+5, line.frame.origin.y, 60, line.frame.size.height) title:@"精选" font:15 align:NSTextAlignmentLeft textColor:[UIColor blackColor]];
    [view addSubview:tt];
    
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
        [imv sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"default02.png"]];
        
        if ([amodel.type intValue] == 2) {//秒杀
            
            
            NSDictionary *relative_info = amodel.relative_info;
            NSDictionary *product_info = [relative_info dictionaryValueForKey:@"product_info"];
            NSString *product_name = [product_info stringValueForKey:@"product_name"];
            
            
            
            
            
            
            UIImageView *backImv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 170)];
            backImv.center = CGPointMake(imv.center.x, imv.center.y - 15);
            [backImv setImage:[UIImage imageNamed:@"homepage_banner_miaosha.png"]];
            [imv addSubview:backImv];
            
            
            
            
            //商品分类
            NSString *fenf = [NSString stringWithFormat:@"········%@········",[product_info stringValueForKey:@"category_name"]];
            UILabel *fenleiLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 15, backImv.frame.size.width, 20) title:fenf font:13 align:NSTextAlignmentCenter textColor:RGBCOLOR(78, 82, 89)];
            [backImv addSubview:fenleiLabel];
            
            //商品名称
            UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(fenleiLabel.frame)-5, backImv.frame.size.width, 40) title:product_name font:20 align:NSTextAlignmentCenter textColor:[UIColor blackColor]];
            [backImv addSubview:nameLabel];
            

            //秒杀价
            
            
            UILabel *miaoshajiaLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(nameLabel.frame), backImv.frame.size.width, 24) title:nil font:15 align:NSTextAlignmentCenter textColor:[UIColor redColor]];
            [backImv addSubview:miaoshajiaLabel];
            NSString *dld = [product_info stringValueForKey:@"current_price"];
            NSString *miaoshajia = [NSString stringWithFormat:@"秒杀价%@元",dld];
            NSMutableAttributedString  *aaa = [[NSMutableAttributedString alloc]initWithString:miaoshajia];
            [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, 3)];
            [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:21] range:NSMakeRange(3, dld.length)];
            miaoshajiaLabel.attributedText = aaa;
            
            //原价
            UILabel *yuanjiaLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(miaoshajiaLabel.frame)-3, backImv.frame.size.width, miaoshajiaLabel.frame.size.height) title:nil font:15 align:NSTextAlignmentCenter textColor:RGBCOLOR(93, 87, 96)];
            NSString *ddle = [product_info stringValueForKey:@"original_price"];
            NSString *yuanjia = [NSString stringWithFormat:@"原价%@元",ddle];
            NSMutableAttributedString  *yyy = [[NSMutableAttributedString alloc]initWithString:yuanjia];
            [yyy addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(2, ddle.length)];
            yuanjiaLabel.attributedText = yyy;
            [backImv addSubview:yuanjiaLabel];

            //秒杀倒计时
            _endTime = [relative_info stringValueForKey:@"end_time"];
            _timer_daojishi = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(ggggg) userInfo:nil repeats:YES];
            [_timer_daojishi fire];
            UILabel *miaoshaTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(yuanjiaLabel.frame), backImv.frame.size.width, 20) title:@"倒计时" font:12 align:NSTextAlignmentCenter textColor:RGBCOLOR(93, 87, 96)];
            [backImv addSubview:miaoshaTitle];

            _daojishiLabel = [[UILabel alloc]initWithFrame:CGRectMake(miaoshaTitle.frame.origin.x, CGRectGetMaxY(miaoshaTitle.frame), miaoshaTitle.frame.size.width, miaoshaTitle.frame.size.height) title:nil font:12 align:NSTextAlignmentCenter textColor:[UIColor redColor]];
            [backImv addSubview:_daojishiLabel];
            
            
            
        }
        
        return imv;
    }
    
    return [UIView new];
    
}



-(void)ggggg{
    
    NSString *haha = [GMAPI daojishi:_endTime];
    _daojishiLabel.text = haha;
}




//点击的哪一页
- (void)didClickPage:(GCycleScrollView *)csView atIndex:(NSInteger)index
{
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"%d",index);
    
    adverModel *model = _TopDataArray[index];
    if ([model.type intValue] == 1) {//活动
        
//        HuodongViewController *cc = [[HuodongViewController alloc]init];
//        cc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:cc animated:YES];
        
        
        //测试评价晒单
        AddCommentViewController *cc = [[AddCommentViewController alloc]init];
        cc.theModelArray = _tableView.dataArray;
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
    
    int cityId = 0;
    int procinceId = 0;
    
    if ([[dic stringValueForKey:@"province"]isEqualToString:@"北京市"] || [[dic stringValueForKey:@"province"]isEqualToString:@"上海市"] || [[dic stringValueForKey:@"province"]isEqualToString:@"天津市"] || [[dic stringValueForKey:@"province"]isEqualToString:@"重庆市"]) {
        theString = [dic stringValueForKey:@"province"];
        procinceId = [GMAPI cityIdForName:theString];
        cityId = 0;
    }else{
        theString = [dic stringValueForKey:@"city"];
        procinceId =[GMAPI cityIdForName:[dic stringValueForKey:@"province"]];
        cityId = [GMAPI cityIdForName:[dic stringValueForKey:@"city"]];
    }
    
    self.leftLabel.text = theString;
    int city_id = [GMAPI cityIdForName:theString];
    NSLog(@"city_id : %d",city_id);
    
    
    
    NSDictionary *cachDic = @{
                          @"province":[NSString stringWithFormat:@"%d",procinceId],
                          @"city":[NSString stringWithFormat:@"%d",cityId]
                          };
    [GMAPI cache:cachDic ForKey:USERLocation];
    
    
    
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



-(void)setLocationDataWithCityStr:(NSString *)city provinceStr:(NSString *)province{
    self.leftLabel.text = city;
    
    int cityId = [GMAPI cityIdForName:self.leftLabel.text];
    
    NSLog(@"我擦 %d",cityId);
    
    
    
    NSString *pStr = [NSString stringWithFormat:@"%d",[GMAPI cityIdForName:province]];
    NSString *cStr = [NSString stringWithFormat:@"%d",[GMAPI cityIdForName:city]];
    
    if ([pStr isEqualToString:cStr]) {
        cStr = @"0";
    }
    
    NSDictionary *dic = @{
                      @"province":pStr,
                      @"city":cStr
                      };
    
    
    [GMAPI cache:dic ForKey:USERLocation];
    
    
    [_tableView showRefreshHeader:YES];
    
    
}



@end
