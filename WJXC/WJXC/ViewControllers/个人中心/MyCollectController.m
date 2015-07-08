//
//  MyCollectController.m
//  WJXC
//
//  Created by lichaowei on 15/7/7.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "MyCollectController.h"
#import "CollectCell.h"

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 代理

#pragma mark - RefreshDelegate

- (void)loadNewData
{
    
}
- (void)loadMoreData
{
    
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
    return 86.f;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _table.dataArray.count + 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"CollectCell";
    CollectCell *cell = (CollectCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
    return cell;
}

@end
