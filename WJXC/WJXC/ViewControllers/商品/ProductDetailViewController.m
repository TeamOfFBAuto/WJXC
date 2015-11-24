//
//  ProductDetailViewController.m
//  WJXC
//
//  Created by gaomeng on 15/7/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "ProductDetailTableViewCell.h"
#import "ProductDetailModel.h"
#import "ProductCommentViewController.h"
#import "RCDChatViewController.h"
#import "ProductModel.h"
#import "ShoppingCarController.h"
#import "SimpleMessage.h"
#import "ConfirmOrderController.h"//确认订单
#import "CoupeView.h"
#import "ButtonProperty.h"
#import "CouponModel.h"
#import "CycleScrollView.h"

@interface ProductDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    UITableView *_tableView;//主tableview
    
    ProductDetailModel *_theProductModel;//数据源
    
    ProductModel *_gouwucheModel;//加入购物车Model
    
    ProductDetailTableViewCell *_tmpCell;
    
    UIButton *_shoucangBtn;
    
    int _theNum;
    
    NSString *_isfavor;//是否收藏
    
    UILabel *_numLabel;//购物车数量
    
    NSString *_endTime;//秒杀倒计时
    UILabel *_miaoShaLabel;//秒杀时间
    NSTimer *_miaoShaTimer;//秒杀计时器
    
    UIButton *_jiaruBtn;//加入购物车或者立即秒杀

    BOOL _isHiddenNavigation;//控制navigationBar显示
    
    CoupeView *_coupeView;//领取优惠券view
}

@property(nonatomic,retain)UIView *selectNumView;//修改加入购物车数字view
@property(nonatomic,retain)UIView *selectNumBgView;//修改加入购物车数字 背景view
@property(nonatomic,retain)UIButton *reductButton;//减少
@property(nonatomic,retain)UIButton *addButton;//加
@property(nonatomic,retain)UITextField *numTf;//显示数量
@property(nonatomic,retain)CycleScrollView *mainScorllView;

@end

@implementation ProductDetailViewController


-(void)viewWillAppear:(BOOL)animated{
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (_isHiddenNavigation) {
        
        _isHiddenNavigation = NO;
        return;
    }
    
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeText WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    self.view.backgroundColor = RGBCOLOR(241, 240, 245);
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(prepareNetData) name:NOTIFICATION_LOGIN object:nil];
    
    [self addKeyBordNotification];
    
    [self creatTableView];
    
    UIView *head = [self creatGscrollViewWithProductModel:nil];
    _tableView.tableHeaderView = head;
    
    [self creatUpView];
    
    [self prepareNetData];
    
    [self addVisitNum];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 网络请求

-(void)networkForCollect{
    
    NSString *authcode = [GMAPI getAuthkey];
    if (authcode.length == 0) {
        
        _isHiddenNavigation = YES;
        
        LoginViewController *login = [[LoginViewController alloc]init];
        
        UINavigationController *unVc = [[UINavigationController alloc]initWithRootViewController:login];
        
        [self presentViewController:unVc animated:YES completion:nil];
        
        return;
    }
    
    
    if ([_isfavor intValue] == 0) {
        NSString *product_id = _theProductModel.product_id;
        
        NSDictionary *dic = @{
                              @"product_id":product_id,
                              @"authcode":[GMAPI getAuthkey],
                              };
        [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:SHOUCANGRODUCT parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
            
            [GMAPI showAutoHiddenMBProgressWithText:[result stringValueForKey:@"msg"] addToView:self.view];
            
            _isfavor = @"1";
            [_shoucangBtn setImage:[UIImage imageNamed:@"homepage_qianggou_collect_y.png"] forState:UIControlStateNormal];
            
        } failBlock:^(NSDictionary *result) {
            
        }];
        
    }else if ([_isfavor intValue] == 1){
        NSString *product_id = _theProductModel.product_id;
        
        NSDictionary *dic = @{
                              @"product_id":product_id,
                              @"authcode":[GMAPI getAuthkey],
                              };
        [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:QUXIAOSHOUCANG parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
            
            [GMAPI showAutoHiddenMBProgressWithText:[result stringValueForKey:@"msg"] addToView:self.view];
            
            _isfavor = @"0";
            [_shoucangBtn setImage:[UIImage imageNamed:@"homepage_qianggou_collect.png"] forState:UIControlStateNormal];
            
        } failBlock:^(NSDictionary *result) {
            
        }];
    }
    
}

