//
//  ShoppingAddressController.m
//  WJXC
//
//  Created by lichaowei on 15/7/7.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "ShoppingAddressController.h"
#import "AddressCell.h"
#import "AddAddressController.h"//添加收货地址
#import "AddressModel.h"
#import "SelectAddressCell.h"

#define kPadding_Default 100
#define kPadding_Delete 1000

@interface ShoppingAddressController ()<RefreshDelegate,UITableViewDataSource>
{
    RefreshTableView *_table;
    __weak AddressModel *_defaultAddress;//记录默认地址
    int _deleteIndexrow;
}

@end

@implementation ShoppingAddressController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"收货地址";
    
    if (self.isSelectAddress) {
        self.rightString = @"管理";
        [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeText];
    }else
    {
        [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    }
    
    _table = [[RefreshTableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH,DEVICE_HEIGHT - 64 - 43 - 25) showLoadMore:NO];
    _table.refreshDelegate = self;
    _table.dataSource = self;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_table];
    [_table showRefreshHeader:YES];
    
    [self createFooter];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateAddress) name:NOTIFICATION_ADDADDRESS object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark 通知处理

- (void)updateAddress
{
    [_table showRefreshHeader:YES];
}

#pragma mark - 网络请求

- (void)updateDefaultAddress:(UIButton *)sender
{
    __weak typeof(_table)weakTable = _table;
    __weak AddressModel *aModel = [_table.dataArray objectAtIndex:sender.tag - kPadding_Default];
    NSString *authkey = [GMAPI getAuthkey];
    NSDictionary *params = @{@"authcode":authkey,
                             @"address_id":aModel.address_id};
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:USER_ADDRESS_SETDEFAULT parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        aModel.default_address = @"1";
        _defaultAddress.default_address = @"0";
        [weakTable reloadData];
        
    } failBlock:^(NSDictionary *result) {
        
        
    }];

}

/**
 *  删除地址
 *
 *  @param index 删掉的下标
 */
- (void)deleteAddress:(int)index
{
    __weak AddressModel *aModel = [_table.dataArray objectAtIndex:index];

    __weak typeof(_table)weakTable = _table;
    NSString *authkey = [GMAPI getAuthkey];
    NSDictionary *params = @{@"authcode":authkey,
                             @"address_id":aModel.address_id};
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:USER_ADDRESS_DELETE parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [weakTable.dataArray removeObjectAtIndex:index];
        [weakTable reloadData];
        
    } failBlock:^(NSDictionary *result) {
        
        
    }];
}

//收货地址

- (void)getAddressList
{
    __weak typeof(_table)weakTable = _table;

    NSDictionary *params = @{@"authcode":[GMAPI getAuthkey],
                             @"page":[NSNumber numberWithInt:_table.pageNum],
                             @"per_page":[NSNumber numberWithInt:20]};
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:USER_ADDRESS_LIST parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSLog(@"result complete %@",result);
        
        NSArray *list = result[@"list"];
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:list.count];
        for (NSDictionary *aDic in list) {
            
            AddressModel *address = [[AddressModel alloc]initWithDictionary:aDic];
            [temp addObject:address];
        }
        
        [weakTable reloadData:temp pageSize:20];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"result fail %@",result);

    }];
}

#pragma mark - 创建视图

- (void)createFooter
{
    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT - 43 - 25 - 64, DEVICE_WIDTH, 43 + 25)];
    [self.view addSubview:footer];
    
    UIButton *btn = [[UIButton alloc]initWithframe:CGRectMake(33, 0, DEVICE_WIDTH - 66, 43) buttonType:UIButtonTypeCustom normalTitle:@"添加新地址" selectedTitle:nil target:self action:@selector(clickToAddNewAddress:)];
    btn.backgroundColor = [UIColor colorWithHexString:@"8ab800"];
    [btn addCornerRadius:3.f];
    [footer addSubview:btn];
}

#pragma mark - 事件处理

/**
 *  跳转至收货地址管理
 *
 *  @param sender
 */
-(void)rightButtonTap:(UIButton *)sender
{
    ShoppingAddressController *shopAddress = [[ShoppingAddressController alloc]init];
    
    [self.navigationController pushViewController:shopAddress animated:YES];
}

- (void)clickToAddNewAddress:(UIButton *)sender
{
    AddAddressController *address = [[AddAddressController alloc]init];
    [self.navigationController pushViewController:address animated:YES];
}

/**
 *  选中默认地址
 *
 *  @param sender
 */
- (void)clickToSelectAddress:(UIButton *)sender
{
    sender.selected = !sender.selected;
}

/**
 *  删除地址
 *
 *  @param sender
 */
- (void)clickToDeleteAddress:(UIButton *)sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"是否确定删除" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = sender.tag;
    sender.tag = 0;
    [alert show];
}

#pragma mark - 代理

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        //确定删除
        
        [self deleteAddress:(int)alertView.tag - kPadding_Delete];
    }
}

#pragma mark - RefreshDelegate

- (void)loadNewData
{
    [self getAddressList];
}
- (void)loadMoreData
{
    [self getAddressList];
}

- (void)loadNewDataForTableView:(UITableView *)tableView
{
    
}
- (void)loadMoreDataForTableView:(UITableView *)tableView
{
    
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddressModel *aModel = _table.dataArray[indexPath.row];

    self.selectAddressId = aModel.address_id;
    
    [_table reloadData];
    
    if (self.isSelectAddress) {
        
        if (self.selectAddressBlock) {
            
            self.selectAddressBlock(aModel);
        }
        
        [self performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:0.5];
        
        return;
    }
    AddAddressController *address = [[AddAddressController alloc]init];
    address.isEditAddress = YES;
    address.addressModel = aModel;
    [self.navigationController pushViewController:address animated:YES];
}

- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSelectAddress) {
        
        return 88.f;
    }
    return 150.f;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _table.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSelectAddress) {

        static NSString *identify = @"SelectAddressCell";
        SelectAddressCell *cell = (SelectAddressCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
        AddressModel *aModel = [_table.dataArray objectAtIndex:indexPath.row];
        [cell setCellWithModel:aModel];
        
        if ([aModel.address_id isEqualToString:self.selectAddressId]) {
            
            cell.selectImage.hidden = NO;
        }else
        {
            cell.selectImage.hidden = YES;
        }
        
        return cell;
    }
    
    static NSString *identify = @"AddressCell";
    AddressCell *cell = (AddressCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
    [cell.addressButton addTarget:self action:@selector(clickToSelectAddress:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    AddressModel *aModel = [_table.dataArray objectAtIndex:indexPath.row];
    [cell setCellWithModel:aModel];
    
    if ([aModel.default_address intValue] == 1) {
        _defaultAddress = aModel;
    }
    
    cell.addressButton.tag = kPadding_Default + indexPath.row;
    [cell.addressButton addTarget:self action:@selector(updateDefaultAddress:) forControlEvents:UIControlEventTouchUpInside];
    cell.deleteButton.tag = kPadding_Delete + indexPath.row;
    [cell.deleteButton addTarget:self action:@selector(clickToDeleteAddress:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.editButton.userInteractionEnabled = NO;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

@end
