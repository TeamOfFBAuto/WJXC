//
//  AddAddressController.m
//  WJXC
//
//  Created by lichaowei on 15/7/14.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "AddAddressController.h"

@interface AddAddressController ()<UITextFieldDelegate>
{
    UIButton *_saveButton;//保存按钮
    UIButton *_defaultButton;//设为默认按钮
}

@end

@implementation AddAddressController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"新建收货地址";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickToHidderKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    NSArray *titles = @[@"收货人:",@"手机号码:",@"所在地区:",@"详细地址:"];
    
    int count = (int)titles.count;
    
    CGFloat top = 0.f;
    
    for (int i = 0; i < count; i ++) {
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 50 * i, 70, 50) title:titles[i] font:15 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"656565"]];
        [self.view addSubview:label];
        
        UITextField *tf = [[UITextField alloc]initWithFrame:CGRectMake(label.right, label.top, DEVICE_WIDTH - label.right - 10, label.height)];
        [self.view addSubview:tf];
        tf.font = [UIFont systemFontOfSize:14];
        tf.delegate = self;
        
        tf.tag = 100 + i;
        
        if (self.isEditAddress) {
            
            if (i == 0) {
                tf.text = self.addressModel.receiver_username;
            }else if (i == 1){
                tf.text = self.addressModel.mobile;
            }else if (i == 2){
                tf.text = self.addressModel.address;
            }else if (i == 3){
                tf.text = self.addressModel.street;
            }
        }

        if (i == 1) {
            //手机号
            tf.keyboardType = UIKeyboardTypePhonePad;
            tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        }
        
        if (i == 2) {
            //地区
            
            tf.enabled = NO;//是否可以用
            
            tf.width -= 18;
            
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 15 - 8, tf.top, 8, 50)];
            imageView.image = [UIImage imageNamed:@"shopping cart_dd_top_jt"];
            [self.view addSubview:imageView];
            imageView.contentMode = UIViewContentModeCenter;
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = tf.frame;
            [self.view addSubview:btn];
            [btn addTarget:self action:@selector(clickToSelectArea:) forControlEvents:UIControlEventTouchUpInside];
            
            tf.text = @"北京市东城区";
        }
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, label.bottom, DEVICE_WIDTH, 0.5)];
        line.backgroundColor = [UIColor colorWithHexString:@"e4e4e4"];
        [self.view addSubview:line];
        
        top = line.bottom;
    }
    
    //设置默认
    
    _defaultButton = [[UIButton alloc]initWithframe:CGRectMake(0, top, 50, 50) buttonType:UIButtonTypeCustom nornalImage:[UIImage imageNamed:@"shopping cart_normal"] selectedImage:[UIImage imageNamed:@"shopping cart_selected"] target:self action:@selector(clickToSelect:)];
    [self.view addSubview:_defaultButton];
    
    //设置是否默认地址
    _defaultButton.selected = [self.addressModel.default_address intValue] == 1 ? YES : NO;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(_defaultButton.right + 5, _defaultButton.top, 160, 50)];
    [self.view addSubview:label];
    label.font = [UIFont systemFontOfSize:15];
    label.text = @"设为默认地址";
    
    _saveButton = [[UIButton alloc]initWithframe:CGRectMake(33, DEVICE_HEIGHT - 64 - 25 - 43, DEVICE_WIDTH - 66, 43) buttonType:UIButtonTypeCustom normalTitle:@"保存" selectedTitle:nil target:self action:@selector(clickToSave:)];
    [self.view addSubview:_saveButton];
    [_saveButton addCornerRadius:3.f];
    [_saveButton setTitleColor:[UIColor colorWithHexString:@"bcbcbc"] forState:UIControlStateNormal];
    [_saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_saveButton setBackgroundColor:[UIColor colorWithHexString:@"f0f0f0"]];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(controlSaveButton) name:UITextFieldTextDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(controlSaveButton) name:UITextFieldTextDidBeginEditingNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(controlSaveButton) name:UITextFieldTextDidEndEditingNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark 网络请求

