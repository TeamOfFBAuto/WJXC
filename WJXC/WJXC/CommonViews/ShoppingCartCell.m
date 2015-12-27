//
//  ShoppingCartCell.m
//  WJXC
//
//  Created by lichaowei on 15/7/16.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "ShoppingCartCell.h"
#import "ProductModel.h"

@implementation ShoppingCartCell
{
    ProductModel *_aModel;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellWithModel:(ProductModel *)aModel
{
    [self.productImageView l_setImageWithURL:[NSURL URLWithString:aModel.cover_pic] placeholderImage:DEFAULT_HEADIMAGE];
    
    CGFloat width =  DEVICE_WIDTH - self.productImageView.right - self.numBgView.width  - 20;
    _nameLabel.width = width;
    
    NSString *name = aModel.product_name;
    _nameLabel.numberOfLines = 2;
    _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _nameLabel.height = [LTools heightForText:name width:_nameLabel.width font:13];
    _nameLabel.text = aModel.product_name;
    
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@",aModel.current_price];
    self.numLabel.text = aModel.product_num;
    
    self.reduceButton.selected = [aModel.product_num intValue] == 1 ? NO : YES;
    self.reduceButton.userInteractionEnabled = [aModel.product_num intValue] == 1 ? NO : YES;
}


@end
