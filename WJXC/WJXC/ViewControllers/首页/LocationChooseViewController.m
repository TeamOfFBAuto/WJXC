//
//  LocationChooseViewController.m
//  WJXC
//
//  Created by gaomeng on 15/7/19.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "LocationChooseViewController.h"
#import "HomeViewController.h"
#define MY_MACRO_NAME ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
@interface LocationChooseViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UITextField *_searchTextField;
    UITableView *_tabelView;
    
    NSDictionary *_locationDic;
    
    NSMutableArray *_dataArray;
    
    UIView *_tmpview;
    
    
    NSMutableArray *_provinceArray;
    NSMutableArray *_citiesArray;
    
    
    int _isOpen[500];
    
    NSArray *_hotCityArray;
    
    
    
}




@end

@implementation LocationChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.myTitle = @"选择城市";

    
    
    
    //收键盘
    UIControl *ccc = [[UIControl alloc]initWithFrame:self.view.bounds];
    [ccc addTarget:self action:@selector(gShou) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ccc];
    
    
    
    
    for (int i=0; i<500; i++) {
        _isOpen[i]=0;
    }
//    _isOpen[0]=1;
    
    
    
    
    [self getHotCity];
    
    
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//从网络获取热门城市
-(void)getHotCity{
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:GET_HOTCITY parameters:nil constructingBodyBlock:nil completion:^(NSDictionary *result) {
        _hotCityArray = [result arrayValueForKey:@"list"];
        _tmpview = [self creatHotCityView];
        [self creatTab];
    } failBlock:^(NSDictionary *result) {
        _tmpview = [self creatHotCityView];
        [self creatTab];
    }];
    
    
    
}


#pragma mark - UITableViewDataSouce && UITableViewDelegate


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _provinceArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger num = 0;
    
    NSArray *citiArray = _citiesArray[section];
    
    
    if (!_isOpen[section]) {
        num=0;
    }else{
        num = citiArray.count;
    }
    
    return num;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view;

    view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 44)];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, 44)];
    titleLabel.font = [UIFont systemFontOfSize:15];
    NSString*provinceStr = _provinceArray[section];
    titleLabel.text = provinceStr;
        
    [view addSubview:titleLabel];
    view.backgroundColor = [UIColor whiteColor];
    
    view.tag = section +10;
    
    
    
    if ([provinceStr isEqualToString:@"北京市"] || [provinceStr isEqualToString:@"上海市"] || [provinceStr isEqualToString:@"天津市"] || [provinceStr isEqualToString:@"重庆市"]){
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(chooseTheStr:)];
        [view addGestureRecognizer:tap];
        
    }else{
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ggShouFang:)];
        [view addGestureRecognizer:tap];
        
        UIButton *jiantouBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        jiantouBtn.backgroundColor = [UIColor redColor];
        [jiantouBtn setFrame:CGRectMake(DEVICE_WIDTH-44, 0, 44, 44)];
        jiantouBtn.userInteractionEnabled = NO;
        [view addSubview:jiantouBtn];
        
        if ( !_isOpen[view.tag-10]) {
            [jiantouBtn setImage:[UIImage imageNamed:@"buy_jiantou_d.png"] forState:UIControlStateNormal];
        }else{
            [jiantouBtn setImage:[UIImage imageNamed:@"buy_jiantou_u.png"] forState:UIControlStateNormal];
        }
    }
    
        
    return view;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *citiesArray = _citiesArray[indexPath.section];
    NSString *cityName = citiesArray[indexPath.row];
    
    NSString *provinceName = _provinceArray[indexPath.section];
    
    [self.delegate setLocationDataWithCityStr:cityName provinceStr:provinceName];
    [self.navigationController popViewControllerAnimated:YES];
}




#pragma mark - 点击section选择直辖市
-(void)chooseTheStr:(UIGestureRecognizer*)ges{
    NSLog(@"%s",__FUNCTION__);
    
     NSString *str = _provinceArray[ges.view.tag - 10];
    
    [self.delegate setLocationDataWithCityStr:str provinceStr:str];
    [self.navigationController popViewControllerAnimated:YES];
    
    
}


-(void)ggShouFang:(UIGestureRecognizer*)ges{
    
    _isOpen[ges.view.tag-10]=!_isOpen[ges.view.tag-10];
    
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:ges.view.tag-10];
    [_tabelView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat height = 0;

    height = 44;
    return height;

}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0.5)];
    view.backgroundColor = RGBCOLOR(200, 199, 204);
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *str = @"dddd";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    
    
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    
    cell.backgroundColor= RGBCOLOR(217, 217, 217);
    
    
    UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH-20, 44)];
    tLabel.font = [UIFont systemFontOfSize:15];
    
    
    NSArray *citiesArray = _citiesArray[indexPath.section];
    NSString *cityName = citiesArray[indexPath.row];
    
    tLabel.text = cityName;
    
    [cell.contentView addSubview:tLabel];
    
    
    
    
    
    
    
    
    return cell;
}






