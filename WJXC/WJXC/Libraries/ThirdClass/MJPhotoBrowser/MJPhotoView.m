//
//  MJZoomingScrollView.m
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MJPhotoView.h"
#import "MJPhoto.h"
#import "MJPhotoLoadingView.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@interface MJPhotoView ()
{
    BOOL _doubleTap;
//    UIImageView *_imageView;
    MJPhotoLoadingView *_photoLoadingView;
    

        BOOL _isZoomed;//当前是否处于放大状态
        
        NSTimer * _tapTimer;//计时点击时间
        
        UIButton * placeHolderButton;
}
@end

@implementation MJPhotoView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        self.delegate = self;
        self.contentMode = UIViewContentModeCenter;
        self.maximumZoomScale = 3.0;
        self.minimumZoomScale = 1.0;
        self.decelerationRate = .85;
        self.contentSize = CGSizeMake(frame.size.width, frame.size.height);
        
        self.showsHorizontalScrollIndicator = NO;
        
        self.showsVerticalScrollIndicator = NO;
        
        
        // create the image view
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
        //        _imageView.image = theImage;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self addSubview:_imageView];
        
        // 进度条
        _photoLoadingView = [[MJPhotoLoadingView alloc] init];
//        _photoLoadingView.center = CGPointMake(self.frame.size.width / 2.f, self.frame.size.height / 2.f);
//        [self addSubview:_photoLoadingView];
        
        // 监听点击
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.delaysTouchesBegan = YES;
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
    }
    return self;
}

#pragma mark - photoSetter
- (void)setPhoto:(MJPhoto *)photo {
    _photo = photo;
    
    [self showImage];
}

#pragma mark 显示图片
- (void)showImage
{
    if (_photo.firstShow) { // 首次显示
        _imageView.image = _photo.placeholder; // 占位图片
        _photo.srcImageView.image = nil;
        
        
        // 不是gif，就马上开始下载
        
        if (![_photo.url.absoluteString hasSuffix:@"gif"]) {
            
            __unsafe_unretained MJPhotoView *photoView = self;
            __unsafe_unretained MJPhoto *photo = _photo;
            
            [_imageView sd_setImageWithURL:_photo.url placeholderImage:_photo.placeholder options:SDWebImageRetryFailed|SDWebImageLowPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                photo.image = image;
                
                // 调整frame参数
                [photoView adjustFrame];
            }];
        }

    } else {
        
        [self photoStartLoad];
    }

    // 调整frame参数
    [self adjustFrame];
}

#pragma mark 开始加载图片
- (void)photoStartLoad
{
    if (_photo.image) {
        self.scrollEnabled = YES;
        _imageView.image = _photo.image;
        
    } else {
        self.scrollEnabled = NO;
        
        // 直接显示进度条
        [_photoLoadingView showLoading];
        [self addSubview:_photoLoadingView];
        
        __weak MJPhotoView *photoView = self;
        __weak MJPhotoLoadingView *loading = _photoLoadingView;
        
        [_imageView sd_setImageWithURL:_photo.url placeholderImage:_photo.srcImageView.image options:SDWebImageRetryFailed|SDWebImageLowPriority  progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
            if (receivedSize > kMinProgress) {
                loading.progress = (float)receivedSize/expectedSize;
            }
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [photoView photoDidFinishLoadWithImage:image];
        }];
    }
}

#pragma mark 加载完毕
- (void)photoDidFinishLoadWithImage:(UIImage *)image
{
    if (image) {
        self.scrollEnabled = YES;
        _photo.image = image;
        [_photoLoadingView removeFromSuperview];
        
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewImageFinishLoad:)]) {
            [self.photoViewDelegate photoViewImageFinishLoad:self];
        }
    } else {
        [self addSubview:_photoLoadingView];
        [_photoLoadingView showFailure];
    }
    
    // 设置缩放比例
    [self adjustFrame];
}

#pragma mark 调整frame
- (void)adjustFrame
{
	if (_imageView.image == nil) return;
    
    
    if (_photo.firstShow) { // 第一次显示的图片
        
        _photo.firstShow = NO; // 已经显示过了
        
        _imageView.frame = [_photo.srcImageView convertRect:_photo.srcImageView.bounds toView:nil];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            _imageView.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.height);
            
            
        } completion:^(BOOL finished) {
            // 设置底部的小图片
            _photo.srcImageView.image = _photo.placeholder;
            [self photoStartLoad];
            
            //通知代理
            if ([self.photoViewDelegate respondsToSelector:@selector(photoViewDidLoad:)]) {
                [self.photoViewDelegate photoViewDidLoad:self];
            }
            
        }];
    } else {
        
        _imageView.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.height);
        
//        CGSize size = _imageView.image.size;
//        _imageView.frame = CGRectMake(0, 0, size.width, size.height);
//        _imageView.center = CGPointMake(self.width/2, self.height/2.f);
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _imageView;
}

#pragma mark - 手势处理

- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    
    _doubleTap = NO;
    
    //是否需要单击隐藏操作
    if (self.cancelSingleTap) {
        
        
        [self performSelector:@selector(cancelSingleTapAction) withObject:nil afterDelay:0.2];
        return;
    }
    [self performSelector:@selector(hide) withObject:nil afterDelay:0.2];
}