/**
 *  添加收货地址
 */
- (void)addAddress
{
//http://182.92.106.193:85/index.php?d=api&c=user&m=add_user_address
//    post参数调取参数：
//    authcode
//    省份id
//    城市id
//    具体的地址
//    收货人姓名
//    收货人手机号
//    收货人电话（可不填）
//    邮编（可不填）
//    是否设为默认地址 1=》是 0=》不是
    
    
    NSString *street = [self textFieldForTag:103].text;
    NSString *receiver_username = [self textFieldForTag:100].text;
    NSString *mobile = [self textFieldForTag:101].text;
    
    if (![LTools isValidateMobile:mobile]) {
        
        [LTools showMBProgressWithText:@"请填写有效手机号" addToView:self.view];
        
        return;
    }
    
    int isDefault = _defaultButton.selected ? 1 : 0;
    
    NSDictionary *params;
    NSString *api;
    
    //编辑
    if (self.isEditAddress) {
        
        api = USER_ADDRESS_EDIT;
        params = @{@"authcode":[GMAPI getAuthkey],
                                 @"address_id":self.addressModel.address_id,
                                 @"pro_id":@"1000",
                                 @"city_id":@"1001",
                                 @"street":street,
                                 @"receiver_username":receiver_username,
                                 @"mobile":mobile,
                                 @"default_address":[NSNumber numberWithInt:isDefault]};
    }else
    {
        api = USER_ADDRESS_ADD;
        params = @{@"authcode":[GMAPI getAuthkey],
                                 @"pro_id":@"1000",
                                 @"city_id":@"1001",
                                 @"street":street,
                                 @"receiver_username":receiver_username,
                                 @"mobile":mobile,
                                 @"default_address":[NSNumber numberWithInt:isDefault]};
    }

    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    __weak typeof(self)weakSelf = self;
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:api parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_ADDADDRESS object:nil];
        
        [weakSelf performSelector:@selector(leftButtonTap:) withObject:self afterDelay:0.3];
        
    } failBlock:^(NSDictionary *result) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    }];

}

#pragma - mark 事件处理

- (UITextField *)textFieldForTag:(int)tag
{
    return (UITextField *)[self.view viewWithTag:tag];
}

- (void)clickToSelect:(UIButton *)sender
{
    sender.selected = !sender.selected;
}

/**
 *  保存新的地址
 *
 *  @param sender
 */
- (void)clickToSave:(UIButton *)sender
{
    [self addAddress];
}

/**
 *  隐藏键盘
 */
- (void)clickToHidderKeyboard
{
    for (int i = 0; i < 4; i ++) {
        
        if ([[self textFieldForTag:100 + i] isFirstResponder]) {
            
            [[self textFieldForTag:100 + i] resignFirstResponder];
        }
    }
    
    self.view.top = 64;
}

/**
 *  选择区域
 *
 *  @param sender
 */
- (void)clickToSelectArea:(UIButton *)sender
{
    
}

/**
 *  检查内容是否都填写了
 */
- (BOOL)allTextFieldIsOK
{
    for (int i = 0; i < 4; i ++) {
        
        //只要有一个为空就 NO
        if ([self textFieldForTag:100 + i].text.length == 0) {
            
            return NO;
        }
    }
    
    return YES;
}

/**
 *  控制保存按钮显示状态
 */
- (void)controlSaveButton
{
    if ([self allTextFieldIsOK]) {
        
        [_saveButton setBackgroundColor:DEFAULT_TEXTCOLOR];
        _saveButton.selected = YES;
    }else
    {
        [_saveButton setBackgroundColor:[UIColor colorWithHexString:@"f0f0f0"]];
        _saveButton.selected = NO;
    }
}

#pragma - mark UITextFieldDelegate <NSObject>

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (iPhone4) {
        self.view.top = 64 - textField.top;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self clickToHidderKeyboard];
    return YES;
}

@end
