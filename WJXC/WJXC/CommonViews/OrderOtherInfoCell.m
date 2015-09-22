//
//  OrderOtherInfoCell.m
//  YiYiProject
//
//  Created by lichaowei on 15/9/12.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "OrderOtherInfoCell.h"
#import "CouponModel.h"
#import "CoupeView.h"

@implementation CustomTextField



@end

@implementation OrderOtherInfoCell
{
    UILabel *minusLabel;//减多少
    UILabel *fullLabel;//满多少
    UIButton *couponBtn;//优惠劵
    CoupeView *_coupeView;//使用优惠劵界面
    UILabel *_label_coupon;//显示是否使用
    UIImageView *_jiantouImage;
    NSArray *_couponList;//优惠劵列表
}

- (void)awakeFromNib {
    // Initialization code
    
    
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *footer = [self footerView];
        [self.contentView addSubview:footer];
    }
    return self;
}

- (UIView *)footerView
{
    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 50)];
    footer.backgroundColor = [UIColor whiteColor];
    
    UILabel *leftLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 80, 50) title:@"可用优惠劵" font:13 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"313131"]];
    [footer addSubview:leftLabel];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor clearColor];
    
    //显示优惠劵使用情况
    self.btn_quan = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btn_quan setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
    [_btn_quan setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateSelected];
    [_btn_quan setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_btn_quan.titleLabel setFont:[UIFont systemFontOfSize:13]];
    _btn_quan.frame = CGRectMake(leftLabel.right + 5, 0, 100, 50);
    [footer addSubview:_btn_quan];
    
    //箭头
    _jiantouImage = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 15 - 6, 19.5, 6, 11)];
    _jiantouImage.image = [UIImage imageNamed:@"shopping cart_dd_middle_jt"];
    [footer addSubview:_jiantouImage];
    _jiantouImage.centerY = _btn_quan.centerY;
    
    //未使用优惠劵
    _label_coupon = [[UILabel alloc]initWithFrame:CGRectMake(_jiantouImage.left - 10 - 40, 0, 40, 50) title:@"未使用" font:13 align:NSTextAlignmentRight textColor:[UIColor colorWithHexString:@"333333"]];
    [footer addSubview:_label_coupon];
    
    //优惠券
    CGFloat aWidth = [LTools fitWidth:85];
    couponBtn = [self couponViewFrame:CGRectMake(DEVICE_WIDTH - 10 - aWidth, 0, aWidth, 28)];
    [footer addSubview:couponBtn];
    couponBtn.centerY = _btn_quan.centerY;
    
    return footer;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)clickToSelectCoupon
{
    if (_coupeView) {
        [_coupeView removeFromSuperview];
        _coupeView = nil;
    }
    
    _coupeView = [[CoupeView alloc]initWithCouponArray:_couponList userStyle:USESTYLE_Use];
    
    __weak typeof(self)weakSelf = self;
    
    _coupeView.coupeBlock = ^(NSDictionary *params){
        
//        ButtonProperty *btn = params[@"button"];
        CouponModel *aModel = params[@"model"];
        [weakSelf updateCouponWithModel:aModel];
    };
    [_coupeView show];
}

//更新优惠劵信息 包括界面显示和shopModel的属性
- (void)updateCouponWithModel:(CouponModel *)aModel
{
    [self updateCouponViewDateWithModel:aModel];
    [self setCellWithModel:aModel couponList:_couponList];
    
    //更改优惠劵了
    if (self.updateCouponBlock) {
        _updateCouponBlock(aModel);
    }
    
}
-(void)setUpdateCouponBlock:(UPDATECOUPONBLOCK)updateCouponBlock
{
    _updateCouponBlock = updateCouponBlock;
}

/**
 *  优惠劵
 *
 *  @return
 */
- (UIButton *)couponViewFrame:(CGRect)frame
{
    UIButton *btn = [[UIButton alloc]initWithframe:frame buttonType:UIButtonTypeCustom normalTitle:nil selectedTitle:nil nornalImage:nil selectedImage:nil target:self action:nil];
    CGFloat aHeight = btn.height / 2.f - 5;
    minusLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, btn.width - 10, aHeight) title:nil font:8 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
    [btn addSubview:minusLabel];
    minusLabel.font = [UIFont boldSystemFontOfSize:8];
    
    fullLabel = [[UILabel alloc]initWithFrame:CGRectMake(minusLabel.left, minusLabel.bottom, minusLabel.width, aHeight) title:nil font:8 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
    [btn addSubview:fullLabel];
    return btn;
}

/**
 *  更新优惠劵显示内容
 *
 *  @param aModel
 */
- (void)updateCouponViewDateWithModel:(CouponModel *)aModel
{
    if (aModel == nil) {
        
        [couponBtn setImage:nil forState:UIControlStateNormal];
        minusLabel.text = @"";
        fullLabel.text = @"";
        return;
    }
    
    int type = [aModel.type intValue];
    
    NSString *title_minus;
    NSString *title_full;
    //满减
    if (type == 1) {
        
        title_minus = [NSString stringWithFormat:@"￥%@",aModel.minus_money];
        title_full = [NSString stringWithFormat:@"满%@即可使用",aModel.full_money];
    }
    //折扣
    else if (type == 2){
        
        NSString *discount = [NSString stringWithFormat:@"%.1f",[aModel.discount_num floatValue] * 10];
        discount = [NSString stringWithFormat:@"%@",[discount stringByRemoveTrailZero]];
        title_minus = @"优惠券";
        title_full = [NSString stringWithFormat:@"本店享%@折优惠",discount];
    }
    minusLabel.text = title_minus;
    fullLabel.text = title_full;
    
    UIImage *aImage = [LTools imageForCoupeColorId:aModel.color];
    [couponBtn setImage:aImage forState:UIControlStateNormal];
}

- (void)setCellWithModel:(CouponModel *)cModel
              couponList:(NSArray *)couponList
{
    //优惠券使用情况
    
    _couponList = couponList;
    
    NSString *title;
    
    //为真时代表已选择优惠劵
    if (cModel) {
        
        title = @"已使用";
        [couponBtn addTarget:self action:@selector(clickToSelectCoupon) forControlEvents:UIControlEventTouchUpInside];

    }else
    {
        int count = (int)couponList.count;
        if (count) {
            title = [NSString stringWithFormat:@"%d张",count];
            [couponBtn addTarget:self action:@selector(clickToSelectCoupon) forControlEvents:UIControlEventTouchUpInside];
        }else
        {
            title = @"暂无优惠";
            [couponBtn removeTarget:self action:@selector(clickToSelectCoupon) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
//    //只是展示
//    if (shopModel.onlyShow) {
//        
//        _label_coupon.hidden = YES;
//        _jiantouImage.hidden = YES;
//        _tf.enabled = NO;
//    }
    
    [_btn_quan setTitle:title forState:UIControlStateNormal];
    
    [self updateCouponViewDateWithModel:cModel];
}


@end
