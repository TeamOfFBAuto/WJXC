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
#import "ConfirmInfoCell.h"
#import "ShoppingAddressController.h"//收货地址
#import "AddressModel.h"
#import "FBActionSheet.h"

#define ALIPAY @"支付宝支付"
#define WXPAY  @"微信支付"

@interface ConfirmOrderController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    UITableView *_table;
    NSArray *_titles;
    NSArray *_titlesSub;
    UITextField *_inputTf;
    NSString *_selectAddressId;//选中的地址
    
    UILabel *_nameLabel;//收货人name
    UILabel *_phoneLabel;//收货人电话
    UILabel *_addressLabel;//收货地址
    UIImageView *_phoneIcon;//电话icon
    
    NSString *_payStyle;//支付类型
}

@end

@implementation ConfirmOrderController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTitle = @"确认订单";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
//    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.productArray];
//    [temp addObjectsFromArray:self.productArray];
//    [temp addObjectsFromArray:self.productArray];
//    [temp addObjectsFromArray:self.productArray];
//    [temp addObjectsFromArray:self.productArray];
//    [temp addObjectsFromArray:self.productArray];
//    self.productArray = temp;
    
    _titles = @[@"支付信息",@"备注信息",@"商品清单",@"价格清单"];
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 64) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickToHidderkeyboard)];
    tap.delegate = self;
    [_table addGestureRecognizer:tap];
    
    [self tableHeaderView];
    [self tableViewFooter];
    
    [self createBottomView];
    
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

/**
 *  确定订单
 *
 *  @param sender
 */
- (void)clickToConfirmOrder:(UIButton *)sender
{
    
}

/**
 *  选择购物地址
 *
 *  @param sender
 */
- (void)clickToSelectAddress:(UIButton *)sender
{
    __weak typeof(self)wealSelf = self;
    ShoppingAddressController *address = [[ShoppingAddressController alloc]init];
    address.isSelectAddress = YES;
    address.selectAddressId = _selectAddressId;
    address.selectAddressBlock = ^(AddressModel *aModel){
        _selectAddressId = aModel.address_id;
        [wealSelf updateAddressInfoWithModel:aModel];
    };
    
    [self.navigationController pushViewController:address animated:YES];
}

/**
 *  更新收货地址信息
 *
 *  @param aModel 
 
 */
- (void)updateAddressInfoWithModel:(AddressModel *)aModel
{
    NSLog(@"---address %@",aModel.address);
    
//    UILabel *_nameLabel;//收货人name
//    UILabel *_phoneLabel;//收货人电话
//    UILabel *_addressLabel;//收货地址
    
    _nameLabel.text = aModel.receiver_username;
    
    CGFloat width = [LTools widthForText:_nameLabel.text font:15];
    _nameLabel.width = width;
    
    _phoneIcon.left = _nameLabel.right + 10;
    _phoneLabel.left = _phoneIcon.right + 10;
    _phoneLabel.text = aModel.mobile;
    _addressLabel.text = aModel.address;

}

#pragma mark - 创建视图
/**
 *  底部工具条
 */
- (void)createBottomView
{
    UIView *bottom = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT - 64 - 50, DEVICE_WIDTH, 50)];
    bottom.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottom];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0.5f)];
    line.backgroundColor = [UIColor colorWithHexString:@"e4e4e4"];
    [bottom addSubview:line];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 36, 50) title:@"合计:" font:15 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"303030"]];
    [bottom addSubview:label];
    
    NSString *price = [NSString stringWithFormat:@"￥%.2f",self.sumPrice];
    UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.right + 10, 0, 100, 50) title:price font:12 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"f98700"]];
    [bottom addSubview:priceLabel];
    
    UIButton *sureButton = [[UIButton alloc]initWithframe:CGRectMake(DEVICE_WIDTH - 15 - 100, 10, 100, 30) buttonType:UIButtonTypeRoundedRect normalTitle:@"提交订单" selectedTitle:nil target:self action:@selector(clickToConfirmOrder:)];
    [sureButton addCornerRadius:3.f];
    [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sureButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    sureButton.backgroundColor = [UIColor colorWithHexString:@"f98700"];
    [bottom addSubview:sureButton];
}

