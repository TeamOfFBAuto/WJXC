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
#import "UserInfo.h"
#import "MyCollectController.h"//我的收藏
#import "ShoppingAddressController.h"//我的地址
#import "OrderViewController.h"//我的订单
#import "SettingsViewController.h"//设置

#import "NickNameSheet.h"//修改昵称view

#import "RCDChatViewController.h"//客服聊天

@interface PersonalViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
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
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [self updateLoginState];
    
    [LTools updateTabbarUnreadMessageNumber];
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
                    [UIImage imageNamed:@"my_collect_youhuiquan"],
                    [UIImage imageNamed:@"my_service"],
                    [UIImage imageNamed:@"my_setting"]];
    _titles_arr = @[@"我的收藏",
                    @"我的地址",
                    @"我的订单",
                    @"我的优惠劵",
                    @"客服中心",
                    @"设置"];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - 49) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
//    _tableView.bounces = NO;
    
    [self tableviewHeaderView];//tableView 头部
    
    //本地数据
    
    UserInfo *userInfo = [UserInfo cacheResultForKey:USERINFO_MODEL];
    [self setViewWithUserInfo:userInfo];
    
    //网络请求
    [self getUserInfo];
    
    //监控退出登录通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificatonForLogout:) name:NOTIFICATION_LOGOUT object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForHeadImage:) name:NOTIFICATION_UPDATEHEADIMAGE_SUCCESS object:nil];
    
    UINavigationController *unvc = [((UITabBarController *)ROOTVIEWCONTROLLER).viewControllers objectAtIndex:3];
    [unvc.tabBarItem addObserver:self forKeyPath:@"badgeValue" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"observeValueForKeyPath %@",change);
    
    if ([keyPath isEqualToString:@"badgeValue"]) {
        
        id new = [change objectForKey:@"new"];
        
        int newNum = 0.f;
        if ([new isKindOfClass:[NSNull class]]) {
            
            newNum = 0;
        }else
        {
            newNum = [new intValue];
        }
        
        NSLog(@"mine未读消息 %d",newNum);
                
        [_tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 网络请求

- (void)getUserInfo
{
    NSString *authcode = [LTools cacheForKey:USER_AUTHOD];
    if (!authcode || authcode.length == 0) {
        
        return;
    }
    NSDictionary *params = @{@"authcode":[LTools cacheForKey:USER_AUTHOD]};
    
    __weak typeof(self)weakSelf = self;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:GET_USERINFO_WITHID parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSLog(@"result %@ %@",result[Erro_Info],result);
        
        NSDictionary *dic = result[@"user_info"];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            UserInfo *userInfo = [[UserInfo alloc]initWithDictionary:dic];
            [weakSelf setViewWithUserInfo:userInfo];
        }
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"result %@",result[Erro_Info]);
        
    }];
}

/**
 *  上传头像
 *
 *  @param aImage
 */
- (void)uploadHeadImage:(UIImage *)aImage
{
    __weak typeof(self)weakSelf = self;
    NSDictionary *params = @{@"authcode":[LTools cacheForKey:USER_AUTHOD]};
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:USER_UPLOAD_HEADIMAGE parameters:params constructingBodyBlock:^(id<AFMultipartFormData> formData) {
        
        if (aImage != nil) {
            NSData *imageData =UIImageJPEGRepresentation(aImage, 0.5);
            [formData appendPartWithFileData:imageData name:@"pic" fileName:@"myhead.jpg" mimeType:@"image/jpg"];
        }
        
    } completion:^(NSDictionary *result) {
        
        NSLog(@"completion result %@",result[Erro_Info]);

        [LTools cacheBool:NO ForKey:USER_UPDATEHEADIMAGE];//不需要更新头像
        
        [weakSelf getUserInfo];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"failBlock result %@",result[Erro_Info]);

    }];
}

/**
 *  修改昵称
 *
 *  @param newName 新的昵称
 */