/**
 *  添加购物车
 */
- (void)addProductWithNum:(int)num
{
    ProductModel *aModel = _gouwucheModel;
    
    int product_num = num;//每次加num个
    
    aModel.addNum = num;
    
    NSString *authcode = [GMAPI getAuthkey];
    
    if (authcode.length == 0) {
        
        [[DBManager shareInstance]insertProduct:aModel];
        
        [LTools showMBProgressWithText:@"添加成功" addToView:self.view];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_UPDATE_TO_CART object:nil];
        
        int num = [[DBManager shareInstance] QueryAllDataNum];
        if (num > 0) {
            _numLabel.hidden = NO;
            _numLabel.text = [NSString stringWithFormat:@"%d",num];
        }else
        {
            _numLabel.hidden = YES;
        }
        
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    NSDictionary*dic = @{@"authcode":authcode,
                         @"product_id":aModel.product_id,
                         @"product_num":[NSNumber numberWithInt:product_num]};
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:ORDER_ADD_TO_CART parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [LTools showMBProgressWithText:result[RESULT_INFO] addToView:self.view];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_UPDATE_TO_CART object:nil];
        
        [weakSelf getShoppingCarNum];
        
    } failBlock:^(NSDictionary *result) {
        
        
    }];
    
}

/**
 *  领取优惠劵
 *
 *  @param aModel 优惠劵model
 *  @param sender
 */
- (void)netWorkForCouponModel:(CouponModel *)aModel
                       button:(UIButton *)sender
{
    
    if (![LTools isLogin:self]) {
        
        [_coupeView removeFromSuperview];
        _coupeView = nil;
        
        return;
    }
    
    NSDictionary * parame  = @{
                               @"coupon_id":aModel.coupon_id,
                               @"authcode":[GMAPI getAuthkey]
                               };
    
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:GET_COUPON parameters:parame constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSLog(@"result %@",result);
        aModel.enable_receive = @"0";
        sender.selected = YES;
        
    } failBlock:^(NSDictionary *result) {
        NSLog(@"failBlock == %@",result);
    }];
    
}

/**
 *  添加浏览量
 */
- (void)addVisitNum
{
    NSDictionary *param;
    NSString *authcode = [GMAPI getAuthkey];
    if (authcode.length == 0) {
        param  = @{
                    @"product_id":self.product_id,
                    };
    }else{
        param  = @{
                    @"product_id":self.product_id,
                    @"authcode":[GMAPI getAuthkey]
                    };
    }
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:GET_PRODUCT_ADDVIEW parameters:param constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"浏览量+1 success");
    } failBlock:^(NSDictionary *result) {
       
        NSLog(@"浏览量+1 fail");
    }];
}

/**
 *  请求单品详情
 */
