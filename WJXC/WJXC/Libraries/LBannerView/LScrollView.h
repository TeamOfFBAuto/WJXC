//
//  LScrollView.h
//  TiJian
//
//  Created by lichaowei on 15/12/22.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,TouchEventState) {
    TouchEventState_began = 0,
    TouchEventState_canceled,
    TouchEventState_ended
};
typedef void(^TouchEventBlock)(TouchEventState touchState);
@interface LScrollView : UIScrollView

@property(nonatomic,copy)void(^ touchEventBlock)(TouchEventState state);

-(void)setTouchEventBlock:(void (^)(TouchEventState state))touchEventBlock;

@end
