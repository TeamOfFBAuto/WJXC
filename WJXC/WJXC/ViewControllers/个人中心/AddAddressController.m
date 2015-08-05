//
//  AddAddressController.m
//  WJXC
//
//  Created by lichaowei on 15/7/14.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "AddAddressController.h"

@interface AddAddressController ()<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
    UIButton *_saveButton;//保存按钮
    UIButton *_defaultButton;//设为默认按钮
    
    
    
    //地区选择
    UIPickerView *_pickeView;
    NSArray *_data;//地区数据
    NSInteger _flagRow;//pickerView地区标志位
    //地区数据字符串拼接
    NSString *_str3;
    NSString *_str1;
    NSString *_str2;
    BOOL _isChooseArea;//是否修改了地区
}

@property(nonatomic,strong)UIView *backPickView;//地区选择pickerView后面的背景view
@property(nonatomic,strong)NSString *province;//省
@property(nonatomic,strong)NSString *city;//城市
@property(nonatomic,assign)NSInteger provinceIn;//省份对应id
@property(nonatomic,assign)NSInteger cityIn;//市区对应id

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
                
                NSString *add = [NSString stringWithFormat:@"%@%@",[GMAPI cityNameForId:[self.addressModel.pro_id intValue]],[GMAPI cityNameForId:[self.addressModel.city_id intValue]]];
                tf.text = add;
                
                self.provinceIn = [self.addressModel.pro_id integerValue];
                self.cityIn = [self.addressModel.city_id integerValue];
                
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
    
    
    
    [self createAreaPickView];
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
    NSString *street = [self textFieldForTag:103].text;
    NSString *receiver_username = [self textFieldForTag:100].text;
    NSString *mobile = [self textFieldForTag:101].text;
    
    if (![LTools isValidateMobile:mobile]) {
        
        [LTools showMBProgressWithText:@"请填写有效手机号" addToView:self.view];
        
        return;
    }
    
    if ([self textFieldForTag:102].text.length == 0) {
        
        [LTools showMBProgressWithText:@"请选择地区" addToView:self.view];
        
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
                                 @"pro_id":[NSNumber numberWithInteger:self.provinceIn],
                                 @"city_id":[NSNumber numberWithInteger:self.cityIn],
                                 @"street":street,
                                 @"receiver_username":receiver_username,
                                 @"mobile":mobile,
                                 @"default_address":[NSNumber numberWithInt:isDefault]};
    }else
    {
        api = USER_ADDRESS_ADD;
        params = @{@"authcode":[GMAPI getAuthkey],
                                 @"pro_id":[NSNumber numberWithInteger:self.provinceIn],
                                 @"city_id":[NSNumber numberWithInteger:self.cityIn],
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
    
    [self clickToHidderKeyboard];//隐藏键盘
    [self areaShow];
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
    
    [self areaHidden];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self clickToHidderKeyboard];
    
    return YES;
}

#pragma mark - 地区选择相关

