//
//  GtopScrollView.m
//  YiYiProject
//
//  Created by gaomeng on 15/1/4.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "GtopScrollView.h"



////滑条宽度
//#define CONTENTSIZEX 320

//按钮空隙
#define BUTTONGAP 5

//按钮id
#define BUTTONID (sender.tag-100)
//滑动id
#define BUTTONSELECTEDID (self.userSelectedChannelID - 100)






@implementation GtopScrollView

- (void)dealloc
{
    
    NSLog(@"%s",__FUNCTION__);
    
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.backgroundColor = [UIColor clearColor];
        self.pagingEnabled = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        _userSelectedChannelID = 100;
        _scrollViewSelectedChannelID = 100;
        
        self.buttonOriginYArray = [NSMutableArray array];
        self.buttonWithArray = [NSMutableArray array];
    }
    return self;
}




- (void)initWithNameButtons
{
    
    int titleBtnWidth = self.frame.size.width;
    int titleBtnHeight = 40;
    
    
    
    self.buttonWithAll = [NSMutableArray arrayWithCapacity:1];
    
    float yPos = 0;
    for (int i = 0; i < [self.nameArray count]; i++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString *title = [self.nameArray objectAtIndex:i];
        
        [button setTag:i+100];
        if (i == 0) {
            button.selected = YES;
        }
        
        [button setBackgroundImage:[UIImage imageNamed:@"gGray.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"gRed.png"] forState:UIControlStateSelected];
        [button setTitle:title forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(selectNameButton:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(0, yPos, titleBtnWidth, titleBtnHeight);
//        button.layer.cornerRadius = 20;
        button.layer.masksToBounds = YES;
        button.backgroundColor = [UIColor whiteColor];
        [self.buttonWithAll addObject:button];
        
        [_buttonOriginYArray addObject:@(yPos)];
        
        yPos += button.frame.size.height+BUTTONGAP;
        
        [_buttonWithArray addObject:@(button.frame.size.height)];
        
        [self addSubview:button];
    }
    
    self.contentSize = CGSizeMake(70, yPos);
    
}


//点击顶部条滚动标签
- (void)selectNameButton:(UIButton *)sender
{
    
    

}








- (void)setButtonUnSelect
{
    
    for (UIButton *btn in self.buttonWithAll) {
        btn.selected = NO;
    }
    
}

- (void)setButtonSelect
{
    //滑动选中按钮
    UIButton *button = (UIButton *)[self viewWithTag:self.userSelectedChannelID];
    button.selected = YES;
    
    
}

//点击titleButton时候 顶部标签大于屏幕高度往后滑动显示出来
- (void)adjustScrollViewContentY:(UIButton *)sender
{
    
    
//    float originY = [[_buttonOriginYArray objectAtIndex:BUTTONSELECTEDID] floatValue];
    float height = [[_buttonWithArray objectAtIndex:BUTTONSELECTEDID] floatValue];
    
    
    if (sender.frame.origin.y - self.contentOffset.y > self.frame.size.height-(BUTTONGAP+height)) {
        NSLog(@"走1");
        [self setContentOffset:CGPointMake(0, height+BUTTONGAP)  animated:YES];
    }
    
    if (sender.frame.origin.y - self.contentOffset.y < 5) {
        NSLog(@"走2");
//        [self setContentOffset:CGPointMake(0,originY)  animated:YES];
    }
}


//rootScrollView滑动的时候 改变titleButton位置 大于屏幕高度向下滑动
-(void)setScrollViewContentOffset
{
    float originY = [[self.buttonOriginYArray objectAtIndex:BUTTONSELECTEDID] floatValue];
    float height = [[self.buttonWithArray objectAtIndex:BUTTONSELECTEDID] floatValue];

    if (originY - self.contentOffset.y > self.frame.size.height-(BUTTONGAP+height)) {
        NSLog(@"走3");
        [self setContentOffset:CGPointMake(0, originY - 30)  animated:YES];
    }

    if (originY - self.contentOffset.y < 5) {
        NSLog(@"走4");
        [self setContentOffset:CGPointMake(0,originY)  animated:YES];
    }
}






-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"contentoffset:%f",scrollView.contentOffset.y);
}

@end
