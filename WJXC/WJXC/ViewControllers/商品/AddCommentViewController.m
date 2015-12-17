//
//  AddCommentViewController.m
//  WJXC
//
//  Created by gaomeng on 15/8/4.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "AddCommentViewController.h"

#import "AddCommentDetailViewController.h"
#import "ProductDetailViewController.h"


@interface AddCommentViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tab;
    NSArray *_dataArray;
    
    int _pingjiaSuccess[1000];
}
@end

@implementation AddCommentViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.navigationController.navigationBarHidden = YES;
//    self.navigationController.navigationBarHidden = NO;
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //在navigationController中移除 确认订单viewController
    
    //确认订单之后到支付页面,这时候不能再返回到确认订单页面
    
    NSArray *vcArray = self.navigationController.viewControllers;
    
    for (UIViewController *viewController in vcArray) {
        
        if ([viewController isKindOfClass:NSClassFromString(@"OrderInfoViewController")]) {
            
            [viewController removeFromParentViewController];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.myTitle = @"评价晒单";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    _dataArray = self.theModelArray;
    
    
    for (int i = 0; i<self.theModelArray.count; i++) {
        ProductModel *amodel = self.theModelArray[i];
        if ([amodel.is_recommend intValue] == 1) {
            _pingjiaSuccess[i] = 1;
        }else{
            _pingjiaSuccess[i] = 0;
        }
        
    }
    [self creatTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)creatTableView{
    _tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-64) style:UITableViewStylePlain];
    _tab.delegate = self;
    _tab.dataSource = self;
    _tab.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tab];
}


#pragma mark - UITableViewDelegate && UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height = 0;
    
    if (indexPath.section == 0) {
        height = 85;
    }else{
        height = 130;
    }
    return height;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = 0;
    if (section == 0) {
        count = _dataArray.count;
    }else{
        count = 1;
    }
    return count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    if (indexPath.section == 0) {
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 5)];
        line.backgroundColor = RGBCOLOR(241, 242, 244);
        [cell.contentView addSubview:line];
        
        ProductModel *amodel = _dataArray[indexPath.row];
        
        UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 15, 60, 60)];
        [imv l_setImageWithURL:[NSURL URLWithString:amodel.cover_pic] placeholderImage:DEFAULT_HEADIMAGE];
        [cell.contentView addSubview:imv];
        
        UILabel *tt = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imv.frame)+10, imv.frame.origin.y, DEVICE_WIDTH - 80 - 90, imv.frame.size.height) title:amodel.product_name font:15 align:NSTextAlignmentLeft textColor:[UIColor blackColor]];
        //    tt.backgroundColor = [UIColor orangeColor];
        [cell.contentView addSubview:tt];
        
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(DEVICE_WIDTH - 10 - 55, 80-10-30 + 5, 55, 25)];
        [tt setMatchedFrame4LabelWithOrigin:CGPointMake(CGRectGetMaxX(imv.frame)+10, imv.frame.origin.y) width:DEVICE_WIDTH - 80 - 90];
        [btn setTitle:@"评价晒单" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        btn.layer.cornerRadius = 4;
        btn.layer.borderWidth = 0.5;
        btn.layer.borderColor = [RGBCOLOR(238, 115, 0)CGColor];
        [btn setTitleColor:RGBCOLOR(238, 115, 0) forState:UIControlStateNormal];
        [cell.contentView addSubview:btn];
        
        btn.tag = indexPath.row +100;
        
        
        if (_pingjiaSuccess[indexPath.row] == 1) {//评价过了
            [btn setTitle:@"已评价" forState:UIControlStateNormal];
        }else{
            [btn addTarget:self action:@selector(pingjiashaidan:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        
    }else{
//        UILabel *tt = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 80, 20) title:@"服务评价" font:15 align:NSTextAlignmentLeft textColor:[UIColor blackColor]];
//        [cell.contentView addSubview:tt];
//        UILabel *ttt = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 120, 10, 100, 20) title:@"满意请给5星" font:12 align:NSTextAlignmentRight textColor:[UIColor blackColor]];
//        [cell.contentView addSubview:ttt];
    }
    
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ProductDetailViewController *cc = [[ProductDetailViewController alloc]init];
    ProductModel *model = _dataArray[indexPath.row];
    cc.product_id = model.product_id;
    [self.navigationController pushViewController:cc animated:YES];
}



-(void)pingjiashaidan:(UIButton *)sender{
    NSInteger tag = sender.tag - 100;
    ProductModel *model = _dataArray[tag];
    
    AddCommentDetailViewController *cc = [[AddCommentDetailViewController alloc]init];
    cc.theModel = model;
    cc.delegate = self;
    cc.dingdanhao = self.dingdanhao;
    cc.theIndex_row = tag;
    
    cc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cc animated:YES];
    
}



-(void)updateView_pingjiaSuccessWithIndex:(NSInteger)index_row{
    _pingjiaSuccess[index_row] = 1;
    [_tab reloadData];
}




@end
