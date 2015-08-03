//
//  GsearchViewController.m
//  WJXC
//
//  Created by gaomeng on 15/7/19.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "GsearchViewController.h"
#import "ProductModel.h"
#import "SeachCustomTableViewCell.h"
#import "ProductDetailViewController.h"

@interface GsearchViewController ()<RefreshDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    UITextField *_tf;
    
    
    RefreshTableView *_tab;
    
}
@end

@implementation GsearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"搜索";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    
    
    UIControl *dd = [[UIControl alloc]initWithFrame:self.view.bounds];
    [dd addTarget:self action:@selector(gshou) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dd];
    
    
    
    [self creatUpview];
    
    [self creatTab];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - MyMethod

-(void)creatTab{
    _tab = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 50, DEVICE_WIDTH, DEVICE_HEIGHT - 50) style:UITableViewStylePlain];
    _tab.refreshDelegate = self;
    _tab.dataSource = self;
    [self.view addSubview:_tab];
    
//    [_tab showRefreshHeader:YES];
}




-(void)loadMoreDataForTableView:(UITableView *)tableView{
    [self prepareNetData];
}


-(void)loadNewDataForTableView:(UITableView *)tableView{
    [self prepareNetData];
}

-(void)prepareNetData{
    NSString * guanjianzi = _tf.text;
    NSDictionary *dic = @{
                          @"province_id":@"1000",
                          @"city_id":@"1001",
                          @"keywords":guanjianzi,
                          @"page":[NSString stringWithFormat:@"%d",_tab.pageNum],
                          @"perpage":@"10"
                          };
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:SEACHERPRODUCT parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSArray *list = [result arrayValueForKey:@"list"];
        
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *dic in list) {
            ProductModel *model = [[ProductModel alloc]initWithDictionary:dic];
            [arr addObject:model];
        }
        
        [_tab reloadData:arr pageSize:10];
        
    } failBlock:^(NSDictionary *result) {
        [_tab loadFail];
    }];
}



-(void)gshou{
    [_tf resignFirstResponder];
}

-(void)creatUpview{
    UIView *backview = [[UIView alloc]initWithFrame:CGRectMake(10, 10, DEVICE_WIDTH - 20 -5 - 35, 30)];
    backview.layer.borderWidth = 0.5;
    backview.layer.cornerRadius = 4;
    backview.layer.borderColor = [RGBCOLOR(128, 167, 0)CGColor];
    [self.view addSubview:backview];
    
    
    UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 20, 20)];
    [imv setImage:[UIImage imageNamed:@"homepage_top_search.png"]];
    [backview addSubview:imv];
    
    _tf = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imv.frame)+5, 0, backview.frame.size.width - 35 - 3, 30)];
    _tf.font = [UIFont systemFontOfSize:15];
    _tf.placeholder = @"请输入关键词";
    _tf.delegate = self;
    [backview addSubview:_tf];
    
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn setFrame:CGRectMake(CGRectGetMaxX(backview.frame)+5, 10, 40, 30)];
    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [searchBtn setTitleColor:RGBCOLOR(128, 167, 0) forState:UIControlStateNormal];
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    
    [searchBtn addTarget:self action:@selector(gSearch) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:searchBtn];
    
    
}


-(void)gSearch{
    
    [_tf resignFirstResponder];
    
    [_tab showRefreshHeader:YES];
    
}


#pragma mark - RefreshDelegate && UITableViewDataSource

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    NSLog(@"%s",__FUNCTION__);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    ProductDetailViewController *cc = [[ProductDetailViewController alloc]init];
    ProductModel *model = _tab.dataArray[indexPath.row];
    cc.product_id = model.product_id;
    cc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cc animated:YES];
    
    
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView{
    return 80;
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _tab.dataArray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    SeachCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[SeachCustomTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    [cell loadCustomViewWithModel:_tab.dataArray[indexPath.row] index:indexPath];
    
    
    return cell;
}




- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self gSearch];
    return YES;
}


@end
