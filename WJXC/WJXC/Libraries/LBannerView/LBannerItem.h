//
//  CircularItem.h
//  TestBannerView
//
//  Created by lichaowei on 15/12/2.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBannerItem : UIView

@property(nonatomic,retain)UIView *contentView;

- (void)updateContent;

@end
