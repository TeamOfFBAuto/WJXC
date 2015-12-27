//
//  CircularBannerView.m
//  CircularBanner
//
//  Created by lichaowei on 15/12/2.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "LBannerView.h"
#import "LBannerItem.h"
#import "LScrollView.h"

@interface LBannerView ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    int _totalNum;
}

@property (nonatomic, strong) LScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) LBannerItem *leftItem;
@property (nonatomic, strong) LBannerItem *middleItem;
@property (nonatomic, strong) LBannerItem *rightItem;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation LBannerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.scrollView = [[LScrollView alloc] initWithFrame:frame];
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.showPageControl = YES;
        self.automicScrolling = YES;
        self.direction = AutomicSrollingDirectionFromLeftToRight;
        self.automicScrollingDuration = 2.f;
        self.scrollView.bounces = NO;
        self.scrollView.decelerationRate = 0.1;
        [self addSubview:self.scrollView];
        [self addSubview:self.pageControl];
        
        __weak typeof(self)weakSelf = self;
        [self.scrollView setTouchEventBlock:^(TouchEventState state) {
           
            if (state == TouchEventState_began) {
                DDLOG(@"began");
                
                [weakSelf stopTimer];
                
            }else if (state == TouchEventState_canceled){
                DDLOG(@"cancel");
                [weakSelf resetTimer];

            }else if (state == TouchEventState_ended){
                DDLOG(@"end");
                [weakSelf resetTimer];

            }
        }];
                
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
//        tap.delegate = self;
        [self.scrollView addGestureRecognizer:tap];
    }
    return self;
}

#pragma mark - Private Methods

- (void)removeSubImageViewFromScrollView:(UIScrollView *)scrollView {
    for (UIView *subview in scrollView.subviews) {
        if ([subview isKindOfClass:[LBannerItem class]]) {
            [subview removeFromSuperview];
        }
    }
}

- (void)resetTimer {
    [self stopTimer];
    if (self.automicScrolling) {
        
        //小于等于1时不需要自动播放
        if (_contentViews.count <= 1) {
            return;
        }
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.automicScrollingDuration target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    }
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - getter

- (LBannerItem *)leftItem {
    if (nil == _leftItem) {
        _leftItem = [[LBannerItem alloc] initWithFrame:self.frame];
    }
    return _leftItem;
}

- (LBannerItem *)middleItem {
    if (nil == _middleItem) {
        _middleItem = [[LBannerItem alloc] initWithFrame:self.frame];
    }
    return _middleItem;
}

- (LBannerItem *)rightItem {
    if (nil == _rightItem) {
        _rightItem = [[LBannerItem alloc] initWithFrame:self.frame];
    }
    return _rightItem;
}

- (UIPageControl *)pageControl {
    if (nil == _pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - 100)/2, CGRectGetHeight(self.frame) - 30, 100, 30)];
        _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:238/255.0f green:238/255.0f blue:238/255.0f alpha:1.0f];
        _pageControl.currentPageIndicatorTintColor = DEFAULT_TEXTCOLOR;
        [self addSubview:_pageControl];
    }
    return _pageControl;
}

#pragma mark - setter

-(void)setAutomicScrollingDuration:(CGFloat)automicScrollingDuration
{
    _automicScrollingDuration = automicScrollingDuration;
    [self resetTimer];
}

-(void)setContentViews:(NSArray *)contentViews
{
    _contentViews = contentViews;
    _totalNum = (int)contentViews.count;
    
    [self removeSubImageViewFromScrollView:self.scrollView];
    if (contentViews.count == 1) {
        
        self.middleItem.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        self.middleItem.contentView = contentViews[0];
        [self.scrollView addSubview:self.middleItem];
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        self.pageControl.hidden = YES;
        
    }else if (contentViews.count > 1) {
        
        self.leftItem.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        self.leftItem.contentView = [contentViews lastObject];
        [self.scrollView addSubview:self.leftItem];
        
        self.middleItem.frame = CGRectMake(CGRectGetWidth(self.frame), 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        self.middleItem.contentView = contentViews[0];
        [self.scrollView addSubview:self.middleItem];
        
        self.rightItem.frame = CGRectMake(CGRectGetWidth(self.frame) * 2, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        self.rightItem.contentView = contentViews[1];
        [self.scrollView addSubview:self.rightItem];

        
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * 3, CGRectGetHeight(self.frame));
        [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.frame), 0) animated:NO];
        
        self.pageControl.hidden = !self.showPageControl;
        self.pageControl.numberOfPages = contentViews.count;
        self.pageControl.currentPage = 0;
        
        [self resetTimer];
    }
}

