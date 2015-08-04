//
//  HuodongViewController.m
//  WJXC
//
//  Created by gaomeng on 15/8/3.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "HuodongViewController.h"
#import "HuodongCustomTableViewCell.h"
#import "HuodongDetailModel.h"
#import "RefreshTableView.h"

@interface HuodongViewController ()<UITableViewDataSource,RefreshDelegate>
{
    RefreshTableView *_tab;
    
    
    HuodongCustomTableViewCell *_tmpCell;
    
    HuodongDetailModel *_theModel;//数据源
    
}
@end

@implementation HuodongViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    self.myTitle = @"活动详情";
    
    [self creatTab];
}


#pragma mark - MyMethod

-(void)prepareNetData{
    NSDictionary *dic = @{
                          @"activity_id":self.huodongId
                          };
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:HUODONGXIANGQING parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSDictionary *detail = [result dictionaryValueForKey:@"detail"];
        _theModel = [[HuodongDetailModel alloc]initWithDictionary:detail];
        [_tab reloadDataSuccess:nil isHaveMore:NO];
    } failBlock:^(NSDictionary *result) {
        [_tab loadFail];
    }];
}

-(void)creatTab{
    _tab = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT) style:UITableViewStylePlain];
    _tab.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tab.refreshDelegate = self;
    _tab.dataSource = self;
    [self.view addSubview:_tab];
    [_tab showRefreshHeader:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - RefreshDelegate && UITableViewDataSource


- (void)loadNewDataForTableView:(UITableView *)tableView{
    [self prepareNetData];
}
- (void)loadMoreDataForTableView:(UITableView *)tableView{
    
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath{
    if (!_tmpCell) {
        static  NSString *identifier = @"ddddd";
        _tmpCell = [[HuodongCustomTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    CGFloat height = [_tmpCell loadCustomViewWithModel:_theModel index:indexPath];
    return height;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *dataArray = _theModel.desc_format;
    return dataArray.count+1;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    HuodongCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[HuodongCustomTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    
    [cell loadCustomViewWithModel:_theModel index:indexPath];
    
    
    
    
    return cell;
    
}



@end
