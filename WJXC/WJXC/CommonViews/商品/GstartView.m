//
//  GstartView.m
//  CustomNewProject
//
//  Created by gaomeng on 14/12/8.
//  Copyright (c) 2014年 FBLIFE. All rights reserved.
//

#import "GstartView.h"

@implementation GstartView

-(GstartView*)initWithStartNum:(int)num Frame:(CGRect)theFrame{
    self = [super initWithFrame:theFrame];
    if (self) {
        
        CGFloat kuan = 12;
        
        for (int i = 0; i<num; i++) {
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0+i*kuan, 0, kuan, theFrame.size.height)];
            [imv setImage:[UIImage imageNamed:@"homepage_star1.png"]];
            [self addSubview:imv];
        }
    }
    
    return self;
}


-(void)updateStartNum{
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    CGFloat kuan = 12;
    
    for (int i = 0; i<5; i++) {
        UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0+i*kuan, 0, kuan, self.frame.size.height)];
        [imv setImage:[UIImage imageNamed:@"homepage_star.png"]];
        [self addSubview:imv];
    }
    
    
    
    
    
    self.startNum = self.startNum>self.maxStartNum ? self.maxStartNum : self.startNum;
    
    int nnn_int = (int)self.startNum;
    
    
    
    if (nnn_int<self.startNum) {//有半颗星
        
        
        for (int i = 0; i<nnn_int; i++) {
            NSLog(@"%d",i);
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0+i*kuan, 0, kuan, self.frame.size.height)];
            [imv setImage:[UIImage imageNamed:@"homepage_star.png"]];
            [self addSubview:imv];
            
            if ((i+1)>=nnn_int) {
                UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0+(i+1)*kuan, 0, kuan, self.frame.size.height)];
                [imv setImage:[UIImage imageNamed:@"homepage_star.png"]];
                [self addSubview:imv];
            }
        }
        
        
        if (nnn_int == 0) {//不足一颗星
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kuan, self.frame.size.height)];
            [imv setImage:[UIImage imageNamed:@"homepage_star.png"]];
            [self addSubview:imv];
        }
        
    }else{//没有半颗星
        for (int i = 0; i<self.startNum; i++) {
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0+i*kuan, 0, kuan, self.frame.size.height)];
            [imv setImage:[UIImage imageNamed:@"homepage_star.png"]];
            [self addSubview:imv];
        }
    }
    
    
}



@end
