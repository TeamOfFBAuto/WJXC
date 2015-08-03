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


-(void)loadCustomViewWithModel:(ProductModel *)theModel index:(NSIndexPath *)theIndexPath{
    UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(10,10, 60, 60)];
    [imv sd_setImageWithURL:[NSURL URLWithString:theModel.cover_pic] placeholderImage:nil];
    [self.contentView addSubview:imv];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imv.frame)+10, imv.frame.origin.y, DEVICE_WIDTH - 90, 30) title:theModel.product_desc font:14 align:NSTextAlignmentLeft textColor:[UIColor blackColor]];
    titleLabel.numberOfLines = 2;
    
    [self.contentView addSubview:titleLabel];
    
    
    
    UILabel *price = [[UILabel alloc]initWithFrame:CGRectMake(titleLabel.frame.origin.x, CGRectGetMaxY(titleLabel.frame), titleLabel.frame.size.width, 30) title:[NSString stringWithFormat:@"￥%@",theModel.current_price] font:14 align:NSTextAlignmentLeft textColor:RGBCOLOR(244, 139, 46)];
    [self.contentView addSubview:price];
    
}

@end