- (void)updateUserName:(NSString *)newName
{
    NSDictionary *params = @{@"authcode":[LTools cacheForKey:USER_AUTHOD],
                             @"user_name":newName};
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak typeof(self)weakSelf = self;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:USER_UPDATE_USEINFO parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSLog(@"result %@ %@",result[Erro_Info],result);
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
            
        //更新本地用户model
        UserInfo *userInfo = [UserInfo cacheResultForKey:USERINFO_MODEL];
        userInfo.user_name = newName;
        [userInfo cacheForKey:USERINFO_MODEL];
        
        [weakSelf setViewWithUserInfo:userInfo];
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"result %@",result[Erro_Info]);
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
    }];
}

#pragma mark - 事件处理

- (void)notificatonForLogout:(NSNotification *)notification
{
    [self updateLoginState];
}

- (void)notificationForHeadImage:(NSNotification *)notification
{
    [self getUserInfo];
}

- (void)setViewWithUserInfo:(UserInfo *)userInfo
{
    //归档保存用户信息
    [userInfo cacheForKey:USERINFO_MODEL];
    
    [LTools cache:userInfo.uid ForKey:USER_UID];
    if (userInfo.avatar) {
        [LTools cache:userInfo.avatar ForKey:USER_HEAD_IMAGEURL];
    }
    if (userInfo.user_name) {
        [LTools cache:userInfo.user_name ForKey:USER_NAME];
    }
    
    self.nameLabel.text = userInfo.user_name;
    
    //需要更换头像,显示本地需要更换的头像
    if ([LTools cacheBoolForKey:USER_UPDATEHEADIMAGE]) {
        
        UIImage *image = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:USER_NEWHEADIMAGE];
        self.iconImageView.image = image;
    }else
    {
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:userInfo.avatar] placeholderImage:DEFAULT_HEADIMAGE];
    }
}

//跳出登录界面
-(void)presentLoginVc{
    
    LoginViewController *login = [[LoginViewController alloc]init];
    UINavigationController *unVc = [[UINavigationController alloc]initWithRootViewController:login];
    [self presentViewController:unVc animated:YES completion:nil];
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
        
        if(buttonIndex ==0){
            NSLog(@"拍照");
            [self choseImageWithTypeCameraTypePhotoLibrary:UIImagePickerControllerSourceTypeCamera];
        }else if(buttonIndex == 1){
            NSLog(@"相册");
            [self choseImageWithTypeCameraTypePhotoLibrary:UIImagePickerControllerSourceTypePhotoLibrary];
        }
        
    }];
}

/**
 *  点击昵称,修改昵称
 */
- (void)clickNickName
{
    __weak typeof(self)weakSelf = self;
    NickNameSheet *sheet = [[NickNameSheet alloc]initWithFrame:self.view.frame];
    sheet.nickActionBlock = ^(NSString *content){
        
        NSLog(@"content %@",content);
        
        if ([LTools isEmpty:content]) {
            
            [LTools showMBProgressWithText:@"用户名不能为空" addToView:weakSelf.view];
        }else
        {
            [weakSelf updateUserName:content];
        }
    };
}

/**
 *  更新登录状态
 */

- (void)updateLoginState
{
    BOOL isLogin = [LTools cacheBoolForKey:LOGIN_SERVER_STATE];//判断登录状态
        
    self.iconImageView.hidden = !isLogin;
    self.nameLabel.hidden = !isLogin;
    self.unLoginButton.hidden = isLogin;
    
    self.nameLabel.text = [LTools cacheForKey:USER_NAME];
    
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:[LTools cacheForKey:USER_HEAD_IMAGEURL]] placeholderImage:DEFAULT_HEADIMAGE];
}

#pragma mark - 创建视图

- (UIImageView *)iconImageView
{
    if (!_iconImageView) {
        
        _iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 75, 50, 50)];
        [_iconImageView addTaget:self action:@selector(clickPersonalImage:) tag:0];
        [_iconImageView addRoundCorner];
        _iconImageView.backgroundColor = [UIColor clearColor];
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
        [_nameLabel addTapGestureTarget:self action:@selector(clickNickName)];
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

