//
//  GclickedImv.m
//  WJXC
//
//  Created by gaomeng on 15/7/17.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "GclickedImv.h"

@implementation GclickedImv

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        //手势
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTap:)];
        [self addGestureRecognizer:tap];
    }
    
    return self;
    
}


//block的set方法
-(void)setKuangBlock:(kuangBlock)kuangBlock{
    _kuangBlock = kuangBlock;
}


//手势方法
-(void)doTap:(UITapGestureRecognizer *)sender{
    GclickedImv *cimv = (GclickedImv*)sender.view;
    if (self.kuangBlock) {
        self.kuangBlock((UIImageView*)cimv,cimv.url,cimv.urls);
    }
}

@end
