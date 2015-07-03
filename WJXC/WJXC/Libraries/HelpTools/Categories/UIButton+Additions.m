//
//  UIButton+Additions.m
//  YiYiProject
//
//  Created by lichaowei on 15/6/10.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "UIButton+Additions.h"

@implementation UIButton (Additions)

/**
 *  初始化button title
 */
- (UIButton *)initWithframe:(CGRect)aFrame
                 buttonType:(UIButtonType)buttonType
                normalTitle:(NSString *)normalTitle
              selectedTitle:(NSString *)selectedTitle
                     target:(id)target
                     action:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:buttonType];
    btn.frame = aFrame;
    
    //normal
    [btn setTitle:normalTitle forState:UIControlStateNormal];
    
    //selected
    [btn setTitle:selectedTitle forState:UIControlStateSelected];
    
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

/**
 *  初始化button image
 */
- (UIButton *)initWithframe:(CGRect)aFrame
                 buttonType:(UIButtonType)buttonType
                nornalImage:(UIImage *)normalImage
              selectedImage:(UIImage *)selectedImage
                     target:(id)target
                     action:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:buttonType];
    btn.frame = aFrame;
    
    //normal
    [btn setImage:normalImage forState:UIControlStateNormal];
    //selected
    [btn setImage:selectedImage forState:UIControlStateSelected];
    
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

/**
 *  初始化button title 和 image
 */
- (UIButton *)initWithframe:(CGRect)aFrame
                 buttonType:(UIButtonType)buttonType
                normalTitle:(NSString *)normalTitle
              selectedTitle:(NSString *)selectedTitle
                nornalImage:(UIImage *)normalImage
              selectedImage:(UIImage *)selectedImage
                     target:(id)target
                     action:(SEL)action
{
    UIButton *btn = [self initWithframe:aFrame buttonType:buttonType normalTitle:normalTitle selectedTitle:selectedTitle target:target action:action];
    //normal
    [btn setImage:normalImage forState:UIControlStateNormal];
    
    //selected
    [btn setImage:selectedImage forState:UIControlStateSelected];
    
    return btn;
}

/**
 *  初始化button title 和 image 、backgroundImage
 */

- (UIButton *)initWithframe:(CGRect)aFrame
                       buttonType:(UIButtonType)buttonType
                normalTitle:(NSString *)normalTitle
              selectedTitle:(NSString *)selectedTitle
                nornalImage:(UIImage *)normalImage
              selectedImage:(UIImage *)selectedImage
       backgroudNormalImage:(UIImage *)bgNormalImage
    backgroundSelectedImage:(UIImage *)bgSelctedImage
                     target:(id)target
                     action:(SEL)action
{
    UIButton *btn = [self initWithframe:aFrame buttonType:buttonType normalTitle:normalTitle selectedTitle:selectedTitle nornalImage:normalImage selectedImage:selectedImage
                                 target:target action:action];
    
    [btn setBackgroundImage:bgNormalImage forState:UIControlStateNormal];
    [btn setBackgroundImage:bgSelctedImage forState:UIControlStateSelected];
    
    return btn;
}


@end
