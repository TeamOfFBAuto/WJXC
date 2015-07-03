//
//  UIViewController+Addtions.m
//  YiYiProject
//
//  Created by lichaowei on 15/5/14.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "UIViewController+Addtions.h"
#import <objc/runtime.h>

char* const ASSOCIATION_SCROLLVIEW = "ASSOCIATION_SCROLLVIEW";
char* const ASSOCIATION_TOPBUTTON = "ASSOCIATION_TOPBUTTON";


@implementation UIViewController (Addtions)

/**
 *  给导航栏加返回按钮
 *
 *  @param target   事件响应者
 *  @param selector 方法选择器
 */
- (void)addBackButtonWithTarget:(id)target action:(SEL)selector
{
    UIBarButtonItem * spaceButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButton1.width = IOS7_OR_LATER ? -10 : 5;
    
    UIButton *button_back=[[UIButton alloc]initWithFrame:CGRectMake(0,8,40,44)];
    [button_back addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button_back setImage:BACK_DEFAULT_IMAGE forState:UIControlStateNormal];
    [button_back setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    UIBarButtonItem *back_item=[[UIBarButtonItem alloc]initWithCustomView:button_back];
    self.navigationItem.leftBarButtonItems=@[spaceButton1,back_item];
}

/**
 *  点击屏幕重新加载
 *
 *  @param target   事件响应者
 *  @param selector 方法选择器
 */
- (void)addReloadButtonWithTarget:(id)target
                           action:(SEL)selector
                             info:(NSString *)info
{
    UIButton *button_back=[[UIButton alloc]initWithFrame:self.view.bounds];
    button_back.backgroundColor = [UIColor clearColor];
    [button_back addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
//    [button_back setImage:BACK_DEFAULT_IMAGE forState:UIControlStateNormal];
    [button_back setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.view addSubview:button_back];
    
    UIImageView *defautlImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 34, 34)];
    [button_back addSubview:defautlImage];
    defautlImage.image = DEFAULT_YIJIAYI;
    defautlImage.centerY = self.view.height/2.f - 32;
    defautlImage.centerX = self.view.width/2.f;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, defautlImage.bottom + 5, button_back.width, 20)];
    label.text = info.length > 0 ? info : @"点击屏幕,重新加载";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:12.f];
    [button_back addSubview:label];
    
}

/**
 *  添加滑动到顶部按钮
 *
 *  @param scroll 需要滑动的UIScrollView
 *  @param aFrame 按钮位置
 */
- (void)addScroll:(UIScrollView *)scroll topButtonPoint:(CGPoint)point
{
    self.topButton = [LTools createButtonWithType:UIButtonTypeCustom frame:CGRectMake(point.x, point.y, 40, 40) normalTitle:nil image:[UIImage imageNamed:@"home_button_top"] backgroudImage:nil superView:nil target:self action:@selector(clickToTop:)];
    [self.view addSubview:self.topButton];
    
    self.topButton.hidden = YES;
    
    self.scrollView = scroll;
    
    [scroll addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        
//        NSLog(@"keyPath %@",change);
        
        UIScrollView *scroll = object;

        if ([scroll isKindOfClass:[UIScrollView class]] && scroll.contentOffset.y > DEVICE_HEIGHT) {
            
            self.topButton.hidden = NO;
        }else
        {
            self.topButton.hidden = YES;
        }
        
    }
}

//使用runtime动态添加属性 set方法
-(void)setScrollView:(UIScrollView *)scrollView
{
    objc_setAssociatedObject(self,ASSOCIATION_SCROLLVIEW,scrollView,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//get方法
-(UIScrollView *)scrollView
{
    return objc_getAssociatedObject(self, ASSOCIATION_SCROLLVIEW);
}

-(void)setTopButton:(UIButton *)topButton
{
    objc_setAssociatedObject(self, ASSOCIATION_TOPBUTTON, topButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIButton *)topButton
{
    return objc_getAssociatedObject(self, ASSOCIATION_TOPBUTTON);
}

- (void)clickToTop:(UIButton *)sender
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

@end
