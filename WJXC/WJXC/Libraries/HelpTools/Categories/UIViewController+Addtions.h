//
//  UIViewController+Addtions.h
//  YiYiProject
//
//  Created by lichaowei on 15/5/14.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Addtions)

//类目中通过runtim来添加属性
@property(nonatomic,retain)UIScrollView *scrollView;
@property(nonatomic,retain)UIButton *topButton;//点击滑动到顶部按钮

/**
 *  给导航栏加返回按钮
 *
 *  @param target   事件响应者
 *  @param selector 方法选择器
 */
- (void)addBackButtonWithTarget:(id)target action:(SEL)selector;

/**
 *  添加滑动到顶部按钮
 *
 *  @param scroll 需要滑动的UIScrollView
 *  @param aFrame 按钮位置
 */
- (void)addScroll:(UIScrollView *)scroll topButtonPoint:(CGPoint)point;

/**
 *  点击屏幕重新加载
 *
 *  @param target   事件响应者
 *  @param selector 方法选择器
 */
- (void)addReloadButtonWithTarget:(id)target
                           action:(SEL)selector
                             info:(NSString *)info;


@end
