//
//  LBannerView.h
//  CircularBanner
//
//  Created by lichaowei on 15/12/2.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,AutomicSrollingDirection) {
    AutomicSrollingDirectionFromLeftToRight,
    AutomicSrollingDirectionFromRightToLeft
};

@interface LBannerView : UIView
@property (nonatomic, strong) NSArray *contentViews;//custom views
@property (nonatomic, assign) BOOL showPageControl;//defult YES
@property (nonatomic, assign) BOOL automicScrolling; //default YES
@property (nonatomic, assign) AutomicSrollingDirection direction;//default AutomicSrollingDirectionFromRightToLeft
@property (nonatomic, assign) CGFloat automicScrollingDuration;//default 2s.
@property (nonatomic, copy) void(^ tapActionBlock)(NSInteger index);//called back when tap.

-(void)setTapActionBlock:(void (^)(NSInteger index))tapActionBlock;

- (instancetype)initWithFrame:(CGRect)frame;

@end
