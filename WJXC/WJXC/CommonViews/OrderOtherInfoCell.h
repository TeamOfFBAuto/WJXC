//
//  OrderOtherInfoCell.h
//  YiYiProject
//
//  Created by lichaowei on 15/9/12.
//  Copyright (c) 2015年 lcw. All rights reserved.
//
/**
 *  订单备注信息cell
 */
#import <UIKit/UIKit.h>


@interface CustomTextField : UITextField

@property(nonatomic,retain)NSIndexPath *indexPath;

@end

typedef void(^UPDATECOUPONBLOCK)(id params);//更新优惠劵

@interface OrderOtherInfoCell : UITableViewCell<UITextFieldDelegate>

@property(nonatomic,retain)UIButton *btn_quan;//优惠劵button
@property(nonatomic,retain)UILabel *label;

@property(nonatomic,copy)UPDATECOUPONBLOCK updateCouponBlock;

//- (void)setCellWithModel:(id)shopModel;

- (void)setCellWithModel:(id)cModel
              couponList:(NSArray *)couponList;

@end
