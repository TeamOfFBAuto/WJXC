//
//  OrderCell.m
//  WJXC
//
//  Created by lichaowei on 15/7/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "OrderCell.h"
#import "OrderModel.h"
#import "ProductModel.h"

@implementation OrderCell

- (void)awakeFromNib {
    // Initialization code
    [self.commentButton setBorderWidth:0.5 borderColor:[UIColor colorWithHexString:@"f98702"]];
    [self.commentButton addCornerRadius:3.f];
    
    [self.delayButton setBorderWidth:0.5 borderColor:[UIColor lightGrayColor]];
    [self.delayButton addCornerRadius:3.f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellWithModel:(OrderModel *)aModel
{
    //只有一个商品
    
    int productNum = (int)aModel.products.count;
    
    if (productNum == 1) {
        
        ProductModel *product = [[ProductModel alloc]initWithDictionary:[aModel.products lastObject]];
        
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:product.cover_pic] placeholderImage:DEFAULT_YIJIAYI];
        self.titleLabel.text = product.product_name;
        _titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _titleLabel.numberOfLines = 2;
        CGFloat height = [LTools heightForText:product.product_name width:_titleLabel.width font:14];
        _titleLabel.height = height;
        
        self.numLabel.text = [NSString stringWithFormat:@"x%d",[product.product_num intValue]];
        self.priceLabel.text = [NSString stringWithFormat:@"￥%.2f",[product.current_price floatValue]];;

        if (self.contentScroll) {
            
            for (UIView *aView in _contentScroll.subviews) {
                
                [aView removeFromSuperview];
            }
            
            [_contentScroll removeFromSuperview];
            _contentScroll = nil;
        }
     
    //好多商品
    }else if (productNum > 1){
        
        
        [self.iconImageView sd_setImageWithURL:nil];
        self.titleLabel.text = @"";
        self.numLabel.text = @"";
        self.priceLabel.text = @"";
        
        if (!self.contentScroll) {
            self.contentScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(10, 10, DEVICE_WIDTH - 20, 60)];
            _contentScroll.contentSize = CGSizeMake(productNum * (60 + 10), 60);
            [self.contentView addSubview:_contentScroll];
            
            for (int i = 0; i < productNum; i ++) {
                
                ProductModel *product = [[ProductModel alloc]initWithDictionary:[aModel.products objectAtIndex:i]];

                NSString *imageUrl = product.cover_pic;
                UIImageView *aImageView = [[UIImageView alloc]initWithFrame:CGRectMake((60 + 10) * i, 0, 60, 60)];
                [aImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:DEFAULT_YIJIAYI];
                [_contentScroll addSubview:aImageView];
            }
        }
    }
    
    NSString *address = [NSString stringWithFormat:@"配送地址:%@",aModel.address];
    self.addressLabel.text = address;
    _addressLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _addressLabel.numberOfLines = 2;
    CGFloat height = [LTools heightForText:address width:DEVICE_WIDTH - 20 font:14];
    _addressLabel.height = height;
    self.realPriceLabel.text = [NSString stringWithFormat:@"￥%.2f",[aModel.total_fee floatValue]];
}

@end