-(void)prepareNetData
{
    NSDictionary *parame;
    NSString *authcode = [GMAPI getAuthkey];
    if (authcode.length == 0) {
        parame  = @{
                    @"product_id":self.product_id,
                    };
    }else{
        parame  = @{
                    @"product_id":self.product_id,
                    @"authcode":[GMAPI getAuthkey]
                    };
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak typeof(self)weakSelf = self;
    __weak typeof(_tableView)weakTable = _tableView;
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:GET_PRODUCTDETAIL parameters:parame constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        int code = [result[RESULT_CODE]intValue];
        if (code == 2000) {
            
            [self performSelector:@selector(leftButtonTap:) withObject:nil afterDelay:0.5];
        }
        
        NSDictionary *detail = [result dictionaryValueForKey:@"detail"];
        
        _theProductModel = [[ProductDetailModel alloc]initWithDictionary:detail];
        
        //多张轮播图
        if (weakTable.tableHeaderView) {
            weakTable.tableHeaderView = nil;
        }
        UIView *head = [self creatGscrollViewWithProductModel:_theProductModel];
        weakTable.tableHeaderView = head;
        
        NSString *text = nil;
        //秒杀判断
        if ([_theProductModel.is_seckill intValue] == 1) {
            
            text = @"立即秒杀";
            
            [weakSelf miaoShaTimer];
        }else
        {
            text = @"加入购物车";
            
            [_miaoShaTimer isValid];
            _miaoShaTimer = nil;
        }
        [_jiaruBtn setTitle:text forState:UIControlStateNormal];
        
        _gouwucheModel = [[ProductModel alloc]initWithDictionary:detail];
        
        _isfavor = _theProductModel.is_favor;
        
        if ([_isfavor intValue] == 0) {//未收藏
            [_shoucangBtn setImage:[UIImage imageNamed:@"homepage_qianggou_collect.png"] forState:UIControlStateNormal];
        }else if ([_isfavor intValue] == 1){//已收藏
            [_shoucangBtn setImage:[UIImage imageNamed:@"homepage_qianggou_collect_y.png"] forState:UIControlStateNormal];
        }
        
        _shoucangBtn.hidden = NO;
        
        [_tableView reloadData];
        
        
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSLog(@"%@",result);
    }];
}

#pragma mark - 视图创建

//创建上面返回收藏分享按钮
-(void)creatUpView{
    UIImageView *theBImv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 60)];
    [theBImv setImage:[UIImage imageNamed:@"homepage_qianggou_banner_top_bg.png"]];
    theBImv.userInteractionEnabled = YES;
    [self.view addSubview:theBImv];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, 10, 50, 50);
    [backBtn setImage:[UIImage imageNamed:@"homepage_qianggou_back.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(gGoback) forControlEvents:UIControlEventTouchUpInside];
    [theBImv addSubview:backBtn];
    
    
    _shoucangBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_shoucangBtn setFrame:CGRectMake(DEVICE_WIDTH - 60, 5, 50, 50)];
    [_shoucangBtn setImage:[UIImage imageNamed:@"homepage_qianggou_collect.png"] forState:UIControlStateNormal];
    [_shoucangBtn addTarget:self action:@selector(networkForCollect) forControlEvents:UIControlEventTouchUpInside];
    [theBImv addSubview:_shoucangBtn];
    _shoucangBtn.hidden = YES;
    
    //    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [shareBtn setFrame:CGRectMake(DEVICE_WIDTH - 50, 5, 50, 50)];
    //    [shareBtn setImage:[UIImage imageNamed:@"homepage_qianggou_share.png"] forState:UIControlStateNormal];
    //    [theBImv addSubview:shareBtn];
}

//创建循环滚动的scrollview
-(UIView *)creatGscrollViewWithProductModel:(ProductDetailModel *)aModel
{
    NSArray *coverImages = aModel.multi_cover;
    if (!aModel || coverImages.count == 0) {
        
        UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0)];
        [imv sd_setImageWithURL:[NSURL URLWithString:_theProductModel.cover_pic] placeholderImage:[UIImage imageNamed:@"default02.png"]];
        return imv;
    }
    int count = (int)coverImages.count;
    NSMutableArray *viewsArray = [NSMutableArray arrayWithCapacity:1];
    for (int i = 0; i < count; i++) {
        UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_WIDTH *W_H_RATIO)];
        imv.userInteractionEnabled = YES;
        NSDictionary *dic = coverImages[i];
        [imv sd_setImageWithURL:[NSURL URLWithString:dic[@"cover_pic"]] placeholderImage:[UIImage imageNamed:@"default02"]];
        [viewsArray addObject:imv];
    }
    
    self.mainScorllView = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_WIDTH * W_H_RATIO) animationDuration:4];
    self.mainScorllView.scrollView.showsHorizontalScrollIndicator = FALSE;
    
    self.mainScorllView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        return viewsArray[pageIndex];
    };
    
    self.mainScorllView.totalPagesCount = ^NSInteger(void){
        return count;
    };
    
//    __weak typeof (self)bself = self;
//    self.mainScorllView.TapActionBlock = ^(NSInteger pageIndex){
//        [bself cycleScrollDidClickedWithIndex:pageIndex];
//    };
    
    return self.mainScorllView;
}



