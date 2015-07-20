//
//  FBActionSheet.h
//  FBAuto
//
//  Created by lichaowei on 14-7-1.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  自定义actionSheet,目前是固定个数
 */

typedef void(^ ActionBlock) (NSInteger buttonIndex);

@interface FBActionSheet : UIView
{
    ActionBlock actionBlock;
    UIView *bgView;
}
@property(nonatomic,retain)UIButton *firstButton;
@property(nonatomic,retain)UIButton *secondButton;

- (void)actionBlock:(ActionBlock)aBlock;

@end
