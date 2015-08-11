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

@interface ProductDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    GCycleScrollView *_gscrollView;//上方循环滚动的scrollview
    
    UITableView *_tableView;//主tableview
    
    ProductDetailModel *_theProductModel;//数据源
    
    ProductModel *_gouwucheModel;//加入购物车Model
    
    ProductDetailTableViewCell *_tmpCell;
    
    UIButton *_shoucangBtn;
    
    int _theNum;
    
    
    NSString *_isfavor;//是否收藏
    
    UILabel *_numLabel;//购物车数量
}
@end

@implementation ProductDetailViewController


-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeText WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    
    self.view.backgroundColor = RGBCOLOR(241, 240, 245);
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(prepareNetData) name:NOTIFICATION_LOGIN object:nil];
    
    [self creatTableView];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    [self creatUpView];
    
    [self prepareNetData];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - MyMethod

-(void)gGoback{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)prepareNetData{
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
    
    
    
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:GET_PRODUCTDETAIL parameters:parame constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        NSLog(@"%@",result);
        
        NSDictionary *detail = [result dictionaryValueForKey:@"detail"];
        
        _theProductModel = [[ProductDetailModel alloc]initWithDictionary:detail];
        
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
    [_shoucangBtn addTarget:self action:@selector(gshoucang) forControlEvents:UIControlEventTouchUpInside];
    [theBImv addSubview:_shoucangBtn];
    _shoucangBtn.hidden = YES;
    
//    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [shareBtn setFrame:CGRectMake(DEVICE_WIDTH - 50, 5, 50, 50)];
//    [shareBtn setImage:[UIImage imageNamed:@"homepage_qianggou_share.png"] forState:UIControlStateNormal];
//    [theBImv addSubview:shareBtn];
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
    
    
    UIButton *jiaruBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [jiaruBtn setTitle:@"加入购物车" forState:UIControlStateNormal];
    jiaruBtn.titleLabel.textColor = [UIColor whiteColor];
    jiaruBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [jiaruBtn setFrame:CGRectMake(CGRectGetMaxX(lianximaijiaBtn.frame)+40, lianximaijiaBtn.frame.origin.y+5, 110,31)];
    if (DEVICE_WIDTH == 320) {
        [jiaruBtn setFrame:CGRectMake(CGRectGetMaxX(lianximaijiaBtn.frame)+15, lianximaijiaBtn.frame.origin.y+5, 110,31)];
    }
    jiaruBtn.layer.cornerRadius = 4;
    jiaruBtn.layer.masksToBounds = YES;
    jiaruBtn.backgroundColor = RGBCOLOR(247, 143, 0);
    [jiaruBtn addTarget:self action:@selector(jiarugouwuche) forControlEvents:UIControlEventTouchUpInside];
    [downView addSubview:jiaruBtn];
    
    
    
    UIButton *gouwuche = [UIButton buttonWithType:UIButtonTypeCustom];
    [gouwuche setFrame:CGRectMake(DEVICE_WIDTH - 60, -10, 50, 50)];
    gouwuche.layer.cornerRadius = 25;
    gouwuche.backgroundColor = RGBCOLOR(122, 171, 0);
    [gouwuche setImage:[UIImage imageNamed:@"homgpage_qianggou_bottom_shopping cart.png"] forState:UIControlStateNormal];
    [gouwuche addTarget:self action:@selector(gouwuche) forControlEvents:UIControlEventTouchUpInside];
    [downView addSubview:gouwuche];
    
    _numLabel = [[UILabel alloc]initWithFrame:CGRectMake(gouwuche.width - 15, - 5, 20, 20) title:nil font:10 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
    _numLabel.backgroundColor = [UIColor redColor];
    [gouwuche addSubview:_numLabel];
    [_numLabel addRoundCorner];
    _numLabel.hidden = YES;
    
    [self getShoppingCarNum];
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










#pragma makr - UITableViewDelegate && UITabelViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0;
    
    
    if (indexPath.row == 0) {//循环滚动
        return 180*GscreenRatio_568;
    }
    
    if (!_tmpCell) {
        _tmpCell = [[ProductDetailTableViewCell alloc]init];
    }
    
    height = [_tmpCell loadCustomViewWithIndex:indexPath theModel:_theProductModel];
    
    return height;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _theProductModel.product_desc.count + 4;
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
        UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 180*GscreenRatio_568)];
        [imv sd_setImageWithURL:[NSURL URLWithString:_theProductModel.cover_pic] placeholderImage:[UIImage imageNamed:@"default02.png"]];
        [cell.contentView addSubview:imv];
        return cell;
    }
    
    
    [cell loadCustomViewWithIndex:indexPath theModel:_theProductModel];
    
    
    
    
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
    if (indexPath.row == 2) {
        ProductCommentViewController *ccc = [[ProductCommentViewController alloc]init];
        ccc.model = _theProductModel;
        [self.navigationController pushViewController:ccc animated:YES];
    }
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
    NSString *productId = [NSString stringWithFormat:@"productId:%@",_theProductModel.product_id];
    
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

-(void)jiarugouwuche{
    
    
    [self clickToAddProduct];
}

#pragma - mark UIAlertViewDelegate <NSObject>

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
        if (buttonIndex == 1) {
            
            NSString *phoneNum = @"010-999999999";
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNum]]];
        }
}

/**
 *  添加购物车 每次一个
 */
- (void)clickToAddProduct
{
    ProductModel *aModel = _gouwucheModel;
    
    int product_num = 1;//测试
    NSString *authcode = [GMAPI getAuthkey];
    
    if (authcode.length == 0) {
        
        [[DBManager shareInstance]insertProduct:aModel];
        
        [LTools showMBProgressWithText:@"添加成功" addToView:self.view];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_UPDATE_TO_CART object:nil];
        
        
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
 *  获取购物车数量
 */
- (void)getShoppingCarNum
{
    NSString *authcode = [GMAPI getAuthkey];
    if (authcode.length == 0) {
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


#pragma mark - 收藏
-(void)gshoucang{
    
    NSString *authcode = [GMAPI getAuthkey];
    if (authcode.length == 0) {
        LoginViewController *login = [[LoginViewController alloc]init];
        
        UINavigationController *unVc = [[UINavigationController alloc]initWithRootViewController:login];
        
        [self presentViewController:unVc animated:YES completion:nil];
        
        return;
    }else{
        
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




@end
