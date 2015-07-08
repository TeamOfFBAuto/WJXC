//
//  NickNameSheet.h
//  WJXC
//
//  Created by lichaowei on 15/7/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//
/**
 *  自定义sheetView 用于修改昵称
 */
#import <UIKit/UIKit.h>

typedef void(^ NickActionBlock) (NSString *content);

@interface NickNameSheet : UIView
{
    UIView *bgView;
    UITextField *_contentTF;
    UIButton *_cancelButton;
    UIButton *_sureButton;
    
    BOOL _isKeyboardShow;
}

@property(nonatomic,copy)NickActionBlock nickActionBlock;

@end
