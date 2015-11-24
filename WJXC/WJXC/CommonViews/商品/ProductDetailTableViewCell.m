//
//  ProductDetailTableViewCell.m
//  WJXC
//
//  Created by gaomeng on 15/7/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "ProductDetailTableViewCell.h"
#import "CouponModel.h"

@implementation ProductDetailTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(CGFloat)loadCustomViewWithIndex:(NSIndexPath*)theIndexPath theModel:(ProductDetailModel*)model{
    CGFloat height = 0;
     if (theIndexPath.row == 1) {//产品名字
        UILabel *productNameLable = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, DEVICE_WIDTH-10, 32)];
        productNameLable.text = model.product_name;
        productNameLable.font = [UIFont systemFontOfSize:14];
        [productNameLable setMatchedFrame4LabelWithOrigin:CGPointMake(10, 10) width:DEVICE_WIDTH-20];
        [self.contentView addSubview:productNameLable];
         
         //是否是秒杀 秒杀加上倒计时
         
         CGFloat priceTop = productNameLable.bottom + 5;
         if ([model.is_seckill intValue] == 1) {

            NSString *time = [model.seckill_info stringValueForKey:@"end_time"];

             NSString *endString = MIAOSHAO_END_TEXT;
             NSString *timeString = [GMAPI daojishi:time endString:endString];
             
             //秒杀活动已结束
             if ([endString isEqualToString:timeString]) {
                 
                 _miaoShaLabel.text = endString;
             }
             
             timeString = [NSString stringWithFormat:@"%@%@",MIAOSHAO_PRE_TEXT,timeString];
             self.miaoShaLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, productNameLable.bottom + 5, 300, 15) title:timeString font:12 align:NSTextAlignmentLeft textColor:RGBCOLOR(238, 115, 0)];
             [self.contentView addSubview:_miaoShaLabel];
             
             priceTop = _miaoShaLabel.bottom + 5;
         }else
         {
             if (self.miaoShaLabel) {
                 [self.miaoShaLabel removeFromSuperview];
                 self.miaoShaLabel = nil;
             }
         }
         
         //有秒杀显示秒杀价格  没有秒杀时判断是否有打折
         
         NSString *yuanjia = model.original_price;
         NSString *xianjia = model.current_price ? model.current_price : @"0";
         if ([model.is_seckill intValue] == 1) {
             
             xianjia = model.seckill_info[@"seckill_price"];
             
         }else
         {
             int discount = [model.discount intValue];
             if (discount == 100 || discount == 0) {
                 //没有打折
                 yuanjia = @"";
             }
         }
         
        UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, priceTop, DEVICE_WIDTH - 20, 15)];
        NSString *price = [NSString stringWithFormat:@"￥%@ %@",xianjia,yuanjia];
        NSMutableAttributedString  *aaa = [[NSMutableAttributedString alloc]initWithString:price];
        [aaa addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(238, 115, 0) range:NSMakeRange(0, xianjia.length+1)];
        [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, xianjia.length+1)];
        
        [aaa addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(105, 106, 107) range:NSMakeRange(xianjia.length+1, yuanjia.length+1)];
        [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(xianjia.length+1, yuanjia.length+1)];
        [aaa addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(xianjia.length+2, yuanjia.length)];
        priceLabel.attributedText = aaa;
        [self.contentView addSubview:priceLabel];
        
        //库存