-(void)createAreaPickView{
    //地区pickview
    _pickeView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 40, DEVICE_WIDTH, 216)];
    _pickeView.delegate = self;
    _pickeView.dataSource = self;
    _isChooseArea = NO;
    
    
    NSLog(@"%@",NSStringFromCGRect(_pickeView.frame));
    
    //取消按钮
    UIButton *quxiaoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    quxiaoBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [quxiaoBtn setTitle:@"取消" forState:UIControlStateNormal];
    [quxiaoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    quxiaoBtn.frame = CGRectMake(10, 5, 60, 30);
    [quxiaoBtn addTarget:self action:@selector(clickToCancel:) forControlEvents:UIControlEventTouchUpInside];
    [quxiaoBtn setBorderWidth:1 borderColor:DEFAULT_TEXTCOLOR];
    [quxiaoBtn addCornerRadius:3.f];
    
    //确定按钮
    UIButton *quedingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    quedingBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [quedingBtn setTitle:@"确定" forState:UIControlStateNormal];
    [quedingBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    quedingBtn.frame = CGRectMake(DEVICE_WIDTH - 70, 5, 60, 30);
    [quedingBtn setBorderWidth:1 borderColor:DEFAULT_TEXTCOLOR];
    [quedingBtn addCornerRadius:3.f];

    [quedingBtn addTarget:self action:@selector(clickToSure:) forControlEvents:UIControlEventTouchUpInside];
    
    //地区选择
    self.backPickView = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 310)];
    self.backPickView .backgroundColor = [UIColor whiteColor];
    
    //上线
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 40)];
    line.backgroundColor = DEFAULT_LINECOLOR;
    [self.backPickView addSubview:line];
    
    //下线
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 40, DEVICE_WIDTH, 0.5f)];
    line2.backgroundColor = DEFAULT_LINECOLOR;
    [self.backPickView addSubview:line2];
    
    [self.backPickView addSubview:quedingBtn];
    [self.backPickView addSubview:quxiaoBtn];
    [self.backPickView addSubview:_pickeView];
    
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"garea" ofType:@"plist"];
    _data = [NSArray arrayWithContentsOfFile:path];
    
    [self.view addSubview:self.backPickView];
}


//地区出现
-(void)areaShow{
    NSLog(@"_backPickView");
    __weak typeof (self)bself = self;
    [UIView animateWithDuration:0.3 animations:^{
        bself.backPickView.frame = CGRectMake(0,DEVICE_HEIGHT-310, DEVICE_WIDTH, 310);
    }];
}

- (void)clickToCancel:(UIButton *)sender
{
    [self areaHidden];
}

- (void)clickToSure:(UIButton *)sender
{
    [self controlSaveButton];
    
    [self areaHidden];
    
    self.provinceIn = [GMAPI cityIdForName:self.province];
    self.cityIn = [GMAPI cityIdForName:self.city];
    
    NSLog(@"在这里  省:%@ id %ld   市:%@ id:%ld",self.province,self.provinceIn,self.city,self.cityIn);
    [self textFieldForTag:102].text = [NSString stringWithFormat:@"%@%@",self.province,self.city];
}

-(void)areaHidden{//地区隐藏
    __weak typeof (self)bself = self;
    
    
    self.provinceIn = [GMAPI cityIdForName:self.province];
    self.cityIn = [GMAPI cityIdForName:self.city];
    
    NSLog(@"在这里  省:%@ id %ld   市:%@ id:%ld",self.province,self.provinceIn,self.city,self.cityIn);
    
    [UIView animateWithDuration:0.3 animations:^{
        bself.backPickView.frame = CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 310);
    }];
    
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if (component == 0) {
        return _data.count;
    } else if (component == 1) {
        NSArray * cities = _data[_flagRow][@"Cities"];
        return cities.count;
    }
    return 0;
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if (component == 0) {
        if ([_data[row][@"State"] isEqualToString:@"省份"]) {
            self.province = @"";
        }else{
            self.province = _data[row][@"State"];
        }
        
        NSString *provinceStr = [NSString stringWithFormat:@"%@",_data[row][@"State"]];
        //字符转id
        self.provinceIn = [GMAPI cityIdForName:provinceStr];//上传
        return provinceStr;
        
        
    } else if (component == 1) {
        NSArray * cities = _data[_flagRow][@"Cities"];
        if ([cities[row][@"city"] isEqualToString:@"市区县"]) {
            self.city = @"";
        }else{
            self.city = cities[row][@"city"];
        }
        NSString *cityStr = [NSString stringWithFormat:@"%@",cities[row][@"city"]];
        //字符转id
        NSString *pppccc = [NSString stringWithFormat:@"%@%@",self.province,self.city];
        self.cityIn = [GMAPI cityIdForName:pppccc];//上传
        
        return cityStr;
    }
    return 0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (component == 0) {
        _flagRow = row;
        _isChooseArea = YES;
    }else if (component == 1){
        _isChooseArea = YES;
    }
    
    [pickerView reloadAllComponents];
}




@end
