//
//  UIButton+Additions.h
//  YiYiProject
//
//  Created by lichaowei on 15/6/10.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Additions)

/**
 *  初始化button title
 */
- (UIButton *)initWithframe:(CGRect)aFrame
                 buttonType:(UIButtonType)buttonType
                normalTitle:(NSString *)normalTitle
              selectedTitle:(NSString *)selectedTitle
                     target:(id)target
                     action:(SEL)action;

/**
 *  初始化button image
 */
- (UIButton *)initWithframe:(CGRect)aFrame
                 buttonType:(UIButtonType)buttonType
                nornalImage:(UIImage *)normalImage
              selectedImage:(UIImage *)selectedImage
                     target:(id)target
                     action:(SEL)action;
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
                     action:(SEL)action;
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
                     action:(SEL)action;

@end
