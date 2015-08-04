//
//  SimpleMessageCell.h
//  WJXC
//
//  Created by lichaowei on 15/8/4.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

@interface SimpleMessageCell : RCMessageCell
/**
 * 消息显示Label
 */
@property(strong, nonatomic) RCAttributedLabel *textLabel;

/**
 * 消息背景
 */
@property(nonatomic, strong) UIImageView *bubbleBackgroundView;

@property(nonatomic, strong) UIImageView *iconImageView;

//@property(nonatomic, strong) 

/**
 * 设置消息数据模型
 *
 * @param model 消息数据模型
 */
- (void)setDataModel:(RCMessageModel *)model;

@end
