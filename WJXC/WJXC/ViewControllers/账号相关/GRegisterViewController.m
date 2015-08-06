//
//  GRegisterViewController.m
//  WJXC
//
//  Created by gaomeng on 15/7/7.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "GRegisterViewController.h"
static int seconds = 60;//计时60s
@interface GRegisterViewController ()
{
    NSMutableArray *_yuanViewArray;
    NSMutableArray *_downYuanTitleLabelArray;
    NSMutableArray *_numLabelArray;
    
    UIScrollView *_downScrollView;
    NSTimer *timer;
}
@end

@implementation GRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    self.myTitle = @"注册";
    
    [self creatUpView];
    
    [self creatDownInfoView];
    
    [self changeTheUpViewStateWithNum:1];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - MyMeThod

-(void)creatUpView{
    
    CGFloat jianju = (DEVICE_WIDTH - (32*3)) /4.0;
    _yuanViewArray = [NSMutableArray arrayWithCapacity:1];
    _downYuanTitleLabelArray = [NSMutableArray arrayWithCapacity:1];
    _numLabelArray = [NSMutableArray arrayWithCapacity:1];
    
    self.upThreeStepView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 90)];
    self.upThreeStepView.backgroundColor = RGBCOLOR(235, 236, 238);
    UIControl *control = [[UIControl alloc]initWithFrame:self.upThreeStepView.bounds];
    [control addTarget:self action:@selector(gShou) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.upThreeStepView];
    
    NSArray *titleArray = @[@"输入手机号",@"输入验证码",@"设置密码"];
    for (int i = 0; i<3; i++) {
        UIView *oneView = [[UIView alloc]initWithFrame:CGRectMake(jianju + i*(jianju+32), 20, 32, 32)];
        if (i == 0) {
            [oneView setFrame:CGRectMake(jianju - 10 + i*(jianju+32), 20, 32, 32)];
            UIView *fenge = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(oneView.frame)+15, oneView.center.y, jianju - 20, 1)];
            fenge.backgroundColor = RGBCOLOR(201, 202, 203);
            [self.upThreeStepView addSubview:fenge];
        }else if (i == 2){
            [oneView setFrame:CGRectMake(jianju + 10 + i*(jianju+32), 20, 32, 32)];
            
        }else if (i == 1){
            UIView *fenge = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(oneView.frame)+15, oneView.center.y, jianju - 20, 1)];
            fenge.backgroundColor = RGBCOLOR(201, 202, 203);
            [self.upThreeStepView addSubview:fenge];
        }
        oneView.layer.cornerRadius = 16;
        oneView.layer.borderWidth = 1;
        oneView.layer.borderColor = [RGBCOLOR(79, 80, 81)CGColor];
        oneView.layer.masksToBounds = YES;
        oneView.backgroundColor = [UIColor clearColor];
        [self.upThreeStepView addSubview:oneView];
        [_yuanViewArray addObject:oneView];
        
        
        UILabel *numLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        numLabel.textAlignment = NSTextAlignmentCenter;
        numLabel.textColor = RGBCOLOR(79, 80, 81);
        numLabel.text = [NSString stringWithFormat:@"%d",i+1];
        numLabel.center = oneView.center;
        [self.upThreeStepView addSubview:numLabel];
        [_numLabelArray addObject:numLabel];
        
        UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70, 15)];
        tLabel.text = titleArray[i];
        CGPoint ccter = oneView.center;
        tLabel.font = [UIFont systemFontOfSize:12];
        tLabel.textAlignment = NSTextAlignmentCenter;
        ccter.y = CGRectGetMaxY(oneView.frame)+15;
        tLabel.center = ccter;
        [self.upThreeStepView addSubview:tLabel];
        [_downYuanTitleLabelArray addObject:tLabel];
    }
    
    
    
}


//修改上方状态
-(void)changeTheUpViewStateWithNum:(int)theNum{
    
    
    //修改顶部
    
    for (UILabel *lable in _numLabelArray) {
        lable.textColor = RGBCOLOR(79, 80, 81);
    }
    
    for (UIView *oneView in _yuanViewArray) {
        oneView.backgroundColor = [UIColor clearColor];
        oneView.layer.cornerRadius = 16;
        oneView.layer.borderWidth = 1;
        oneView.layer.borderColor = [RGBCOLOR(79, 80, 81)CGColor];
        oneView.layer.masksToBounds = YES;
    }
    
    for (UILabel *numLabel in _downYuanTitleLabelArray) {
        numLabel.textColor = RGBCOLOR(79, 80, 81);
    }
    
    
    UIView *oneView = _yuanViewArray[theNum - 1];
    oneView.backgroundColor = RGBCOLOR(122, 172, 0);
    oneView.layer.borderWidth = 0;
    UILabel *numlabel = _numLabelArray[theNum - 1];
    numlabel.textColor = [UIColor whiteColor];
    UILabel *ttLabel = _downYuanTitleLabelArray[theNum - 1];
    ttLabel.textColor = RGBCOLOR(122, 172, 0);
    
}


