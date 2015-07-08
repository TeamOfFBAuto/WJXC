//
//  GCycleScrollView.h
//  YiYiProject
//
//  Created by gaomeng on 14/12/21.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum{
    GCYCELNORMORL = 0,//正常
    GCYCELNEARSTORE ,
}GCycelScrollViewType;

@protocol GCycleScrollViewDelegate;
@protocol GCycleScrollViewDatasource;

@interface GCycleScrollView : UIView<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
    
    NSInteger _totalPages;
    NSInteger _curPage;
    
    NSMutableArray *_curViews;
}

@property (nonatomic,readonly) UIScrollView *scrollView;
@property (nonatomic,readonly) UIPageControl *pageControl;
@property (nonatomic,assign) NSInteger currentPage;
@property (nonatomic,assign,setter = setDataource:) id<GCycleScrollViewDatasource> datasource;
@property (nonatomic,assign,setter = setDelegate:) id<GCycleScrollViewDelegate> delegate;
@property(nonatomic,assign)GCycelScrollViewType theGcycelScrollViewType;

- (void)reloadData;
- (void)setViewContent:(UIView *)view atIndex:(NSInteger)index;
- (void)loadGcycleScrollView;
@end

@protocol GCycleScrollViewDelegate <NSObject>
@optional
- (void)didClickPage:(GCycleScrollView *)csView atIndex:(NSInteger)index;
@end


@protocol GCycleScrollViewDatasource <NSObject>
@required
- (NSInteger)numberOfPagesWithScrollView:(GCycleScrollView*)theGCycleScrollView;
- (UIView *)pageAtIndex:(NSInteger)index ScrollView:(GCycleScrollView *)theGCycleScrollView;

@end