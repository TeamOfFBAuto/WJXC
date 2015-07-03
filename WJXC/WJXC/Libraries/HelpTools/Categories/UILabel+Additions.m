//
//  UILabel+Additions.m
//  YiYiProject
//
//  Created by lichaowei on 15/6/10.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "UILabel+Additions.h"

@implementation UILabel (Additions)

- (UILabel *)initWithFrame:(CGRect)aFrame
                        title:(NSString *)title
                         font:(CGFloat)size
                        align:(NSTextAlignment)align
                    textColor:(UIColor *)textColor
{
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:aFrame];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:size];
    titleLabel.textAlignment = align;
    titleLabel.textColor = textColor;
    return titleLabel;
}

@end
