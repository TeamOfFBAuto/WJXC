//
//  MJPhotoBrowser.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

#import <UIKit/UIKit.h>

#import "MJPhotoView.h"

@protocol MJPhotoBrowserDelegate;
@interface MJPhotoBrowser : UIViewController <UIScrollViewDelegate>
// 代理
@property (nonatomic, weak) id<MJPhotoBrowserDelegate> delegate;
// 所有的图片对象
@property (nonatomic, strong) NSArray *photos;
// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentPhotoIndex;

@property (nonatomic,retain)UIViewController *testViewController;

@property(nonatomic,assign)BOOL cancelSingleTap;//取消单击

// 显示
- (void)show;

//显示在哪个视图控制器上
- (void)showWithController:(UIViewController *)viewController;

//隐藏
- (void)hide;

- (MJPhotoView *)currentPhotoView;

@end

@protocol MJPhotoBrowserDelegate <NSObject>
@optional
// 切换到某一页图片
- (void)photoBrowser:(MJPhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index;

@end