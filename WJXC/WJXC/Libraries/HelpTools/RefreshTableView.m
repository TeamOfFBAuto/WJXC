//
//  RefreshTableView.m
//  TuanProject
//s
//  Created by 李朝伟 on 13-9-6.
//  Copyright (c) 2013年 lanou. All rights reserved.
//

#import "RefreshTableView.h"

//创建此类时,自动创建下拉刷新headerView,只有当判断有更多数据时,使用者去调用创建footerView方法

#define NORMAL_TEXT @"上拉加载更多"
#define NOMORE_TEXT @"没有更多数据"

#define TABLEFOOTER_HEIGHT 50.f

@implementation RefreshTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.pageNum = 1;
        self.dataArray = [NSMutableArray array];
        
        [self createHeaderView];
//        [self createFooterView];
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)theStyle
{
    self = [super initWithFrame:frame style:theStyle];
    if (self) {
        // Initialization code
        
        self.pageNum = 1;
        self.dataArray = [NSMutableArray array];
        
        [self createHeaderView];
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        
    }
    return self;
}



- (void)dealloc
{
    self.dataArray = nil;
    self.loadingIndicator = nil;
    self.normalLabel = nil;
    self.loadingLabel = nil;
    self.delegate = nil;
    _refreshHeaderView.delegate = nil;
    _refreshHeaderView = nil;
    NSLog(@"%s dealloc",__FUNCTION__);
}

-(id)initWithFrame:(CGRect)frame superView:(UIView *)superView
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.pageNum = 1;
        self.dataArray = [NSMutableArray array];
        self.delegate = self;
        [self createHeaderViewWithSuperView:superView];
        
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame showLoadMore:(BOOL)show
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.pageNum = 1;
        self.dataArray = [NSMutableArray array];
        self.delegate = self;
        [self createHeaderView];
        if (show) {
            
            [self createFooterView];
        }
    }
    return self;
}

/**
 *  创建headerView 需要制定父视图
 *
 *  @param superView 父视图
 */
-(void)createHeaderViewWithSuperView:(UIView *)superView
{
    if (_refreshHeaderView && _refreshHeaderView.superview) {
        [_refreshHeaderView removeFromSuperview];
    }
    _refreshHeaderView = [[LRefreshTableHeaderView alloc]initWithFrame:CGRectMake(0.0f,0.f, self.frame.size.width, self.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    _refreshHeaderView.backgroundColor = [UIColor clearColor];
    [_refreshHeaderView refreshLastUpdatedDate];
    [superView addSubview:_refreshHeaderView];

}

-(void)createHeaderView
{
    if (_refreshHeaderView && _refreshHeaderView.superview) {
        [_refreshHeaderView removeFromSuperview];
    }
    _refreshHeaderView = [[LRefreshTableHeaderView alloc]initWithFrame:CGRectMake(0.0f,0.0f - self.bounds.size.height, self.frame.size.width, self.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    _refreshHeaderView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:_refreshHeaderView];
    [_refreshHeaderView refreshLastUpdatedDate];
}
-(void)removeHeaderView
{
    if (_refreshHeaderView && [_refreshHeaderView superview]) {
        [_refreshHeaderView removeFromSuperview];
    }
    _refreshHeaderView = Nil;
}

- (void)createFooterView
{
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320, TABLEFOOTER_HEIGHT)];
    
    [tableFooterView addSubview:self.loadingIndicator];
    [tableFooterView addSubview:self.loadingLabel];
    [tableFooterView addSubview:self.normalLabel];
    
    tableFooterView.backgroundColor = [UIColor clearColor];
    self.tableFooterView = tableFooterView;
}


#pragma mark-
#pragma mark force to show the refresh headerView
//代码触发刷新
-(void)showRefreshHeader:(BOOL)animated
{
    if (animated)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        self.contentInset = UIEdgeInsetsMake(65.0f, 0.0f, 0.0f, 0.0f);
        [self scrollRectToVisible:CGRectMake(0, 0.0f, 1, 1) animated:NO];
        [UIView commitAnimations];
    }
    else
    {
        self.contentInset = UIEdgeInsetsMake(65.0f, 0.0f, 0.0f, 0.0f);
        [self scrollRectToVisible:CGRectMake(0, 0.0f, 1, 1) animated:NO];
    }
    
    [_refreshHeaderView setState:L_EGOOPullRefreshLoading];
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:self];
}


-(void)showRefreshNoOffset
{
    _isReloadData = YES;
    
//    self.userInteractionEnabled = NO;
    
    _reloading = YES;
        
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(loadNewData)]) {
        
        self.pageNum = 1;
        [_refreshDelegate performSelector:@selector(loadNewData)];
    }
    
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(loadNewDataForTableView:)]) {
        
        self.pageNum = 1;
        [_refreshDelegate loadNewDataForTableView:self];
    }
}