- (void)tableViewFooter
{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 61)];
    footerView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    _table.tableFooterView = footerView;
}

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
    _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameIcon.right + 10, 13, 60, nameIcon.height) title:@"张三" font:15.f align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
    [addressView addSubview:_nameLabel];
    
    //电话icon
    _phoneIcon = [[UIImageView alloc]initWithFrame:CGRectMake(_nameLabel.right + 10, 13, 12, 17.5)];
    [addressView addSubview:_phoneIcon];
    _phoneIcon.image = [UIImage imageNamed:@"shopping cart_dd_top_phone"];
    
    //电话
    _phoneLabel = [[UILabel alloc]initWithFrame:CGRectMake(_phoneIcon.right + 10, 13, 120, nameIcon.height) title:@"18622290909" font:15.f align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"323232"]];
    [addressView addSubview:_phoneLabel];
    
    //地址
    _addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, _phoneIcon.bottom + 15, DEVICE_WIDTH - 10 * 4, 40) title:@"北京 海淀区 四环至五环之间 清河小营西路27号金领时代大厦801" font:14 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"646462"]];
    [addressView addSubview:_addressLabel];
    _addressLabel.numberOfLines = 2;
    _addressLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    //箭头
    UIImageView *arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 40, 0, 40, addressView.height)];
    [addressView addSubview:arrowImage];
    arrowImage.image = [UIImage imageNamed:@"shopping cart_dd_top_jt"];
    arrowImage.contentMode = UIViewContentModeCenter;
    
    UIImageView *bottomImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, addressView.bottom, DEVICE_WIDTH, 3)];
    [headerView addSubview:bottomImage];
    bottomImage.image = [UIImage imageNamed:@"shopping cart_dd_top_line"];
    
    _table.tableHeaderView = headerView;
    
    //点击事件
    [headerView addTaget:self action:@selector(clickToSelectAddress:) tag:0];
}

#pragma mark - UITapGestureDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ![NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"];
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self clickToHidderkeyboard];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        FBActionSheet *sheet = [[FBActionSheet alloc]initWithFrame:self.view.frame];
        [sheet.firstButton setTitle:ALIPAY forState:UIControlStateNormal];
        [sheet.secondButton setTitle:WXPAY forState:UIControlStateNormal];

        __weak typeof(_table)weakTable = _table;
        [sheet actionBlock:^(NSInteger buttonIndex) {
            NSLog(@"%ld",(long)buttonIndex);
            
            if(buttonIndex ==0){
                NSLog(@"-->%@",ALIPAY);
                
                _payStyle = ALIPAY;
                
            }else if(buttonIndex == 1){
                NSLog(@"-->%@",WXPAY);
                _payStyle = WXPAY;
            }
            [weakTable reloadData];
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 3) {
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
    if (section == 2) {
        
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
            _inputTf = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH - 20, 30)];
            _inputTf.placeholder = @"填写备注";
            _inputTf.font = [UIFont systemFontOfSize:12];
            [cell.contentView addSubview:_inputTf];
            _inputTf.clearButtonMode = UITextFieldViewModeWhileEditing;
        }
        
        return cell;
    }
    
    if (indexPath.section == 3) {
        
        static NSString *identify = @"ConfirmInfoCell";
        ConfirmInfoCell *cell = (ConfirmInfoCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
        if (indexPath.row == 0) {
            
            cell.nameLabel.text = @"商品总价";
            cell.priceLabel.text = [NSString stringWithFormat:@"￥%.2f",self.sumPrice];
            
        }else if (indexPath.row == 1){
            cell.nameLabel.text = @"运费";
            cell.priceLabel.text = [NSString stringWithFormat:@"￥%.2f",0.00];
        }
        
        return cell;
    }
    
    static NSString *identify = @"SelectCell";
    SelectCell *cell = (SelectCell *)[LTools cellForIdentify:identify cellName:identify forTable:tableView];
    if (indexPath.section == 0) {
        cell.nameLabel.text = @"支付方式";
        
        if (indexPath.row == 0) {
            
            cell.contentLabel.text = _payStyle;
        }
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

@end