//创建tableview
-(void)creatTableView{
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-45) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    UIImageView *downView = [[UIImageView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT - 45, DEVICE_WIDTH, 45)];
    downView.userInteractionEnabled = YES;
    [downView setImage:[UIImage imageNamed:@"homepage_qiangou_bottom_bg.png"]];
    [self.view addSubview:downView];
    
    //线条
    UIView *topLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, downView.width, 0.5)];
    topLine.backgroundColor = [UIColor colorWithHexString:@"8ab800"];
    [downView addSubview:topLine];
    
    UIButton *phoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [phoneBtn setFrame:CGRectMake(10, 0, 45, 45)];
    //    phoneBtn.backgroundColor = [UIColor orangeColor];
    [phoneBtn setTitle:@"拨打电话" forState:UIControlStateNormal];
    phoneBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    [phoneBtn setImage:[UIImage imageNamed:@"bodadianhua.png"] forState:UIControlStateNormal];
    [phoneBtn setTitleColor:RGBCOLOR(132, 173, 0) forState:UIControlStateNormal];
    [phoneBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 10, 20, 0)];
    [phoneBtn setTitleEdgeInsets:UIEdgeInsetsMake(15, -15, 0, 0)];
    [phoneBtn addTarget:self action:@selector(bodadianhua) forControlEvents:UIControlEventTouchUpInside];
    [downView addSubview:phoneBtn];
    
    UIButton *lianximaijiaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [lianximaijiaBtn setFrame:CGRectMake(CGRectGetMaxX(phoneBtn.frame)+20, phoneBtn.frame.origin.y, phoneBtn.frame.size.width, phoneBtn.frame.size.height)];
    [lianximaijiaBtn setTitle:@"联系卖家" forState:UIControlStateNormal];
    [lianximaijiaBtn setImage:[UIImage imageNamed:@"lianximaijia.png"] forState:UIControlStateNormal];
    [lianximaijiaBtn setTitleColor:RGBCOLOR(132, 173, 0) forState:UIControlStateNormal];
    lianximaijiaBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    [lianximaijiaBtn addTarget:self action:@selector(lianximaijia) forControlEvents:UIControlEventTouchUpInside];
    [lianximaijiaBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 10, 20, 0)];
    [lianximaijiaBtn setTitleEdgeInsets:UIEdgeInsetsMake(15, -15, 0, 0)];
    [downView addSubview:lianximaijiaBtn];
    
    NSString *text = nil;
    if ([_theProductModel.is_seckill intValue] == 1) {
        text = @"加入购物车";
    }else
    {
        text = @"立即秒杀";
    }
    
    _jiaruBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_jiaruBtn setTitle:text forState:UIControlStateNormal];
    _jiaruBtn.titleLabel.textColor = [UIColor whiteColor];
    _jiaruBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_jiaruBtn setFrame:CGRectMake(CGRectGetMaxX(lianximaijiaBtn.frame)+40, lianximaijiaBtn.frame.origin.y+5, 110,31)];
    if (DEVICE_WIDTH == 320) {
        [_jiaruBtn setFrame:CGRectMake(CGRectGetMaxX(lianximaijiaBtn.frame)+15, lianximaijiaBtn.frame.origin.y+5, 110,31)];
    }
    _jiaruBtn.layer.cornerRadius = 4;
    _jiaruBtn.layer.masksToBounds = YES;
    _jiaruBtn.backgroundColor = RGBCOLOR(247, 143, 0);
    [_jiaruBtn addTarget:self action:@selector(jiarugouwuche) forControlEvents:UIControlEventTouchUpInside];
    [downView addSubview:_jiaruBtn];
    
    
    UIButton *gouwuche = [UIButton buttonWithType:UIButtonTypeCustom];
    [gouwuche setFrame:CGRectMake(DEVICE_WIDTH - 64.5 - 10, -20 - 4, 64.5, 64)];
    gouwuche.layer.cornerRadius = 25;
    //    gouwuche.backgroundColor = [UIColor whiteColor];
    [gouwuche setBackgroundImage:[UIImage imageNamed:@"homepage_xq_gwc"] forState:UIControlStateNormal];
    [gouwuche addTarget:self action:@selector(gouwuche) forControlEvents:UIControlEventTouchUpInside];
    [downView addSubview:gouwuche];
    
    _numLabel = [[UILabel alloc]initWithFrame:CGRectMake(gouwuche.width - 15, - 5, 20, 20) title:nil font:10 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
    _numLabel.backgroundColor = [UIColor redColor];
    [gouwuche addSubview:_numLabel];
    [_numLabel addRoundCorner];
    _numLabel.hidden = YES;
    
    [self getShoppingCarNum];
}