//创建下方信息填写view
-(void)creatDownInfoView{

    _downScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.upThreeStepView.frame), DEVICE_WIDTH, DEVICE_HEIGHT-64-self.upThreeStepView.frame.size.height)];
    _downScrollView.userInteractionEnabled = YES;
    _downScrollView.scrollEnabled = YES;
    [_downScrollView setContentSize:CGSizeMake(DEVICE_WIDTH*3, self.downInfoView.frame.size.height)];
    [self.view addSubview:_downScrollView];
    
    
    
    
    //输入手机号
    
    UIView *phoneNumView = [[UIView alloc]initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH - 20, 47)];
    phoneNumView.backgroundColor = [UIColor whiteColor];
    phoneNumView.layer.cornerRadius = 4;
    [_downScrollView addSubview:phoneNumView];
    
    self.phoneTF = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, phoneNumView.frame.size.width-20, 47)];
    [phoneNumView addSubview:self.phoneTF];
    self.phoneTF.tag = 100;
    self.phoneTF.font = [UIFont systemFontOfSize:15];
    self.phoneTF.placeholder = @"输入手机号";
    
    UIButton *getYanzhengmaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [getYanzhengmaBtn setFrame:CGRectMake(10, CGRectGetMaxY(phoneNumView.frame)+20, DEVICE_WIDTH-20, 47)];