#pragma mark - EGORefreshTableDelegate
- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos
{
    [self beginToReloadData:aRefreshPos];
}

//根据刷新类型，是看是下拉还是上拉
-(void)beginToReloadData:(EGORefreshPos)aRefreshPos
{
    //  should be calling your tableviews data source model to reload
    _reloading = YES;
    if (aRefreshPos ==  EGORefreshHeader)
    {
        _isReloadData = YES;
        
        if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(loadNewData)]) {
            
            self.pageNum = 1;
            [_refreshDelegate performSelector:@selector(loadNewData)];
        }
        
        if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(loadNewDataForTableView:)]) {
            
            self.pageNum = 1;
            [_refreshDelegate loadNewDataForTableView:self];
        }
    }
    
    // overide, the actual loading data operation is done in the subclass
}

- (void)reloadData:(NSArray *)data isHaveMore:(BOOL)isHave
{
    self.isHaveMoreData = isHave;
    
    if (self.isReloadData) {
        
        [self.dataArray removeAllObjects];
        
    }
    [self.dataArray addObjectsFromArray:data];
    
    [self performSelector:@selector(finishReloadigData) withObject:nil afterDelay:0];
}

//成功加载
- (void)reloadData:(NSArray *)data pageSize:(int)pageSize
{
    if (data.count < pageSize) {
        
        self.isHaveMoreData = NO;
    }else
    {
        self.isHaveMoreData = YES;
    }
    
    if (self.isReloadData) {
        
        [self.dataArray removeAllObjects];
        
    }
    [self.dataArray addObjectsFromArray:data];
    
    [self performSelector:@selector(finishReloadigData) withObject:nil afterDelay:0];
}

//成功加载
- (void)reloadData:(NSArray *)data total:(int)totalPage
{
    if (self.pageNum < totalPage) {
        
        self.isHaveMoreData = YES;
    }else
    {
        self.isHaveMoreData = NO;
    }
    
    if (self.isReloadData) {
        
        [self.dataArray removeAllObjects];
        
    }
    [self.dataArray addObjectsFromArray:data];
    
    [self performSelector:@selector(finishReloadigData) withObject:nil afterDelay:0];
}


//成功加载
- (void)reloadData1:(NSArray *)data1 pageSize:(int)pageSize
{
    if (data1.count < pageSize) {
        
        self.isHaveMoreData = NO;
    }else
    {
        self.isHaveMoreData = YES;
    }
    
    if (self.isReloadData) {
        
        [self.dataArray removeAllObjects];
        
    }
    [self.dataArray addObjectsFromArray:data1];
}



//请求数据失败

- (void)loadFail
{
    if (self.isLoadMoreData) {
        self.pageNum --;
        
        if (self.pageNum < 1) {
            self.pageNum = 1;
        }
    }
    [self performSelector:@selector(finishReloadigData) withObject:nil afterDelay:1.0];

}

//完成数据加载

- (void)finishReloadigData
{
    NSLog(@"finishReloadigData完成加载");
    
    

    _reloading = NO;
    if (_refreshHeaderView) {
        [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
        self.isReloadData = NO;
    }
    
    if (self.tableFooterView == nil) {
        [self createFooterView];
        
    }
    
    @try {
        
        [self reloadData];
        
    }
    @catch (NSException *exception) {
        
        NSLog(@"%@",exception);
    }
    @finally {
        
    }
    
    //如果有更多数据，重新设置footerview  frame
    if (self.isHaveMoreData)
    {
        [self stopLoading:1];
        
    }else {
        
        [self stopLoading:2];
    }
    
    self.userInteractionEnabled = YES;
}

- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView*)view
{
    return _reloading;
}
- (NSDate*)egoRefreshTableDataSourceLastUpdated:(UIView*)view
{
    return [NSDate date];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
    
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(refreshScrollViewDidScroll:)]) {
        [_refreshDelegate refreshScrollViewDidScroll:scrollView];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_refreshHeaderView)
    {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    
    // 下拉到最底部时显示更多数据
    
    if(_isHaveMoreData && scrollView.contentOffset.y > ((scrollView.contentSize.height - scrollView.frame.size.height-40)))
    {
        if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(loadMoreData)]) {
            
            [self startLoading];
            
            _isLoadMoreData = YES;
            
            self.pageNum ++;
            [_refreshDelegate performSelector:@selector(loadMoreData)];
        }
        
        
        if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(loadMoreDataForTableView:)]) {
            
            [self startLoading];
            
            _isLoadMoreData = YES;
            
            self.pageNum ++;
            [_refreshDelegate loadMoreDataForTableView:self];
        }
    }
}

