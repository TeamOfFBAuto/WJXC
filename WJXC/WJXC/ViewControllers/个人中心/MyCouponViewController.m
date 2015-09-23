//
//  MyCouponViewController.m
//  WJXC
//
//  Created by gaomeng on 15/9/23.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "MyCouponViewController.h"
#import "CouponModel.h"

@interface MyCouponViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *_youhuiquanArray;//优惠券数组
    NSArray *_disable_use_Array;//不可用的优惠券
    
    UITableView *_tab;
}
@end

@implementation MyCouponViewController


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.myTitle = @"我的优惠券";
    
    
    
    
    [self getYouhuiquan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - MyMethod

//视图创建
-(void)creatTab{
    _tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStyleGrouped];
    _tab.delegate = self;
    _tab.dataSource = self;
    [self.view addSubview:_tab];
}


//网络请求
-(void)getYouhuiquan{
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary * parame  = @{
                               @"page":@"1",
                               @"per_page":@"100",
                               @"authcode":[GMAPI getAuthkey]
                               };
    
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:MYYOUHUIQUAN_LIST parameters:parame constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSArray *tmp = [result arrayValueForKey:@"coupon_list"];
        NSMutableArray *m_tmp = [NSMutableArray arrayWithCapacity:1];
        NSMutableArray *m_tmp_dis = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *dic in tmp) {
            CouponModel *model = [[CouponModel alloc]initWithDictionary:dic];
            if (model.enable_use == 1) {//可用
                [m_tmp addObject:model];
            }else if (model.enable_use == 0){//不可用
                [m_tmp_dis addObject:model];
            }
            
            
            
        }
        _youhuiquanArray = (NSArray*)m_tmp;
        _disable_use_Array = (NSArray *)m_tmp_dis;
        
        
        [self creatTab];
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
       
        
    } failBlock:^(NSDictionary *result) {
        NSLog(@"failBlock == %@",result);
    }];
  
    
}



-(void)loadYouhuiquanCustomCell:(NSIndexPath*)indexPath tableViewCell:(UITableViewCell*)cell type:(int)theType{
    
    
    
    NSArray *dataArray;
    if (theType == 0) {//可用
        dataArray = _youhuiquanArray;
    }else if (theType == 1){//失效
        dataArray = _disable_use_Array;
    }
    
    
    
    //数据model
    CouponModel *aModel = dataArray[indexPath.row];
    
    UIImageView *backImv = [[UIImageView alloc]initWithFrame:CGRectMake(15, 5, DEVICE_WIDTH-10, 200*DEVICE_WIDTH/750.0-10)];
    if (theType == 0) {//可用
        [backImv setImage:[UIImage imageNamed:@"youhuiquankuang.png"]];
    }else if (theType == 1){//失效
        [backImv setImage:[UIImage imageNamed:@"youhuiquan_gray.png"]];
    }
    
    [cell.contentView addSubview:backImv];
    
    
    
    UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 250.0/750*DEVICE_WIDTH, backImv.frame.size.height)];
    tLabel.font = [UIFont systemFontOfSize:30];
    tLabel.textAlignment = NSTextAlignmentCenter;
    if (theType == 0) {//可用
        tLabel.textColor = RGBCOLOR(124, 171, 0);
    }else if (theType == 1){//失效
        tLabel.textColor = RGBCOLOR(134, 135, 136);
    }
    
    [backImv addSubview:tLabel];
    
    //分割线
    UIView *fline = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(tLabel.frame), backImv.frame.size.height*0.18, 1, backImv.frame.size.height*0.64)];
    if (theType == 0) {//可用
        fline.backgroundColor = RGBCOLOR(174, 207, 82);
    }else if (theType == 1){//失效
        fline.backgroundColor = RGBCOLOR(134, 135, 136);
    }
    
    [backImv addSubview:fline];
    
    
    //描述
    UILabel *miaoshuLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(fline.frame)+35.0/750*DEVICE_WIDTH, fline.frame.origin.y, 400.0/750*DEVICE_WIDTH, fline.frame.size.height*0.5)];
    miaoshuLabel.textColor = tLabel.textColor;
    miaoshuLabel.font = [UIFont systemFontOfSize:15];
    [backImv addSubview:miaoshuLabel];
    
    //使用期限
    UILabel *useTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(miaoshuLabel.frame.origin.x, CGRectGetMaxY(miaoshuLabel.frame), miaoshuLabel.frame.size.width, miaoshuLabel.frame.size.height)];
    useTimeLabel.textColor = miaoshuLabel.textColor;
    useTimeLabel.font = [UIFont systemFontOfSize:14];
    NSString *t1 = [GMAPI timechangeAll3:aModel.use_start_time];
    NSString *t2 = [GMAPI timechangeAll3:aModel.use_end_time];
    useTimeLabel.text = [NSString stringWithFormat:@"%@-%@",t1,t2];
    [backImv addSubview:useTimeLabel];
    
    
    
    
    
    
    int type = [aModel.type intValue];
    
    if (type == 1) {//满减
        tLabel.text = [NSString stringWithFormat:@"%@元",aModel.minus_money];
        miaoshuLabel.text = [NSString stringWithFormat:@"满%@元可使用",aModel.full_money];
        
    }else if (type == 2){//折扣
        NSString *discount = [NSString stringWithFormat:@"%.1f",[aModel.discount_num floatValue] * 10];
        tLabel.text = [NSString stringWithFormat:@"%@折",discount];
        miaoshuLabel.text = [NSString stringWithFormat:@"全场通用"];
        
    }
    
    
    
    if (theType == 1){//失效
        UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(fline.frame), 5, backImv.frame.size.height - 10, backImv.frame.size.height - 10)];
        [backImv addSubview:imv];
        
        if (aModel.disable_use_reason == 1) {//已使用过
            [imv setImage:[UIImage imageNamed:@"yishiyong.png"]];
        }else if (aModel.disable_use_reason == 2){//已过期
            [imv setImage:[UIImage imageNamed:@"yiguoqi.png"]];
        }
    }

    
    
    
    
    
    
}


#pragma mark - UITableViewDelegate && UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    if (indexPath.section == 0) {//可用优惠券
        
        [self loadYouhuiquanCustomCell:indexPath tableViewCell:cell type:0];
        
    }else if (indexPath.section == 1){//已失效
        [self loadYouhuiquanCustomCell:indexPath tableViewCell:cell type:1];
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0;
    height = 200*DEVICE_WIDTH/750.0;
    return height;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    if (section == 0) {
        num = _youhuiquanArray.count;
    }else if (section == 1){
        num = _disable_use_Array.count;
    }
    
    return num;
}



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0.01)];
    
    if (section == 1) {
        [view setFrame:CGRectMake(0, 0, DEVICE_WIDTH, 70.0/750*DEVICE_WIDTH)];
        view.backgroundColor = RGBCOLOR(241, 242, 244);
        UILabel *l = [[UILabel alloc]initWithFrame:view.bounds];
        l.textAlignment = NSTextAlignmentCenter;
        [view addSubview:l];
        l.font = [UIFont systemFontOfSize:11];
        l.textColor = RGBCOLOR(80, 81, 82);
        l.text = @"已失效的券";
        [view addSubview:l];
    }
    
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat height = 0;
    if (section == 0) {
        height = 0.01;
    }else if (section == 1){
        height = 70.0/750*DEVICE_WIDTH;
    }
    
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}










@end
