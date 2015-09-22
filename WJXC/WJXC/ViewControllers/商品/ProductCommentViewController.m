//
//  ProductCommentViewController.m
//  WJXC
//
//  Created by gaomeng on 15/7/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "ProductCommentViewController.h"
#import "ProductCommentTableViewCell.h"
#import "GclickedImv.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"
@interface ProductCommentViewController ()<RefreshDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    int _buttonNum;//button个数
    UIView *_indicator;//指示器
    UIScrollView *_scroll;
    
    RefreshTableView *_tab0;
    RefreshTableView *_tab1;
    RefreshTableView *_tab2;
    RefreshTableView *_tab3;
    
    ProductCommentTableViewCell *_tmpCell;
    
}
@end

@implementation ProductCommentViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTitle = @"评价晒单";
    [self setMyViewControllerLeftButtonType:MyViewControllerLeftbuttonTypeBack WithRightButtonType:MyViewControllerRightbuttonTypeNull];
    
    
    NSString *comment_num = [NSString stringWithFormat:@"全部 %@",self.model.comment_num];
    NSString *good_comment_num = [NSString stringWithFormat:@"好评 %@",self.model.good_comment_num];
    NSString *normal_comment_num = [NSString stringWithFormat:@"中评 %@",self.model.normal_comment_num];
    NSString *bad_comment_num = [NSString stringWithFormat:@"差评 %@",self.model.bad_comment_num];
    
    NSArray *titles = @[comment_num,good_comment_num,normal_comment_num,bad_comment_num];
    int count = (int)titles.count;
    CGFloat width = DEVICE_WIDTH / count;
    _buttonNum = count;
    
    _scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 40, DEVICE_WIDTH, DEVICE_HEIGHT - 64 - 40)];
    _scroll.delegate = self;
    _scroll.contentSize = CGSizeMake(DEVICE_WIDTH * count, _scroll.height);
    _scroll.showsHorizontalScrollIndicator = NO;
    _scroll.pagingEnabled = YES;
    [self.view addSubview:_scroll];
    
    //scrollView 和 系统手势冲突问题
    [_scroll.panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    
    for (int i = 0; i < count; i ++) {
        //横滑上方的按钮
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [self.view addSubview:btn];
        btn.tag = 100 + i;
        btn.frame = CGRectMake(width * i, 0, width, 40);
        [btn setTitleColor:[UIColor colorWithHexString:@"646464"] forState:UIControlStateNormal];
        [btn setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateSelected];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [btn addTarget:self action:@selector(clickToSelect:) forControlEvents:UIControlEventTouchUpInside];
        btn.selected = YES;
        
        RefreshTableView *_table = [[RefreshTableView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH * i, 0, DEVICE_WIDTH,_scroll.height)];
        _table.refreshDelegate = self;
        _table.dataSource = self;
        [_scroll addSubview:_table];
        _table.tag = 200 + i;
        
        if (_table.tag == 200) {
            _tab0 = _table;
        }else if (_table.tag == 201){
            _tab1 = _table;
        }else if (_table.tag == 202){
            _tab2 = _table;
        }else if (_table.tag == 203){
            _tab3 = _table;
        }
        
        
        [_table showRefreshHeader:YES];
        
        
    }
    
    _indicator = [[UIView alloc]initWithFrame:CGRectMake(0, 38, width, 2)];
    _indicator.backgroundColor = DEFAULT_TEXTCOLOR;
    [self.view addSubview:_indicator];
    
    //默认选中第一个
    [self controlSelectedButtonTag:100];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark 网络请求

#pragma - mark 事件处理

/**
 *  获取button 根据tag
 */
- (UIButton *)buttonForTag:(int)tag
{
    return (UIButton *)[self.view viewWithTag:tag];
}

/**
 *  根据下标来获取tableView
 *
 *  @param index 下标 1，2，3，4
 */
- (RefreshTableView *)refreshTableForIndex:(int)index
{
    return (RefreshTableView *)[self.view viewWithTag:index + 200];
}

/**
 *  控制button选中状态
 */
- (void)controlSelectedButtonTag:(int)tag
{
    for (int i = 0; i < _buttonNum; i ++) {
        
        [self buttonForTag:100 + i].selected = (i + 100 == tag) ? YES : NO;
    }
    
    __weak typeof(_indicator)weakIndicator = _indicator;
    [UIView animateWithDuration:0.1 animations:^{
        
        weakIndicator.left = DEVICE_WIDTH / _buttonNum * (tag - 100);
    }];
}

/**
 *  点击button
 *
 *  @param sender
 */
- (void)clickToSelect:(UIButton *)sender
{
    [self controlSelectedButtonTag:(int)sender.tag];
    
    __weak typeof(_scroll)weakScroll = _scroll;
    [UIView animateWithDuration:0.1 animations:^{
        
        [weakScroll setContentOffset:CGPointMake(DEVICE_WIDTH * (sender.tag - 100), 0)];
    }];
}

- (void)clickToComment:(UIButton *)sender
{
    
}

#pragma - mark 视图创建

#pragma - 代理

#pragma mark - RefreshDelegate

- (void)loadNewDataForTableView:(RefreshTableView *)tableView
{
    NSLog(@"%s",__FUNCTION__);
    
    if (!self.model.product_id) {
        return;
    }
    
    NSDictionary *parame;
    if (tableView.tag == 200) {//全部评论
        parame = @{
                   @"product_id":self.model.product_id,
                   @"comment_level":@"0",
                   @"page":[NSString stringWithFormat:@"%d",tableView.pageNum],
                   @"perpage":@"20"
                   };
    }else if (tableView.tag == 201){//好评
        parame = @{
                   @"product_id":self.model.product_id,
                   @"comment_level":@"3",
                   @"page":[NSString stringWithFormat:@"%d",tableView.pageNum],
                   @"perpage":@"20"
                   };
    }else if (tableView.tag == 202){//中评
        parame = @{
                   @"product_id":self.model.product_id,
                   @"comment_level":@"2",
                   @"page":[NSString stringWithFormat:@"%d",tableView.pageNum],
                   @"perpage":@"20"
                   };
    }else if (tableView.tag == 203){//差评
        parame = @{
                   @"product_id":self.model.product_id,
                   @"comment_level":@"1",
                   @"page":[NSString stringWithFormat:@"%d",tableView.pageNum],
                   @"perpage":@"20"
                   };
    }
    
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:GET_PRODUCT_COMMENT parameters:parame constructingBodyBlock:nil completion:^(NSDictionary *result) {
        NSLog(@"%@",result);
        
        NSArray *list = [result arrayValueForKey:@"list"];
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *dic in list) {
            ProductCommentModel *model = [[ProductCommentModel alloc]initWithDictionary:dic];
            [arr addObject:model];
        }
        
        [tableView reloadData:arr pageSize:20];
    } failBlock:^(NSDictionary *result) {
        [tableView loadFail];
    }];
    
    
    
}
- (void)loadMoreDataForTableView:(RefreshTableView *)tableView
{
    NSLog(@"%s",__FUNCTION__);
    NSDictionary *parame;
    if (tableView.tag == 200) {//全部评论
        parame = @{
                   @"product_id":self.model.product_id,
                   @"comment_level":@"0",
                   @"page":[NSString stringWithFormat:@"%d",tableView.pageNum],
                   @"perpage":@"20"
                   };
    }else if (tableView.tag == 201){//好评
        parame = @{
                   @"product_id":self.model.product_id,
                   @"comment_level":@"3",
                   @"page":[NSString stringWithFormat:@"%d",tableView.pageNum],
                   @"perpage":@"20"
                   };
    }else if (tableView.tag == 202){//中评
        parame = @{
                   @"product_id":self.model.product_id,
                   @"comment_level":@"2",
                   @"page":[NSString stringWithFormat:@"%d",tableView.pageNum],
                   @"perpage":@"20"
                   };
    }else if (tableView.tag == 203){//差评
        parame = @{
                   @"product_id":self.model.product_id,
                   @"comment_level":@"1",
                   @"page":[NSString stringWithFormat:@"%d",tableView.pageNum],
                   @"perpage":@"20"
                   };
    }
    
    
    [[YJYRequstManager shareInstance]requestWithMethod:YJYRequstMethodGet api:GET_PRODUCT_COMMENT parameters:parame constructingBodyBlock:nil completion:^(NSDictionary *result) {
        
        NSLog(@"%@",result);
        
        NSArray *list = [result arrayValueForKey:@"list"];
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *dic in list) {
            ProductCommentModel *model = [[ProductCommentModel alloc]initWithDictionary:dic];
            [arr addObject:model];
        }
        
        [tableView reloadData:arr pageSize:20];
    } failBlock:^(NSDictionary *result) {
        [tableView loadFail];
    }];
    
}

