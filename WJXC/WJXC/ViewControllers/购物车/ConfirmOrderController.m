//
//  ConfirmOrderController.m
//  WJXC
//
//  Created by lichaowei on 15/7/18.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "ConfirmOrderController.h"
#import "SelectCell.h"
#import "ProductCell.h"

@interface ConfirmOrderController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_table;
    NSArray *_titles;
    NSArray *_titlesSub;
    UITextField *_inputTf;
}

@end

@implementation ConfirmOrderController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"确认订单";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    _titles = @[@"支付信息",@"备注信息",@"商品清单",@"价格清单"];
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickToHidderkeyboard)];
    [_table addGestureRecognizer:tap];
    
    [self tableHeaderView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 事件处理

- (void)clickToHidderkeyboard
{
    [_inputTf resignFirstResponder];
}

#pragma mark - 创建视图

- (void)tableHeaderView
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 122)];
    headerView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    
    UIImageView *topImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, DEVICE_WIDTH, 3)];
    [headerView addSubview:topImage];
    topImage.image = [UIImage imageNamed:@"shopping cart_dd_top_line"];
    
    UIView *addressView = [[UIView alloc]initWithFrame:CGRectMake(0, topImage.bottom, DEVICE_WIDTH, 100)];
    addressView.backgroundColor = [UIColor colorWithHexString:@"fffaf4"];
    [headerView addSubview:addressView];
    
    //名字icon
    UIImageView *nameIcon = [[UIImageView alloc]initWithFrame:CGRectMake(10, 13, 12, 17.5)];
    [addressView addSubview:nameIcon];
    nameIcon.image = [UIImage imageNamed:@"shopping cart_dd_top_name"];
    
    //名字
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameIcon.right + 10, 13, 60, nameIcon.height) title:@"张三" font:15.f align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
    [addressView addSubview:nameLabel];
    
    //电话icon
    UIImageView *phoneIcon = [[UIImageView alloc]initWithFrame:CGRectMake(nameLabel.right + 10, 13, 12, 17.5)];
    [addressView addSubview:phoneIcon];
    phoneIcon.image = [UIImage imageNamed:@"shopping cart_dd_top_phone"];
    
    //电话
    UILabel *phoneLabel = [[UILabel alloc]initWithFrame:CGRectMake(phoneIcon.right + 10, 13, 120, nameIcon.height) title:@"18622290909" font:15.f align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
    [addressView addSubview:phoneLabel];
    
    //地址
    UILabel *addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, phoneIcon.bottom + 15, DEVICE_WIDTH - 10 * 4, 40) title:@"北京 海淀区 四环至五环之间 清河小营西路27号金领时代大厦801" font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"646462"]];
    [addressView addSubview:addressLabel];
    addressLabel.numberOfLines = 2;
    addressLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    //箭头
    UIImageView *arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 40, 0, 40, addressView.height)];
    [addressView addSubview:arrowImage];
    arrowImage.image = [UIImage imageNamed:@"shopping cart_dd_top_jt"];
    arrowImage.contentMode = UIViewContentModeCenter;
    
    UIImageView *bottomImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, addressView.bottom, DEVICE_WIDTH, 3)];
    [headerView addSubview:bottomImage];
    bottomImage.image = [UIImage imageNamed:@"shopping cart_dd_top_line"];
    
    _table.tableHeaderView = headerView;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 1) {
        return 30;
    }
    if (indexPath.section == 2) {
        return 85;
    }
    
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 37.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 37.5)];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, view.height) title:_titles[section] font:12 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"9d9d9d"]];
    [view addSubview:label];
    view.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    
    return view;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 || section == 1) {
        
        return 1;
    }
    if (section == 3) {
        
        return self.productArray.count;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        static NSString *identify = @"ProductCell";
        ProductCell *cell = (ProductCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
        
        ProductModel *aModel = [self.productArray objectAtIndex:indexPath.row];
        
        [cell setCellWithModel:aModel];
        
        return cell;
    }
    
    if (indexPath.section == 1) {
        
        static NSString *identify = @"tableCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        }
        
        _inputTf = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH - 20, 30)];
        _inputTf.placeholder = @"填写备注";
        _inputTf.font = [UIFont systemFontOfSize:12];
        [cell.contentView addSubview:_inputTf];
        _inputTf.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        return cell;
    }
    
    static NSString *identify = @"SelectCell";
    SelectCell *cell = (SelectCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
    if (indexPath.section == 0) {
        cell.nameLabel.text = @"支付方式";
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

@end