- (void)setShowPageControl:(BOOL)showPageControl {
    _showPageControl =showPageControl;
    if (showPageControl) {
        if (_pageControl && _contentViews.count > 1) {
            _pageControl.hidden = NO;
        }else {
            _pageControl.hidden = YES;
        }
    }else {
        if (_pageControl) {
            _pageControl.hidden = YES;
        }
    }
}

- (void)setAutomicScrolling:(BOOL)automicSrolling {
    _automicScrolling = automicSrolling;
    if (automicSrolling && _contentViews.count > 1) {
        [self resetTimer];
    }else {
        [self stopTimer];
    }
}

#pragma mark - Action

- (void)timerAction:(id)sender {
    
    if (self.direction == AutomicSrollingDirectionFromLeftToRight) {
        //从右往左滑动，默认值
        [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.scrollView.frame) * 2, 0) animated:YES];
    }else {
        //从左往右滑动
        [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.scrollView.frame) * 0, 0) animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopTimer];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetx = scrollView.contentOffset.x;
    //处理向左滑动
    //针对两个情况特殊处理
    if (_totalNum == 2) {
        
        if (offsetx < self.frame.size.width) {
            [self.leftItem updateContent];
        }else{
            [self.rightItem updateContent];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self resetTimer];
    [self configItemsWithScrollView:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    [self configItemsWithScrollView:scrollView];
}

#pragma mark - item配置
/**
 *  根据scroll滑动情况配置各item视图
 *
 *  @param scrollView
 */
- (void)configItemsWithScrollView:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x/CGRectGetWidth(self.frame);
    
    
//    CGFloat pageWidth = self.frame.size.width;
//    NSInteger index = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    //页数必须小于总页数
    if (index > _totalNum) {
        return;
    }
    
    if (index == 2) {
        _currentPage = _currentPage + 1;
        
        if (_currentPage == _contentViews.count) {
            _currentPage = 0;
            self.leftItem.contentView = [_contentViews lastObject];
            self.middleItem.contentView = _contentViews[_currentPage];
            self.rightItem.contentView = _contentViews[_currentPage + 1];
        }else {
            self.leftItem.contentView = _contentViews[_currentPage - 1];
            self.middleItem.contentView = _contentViews[_currentPage];
            self.rightItem.contentView = _currentPage + 1 == _contentViews.count ? _contentViews[0] : _contentViews[_currentPage + 1];
        }
    }else if (index == 0) {
        _currentPage = _currentPage - 1;
        if (_currentPage == -1) {
            _currentPage = _contentViews.count - 1;
            self.leftItem.contentView = _contentViews[_currentPage - 1];
            self.middleItem.contentView = _contentViews[_currentPage];
            self.rightItem.contentView = _contentViews[0];
        }else {
            self.leftItem.contentView = _currentPage - 1 < 0 ? _contentViews[_contentViews.count - 1] : _contentViews[_currentPage - 1];
            self.middleItem.contentView = _contentViews[_currentPage];
            self.rightItem.contentView = _contentViews[_currentPage + 1];
        }
    }
    [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.frame), 0) animated:NO];
    self.pageControl.currentPage = _currentPage;
}

#pragma mark - 点击事件

-(void)setTapActionBlock:(void (^)(NSInteger index))tapActionBlock
{
    _tapActionBlock = tapActionBlock;
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture
{
    DDLOG_CURRENT_METHOD;
    if (_tapActionBlock) {
        _tapActionBlock(_currentPage);
    }
}

@end