//新加
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    
}
- (CGFloat)heightForRowIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    
    CGFloat height = 0;
    
    if (!_tmpCell) {
        _tmpCell = [[ProductCommentTableViewCell alloc]init];
    }
    
    RefreshTableView *tab = (RefreshTableView*)tableView;
    height = [_tmpCell loadCustomViewWithIndex:indexPath theModel:tab.dataArray[indexPath.row]];
    
    return height;
}

- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

#pragma - mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    RefreshTableView *refreshTable = (RefreshTableView *)tableView;
    return refreshTable.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"OrderCell";
    ProductCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[ProductCommentTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    int tableViewTag = (int)tableView.tag;
    
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    switch (tableViewTag) {
        case 200://全部评论
        {
            [cell loadCustomViewWithIndex:indexPath theModel:_tab0.dataArray[indexPath.row]];
            
        }
            break;
        case 201://好评
        {
            [cell loadCustomViewWithIndex:indexPath theModel:_tab1.dataArray[indexPath.row]];
        }
            break;
        case 202://中评
        {
            [cell loadCustomViewWithIndex:indexPath theModel:_tab2.dataArray[indexPath.row]];
        }
            break;
        case 203://差评
        {
            [cell loadCustomViewWithIndex:indexPath theModel:_tab3.dataArray[indexPath.row]];
        }
            break;
        default:
            break;
    }
    
    
    __weak typeof (self)bself = self;
    
    
    
    
    
//    for (GclickedImv *imv in cell.imvArray) {
//        
//        [imv setKuangBlock:^(UIImageView *imv, NSString *url NSMutableArray) {
//            [bself tapImage:imv url:url];
//        }];
//    }
    
    
    for (GclickedImv *imv in cell.imvArray) {
        [imv setKuangBlock:^(UIImageView *imv, NSString *url, NSMutableArray *urls) {
            [bself tapImage:imv url:url theUrls:urls];
        }];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma - mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    int page = floor((scrollView.contentOffset.x - DEVICE_WIDTH / 2) / DEVICE_WIDTH) + 1;//只要大于半页就算下一页
    NSLog(@"page %d",page);
    //选中状态
    [self controlSelectedButtonTag:page + 100];
    
}







- (void)tapImage:(UIImageView *)theImv url:(NSString *)imageUrl theUrls:(NSMutableArray*)urls
{
    
    
    UIImageView *aImageView = theImv;
    
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:1];
    
    // 替换为中等尺寸图片
//    NSString *url = imageUrl;
//    MJPhoto *photo = [[MJPhoto alloc] init];
//    photo.url = [NSURL URLWithString:url]; // 图片路径
//    photo.srcImageView = aImageView; // 来源于哪个UIImageView
//    [photos addObject:photo];
    
    for (NSString *url in urls) {
        MJPhoto *photo = [[MJPhoto alloc]init];
        photo.url = [NSURL URLWithString:url];
        photo.srcImageView = aImageView;
        [photos addObject:photo];
    }
    
    
    
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = 0; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}

@end