#pragma mark -
#pragma mark overide UITableViewDelegate methods
//将要显示
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(refreshTableView:willDisplayCell:forRowAtIndexPath:)]) {
        
        [_refreshDelegate refreshTableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}
//显示完了
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath NS_AVAILABLE_IOS(6_0)
{
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(refreshTableView:didEndDisplayingCell:forRowAtIndexPath:)]) {
        
        [_refreshDelegate refreshTableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
    }
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(7_0)
//{
//    
//    
//    return 100;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat aHeight = 0.0;
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(heightForRowIndexPath:)]) {
        aHeight = [_refreshDelegate heightForRowIndexPath:indexPath];
    }
    
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(heightForRowIndexPath:tableView:)]) {
        aHeight = [_refreshDelegate heightForRowIndexPath:indexPath tableView:tableView];
    }
    
    return aHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(didSelectRowAtIndexPath:)]) {
        [_refreshDelegate didSelectRowAtIndexPath:indexPath];
    }
    
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(didSelectRowAtIndexPath:tableView:)]) {
        [_refreshDelegate didSelectRowAtIndexPath:indexPath tableView:tableView];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *aView;
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(viewForHeaderInSection:tableView:)]) {
        aView = [_refreshDelegate viewForHeaderInSection:section tableView:tableView];
    }
    return aView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat aHeight = 0.0;
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(heightForHeaderInSection:tableView:)]) {
        aHeight = [_refreshDelegate heightForHeaderInSection:section tableView:tableView];
    }
    return aHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
//    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 0.5)];
//    line.backgroundColor = [UIColor lightGrayColor];
//    
//    return line;
    
    UIView *aView;
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(viewForFooterInSection:tableView:)]) {
        aView = [_refreshDelegate viewForFooterInSection:section tableView:tableView];
        return aView;
    }else{
        return [UIView new];
    }
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    CGFloat aHeight = 0.0;
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(heightForFooterInSection:tableView:)]) {
        aHeight = [_refreshDelegate heightForFooterInSection:section tableView:tableView];
        return aHeight;
    }else{
        return 0.5;
    }
    
    return 0.5;
}

#pragma mark -
#pragma mark overide UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == Nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    return cell;
}


#pragma - mark 创建所需label 和 UIActivityIndicatorView

- (UIActivityIndicatorView*)loadingIndicator
{
    if (!_loadingIndicator) {
        _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _loadingIndicator.hidden = YES;
        _loadingIndicator.backgroundColor = [UIColor clearColor];
        _loadingIndicator.hidesWhenStopped = YES;
        _loadingIndicator.frame = CGRectMake(self.frame.size.width/2 - 70 ,6+2 + (TABLEFOOTER_HEIGHT - 40)/2.0, 24, 24);
    }
    return _loadingIndicator;
}

- (UILabel*)normalLabel
{
    if (!_normalLabel) {
        _normalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 8 + (TABLEFOOTER_HEIGHT - 40)/2.0, self.frame.size.width, 20)];
        _normalLabel.text = NSLocalizedString(NORMAL_TEXT, nil);
        _normalLabel.backgroundColor = [UIColor clearColor];
        [_normalLabel setFont:[UIFont systemFontOfSize:14]];
        _normalLabel.textAlignment = NSTextAlignmentCenter;
        [_normalLabel setTextColor:[UIColor darkGrayColor]];
    }
    
    return _normalLabel;
    
}

- (UILabel*)loadingLabel
{
    if (!_loadingLabel) {
        _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.f/2-80,8 + (TABLEFOOTER_HEIGHT - 40)/2.0, self.frame.size.width/2+30, 20)];
        _loadingLabel.text = NSLocalizedString(@"加载中...", nil);
        _loadingLabel.backgroundColor = [UIColor clearColor];
        [_loadingLabel setFont:[UIFont systemFontOfSize:14]];
        _loadingLabel.textAlignment = NSTextAlignmentCenter;
        [_loadingLabel setTextColor:[UIColor darkGrayColor]];
        [_loadingLabel setHidden:YES];
    }
    
    return _loadingLabel;
}


- (void)startLoading
{
    [self.loadingIndicator startAnimating];
    [self.loadingLabel setHidden:NO];
    [self.normalLabel setHidden:YES];
}

- (void)stopLoading:(int)loadingType
{
    _isLoadMoreData = NO;
    
    [self.loadingIndicator stopAnimating];
    switch (loadingType) {
        case 1:
            [self.normalLabel setHidden:NO];
            [self.normalLabel setText:NSLocalizedString(NORMAL_TEXT, nil)];
            [self.loadingLabel setHidden:YES];
            break;
        case 2:
            [self.normalLabel setHidden:NO];
            [self.normalLabel setText:NSLocalizedString(NOMORE_TEXT, nil)];
            [self.loadingLabel setHidden:YES];
            break;
        default:
            break;
    }
}



@end
