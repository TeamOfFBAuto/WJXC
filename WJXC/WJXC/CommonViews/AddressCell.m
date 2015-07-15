//
//  AddressCell.m
//  WJXC
//
//  Created by lichaowei on 15/7/7.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "AddressCell.h"
#import "AddressModel.h"

@implementation AddressCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellWithModel:(AddressModel *)aModel
{
    self.nameLabel.text = aModel.receiver_username;
    self.nameLabel.width = [LTools widthForText:aModel.receiver_username font:16];
    self.phoneLabel.left = self.nameLabel.right + 10;
    self.phoneLabel.width = [LTools widthForText:aModel.mobile font:16];
    self.phoneLabel.text = aModel.mobile;
    self.addressLabel.text = aModel.address;
    self.addressButton.selected = [aModel.default_address intValue] == 1 ? YES : NO;
    
    self.addressLabel.height = [LTools heightForText:aModel.address width:_addressLabel.width font:13];
    self.addressLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.addressLabel.numberOfLines = 2;
}

@end
