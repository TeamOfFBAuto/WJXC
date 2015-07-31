//
//  ClassCustomTableViewCell.m
//  WJXC
//
//  Created by gaomeng on 15/7/28.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "ClassCustomTableViewCell.h"

@implementation ClassCustomTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



-(void)setGouwucheBlock:(gouwucheBlock)gouwucheBlock{
    _gouwucheBlock = gouwucheBlock;
}


-(CGFloat)loadCustomViewWithModel:(ProductModel*)model index:(NSIndexPath*)theIndexPath{
    
    self.backgroundColor = [UIColor whiteColor];
    
    CGFloat height = 0;
    CGFloat height_width = 560.0/750;
    
    UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, DEVICE_WIDTH, DEVICE_WIDTH *height_width)];
    [imv sd_setImageWithURL:[NSURL URLWithString:model.cover_pic] placeholderImage:nil];
    [self.contentView addSubview:imv];
    
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(imv.frame)+5, DEVICE_WIDTH - 10, 0)];
    nameLabel.font = [UIFont systemFontOfSize:13];
    nameLabel.text = model.product_desc;
    nameLabel.textColor = [UIColor blackColor];
    [nameLabel setMatchedFrame4LabelWithOrigin:CGPointMake(10, CGRectGetMaxY(imv.frame)+5) width:DEVICE_WIDTH - 10];
    [self.contentView addSubview:nameLabel];
    
    
    UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(nameLabel.frame)+10, DEVICE_WIDTH - 20 - 50, 15)];
    priceLabel.textColor = RGBCOLOR(240, 114, 0);
    priceLabel.font = [UIFont systemFontOfSize:13];
    priceLabel.text = model.current_price;
    [self.contentView addSubview:priceLabel];
    
    
    
    
    
    UIButton *gouwuche = [UIButton buttonWithType:UIButtonTypeCustom];
    [gouwuche setFrame:CGRectMake(DEVICE_WIDTH - 50, CGRectGetMaxY(nameLabel.frame), 35, 35)];
    [gouwuche setImage:[UIImage imageNamed:@"my_collect_shoppingcart.png"] forState:UIControlStateNormal];
    
    if ([self.type isEqualToString:@"新品"]) {
        gouwuche.tag = 300+theIndexPath.row;
    }else if ([self.type isEqualToString:@"热卖"]){
        gouwuche.tag = -300-theIndexPath.row;
    }
    
    [gouwuche addTarget:self action:@selector(gouwucheBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:gouwuche];
    
    
    
    height = CGRectGetMaxY(gouwuche.frame);
    
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, height - 0.5, DEVICE_WIDTH, 0.5)];
    line.backgroundColor = RGBCOLOR(220, 221, 223);
    [self.contentView addSubview:line];
    
    return height;
    
}


-(void)gouwucheBtnClicked:(UIButton *)sender{
    if (self.gouwucheBlock) {
        self.gouwucheBlock(sender.tag);
    }
}


@end