//    [getYanzhengmaBtn setBackgroundColor:RGBCOLOR(207, 208, 209)];
//    [getYanzhengmaBtn setTitleColor:RGBCOLOR(155, 156, 157) forState:UIControlStateNormal];
    [getYanzhengmaBtn setBackgroundColor:RGBCOLOR(122, 172, 0)];
    [getYanzhengmaBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [getYanzhengmaBtn addTarget:self action:@selector(getYanzhengmaBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [getYanzhengmaBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    getYanzhengmaBtn.layer.cornerRadius = 4;
    getYanzhengmaBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_downScrollView addSubview:getYanzhengmaBtn];
    
    
    
    //输入验证码
    UIView *yanzhengmaView = [[UIView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH+10, 0, DEVICE_WIDTH-20, 47)];
    yanzhengmaView.backgroundColor = [UIColor whiteColor];
    yanzhengmaView.layer.cornerRadius = 4;
    yanzhengmaView.tag = 101;
    [_downScrollView addSubview:yanzhengmaView];
    
    self.yanzhengmaTf = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, yanzhengmaView.frame.size.width-20, 47)];
    self.yanzhengmaTf.placeholder = @"请输入验证码";
    self.yanzhengmaTf.font = [UIFont systemFontOfSize:15];
    [yanzhengmaView addSubview:self.yanzhengmaTf];

    UILabel *tishiLabel = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH+10, CGRectGetMaxY(yanzhengmaView.frame)+14, yanzhengmaView.frame.size.width, 15)];
    tishiLabel.font = [UIFont systemFontOfSize:12];
    tishiLabel.textColor = RGBCOLOR(122, 123, 124);
    tishiLabel.text = @"没有收到短信验证码？请在一分钟后重试";
    [_downScrollView addSubview:tishiLabel];

    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(DEVICE_WIDTH+10, CGRectGetMaxY(tishiLabel.frame)+14, yanzhengmaView.frame.size.width, 40)];
    btn.backgroundColor = RGBCOLOR(122, 172, 0);
    [btn setTitle:@"下一步" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClicked) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    btn.layer.cornerRadius = 4;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_downScrollView addSubview:btn];

    
    //设置密码
    
    UIView *mimaView = [[UIView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH*2+10, 0, DEVICE_WIDTH-20, 98.5)];
    mimaView.backgroundColor = [UIColor whiteColor];
    mimaView.layer.cornerRadius = 4;
    UIView *fenge = [[UIView alloc]initWithFrame:CGRectMake(0, 49, mimaView.frame.size.width, 0.5)];
    fenge.backgroundColor = RGBCOLOR(231, 232, 234);
    [mimaView addSubview:fenge];
    [_downScrollView addSubview:mimaView];
    
    for (int i = 0; i<2; i++) {
        
        if (i == 0) {
            self.mimaTf = [[UITextField alloc]initWithFrame:CGRectMake(10, 49.5*i, mimaView.frame.size.width-20, 49)];
            self.mimaTf.font = [UIFont systemFontOfSize:12];
            self.mimaTf.placeholder = @"输入密码";
            [mimaView addSubview:self.mimaTf];
        }else if (i == 1){
            self.mima2Tf = [[UITextField alloc]initWithFrame:CGRectMake(10, 49.5*i, mimaView.frame.size.width-20, 49)];
            self.mima2Tf.font = [UIFont systemFontOfSize:12];
            self.mima2Tf.placeholder = @"再次输入密码";
            [mimaView addSubview:self.mima2Tf];
        }
        
    }
    
    
    UIButton *querenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [querenBtn setFrame:CGRectMake(2*DEVICE_WIDTH+10, CGRectGetMaxY(mimaView.frame)+12, mimaView.frame.size.width, 40)];
    [querenBtn setTitle:@"确认" forState:UIControlStateNormal];
    [querenBtn addTarget:self action:@selector(querenBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    querenBtn.layer.cornerRadius = 4;
    querenBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [querenBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [querenBtn setBackgroundColor:RGBCOLOR(122, 172, 0)];
    [_downScrollView addSubview:querenBtn];
    
    
    
}



//收键盘
-(void)gShou{
    [self.phoneTF resignFirstResponder];
    [self.yanzhengmaTf resignFirstResponder];
}


//获取验证码
-(void)getYanzhengmaBtnClicked{
    
    
    if (self.phoneTF.text.length < 11) {
        [GMAPI showAutoHiddenMBProgressWithText:@"请填写手机号" addToView:self.view];
    }else{
        SecurityCode_Type type;//默认注册
        type = 1;
        
        NSString *mobile = self.phoneTF.text;
        
        if (![LTools isValidateMobile:mobile]) {
            
            [LTools alertText:ALERT_ERRO_PHONE viewController:self];
            return;
        }
        
        [self startTimer];
        
        __weak typeof(self)weakSelf = self;
        
       
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        NSDictionary *param = @{
                                @"mobile":mobile
                                };
        [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:USER_GET_SECURITY_CODE parameters:param constructingBodyBlock:nil completion:^(NSDictionary *result) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSLog(@"result %@",result);
            
            [LTools showMBProgressWithText:result[RESULT_INFO] addToView:self.view];
            
            [self changeTheUpViewStateWithNum:2];
            [_downScrollView setContentOffset:CGPointMake(DEVICE_WIDTH, 0) animated:YES];
        } failBlock:^(NSDictionary *result) {
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSLog(@"failDic %@",result);
            [GMAPI showAutoHiddenMBProgressWithText:[result objectForKey:@"msg"] addToView:self.view];
            [weakSelf renewTimer];
        }];
        
        
    }
    
    
    
    
}

//输入完验证码
-(void)btnClicked{
    
    
    
    if (self.yanzhengmaTf.text.length == 0) {
        [GMAPI showAutoHiddenMBProgressWithText:@"请输入验证码" addToView:self.view];
    }else{
        [self changeTheUpViewStateWithNum:3];
        [_downScrollView setContentOffset:CGPointMake(2*DEVICE_WIDTH, 0) animated:YES];
    }
    
    
}

//提交注册
-(void)querenBtnClicked{
    //    get方式调取
    //    参数解释依次为:
    //    username(昵称,可不填，系统自动分配一个) string
    //    password（密码，必须大于等于6位，不能有中文）string
    //    gender(性别，1=》男 2=》女，可不填，默认为女) int
    //    type(注册类型，1=》手机注册 2=》邮箱注册，默认为手机注册) int
    //    code(验证码 6位数字) int
    //    mobile(手机号) string
    
    [self gShou];
    
    
    if (![self.mimaTf.text isEqualToString:self.mima2Tf.text]) {
        [GMAPI showAutoHiddenMBProgressWithText:@"两次输入密码不一致" addToView:self.view];
        return;
    }
    
    NSString *userName = @"";
    NSString *password = self.mimaTf.text;
    Gender sex = Gender_Girl;//默认女
    Register_Type type = Register_Phone;//默认手机号方式
    int code = [self.yanzhengmaTf.text intValue];
    NSString *mobile = self.phoneTF.text;
    
    if (![LTools isValidateMobile:mobile]) {
        
        [LTools alertText:ALERT_ERRO_PHONE viewController:self];
        return;
    }
    
    if (![LTools isValidatePwd:password]) {
        
        [LTools alertText:ALERT_ERRO_PASSWORD viewController:self];
        return;
    }
    if (self.mimaTf.text.length != 6) {
        
        [LTools alertText:ALERT_ERRO_SECURITYCODE viewController:self];
        return;
    }
    
    
    NSString *codestr = [NSString stringWithFormat:@"%d",code];
    NSDictionary *params = @{@"mobile":mobile,
                             @"code":codestr,
                             @"password":password
                             };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:USER_REGISTER_ACTION parameters:params constructingBodyBlock:nil completion:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self performSelector:@selector(clickToClose) withObject:nil afterDelay:0.2];
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSLog(@"failDic %@",result);
    }];
}


- (void)clickToClose {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}



- (void)startTimer
{
//    [self.codeButton setTitle:@"" forState:UIControlStateNormal];
//    
//    self.codeLabel.hidden = NO;
//    
//    seconds = 60;
//    
//    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(calculateTime) userInfo:Nil repeats:YES];
//    _codeButton.userInteractionEnabled = NO;
}

//计算时间
- (void)calculateTime
{
//    NSString *title = [NSString stringWithFormat:@"%d秒",seconds];
//    
//    self.codeLabel.text = title;
//    
//    if (seconds != 0) {
//        seconds --;
//    }else
//    {
//        [self renewTimer];
//    }
    
}
//计时器归零
- (void)renewTimer
{
//    [timer invalidate];//计时器停止
//    _codeButton.userInteractionEnabled = YES;
//    [_codeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
//    _codeLabel.hidden = YES;
//    seconds = 60;
}

@end
