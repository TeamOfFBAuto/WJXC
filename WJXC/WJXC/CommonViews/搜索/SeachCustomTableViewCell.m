//
//  SeachCustomTableViewCell.m
//  WJXC
//
//  Created by gaomeng on 15/8/3.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "SeachCustomTableViewCell.h"

@implementation SeachCustomTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imv = [[UIImageView alloc]initWithFrame:CGRectMake(10,10, 60, 60)];
        [self.contentView addSubview:self.imv];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.imv.frame)+10, self.imv.frame.origin.y, DEVICE_WIDTH - 90, 40)];
        self.titleLabel.font = [UIFont systemFontOfSize:13];
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.textColor =[UIColor blackColor];
        [self.contentView addSubview:self.titleLabel];
        
        self.priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.titleLabel.frame.origin.x, CGRectGetMaxY(self.titleLabel.frame), self.titleLabel.frame.size.width, 20)];
        self.priceLabel.font = [UIFont systemFontOfSize:13];
        self.priceLabel.textColor = RGBCOLOR(244, 139, 46);
        [self.contentView addSubview:self.priceLabel];
        
    }
    
    return self;
}



-(void)loadCustomViewWithModel:(ProductModel *)theModel index:(NSIndexPath *)theIndexPath{
    [self.imv sd_setImageWithURL:[NSURL URLWithString:theModel.cover_pic] placeholderImage:nil];
    self.titleLabel.text = theModel.product_name;
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@",theModel.current_price];
}

@end
