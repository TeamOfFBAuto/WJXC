//
//  NickNameSheet.m
//  WJXC
//
//  Created by lichaowei on 15/7/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "NickNameSheet.h"

@implementation NickNameSheet
#define KLEFT 15
#define KTOP 20
#define DIS_SMALL 10
#define DIS_BIG 8


- (void)dealloc
{
    [self deleteKeyBordNotification];
    _cancelButton = nil;
    _sureButton = nil;
    self.nickActionBlock = nil;
    bgView = nil;
    _contentTF = nil;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.frame = [UIScreen mainScreen].bounds;
        
        self.window.windowLevel = UIAlertViewStyleDefault;
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        
        self.alpha = 0.0;
        
        bgView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIApplication sharedApplication].keyWindow.bottom, DEVICE_WIDTH, 208)];
        bgView.backgroundColor = [UIColor clearColor];
        [self addSubview:bgView];
        
        UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(KLEFT, 0, DEVICE_WIDTH - KLEFT * 2, 45 * 2)];
        [bgView addSubview:contentView];
        contentView.backgroundColor = [UIColor whiteColor];
        [contentView addCornerRadius:5.f];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 19, contentView.width - 40, 12) title:@"请输入您的昵称" font:11 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"646464"]];
        [contentView addSubview:label];
        
        _contentTF = [[UITextField alloc]initWithFrame:CGRectMake(label.left, label.bottom + 15, label.width, 14)];
        _contentTF.font = [UIFont systemFontOfSize:13];
        _contentTF.textColor = [UIColor colorWithHexString:@"646464"];
        [contentView addSubview:_contentTF];
        
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(_contentTF.left - 2, _contentTF.bottom + 5, _contentTF.width, 0.5)];
        line.backgroundColor = DEFAULT_TEXTCOLOR;
        [contentView addSubview:line];
      
        
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame = CGRectMake(KLEFT, contentView.bottom + 8, DEVICE_WIDTH - KLEFT * 2, 45);
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
        _cancelButton.tag = 100;
        [_cancelButton addTarget:self action:@selector(clickToCancel:) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.backgroundColor = [UIColor whiteColor];
        [_cancelButton addCornerRadius:5.f];
        [bgView addSubview:_cancelButton];
        
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureButton.frame = CGRectMake(KLEFT, _cancelButton.bottom + 8, DEVICE_WIDTH - KLEFT * 2, 45);
        [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
        [_sureButton setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
        _sureButton.tag = 101;
        [_sureButton addTarget:self action:@selector(clickToSure:) forControlEvents:UIControlEventTouchUpInside];
        [_sureButton addCornerRadius:5.f];
        _sureButton.backgroundColor = [UIColor whiteColor];
        [bgView addSubview:_sureButton];
        
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        
        _isKeyboardShow = NO;
        
        [self addKeyBordNotification];
        
        [self show];
    }
    return self;
}

- (void)show
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect aFrame = bgView.frame;
        aFrame.origin.y = [UIApplication sharedApplication].keyWindow.bottom - 208;
        bgView.frame = aFrame;
        
        self.alpha = 1.0;
    }];
}

- (void)clickToCancel:(UIButton *)sender
{
    [self hidden];
}

- (void)clickToSure:(UIButton *)sender
{
    [self hidden];
    if (self.nickActionBlock) {
        
        self.nickActionBlock(_contentTF.text);
    }
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
    //键盘在的时候 隐藏键盘
    if (_isKeyboardShow) {
        
        [_contentTF resignFirstResponder];
        
    }else
    {
        [self hidden];

    }
}

#pragma mark - 键盘相关

-(void)addKeyBordNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillShowKeyboardForCustomInputView:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillHideKeyboardForCustomInputView:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)deleteKeyBordNotification
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - 监测键盘弹出收起以及高度变化

-(void)handleWillShowKeyboardForCustomInputView:(NSNotification *)notification
{
    
    //键盘出来时 取消和确定按钮 隐藏
    
    _cancelButton.hidden = YES;
    _sureButton.hidden = YES;
    
    _isKeyboardShow = YES;
    
    __weak typeof(bgView)weakBgView = bgView;

    [UIView animateWithDuration:0.33f animations:^{
        
        CGRect aFrame = weakBgView.frame;
        aFrame.origin.y = DEVICE_HEIGHT/2.f - 45 * 2 - 10;
        weakBgView.frame = aFrame;
        
    }];
    
}


-(void)handleWillHideKeyboardForCustomInputView:(NSNotification *)notification
{
    
//    __weak typeof(self)weakSelf = self;
    __weak typeof(bgView)weakBgView = bgView;
    
    _isKeyboardShow = NO;
    [UIView animateWithDuration:0.33f animations:^{
        
        //恢复原位置
        CGRect aFrame = weakBgView.frame;
        aFrame.origin.y = [UIApplication sharedApplication].keyWindow.bottom - 208;
        weakBgView.frame = aFrame;
        
        _cancelButton.hidden = NO;
        _sureButton.hidden = NO;
        
    } completion:^(BOOL finished) {
        
        //键盘出来时 取消和确定按钮 隐藏

    }];
    
}



@end