-(void)choseImageWithTypeCameraTypePhotoLibrary:(UIImagePickerControllerSourceType)type{
    
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate =self;
    imagePicker.sourceType = type;
    imagePicker.allowsEditing = YES;
    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    imagePicker.allowsEditing =YES;
    [self presentViewController:imagePicker animated:YES completion:^{
        
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    //    NSData * imageData = UIImageJPEGRepresentation(image,0.6);
    
     image = [LTools scaleToSizeWithImage:image size:CGSizeMake(200, 200)];
    //TODO：将图片发给服务器
    
    [LTools cacheBool:YES ForKey:USER_UPDATEHEADIMAGE];//需要更新头像
    
    [[SDImageCache sharedImageCache]storeImage:image forKey:USER_NEWHEADIMAGE toDisk:YES];//存储更新头像image
    
    [self uploadHeadImage:image];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.iconImageView.image = image;

    });
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
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
    
    
    BOOL isLogin = [LTools cacheBoolForKey:LOGIN_SERVER_STATE];//判断登录状态

    int index = (int)indexPath.row;
    switch (index) {
        case 0:
        {
            NSLog(@"我的收藏");
            
            if (!isLogin) {
                [self presentLoginVc];
                return;
            }
            
            MyCollectController *collect = [[MyCollectController alloc]init];
            collect.hidesBottomBarWhenPushed = YES;
            collect.lastPageNavigationHidden = YES;
            [self.navigationController pushViewController:collect animated:YES];
        }
            break;
        case 1:
        {
            if (!isLogin) {
                [self presentLoginVc];
                return;
            }
            NSLog(@"我的地址");
            ShoppingAddressController *shopping = [[ShoppingAddressController alloc]init];
            shopping.hidesBottomBarWhenPushed = YES;
            shopping.lastPageNavigationHidden = YES;
            [self.navigationController pushViewController:shopping animated:YES];

        }
            break;
        case 2:
        {
            if (!isLogin) {
                [self presentLoginVc];
                return;
            }
            NSLog(@"我的订单");
            OrderViewController *order = [[OrderViewController alloc]init];
            order.hidesBottomBarWhenPushed = YES;
            order.lastPageNavigationHidden = YES;
            [self.navigationController pushViewController:order animated:YES];

        }
            break;
        case 3:{
            
            NSLog(@"我的优惠劵");
            
        }
            break;
        case 4:
        {
            NSLog(@"客服中心");
            
            RCDChatViewController *chatService = [[RCDChatViewController alloc] init];
            chatService.userName = @"客服";
            chatService.targetId = SERVICE_ID;
            chatService.conversationType = ConversationType_CUSTOMERSERVICE;
            chatService.title = chatService.userName;
            chatService.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:chatService animated:YES];
            
        }
            break;
        case 5:
        {
            NSLog(@"设置");
            SettingsViewController *settings = [[SettingsViewController alloc]init];
            settings.hidesBottomBarWhenPushed = YES;
            settings.lastPageNavigationHidden = YES;
            [self.navigationController pushViewController:settings animated:YES];
            
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
    
    if (indexPath.row == 3) {
        
        int num = [[RCIMClient sharedRCIMClient]getUnreadCount: @[@(ConversationType_CUSTOMERSERVICE)]];
        if (num <= 0) {
            
            cell.messageNumLabel.hidden = YES;
        }else
        {
            NSString *numstring;
            if (num > 99) {
                numstring = [NSString stringWithFormat:@"%d+",99];
            }else
            {
                numstring = [NSString stringWithFormat:@"%d",num];
            }
            cell.messageNumLabel.hidden = NO;
            
            cell.messageNumLabel.text = numstring;
        }
        
    }else
    {
        cell.messageNumLabel.hidden = YES;
    }
    
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
