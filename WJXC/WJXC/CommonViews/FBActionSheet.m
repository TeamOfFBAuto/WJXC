//
//  FBActionSheet.m
//  FBAuto
//
//  Created by lichaowei on 14-7-1.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "FBActionSheet.h"
#define KLEFT 15
#define KTOP 20
#define DIS_SMALL 10
#define DIS_BIG 8

@implementation FBActionSheet

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.frame = [UIScreen mainScreen].bounds;
        
        self.window.windowLevel = UIAlertViewStyleDefault;
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        
        self.alpha = 0.0;
        
        bgView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIApplication sharedApplication].keyWindow.bottom, DEVICE_WIDTH, 208 - 35)];
        bgView.backgroundColor = [UIColor clearColor];
        [self addSubview:bgView];
        
        UIView *btnView = [[UIView alloc]initWithFrame:CGRectMake(KLEFT, KTOP, DEVICE_WIDTH - KLEFT * 2, 45 * 2)];
        [bgView addSubview:btnView];
        [btnView addCornerRadius:5.f];
        
        UIButton *firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
        firstButton.frame = CGRectMake(0, 0, DEVICE_WIDTH - KLEFT * 2, 45);
        [firstButton setTitle:@"拍照" forState:UIControlStateNormal];
        [firstButton setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
        firstButton.tag = 100;
        firstButton.backgroundColor = [UIColor whiteColor];
        [firstButton setBackgroundImage:[UIImage imageNamed:@"bai_button554_90"] forState:UIControlStateNormal];
        [btnView addSubview:firstButton];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, firstButton.bottom, firstButton.width, 0.5f)];
        [btnView addSubview:line];
        line.backgroundColor = [UIColor colorWithHexString:@"d6d6d6"];
        
        UIButton *secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
        secondButton.frame = CGRectMake(0, firstButton.bottom + 0.5, DEVICE_WIDTH - KLEFT * 2, 45);
        [secondButton setTitle:@"从手机相册选择" forState:UIControlStateNormal];
        [secondButton setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
        secondButton.tag = 101;
        secondButton.backgroundColor = [UIColor whiteColor];
        [secondButton setBackgroundImage:[UIImage imageNamed:@"bai_button554_90"] forState:UIControlStateNormal];
        [btnView addSubview:secondButton];
        
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(KLEFT, btnView.bottom + DIS_BIG, DEVICE_WIDTH - KLEFT * 2, 45);
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
        cancelButton.layer.cornerRadius = 5;
        cancelButton.tag = 102;
        cancelButton.backgroundColor = [UIColor whiteColor];
        [cancelButton setBackgroundImage:[UIImage imageNamed:@"hui_button554_90"] forState:UIControlStateNormal];
        [bgView addSubview:cancelButton];
        
        [firstButton addTarget:self action:@selector(actionToDo:) forControlEvents:UIControlEventTouchUpInside];
        [secondButton addTarget:self action:@selector(actionToDo:) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton addTarget:self action:@selector(actionToDo:) forControlEvents:UIControlEventTouchUpInside];
        
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        
        [self show];
    }
    return self;
}

- (void)show
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect aFrame = bgView.frame;
        aFrame.origin.y = [UIApplication sharedApplication].keyWindow.bottom - (208 - 35);
        bgView.frame = aFrame;
        
        self.alpha = 1.0;
    }];
}


- (void)actionBlock:(ActionBlock)aBlock
{
    actionBlock = aBlock;
}

- (void)actionToDo:(UIButton *)button
{
    //0,1,2
    actionBlock(button.tag - 100);
    [self hidden];
}

- (void)hidden
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect aFrame = bgView.frame;
        aFrame.origin.y = [UIApplication sharedApplication].keyWindow.bottom;
        bgView.frame = aFrame;
        
        self.alpha = 0;
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];

    }];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hidden];
}

@end