#pragma mark - 添加购物数量控制

-(UIView *)selectNumBgView
{
    if (_selectNumBgView) {
        return _selectNumBgView;
    }
    _selectNumBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    _selectNumBgView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
    [[UIApplication sharedApplication].keyWindow addSubview:_selectNumBgView];
    
    return _selectNumBgView;
}

-(UIView *)selectNumView
{
    if (_selectNumView) {
        return _selectNumView;
    }
    
    _selectNumView = [[UIView alloc]initWithFrame:CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 170)];
    _selectNumView.backgroundColor = [UIColor whiteColor];
    [self.selectNumBgView addSubview:_selectNumView];
    self.selectNumBgView.alpha = 0.f;
    
    //line
    UIImageView *line1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, _selectNumView.height - 0.5, DEVICE_WIDTH, 0.5)];
    line1.backgroundColor = DEFAULT_LINECOLOR;
    [_selectNumView addSubview:line1];
    
    //隐藏整个view按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT - _selectNumView.height);
    [btn addTarget:self action:@selector(clickToHiddenSelectView) forControlEvents:UIControlEventTouchUpInside];
    [self.selectNumBgView addSubview:btn];
    
    [_selectNumBgView bringSubviewToFront:_selectNumView];
    
    //关闭按钮
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn addTarget:self action:@selector(clickToHiddenSelectView) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setImage:[UIImage imageNamed:@"guanbi"] forState:UIControlStateNormal];
    closeBtn.frame = CGRectMake(DEVICE_WIDTH - 10 - 25, 10 - 5, 25, 25);
    [_selectNumView addSubview:closeBtn];
    
    //数字加减view
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, _selectNumView.width, 40) title:@"选择购买数量" font:14 align:NSTextAlignmentCenter textColor:[UIColor colorWithHexString:@"323232"]];
    [_selectNumView addSubview:label];
    
    //line
    UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, label.bottom, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = DEFAULT_LINECOLOR;
    [_selectNumView addSubview:line];
    
    CGFloat left = (DEVICE_WIDTH - 80 * 2 - 100) / 2.f;
    //减号
    UIButton *reductButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [reductButton setTitle:@"-" forState:UIControlStateNormal];
    [reductButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [reductButton setTitleColor:[UIColor colorWithHexString:@"323232"] forState:UIControlStateSelected];
    reductButton.frame = CGRectMake(left, line.bottom, 80, 50);
    reductButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [reductButton addTarget:self action:@selector(clickToReduce) forControlEvents:UIControlEventTouchUpInside];
    [_selectNumView addSubview:reductButton];
    reductButton.enabled = NO;
    
    self.reductButton = reductButton;
    
    //显示数字
    
    self.numTf = [[UITextField alloc]initWithFrame:CGRectMake(reductButton.right, reductButton.top, 100, 50)];
    _numTf.text = @"1";
    _numTf.textAlignment = NSTextAlignmentCenter;
    _numTf.textColor = [UIColor colorWithHexString:@"323232"];
    _numTf.delegate = self;
    _numTf.keyboardType = UIKeyboardTypeNumberPad;
    [_selectNumView addSubview:_numTf];
    
    //减号
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setTitle:@"+" forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor colorWithHexString:@"323232"] forState:UIControlStateNormal];
    addButton.frame = CGRectMake(_numTf.right, line.bottom, 80, 50);
    addButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [addButton addTarget:self action:@selector(clickToAdd) forControlEvents:UIControlEventTouchUpInside];

    [_selectNumView addSubview:addButton];
    
    UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sureButton.frame = CGRectMake(reductButton.left, reductButton.bottom + 5, addButton.right - reductButton.left, 35);
    sureButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [_selectNumView addSubview:sureButton];
    sureButton.backgroundColor = [UIColor orangeColor];
    [sureButton addTarget:self action:@selector(clickToSure) forControlEvents:UIControlEventTouchUpInside];
    [sureButton addCornerRadius:5.f];
    
    return _selectNumView;
}

