//
//  CollectCell.m
//  WJXC
//
//  Created by lichaowei on 15/7/7.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "CollectCell.h"
#import "ProductModel.h"

@implementation CollectCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellWithModel:(ProductModel *)aModel
{
//    @property (strong, nonatomic) IBOutlet UIImageView *iconImageView;
//    @property (strong, nonatomic) IBOutlet UILabel *nameLabel;
//    @property (strong, nonatomic) IBOutlet UILabel *priceLabel;
//    @property (strong, nonatomic) IBOutlet UIButton *carButton;
    
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:aModel.product_pic] placeholderImage:DEFAULT_YIJIAYI];
    self.nameLabel.text = aModel.product_name;
    self.priceLabel.text = [NSString stringWithFormat:@"￥%.2f",[aModel.current_price floatValue]];
}

@end
