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

    UIButton *jianBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [jianBtn setImage:[UIImage imageNamed:@"homepage_xq_bottom_-.png"] forState:UIControlStateNormal];
    [jianBtn setFrame:CGRectMake(10, 5, 35, 35)];
    [downView addSubview:jianBtn];
    [jianBtn addTarget:self action:@selector(gJian) forControlEvents:UIControlEventTouchUpInside];
    
    
    _theNum = 1;
    self.numLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(jianBtn.frame), jianBtn.frame.origin.y+2, 45, 30)];
    self.numLabel.layer.borderWidth = 0.5;
    self.numLabel.layer.cornerRadius = 5;
    self.numLabel.layer.borderColor = [RGBCOLOR(247, 143, 0)CGColor];
    self.numLabel.text = [NSString stringWithFormat:@"%d",_theNum];
    self.numLabel.textColor = RGBCOLOR(247, 143, 0);
    self.numLabel.font = [UIFont systemFontOfSize:15];
    self.numLabel.textAlignment = NSTextAlignmentCenter;
    [downView addSubview:self.numLabel];
    
    UIButton *jiaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [jiaBtn setFrame:CGRectMake(CGRectGetMaxX(self.numLabel.frame), jianBtn.frame.origin.y, jianBtn.frame.size.width, jianBtn.frame.size.height)];
    [jiaBtn setImage:[UIImage imageNamed:@"homepage_xq_bottom_+.png"] forState:UIControlStateNormal];
    [downView addSubview:jiaBtn];
    
    [jiaBtn addTarget:self action:@selector(gJia) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *jiaruBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [jiaruBtn setTitle:@"加入购物车" forState:UIControlStateNormal];
    
    jiaruBtn.titleLabel.textColor = [UIColor whiteColor];
    jiaruBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [jiaruBtn setFrame:CGRectMake(CGRectGetMaxX(jiaBtn.frame)+10, jiaBtn.frame.origin.y+2, 110,self.numLabel.frame.size.height)];
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


-(void)gouwuche{
    NSLog(@"%s",__FUNCTION__);
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


@end
