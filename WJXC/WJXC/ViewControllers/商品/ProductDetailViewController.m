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
    
    
}
@end

@implementation ProductDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    self.myTitle = @"单品详情";
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
//    [self creatTableView];
    
    [self prepareNetData];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - MyMethod

-(void)prepareNetData{
    
    NSDictionary *parame = @{
                             @"product_id":@"1",
                             @"comment_page":@"1",
                             @"comment_perpage":@"20"
                             };
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:GET_PRODUCTDETAIL parameters:parame constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        NSLog(@"%@",result);
        
        NSDictionary *detail = [result dictionaryValueForKey:@"detail"];
        
        _theProductModel = [[ProductDetailModel alloc]initWithDictionary:detail];
        
        [self creatTableView];
        
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


//创建tableview
-(void)creatTableView{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
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
    
    
//    NSDictionary *dic = _topScrollviewImvInfoArray[index];
//    if ([[dic stringValueForKey:@"redirect_type"]intValue]==1) {//可以跳转
//        
//        NSString *adv_type_val = [dic stringValueForKey:@"adv_type_val"];
//        if ([adv_type_val intValue]==1) {//广告类型
//            GwebViewController *gwebvc = [[GwebViewController alloc]init];
//            gwebvc.urlstring = [dic stringValueForKey:@"redirect_url"];
//            gwebvc.hidesBottomBarWhenPushed = YES;
//            [self.rootViewController.navigationController pushViewController:gwebvc animated:YES];
//        }else if ([adv_type_val intValue]==2 || [adv_type_val intValue]==3){//2:跳转商场活动  3:跳转店铺活动
//            NSString *theId = [dic stringValueForKey:@"theme_id"];
//            MessageDetailController *detail = [[MessageDetailController alloc]init];
//            detail.msg_id = theId;
//            detail.isActivity = YES;
//            detail.hidesBottomBarWhenPushed = YES;
//            [self.rootViewController.navigationController pushViewController:detail animated:YES];
//            
//        }else if ([adv_type_val intValue]==4){//跳转单品页面
//            NSString *theId = [dic stringValueForKey:@"theme_id"];
//            ProductDetailController *ccc = [[ProductDetailController alloc]init];
//            ccc.product_id = theId;
//            ccc.hidesBottomBarWhenPushed = YES;
//            [self.rootViewController.navigationController pushViewController:ccc animated:YES];
//            
//        }
//        
//    }
    
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
        [self.navigationController pushViewController:ccc animated:YES];
    }
}


@end
