//
//  HuodongViewController.m
//  WJXC
//
//  Created by gaomeng on 15/8/3.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "HuodongViewController.h"
#import "HuodongCustomTableViewCell.h"

@interface HuodongViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tab;
    
    NSArray *_dataArray;
    
    HuodongCustomTableViewCell *_tmpCell;
    
}
@end

@implementation HuodongViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    self.myTitle = @"活动详情";
    
    
}




-(void)creatTab{
    _tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT) style:UITableViewStylePlain];
    _tab.delegate = self;
    _tab.dataSource = self;
    [self.view addSubview:_tab];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDelegate && UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!_tmpCell) {
        static  NSString *identifier = @"ddddd";
        _tmpCell = [[HuodongCustomTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    CGFloat height = [_tmpCell loadCustomViewWithModel:_dataArray[indexPath.row] index:indexPath];
    return height;
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    HuodongCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[HuodongCustomTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    [cell loadCustomViewWithModel:_dataArray[indexPath.row] index:indexPath];
    
    return cell;
    
}



@end