- (void)cancelSingleTapAction
{
    // 通知代理
    if (!_doubleTap && [self.photoViewDelegate respondsToSelector:@selector(photoViewSingleTap:)]) {
        [self.photoViewDelegate photoViewSingleTap:self];
    }
}


- (void)hide
{
    //    //是否需要单击隐藏操作
    //    if (self.cancelSingleTap) {
    //        return;
    //    }
    
    
    if (_doubleTap){
       
        _doubleTap = NO;
        return;
    }
    
    // 移除进度条
    [_photoLoadingView removeFromSuperview];
    self.contentOffset = CGPointZero;
    
    // 清空底部的小图
    
    _photo.srcImageView.image = nil;
    
    CGFloat duration = 0.15;
    if (_photo.srcImageView.clipsToBounds) {
        [self performSelector:@selector(reset) withObject:nil afterDelay:duration];
    }
    
    //_imageView从父视图上移除,加载在windows上,然后做动画
    [_imageView removeFromSuperview];
    [[UIApplication sharedApplication].keyWindow addSubview:_imageView];

    
    if ([self.photoViewDelegate respondsToSelector:@selector(photoViewDidEndZoom:)]) {
        [self.photoViewDelegate photoViewDidEndZoom:self];
    }
    
    [UIView animateWithDuration:duration + 0.1 + 0.1 animations:^{
        
        _imageView.frame = [_photo.srcImageView.superview convertRect:_photo.srcImageView.frame toView:[UIApplication sharedApplication].keyWindow];
        
        
        // gif图片仅显示第0张
        if (_imageView.image.images) {
            _imageView.image = _imageView.image.images[0];
        }
        
        // 通知代理
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewSingleTap:)]) {
            [self.photoViewDelegate photoViewSingleTap:self];
        }
        
    } completion:^(BOOL finished) {
        
        [_imageView removeFromSuperview];
        // 设置底部的小图片
        _photo.srcImageView.image = _photo.placeholder;
        
        
    }];
    
}

- (void)reset
{
    _imageView.image = _photo.capture;
    _imageView.contentMode = UIViewContentModeScaleToFill;
}


- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    _doubleTap = YES;
    
//    CGPoint touchPoint = [tap locationInView:self];
//	if (self.zoomScale == self.maximumZoomScale) {
//		[self setZoomScale:self.minimumZoomScale animated:YES];
//	} else {
//		[self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
//	}
    
    if( _isZoomed )
    {
        _isZoomed = NO;
        [self setZoomScale:self.minimumZoomScale animated:YES];
    }
    else {
        
        _isZoomed = YES;
        
        // define a rect to zoom to.
        
        CGPoint touchCenter = [tap locationInView:self];
//        CGPoint touchCenter = [touch locationInView:self];
        
        //1/3 区域要放大
        
        CGSize zoomRectSize = CGSizeMake(self.frame.size.width / self.maximumZoomScale, self.frame.size.height / self.maximumZoomScale );
        
        //1/3 区域中心点
        
        CGRect zoomRect = CGRectMake( touchCenter.x - zoomRectSize.width * .5, touchCenter.y - zoomRectSize.height * .5, zoomRectSize.width, zoomRectSize.height );
        
        //下面四个判断 暂未发现什么用处
        
        // correct too far left
        if( zoomRect.origin.x < 0 )
            zoomRect = CGRectMake(0, zoomRect.origin.y, zoomRect.size.width, zoomRect.size.height );
        
        // correct too far up
        if( zoomRect.origin.y < 0 )
            zoomRect = CGRectMake(zoomRect.origin.x, 0, zoomRect.size.width, zoomRect.size.height );
        
        // correct too far right
        if( zoomRect.origin.x + zoomRect.size.width > self.frame.size.width )
            zoomRect = CGRectMake(self.frame.size.width - zoomRect.size.width, zoomRect.origin.y, zoomRect.size.width, zoomRect.size.height );
        
        // correct too far down
        if( zoomRect.origin.y + zoomRect.size.height > self.frame.size.height )
            zoomRect = CGRectMake( zoomRect.origin.x, self.frame.size.height - zoomRect.size.height, zoomRect.size.width, zoomRect.size.height );
        
        // zoom to it.
        [self zoomToRect:zoomRect animated:YES];
    }
    
}

- (void)dealloc
{
    // 取消请求
    [_imageView sd_setImageWithURL:[NSURL URLWithString:@"file:///abc"]];
    _photoLoadingView = nil;
}

//- (void)setFrame:(CGRect)theFrame
//{
//    // store position of the image view if we're scaled or panned so we can stay at that point
//    CGPoint imagePoint = _imageView.frame.origin;
//    
//    [super setFrame:theFrame];
//    
//    // update content size
//    self.contentSize = CGSizeMake(theFrame.size.width * self.zoomScale, theFrame.size.height * self.zoomScale );
//    
//    NSLog(@"contentSize %f %f",self.contentSize.width,self.contentSize.height);
//    // resize image view and keep it proportional to the current zoom scale
//    _imageView.frame = CGRectMake( imagePoint.x, imagePoint.y, theFrame.size.width * self.zoomScale, theFrame.size.height * self.zoomScale);
//}

@end