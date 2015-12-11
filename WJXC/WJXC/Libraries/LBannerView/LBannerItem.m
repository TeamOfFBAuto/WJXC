//
//  LBannerItem.m
//  TestBannerView
//
//  Created by lichaowei on 15/12/2.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "LBannerItem.h"

@implementation LBannerItem

-(void)setContentView:(UIView *)contentView
{
    _contentView = contentView;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self addSubview:contentView];
}

- (void)updateContent
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self addSubview:_contentView];
}

@end