- (void)selectShowView:(BOOL)show
{
    __weak typeof(UIView *)weakView = self.selectNumView;
    
    [UIView animateWithDuration:0.3 animations:^{
       
        weakView.top = show ? DEVICE_HEIGHT - 170 : DEVICE_HEIGHT;
        _selectNumBgView.alpha = show ? 1.f : 0.f;
    }];
}

#pragma mark - MyMethod

/**
 *  确认提交
 */
- (void)clickToSure
{
    [self clickToHiddenSelectView];
    
    int num = [self.numTf.text intValue];
    num = num > 1 ? num : 1;
    
    [self addProductWithNum:num];
    
}

- (void)updateReduceState
{
    if ([self.numTf.text intValue] > 1) {
        self.reductButton.selected = YES;
        self.reductButton.enabled = YES;
    }else
    {
        self.reductButton.selected = NO;
        self.reductButton.enabled = NO;
    }
}

- (void)clickToAdd
{
    // + 1
    
    self.numTf.text = NSStringFromInt([self.numTf.text intValue] + 1);
    
    [self updateReduceState];
}

- (void)clickToReduce
{
    // - 1
    int num = [self.numTf.text intValue];
    if (num > 1) {
        
        self.numTf.text = NSStringFromInt(num - 1);
    }
    [self updateReduceState];
}

- (void)clickToHiddenSelectView
{
    [self selectShowView:NO];
    [_numTf resignFirstResponder];
}

-(void)gGoback{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)gJian{
    
    _theNum--;
    if (_theNum == 0) {
        _theNum = 1;
    }
    self.numLabel.text = [NSString stringWithFormat:@"%d",_theNum];
}

-(void)gJia{
    
    _theNum++;
    self.numLabel.text = [NSString stringWithFormat:@"%d",_theNum];
}

/**
 *  点击去获取优惠劵
 */
- (void)clickToCoupe
{
    if (_coupeView) {
        [_coupeView removeFromSuperview];
        _coupeView = nil;
    }
    
    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *dic in _theProductModel.coupon_list) {
        CouponModel *amodel = [[CouponModel alloc]initWithDictionary:dic];
        [tmp addObject:amodel];
    }
    
    if (tmp.count == 0) {
        
        //没有优惠劵可领
        [LTools showMBProgressWithText:@"暂无优惠劵可领" addToView:self.view];
        
        return;
    }
    
    _coupeView = [[CoupeView alloc]initWithCouponArray:tmp userStyle:USESTYLE_Get];
    
    __weak typeof(self)weakSelf = self;
    
    _coupeView.coupeBlock = ^(NSDictionary *params){
        
        ButtonProperty *btn = params[@"button"];
        CouponModel *aModel = params[@"model"];
        
        [weakSelf netWorkForCouponModel:aModel button:btn];
    };
    [_coupeView show];
}

#pragma - mark 秒杀倒计时

- (void)miaoShaTimer
{
    _endTime = [_theProductModel.seckill_info stringValueForKey:@"end_time"];
    
    NSString *endString = MIAOSHAO_END_TEXT;
    NSString *timeString = [GMAPI daojishi:_endTime endString:endString];
    
    //秒杀活动已结束
    if ([endString isEqualToString:timeString]) {
        
        _miaoShaLabel.text = endString;
        return;
    }
    
    _miaoShaTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_miaoShaTimer forMode:NSRunLoopCommonModes];
}

