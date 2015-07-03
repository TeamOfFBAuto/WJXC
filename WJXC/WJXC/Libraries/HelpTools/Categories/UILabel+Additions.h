//
//  UILabel+Additions.h
//  YiYiProject
//
//  Created by lichaowei on 15/6/10.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Additions)

- (UILabel *)initWithFrame:(CGRect)aFrame
                     title:(NSString *)title
                      font:(CGFloat)size
                     align:(NSTextAlignment)align
                 textColor:(UIColor *)textColor;
@end
