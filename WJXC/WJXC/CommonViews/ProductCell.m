//
//  ProductCell.m
//  WJXC
//
//  Created by lichaowei on 15/7/18.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "ProductCell.h"
#import "ProductModel.h"

@implementation ProductCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellWithModel:(ProductModel *)model
{
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.cover_pic] placeholderImage:DEFAULT_YIJIAYI];
    self.productNameLabel.text = model.product_name;
    
    NSString *price = nil;
    if ([model.is_seckill intValue] == 1) {
        
        price = [model.seckill_info stringValueForKey:@"seckill_price"];
    }else
    {
        price = model.current_price;
    }
    
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@",price];
    self.numLabel.text = [NSString stringWithFormat:@"x %@",model.product_num];
}

@end