-(void)updateTime{
    
    if ([_theProductModel.is_seckill intValue] == 0) {
        
        return;
    }
    
    NSString *endString = MIAOSHAO_END_TEXT;
    NSString *timeString = [GMAPI daojishi:_endTime endString:endString];
    
    //秒杀互动已经结束
    if ([endString isEqualToString:timeString]) {
        
        _miaoShaLabel.text = endString;
        
        [_miaoShaTimer isValid];
        _miaoShaTimer = nil;
        
        [self prepareNetData];
        
        return;
    }

    NSString *haha = [NSString stringWithFormat:@"%@%@",MIAOSHAO_PRE_TEXT,[GMAPI daojishi:_endTime endString:endString]];
    _miaoShaLabel.text = haha;
    
}

#pragma mark - 拨打电话
-(void)bodadianhua{
    
    [self clickToPhone:nil];
}
#pragma mark - 联系卖家
-(void)lianximaijia{
    
    [self clickToChat:nil];
}


#pragma mark - 跳转购物车

-(void)gouwuche{
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    UITabBarController *tabbarVc = ROOTVIEWCONTROLLER;
    
    tabbarVc.selectedIndex = 2;
}

/**
 *  联系客服
 *
 *  @param sender
 */
- (void)clickToChat:(UIButton *)sender
{
    [self sendProductDetailMessage];
    
    RCDChatViewController *chatService = [[RCDChatViewController alloc] init];
    chatService.userName = @"客服";
    chatService.targetId = SERVICE_ID;
    chatService.conversationType = ConversationType_CUSTOMERSERVICE;
    chatService.title = chatService.userName;
    [self.navigationController pushViewController:chatService animated:YES];
}


//发送产品图文链接

-(void)sendProductDetailMessage
{
    /**
     *  发送消息。可以发送任何类型的消息。
     *  注：如果通过该接口发送图片消息，需要自己实现上传图片，把imageUrl传入content（注意它将是一个RCImageMessage）。
     *  @param conversationType 会话类型。
     *  @param targetId         目标 Id。根据不同的 conversationType，可能是聊天 Id、讨论组 Id、群组 Id 或聊天室 Id。
     *  @param content          消息内容。
     *  @param pushContent      推送消息内容
     *  @param successBlock     调用完成的处理。
     *  @param errorBlock       调用返回的错误信息。
     *
     *  @return 发送的消息实体。
     */
    
    NSString *imageUrl = _theProductModel.cover_pic;
    NSString *digest = [NSString stringWithFormat:@"\n现价:%.2f元\n原价:%.2f元",[_theProductModel.current_price floatValue],[_theProductModel.original_price floatValue]];
    
    NSString *product = [NSString stringWithFormat:WEB_PRODUCTDETAIL,_theProductModel.product_id];
    NSString *productId = [NSString stringWithFormat:@"%@%@",SERVER_URL,product];
    
    NSString *title = [NSString stringWithFormat:@"我在看:[%@]",_theProductModel.product_name];
    
    RCRichContentMessage *msg = [RCRichContentMessage messageWithTitle:title digest:digest imageURL:imageUrl extra:productId];
    [[RCIMClient sharedRCIMClient]sendMessage:ConversationType_CUSTOMERSERVICE targetId:SERVICE_ID content:msg pushContent:@"客服消息" success:^(long messageId) {
        NSLog(@"messageid %ld",messageId);
    } error:^(RCErrorCode nErrorCode, long messageId) {
        NSLog(@"nErrorCode %ld",nErrorCode);
        
    }];
}

/**
 *  拨打电话
 *
 *  @param sender
 */
- (void)clickToPhone:(UIButton *)sender
{
    NSString *phoneNum = _theProductModel.merchant_phone;
    NSString *msg = [NSString stringWithFormat:@"拨打:%@",phoneNum];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

#pragma mark - 加入购物车

- (void)jiarugouwuche{
    
    if ([_theProductModel.is_seckill intValue] == 1) {
        
        //秒杀 直接跳转至提交订单
        
        _isHiddenNavigation = YES;
        
        //需要登录
        if (![LTools isLogin:self]) {
            
            return;
        }
        
        ProductModel *aModel = _gouwucheModel;
        aModel.product_num = @"1";//秒杀只能一件
        aModel.is_seckill = @"1";//是秒杀
        
        CGFloat price = [[_theProductModel.seckill_info stringValueForKey:@"seckill_price"] floatValue];
        
        ConfirmOrderController *confirm = [[ConfirmOrderController alloc]init];
        confirm.productArray = @[aModel];
        confirm.sumPrice = price;
        [self.navigationController pushViewController:confirm animated:YES];
        
    }else
    {
        
        [self selectShowView:YES];
        
    }
}

#pragma - mark UIAlertViewDelegate <NSObject>

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
        if (buttonIndex == 1) {
            
            NSString *phone = _theProductModel.merchant_phone;
            
            if (phone) {
                
                NSString *phoneNum = phone;
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNum]]];
            }
            
        }
}

