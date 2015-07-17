//
//  MJZoomingScrollView.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MJPhotoBrowser, MJPhoto, MJPhotoView;

@protocol MJPhotoViewDelegate <NSObject>
- (void)photoViewImageFinishLoad:(MJPhotoView *)photoView;
- (void)photoViewSingleTap:(MJPhotoView *)photoView;
- (void)photoViewDidEndZoom:(MJPhotoView *)photoView;

- (void)photoViewDidLoad:(MJPhotoView *)photoView;//完成显示

@end

@interface MJPhotoView : UIScrollView <UIScrollViewDelegate>
// 图片
@property (nonatomic, strong) MJPhoto *photo;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, assign) UIView *clearView;//test
// 代理
@property (nonatomic, weak) id<MJPhotoViewDelegate> photoViewDelegate;

@property (nonatomic,assign)BOOL cancelSingleTap;//是否取消单击隐藏功能

- (void)hide;//隐藏

@end