-(UIView*)creatHotCityView{
    
    CGFloat height = 0.0f;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 50)];
    view.backgroundColor = [UIColor whiteColor];
    
    
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 60, 20)];
    lab.text = @"热门城市";
    lab.font = [UIFont boldSystemFontOfSize:15];
    [view addSubview:lab];
    
    UILabel *nowLocationLabel_t = [[UILabel alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(lab.frame)+15, 85, 12)];
    nowLocationLabel_t.font = [UIFont systemFontOfSize:12];
    nowLocationLabel_t.text = @"当前地理位置为";
    [view addSubview:nowLocationLabel_t];
    
    self.nowLocationLabel_c = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(nowLocationLabel_t.frame)+15, nowLocationLabel_t.frame.origin.y, 85, 12)];
    self.nowLocationLabel_c.font = [UIFont systemFontOfSize:12];
    [view addSubview:self.nowLocationLabel_c];
    
    
    __weak typeof (self)bself = self;
    
    [[GMAPI appDeledate]startDingweiWithBlock:^(NSDictionary *dic) {
        
        [bself theLocationDictionary:dic];
    }];
    
    
    
    NSInteger totle = _hotCityArray.count;
    CGFloat jianju = 10;//间距
    int sumOneRow = 5;//每行几个
    int btnHeight = 25;//按钮高
    CGFloat theWidth = (DEVICE_WIDTH - 60 - sumOneRow * jianju)*1.0f/sumOneRow;//按钮宽度
    
    for (int i = 0; i<totle; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:_hotCityArray[i] forState:UIControlStateNormal];
        btn.layer.borderColor = [RGBCOLOR(122, 172, 0)CGColor];
        [btn setTitleColor:RGBCOLOR(122, 172, 0) forState:UIControlStateNormal];
        btn.layer.borderWidth = 0.5;
        btn.layer.cornerRadius = 4;
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        btn.layer.masksToBounds = YES;
        btn.tag = i+10000;
        
        [btn setFrame:CGRectMake(nowLocationLabel_t.frame.origin.x+i%sumOneRow*(jianju +theWidth), CGRectGetMaxY(nowLocationLabel_t.frame)+10 +i/sumOneRow*(25+jianju) ,theWidth, btnHeight)];
        [view addSubview:btn];
        
        height = CGRectGetMaxY(btn.frame)+10;
        
        [btn addTarget:self action:@selector(hotCityClicked:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    CGRect r = view.frame;
    r.size.height = height;
    view.frame = r;
    
    NSLog(@"-------------------------%f",r.size.height);
    
    return view;
    
}



#pragma mark - 点击热门城市
-(void)hotCityClicked:(UIButton *)sender{
    NSString *str = [NSString stringWithFormat:@"%@市",sender.titleLabel.text];
    
    int aa = [GMAPI cityIdForName:str];
    NSString *aaa = [NSString stringWithFormat:@"%d",aa];
    aaa = [aaa substringWithRange:NSMakeRange(0, 2)];
    aaa = [aaa stringByAppendingString:@"00"];
    aa = [aaa intValue];
    NSString *ppp = [GMAPI cityNameForId:aa];
    [self.delegate setLocationDataWithCityStr:str provinceStr:ppp];
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)creatTab{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"garea" ofType:@"plist"];
    NSArray *arr = [NSArray arrayWithContentsOfFile:path];
    
    
    _provinceArray = [NSMutableArray arrayWithCapacity:1];//省份数组
    _citiesArray = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *dic in arr) {
        NSString *province = [dic stringValueForKey:@"State"];
        if ([province isEqualToString:@"省份"]) {
            continue;
        }
        [_provinceArray addObject:province];
        
        
        NSArray *cityArray = [dic arrayValueForKey:@"Cities"];
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *citydic in cityArray) {
            NSString *city = [citydic stringValueForKey:@"city"];
            if ([city isEqualToString:@"市区县"]) {
                continue;
            }
            [array addObject:city];
        }
        
        [_citiesArray addObject:array];
        
    }
    
    
    
    
    
    
    
    _tabelView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-64) style:UITableViewStyleGrouped];
    
    _tabelView.delegate = self;
    _tabelView.dataSource = self;
    [self.view addSubview:_tabelView];
    
    _tabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _tabelView.tableHeaderView = _tmpview;
    
}


-(void)gShou{
    [_searchTextField resignFirstResponder];
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
    
    self.nowLocationLabel_c.text = theString;
    self.nowLocationLabel_c.textColor = RGBCOLOR(241, 115, 0);
    int city_id = [GMAPI cityIdForName:theString];
    NSLog(@"city_id : %d",city_id);
    
}









@end