/**
 *  获取购物车数量
 */
- (void)getShoppingCarNum
{
    NSString *authcode = [GMAPI getAuthkey];
    if (authcode.length == 0) {
        
        int num = [[DBManager shareInstance]QueryAllDataNum];
        if (num > 0) {
            _numLabel.hidden = NO;
            _numLabel.text = [NSString stringWithFormat:@"%d",num];
        }else
        {
            _numLabel.hidden = YES;
        }
        
        return;
    }
    
    __weak typeof(UILabel *)weakLabel = _numLabel;
    NSDictionary*dic = @{@"authcode":authcode};
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:GET_SHOPPINGCAR_NUM parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSLog(@"result %@",result);
        
        int num = [[result objectForKey:@"num"] intValue];
        if (num > 0) {
            weakLabel.hidden = NO;
            weakLabel.text = [NSString stringWithFormat:@"%d",num];
        }else
        {
            weakLabel.hidden = YES;
        }
        
    } failBlock:^(NSDictionary *result) {
        
        NSLog(@"result fail %@",result);
        
    }];

}

#pragma mark - 添加删除键盘检测通知


-(void)addKeyBordNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillShowKeyboardForCustomInputView:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillHideKeyboardForCustomInputView:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark - 监测键盘弹出收起以及高度变化

-(void)handleWillShowKeyboardForCustomInputView:(NSNotification *)notification
{
    __weak typeof(self) weakSelf = self;
    
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat keyboardY = [[UIApplication sharedApplication].keyWindow convertRect:keyboardRect fromView:nil].origin.y;
    
    [UIView animateWithDuration:0.33f animations:^{
        
        weakSelf.selectNumView.top = keyboardY - weakSelf.selectNumView.height;
        
    } completion:^(BOOL finished) {
        
    }];
}

-(void)handleWillHideKeyboardForCustomInputView:(NSNotification *)notification
{
    
}

#pragma mark - UITextFieldDelegate <NSObject>

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //判断数字不能小于0
    
    if ([textField.text intValue] == 0) {
        textField.text = @"1";
    }
}

#pragma mark - UITableViewDelegate && UITabelViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0;
    
    
    if (indexPath.row == 0) {//循环滚动
        //        return 180*GscreenRatio_568;
        
//        return DEVICE_WIDTH * W_H_RATIO;
        
        return 0.f;
    }
    
    if (!_tmpCell) {
        _tmpCell = [[ProductDetailTableViewCell alloc]init];
    }
    
    height = [_tmpCell loadCustomViewWithIndex:indexPath theModel:_theProductModel];
    
    return height;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _theProductModel.product_desc.count + 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    ProductDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[ProductDetailTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    if (indexPath.row == 0) {
        
//        UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 0)];
//        [imv sd_setImageWithURL:[NSURL URLWithString:_theProductModel.cover_pic] placeholderImage:[UIImage imageNamed:@"default02.png"]];
//        [cell.contentView addSubview:imv];
        return cell;
    }
    
    [cell loadCustomViewWithIndex:indexPath theModel:_theProductModel];
    
    if (indexPath.row == 1) {
        _miaoShaLabel = cell.miaoShaLabel;//没有秒杀时为nil
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 3) {
        ProductCommentViewController *ccc = [[ProductCommentViewController alloc]init];
        ccc.model = _theProductModel;
        [self.navigationController pushViewController:ccc animated:YES];
    }else if (indexPath.row == 2){
        NSLog(@"%s",__FUNCTION__);
        
        [self clickToCoupe];
    }
}


@end
