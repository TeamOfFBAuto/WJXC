//
//  LScrollView.m
//  TiJian
//
//  Created by lichaowei on 15/12/22.
//  Copyright © 2015年 lcw. All rights reserved.
//

#import "LScrollView.h"

@implementation LScrollView

-(void)setTouchEventBlock:(void (^)(TouchEventState state))touchEventBlock
{
    _touchEventBlock = touchEventBlock;
}

//
//- (BOOL)touchesShouldBegin:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event inContentView:(UIView *)view
//{
//    DDLOG_CURRENT_METHOD;
//    return YES;
//}
//// called before scrolling begins if touches have already been delivered to a subview of the scroll view. if it returns NO the touches will continue to be delivered to the subview and scrolling will not occur
//// not called if canCancelContentTouches is NO. default returns YES if view isn't a UIControl
//// this has no effect on presses
//- (BOOL)touchesShouldCancelInContentView:(UIView *)view{
//    
//    DDLOG_CURRENT_METHOD;
//    return YES;
//}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    DDLOG_CURRENT_METHOD;
    if (_touchEventBlock) {
        _touchEventBlock(TouchEventState_began);
    }
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    DDLOG_CURRENT_METHOD;
    if (_touchEventBlock) {
        _touchEventBlock(TouchEventState_canceled);
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    DDLOG_CURRENT_METHOD;
    if (_touchEventBlock) {
        _touchEventBlock(TouchEventState_ended);
    }
}



@end
