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

@interface ProductDetailViewController ()<GCycleScrollViewDelegate,GCycleScrollViewDatasource,UITableViewDataSource,UITableViewDelegate>
{
    GCycleScrollView *_gscrollView;//上方循环滚动的scrollview
    
    UITableView *_tableView;//主tableview
    
    ProductDetailModel *_theProductModel;//数据源
    
    ProductDetailTableViewCell *_tmpCell;
    
    int _theNum;
    
    
}
@end

@implementation ProductDetailViewController


-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
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
    
    NSDictionary *parame = @{
                             @"product_id":self.product_id
                             };
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:GET_PRODUCTDETAIL parameters:parame constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        NSLog(@"%@",result);
        
        NSDictionary *detail = [result dictionaryValueForKey:@"detail"];
        
        _theProductModel = [[ProductDetailModel alloc]initWithDictionary:detail];
        
        
        [_tableView reloadData];
        
        
        
    } failBlock:^(NSDictionary *result) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSLog(@"%@",result);
    }];
}


//创建循环滚动的scrollview
-(UIView*)creatGscrollView{
    _gscrollView = [[GCycleScrollView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 180*GscreenRatio_568)];
    _gscrollView.theGcycelScrollViewType = GCYCELNORMORL;
    [_gscrollView loadGcycleScrollView];
    _gscrollView.tag = 200;
    _gscrollView.delegate = self;
    _gscrollView.datasource = self;
    return _gscrollView;
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
    
    
    UIButton *shoucangBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shoucangBtn setFrame:CGRectMake(DEVICE_WIDTH - 100, 5, 50, 50)];
    [shoucangBtn setImage:[UIImage imageNamed:@"homepage_qianggou_collect.png"] forState:UIControlStateNormal];
    [theBImv addSubview:shoucangBtn];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn setFrame:CGRectMake(DEVICE_WIDTH - 50, 5, 50, 50)];
    [shareBtn setImage:[UIImage imageNamed:@"homepage_qianggou_share.png"] forState:UIControlStateNormal];
    [theBImv addSubview:shareBtn];
}


//创建tableview
-(void)creatTableView{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT) style:UITableViewStylePlain];
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
    [jiaruBtn setFrame:CGRectMake(CGRectGetMaxX(lianximaijiaBtn.frame)+12, lianximaijiaBtn.frame.origin.y+5, 110,31)];
    jiaruBtn.layer.cornerRadius = 4;
    jiaruBtn.layer.masksToBounds = YES;
    jiaruBtn.backgroundColor = RGBCOLOR(247, 143, 0);
    [downView addSubview:jiaruBtn];
    
    
    
    UIButton *gouwuche = [UIButton buttonWithType:UIButtonTypeCustom];
    [gouwuche setFrame:CGRectMake(DEVICE_WIDTH - 60, -10, 50, 50)];
    gouwuche.layer.cornerRadius = 25;
    gouwuche.backgroundColor = RGBCOLOR(122, 171, 0);
    [gouwuche setImage:[UIImage imageNamed:@"homgpage_qianggou_bottom_shopping cart.png"] forState:UIControlStateNormal];
    [gouwuche addTarget:self action:@selector(gouwuche) forControlEvents:UIControlEventTouchUpInside];
    [downView addSubview:gouwuche];
    
    
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



#pragma mark - GCycleScrollViewDelegate && GCycleScrollViewDatasource

//滚动总共几页
- (NSInteger)numberOfPagesWithScrollView:(GCycleScrollView*)theGCycleScrollView
{
    
    NSInteger num = 0;
    if (theGCycleScrollView.tag == 200) {
        num = _theProductModel.image.count;
    }
    return num;
    
}

//每一页
- (UIView *)pageAtIndex:(NSInteger)index ScrollView:(GCycleScrollView *)theGCycleScrollView
{
    
    
    if (theGCycleScrollView.tag == 200) {
        UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 180*GscreenRatio_568)];
        imv.userInteractionEnabled = YES;
        
        NSDictionary *dic = _theProductModel.image[index];
        NSString *str = nil;
        if ([dic isKindOfClass:[NSDictionary class]]) {
            str = [dic objectForKey:@"pic"];
        }
        
        [imv sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:nil];
        return imv;
    }
    
    return [UIView new];
    
}

//点击的哪一页
- (void)didClickPage:(GCycleScrollView *)csView atIndex:(NSInteger)index
{

    
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
        [cell.contentView addSubview:[self creatGscrollView]];
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


#pragma mark - 购物车

-(void)gouwuche{
    
    
}

/**
 *  联系客服
 *
 *  @param sender
 */
- (void)clickToChat:(UIButton *)sender
{
    RCDChatViewController *chatService = [[RCDChatViewController alloc] init];
    chatService.userName = @"客服";
    chatService.targetId = SERVICE_ID;
    chatService.conversationType = ConversationType_CUSTOMERSERVICE;
    chatService.title = chatService.userName;
    //    RCHandShakeMessage* textMsg = [[RCHandShakeMessage alloc] init];
    //    [[RongUIKit sharedKit] sendMessage:ConversationType_CUSTOMERSERVICE targetId:SERVICE_ID content:textMsg delegate:nil];
    [self.navigationController showViewController:chatService sender:nil];
}

/**
 *  拨打电话
 *
 *  @param sender
 */
- (void)clickToPhone:(UIButton *)sender
{
    NSString *phoneNum = @"010-999999999";
    NSString *msg = [NSString stringWithFormat:@"拨打:%@",phoneNum];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
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
    ProductModel *aModel = nil;
    
    int product_num = 1;//测试
    NSString *authcode = [GMAPI getAuthkey];
    
    if (authcode.length == 0) {
        
        [[DBManager shareInstance]insertProduct:aModel];
        
        [LTools showMBProgressWithText:@"添加购物车成功" addToView:self.view];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_UPDATE_TO_CART object:nil];
        
        
        return;
    }
    
    NSDictionary*dic = @{@"authcode":authcode,
                         @"product_id":aModel.product_id,
                         @"product_num":[NSNumber numberWithInt:product_num]};
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodPost api:ORDER_ADD_TO_CART parameters:dic constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        [LTools showMBProgressWithText:result[RESULT_INFO] addToView:self.view];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_UPDATE_TO_CART object:nil];
        
    } failBlock:^(NSDictionary *result) {
        
        
    }];
    
}


@end
