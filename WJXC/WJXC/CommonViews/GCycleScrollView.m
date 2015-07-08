//
//  GCycleScrollView.m
//  YiYiProject
//
//  Created by gaomeng on 14/12/21.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import "GCycleScrollView.h"

@implementation GCycleScrollView

- (void)dealloc
{
    _scrollView = nil;
    _pageControl = nil;
    _curViews = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)loadGcycleScrollView{
    if (self.theGcycelScrollViewType == GCYCELNEARSTORE) {//附近的商场
        UIImageView *imv1_back = [[UIImageView alloc]initWithFrame:CGRectMake(0, 60, self.bounds.size.width, self.bounds.size.height-60)];
        [imv1_back setImage:[UIImage imageNamed:@"gimv1_back.png"]];
        [self addSubview:imv1_back];
    }
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
    _scrollView.pagingEnabled = YES;
    [self addSubview:_scrollView];
    
    CGRect rect = self.bounds;
    rect.origin.y = rect.size.height - 30;
    rect.size.height = 30;
    _pageControl = [[UIPageControl alloc] initWithFrame:rect];
    _pageControl.userInteractionEnabled = NO;
    if (self.theGcycelScrollViewType == GCYCELNEARSTORE) {
        _pageControl.hidden = NO;
    }
    
    [self addSubview:_pageControl];
    
    _curPage = 0;
}

- (void)setDataource:(id<GCycleScrollViewDatasource>)datasource
{
    _datasource = datasource;
    [self reloadData];
}

- (void)reloadData
{
    
    _totalPages = [_datasource numberOfPagesWithScrollView:self];
    if (_totalPages == 0) {
        return;
    }
    _pageControl.numberOfPages = _totalPages;
    [self loadData];
}

- (void)loadData
{
    
    _pageControl.currentPage = _curPage;
    
    //从scrollView上移除所有的subview
    NSArray *subViews = [_scrollView subviews];
    if([subViews count] != 0) {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [self getDisplayImagesWithCurpage:(int)_curPage];
    
    for (int i = 0; i < 3; i++) {
        UIView *v = [_curViews objectAtIndex:i];
        v.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleTap:)];
        [v addGestureRecognizer:singleTap];
        v.frame = CGRectOffset(v.frame, v.frame.size.width * i, 0);
        [_scrollView addSubview:v];
    }
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
}

- (void)getDisplayImagesWithCurpage:(int)page {
    
    int pre = [self validPageValue:_curPage-1];
    int last = [self validPageValue:_curPage+1];
    
    if (!_curViews) {
        _curViews = [[NSMutableArray alloc] init];
    }
    
    [_curViews removeAllObjects];
    
    [_curViews addObject:[_datasource pageAtIndex:pre ScrollView:self]];
    [_curViews addObject:[_datasource pageAtIndex:page ScrollView:self]];
    [_curViews addObject:[_datasource pageAtIndex:last ScrollView:self]];
}

- (int)validPageValue:(NSInteger)value {
    
    if(value == -1) value = _totalPages - 1;
    if(value == _totalPages) value = 0;
    
    return (int)value;
    
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    
    if ([_delegate respondsToSelector:@selector(didClickPage:atIndex:)]) {
        [_delegate didClickPage:self atIndex:_curPage];
    }
    
}

- (void)setViewContent:(UIView *)view atIndex:(NSInteger)index
{
    if (index == _curPage) {
        [_curViews replaceObjectAtIndex:1 withObject:view];
        for (int i = 0; i < 3; i++) {
            UIView *v = [_curViews objectAtIndex:i];
            v.userInteractionEnabled = YES;
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(handleTap:)];
            [v addGestureRecognizer:singleTap];
            v.frame = CGRectOffset(v.frame, v.frame.size.width * i, 0);
            [_scrollView addSubview:v];
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    
    if (self.theGcycelScrollViewType == GCYCELNEARSTORE) {
        int x = aScrollView.contentOffset.x;
        //往下翻一张
        if(x >= (2*self.frame.size.width)) {
            
            [self loadData];
        }
        
        //往上翻
        if(x <= 0) {
            
            [self loadData];
        }
    }else{
        int x = aScrollView.contentOffset.x;
        //往下翻一张
        if(x >= (2*self.frame.size.width)) {
            _curPage = [self validPageValue:_curPage+1];
            [self loadData];
        }
        
        //往上翻
        if(x <= 0) {
            _curPage = [self validPageValue:_curPage-1];
            [self loadData];
        }
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:YES];
    
}

@end