//        UILabel *kucenLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(priceLabel.frame)+5, DEVICE_WIDTH-20, 15)];
//        kucenLabel.font = [UIFont systemFontOfSize:12];
//        kucenLabel.text = [NSString stringWithFormat:@"库存：%@件",model.discount];
//        [self.contentView addSubview:kucenLabel];

         height = CGRectGetMaxY(priceLabel.frame)+10;
         
         UIView *fengeView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(priceLabel.frame)+9.5, DEVICE_WIDTH, 0.5)];
         fengeView.backgroundColor = RGBCOLOR(220, 221, 223);
         [self.contentView addSubview:fengeView];
        
     }else if (theIndexPath.row == 2){//店铺优惠券
         UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 65, 35)];
         titleLabel.font = [UIFont systemFontOfSize:12];
         titleLabel.text = @"店铺优惠券";
         [self.contentView addSubview:titleLabel];
         
         UIView *fengeView = [[UIView alloc]initWithFrame:CGRectMake(0, 35-0.5, DEVICE_WIDTH, 0.5)];
         fengeView.backgroundColor = RGBCOLOR(220, 221, 223);
         [self.contentView addSubview:fengeView];
         
         CGFloat xx = DEVICE_WIDTH*325/750;
         UIView *couponsBackView = [[UIView alloc]initWithFrame:CGRectMake(xx, 3.5, DEVICE_WIDTH-5-xx, 28)];
         [self.contentView addSubview:couponsBackView];
         
         
         NSMutableArray *coupont_modleListArray = [NSMutableArray arrayWithCapacity:1];
         
         for (NSDictionary *dic in model.coupon_list) {
             CouponModel *model = [[CouponModel alloc]initWithDictionary:dic];
             [coupont_modleListArray addObject:model];
         }
         
         
         CGFloat c_w = (DEVICE_WIDTH -5 - xx)/3.0;
         for (int i = 0; i<coupont_modleListArray.count; i++) {
             
             CouponModel *model = coupont_modleListArray[i];
             
             UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake((2-i)*c_w, 0, c_w-2, couponsBackView.frame.size.height)];
             
             if ([model.color intValue] == 1) {//红色
                 [imv setImage:[UIImage imageNamed:@"youhuiquan_r_48.png"]];
             }else if ([model.color intValue] == 2){//黄色
                 [imv setImage:[UIImage imageNamed:@"youhuiquan_y_48.png"]];
             }else if ([model.color intValue] == 3){//蓝色
                 [imv setImage:[UIImage imageNamed:@"youhuiquan_b_48.png"]];
             }
             
             [couponsBackView addSubview:imv];
             
             
             
             UILabel *ttLabel = [[UILabel alloc]initWithFrame:imv.bounds];
             ttLabel.font = [UIFont systemFontOfSize:10];
             ttLabel.textColor = [UIColor whiteColor];
             ttLabel.textAlignment = NSTextAlignmentCenter;
             [imv addSubview:ttLabel];
             
             if ([model.type intValue] == 1) {//满减
                 ttLabel.text = [NSString stringWithFormat:@"满%@减%@",model.full_money,model.minus_money];
             }else if ([model.type intValue] == 2){//打折
                 ttLabel.text = [NSString stringWithFormat:@"%.1f折优惠",[model.discount_num floatValue] * 10];
             }
             
             
             
             if (i == 2) {
                 break;
             }
             
         }
         
         
         height = 35;
         
         
         
         
         
         
     }else if (theIndexPath.row == 3){//评价晒单
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, DEVICE_WIDTH - 20, 15)];
        titleLabel.text = @"评价晒单";
        titleLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:titleLabel];
        
        UIView *fengeView = [[UIView alloc]initWithFrame:CGRectMake(0, 32-0.5, DEVICE_WIDTH, 0.5)];
        fengeView.backgroundColor = RGBCOLOR(220, 221, 223);
        [self.contentView addSubview:fengeView];
        
        
        //箭头
        UIImageView *jiantou = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 15, 10, 7, 12)];
        [jiantou setImage:[UIImage imageNamed:@"my_jiantou.png"]];
        [self.contentView addSubview:jiantou];
        
        height = 32;
        
    }else if (theIndexPath.row == 4){//产品详情
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, DEVICE_WIDTH-20, 15)];
        titleLabel.text = @"产品详情：";
        titleLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:titleLabel];
        height = 32;
        
    }else{
        NSDictionary *dic = model.product_desc[theIndexPath.row -5];
        if ([[dic stringValueForKey:@"type"]intValue] == 1) {//文字
            NSString *content = [dic stringValueForKey:@"content"];
            UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectZero];
            contentLabel.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:contentLabel];
            contentLabel.text = content;
            [contentLabel setMatchedFrame4LabelWithOrigin:CGPointMake(10, 10) width:DEVICE_WIDTH - 20];
            height = contentLabel.frame.size.height +10 +10;
            
        }else if ([[dic stringValueForKey:@"type"]intValue] == 2){//图片
            NSString *src = [dic stringValueForKey:@"src"];
            NSString *width = [dic stringValueForKey:@"width"];
            NSString *height_ = [dic stringValueForKey:@"height"];
            CGFloat width_f = [width floatValue];
            CGFloat height_f = [height_ floatValue];
            
            
            if ([width floatValue]>DEVICE_WIDTH-20) {
                width = [NSString stringWithFormat:@"%f",DEVICE_WIDTH-20];
                
                height_ = [NSString stringWithFormat:@"%f",(DEVICE_WIDTH-20)*height_f/width_f];
            }
            
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, [width floatValue], [height_ floatValue])];
            [imv l_setImageWithURL:[NSURL URLWithString:src] placeholderImage:nil];
            imv.backgroundColor = RGBCOLOR(236, 236, 236);
            [self.contentView addSubview:imv];
            
            height = [height_ floatValue];
        }
        
        
    }
    
    
    return height;
}


@end
