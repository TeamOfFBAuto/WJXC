//
//  PersonalViewController.m
//  WJXC
//
//  Created by lichaowei on 15/6/25.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "PersonalViewController.h"
#import "LoginViewController.h"
#import "PersonalCell.h"
#import "FBActionSheet.h"

@interface PersonalViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
{
    UITableView *_tableView;
    NSArray *_images_arr;
    NSArray *_titles_arr;
    
    UIImageView *_headImageView;
    UIView *_headerView;//tableView头部view
    
//    UIImageView *_iconImageView;//头像
//    UILabel *_nameLabel;//名字
    
//    UIButton *_unLoginButton;//未登录button
}

@property(nonatomic,retain)UIButton *unLoginButton;
@property(nonatomic,retain)UIImageView *iconImageView;//头像
@property(nonatomic,retain)UILabel *nameLabel;//名字


@end

@implementation PersonalViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _images_arr = @[[UIImage imageNamed:@"my_collect"],
                    [UIImage imageNamed:@"my_address"],
                    [UIImage imageNamed:@"my_indent"],
                    [UIImage imageNamed:@"my_setting"]];
    _titles_arr = @[@"我的收藏",
                    @"我的地址",
                    @"我的订单",
                    @"设置"];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    _tableView.bounces = NO;
    
    [self tableviewHeaderView];//tableView 头部
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 事件处理

//跳出登录界面
-(void)presentLoginVc{
    
//    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选择", nil];
//    [sheet showInView:self.view];
    
    
//    LoginViewController *login = [[LoginViewController alloc]init];
//    UINavigationController *unVc = [[UINavigationController alloc]initWithRootViewController:login];
//    [self presentViewController:unVc animated:YES completion:nil];
}

/**
 *  点击头像
 *
 *  @param sender
 */
- (void)clickPersonalImage:(UIButton *)sender
{
    FBActionSheet *sheet = [[FBActionSheet alloc]initWithFrame:self.view.frame];
    [sheet actionBlock:^(NSInteger buttonIndex) {
        NSLog(@"%ld",(long)buttonIndex);
        if (buttonIndex == 0) {
            NSLog(@"拍照");
            
            
        }else if (buttonIndex == 1)
        {
            NSLog(@"相册");
            
        }
        
    }];
}

/**
 *  更新登录状态
 */

- (void)updateLoginState
{
    BOOL isLogin = NO;//判断登录状态
        
    self.iconImageView.hidden = !isLogin;
    self.nameLabel.hidden = !isLogin;
    self.unLoginButton.hidden = isLogin;
}

#pragma mark - 创建视图

- (UIImageView *)iconImageView
{
    if (!_iconImageView) {
        
        _iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 75, 50, 50)];
        [_iconImageView addTaget:self action:@selector(clickPersonalImage:) tag:0];
        [_iconImageView addRoundCorner];
        _iconImageView.backgroundColor = [UIColor orangeColor];
        [_iconImageView setBorderWidth:2.f borderColor:[UIColor whiteColor]];
        _iconImageView.centerX = DEVICE_WIDTH/2.f;
        [_headerView addSubview:_iconImageView];
    }
    
    return _iconImageView;
}

-(UILabel *)nameLabel
{
    if (!_nameLabel) {
        //用户名
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, _iconImageView.bottom + 5, DEVICE_WIDTH, 30) title:@"name" font:14 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
        [_headerView addSubview:_nameLabel];
    }
    return _nameLabel;
}

-(UIButton *)unLoginButton
{
    if (!_unLoginButton) {
        
        _unLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_unLoginButton setTitle:@"登录" forState:UIControlStateNormal];
        [_unLoginButton setFrame:CGRectMake(0, 75, 60, 30)];
        _unLoginButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_unLoginButton addTarget:self action:@selector(presentLoginVc) forControlEvents:UIControlEventTouchUpInside];
        [_unLoginButton addCornerRadius:5.f];
        [_unLoginButton setBorderWidth:1.f borderColor:[UIColor whiteColor]];
        [_headerView addSubview:_unLoginButton];
        _unLoginButton.centerX = DEVICE_WIDTH / 2.f;
    }
    return _unLoginButton;
}

- (void)tableviewHeaderView
{
    _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 165)];
    
    _headImageView = [[UIImageView alloc]initWithFrame:_headerView.bounds];
    _headImageView.image = [UIImage imageNamed:@"my_bg"];
    [_headerView addSubview:_headImageView];
    [self updateLoginState];

    _tableView.tableHeaderView = _headerView;
}

#pragma mark - 代理

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}



- (void)willPresentActionSheet:(UIActionSheet *)actionSheet

{
    
    for (UIView *subViwe in actionSheet.subviews) {
        
        if ([subViwe isKindOfClass:[UIButton class]]) {
            
            UIButton *button = (UIButton*)subViwe;
            
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            
        }
        
    }
    
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    int index = (int)indexPath.row;
    switch (index) {
        case 0:
        {
            NSLog(@"我的收藏");
        }
            break;
        case 1:
        {
            NSLog(@"我的地址");

        }
            break;
        case 2:
        {
            NSLog(@"我的订单");

        }
            break;
        case 3:
        {
            NSLog(@"设置");

        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titles_arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"PersonalCell";
    PersonalCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"PersonalCell" owner:self options:nil]lastObject];
    }

    cell.iconImageView.image = _images_arr[indexPath.row];
    cell.titleLabel.text = _titles_arr[indexPath.row];
    
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.5;
}


@end
