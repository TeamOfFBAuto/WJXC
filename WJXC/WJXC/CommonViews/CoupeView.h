//
//  CoupeView.h
//  YiYiProject
//
//  Created by lichaowei on 15/9/10.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

/**
 *  获取优惠券view
 */
#import <UIKit/UIKit.h>

typedef void(^COUPEBLOCK)(NSDictionary *params);

typedef enum {
   
    USESTYLE_Get = 0, //领取优惠劵
    USESTYLE_Use = 1 //选择使用优惠劵
    
}USESTYLE; //对优惠劵的操作类型

@interface CoupeView : UIView{
    NSArray *_coupeArray;
    USESTYLE _userStyle;
    id _selectedCouponModel;//选中的优惠劵
}

@property(nonatomic,copy)COUPEBLOCK coupeBlock;

//-(instancetype)initWithCouponArray:(NSArray *)couponArray;

-(instancetype)initWithCouponArray:(NSArray *)couponArray
                         userStyle:(USESTYLE)userStyle;

- (void)show;



@end
