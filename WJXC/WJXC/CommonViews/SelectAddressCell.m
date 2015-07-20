//
//  SelectAddressCell.m
//  WJXC
//
//  Created by lichaowei on 15/7/20.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "SelectAddressCell.h"
#import "AddressModel.h"

@implementation SelectAddressCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellWithModel:(AddressModel *)aModel
{
//    UILabel *nameLabel;
//    @property (strong, nonatomic) IBOutlet UILabel *phoneLabel;
//    @property (strong, nonatomic) IBOutlet UILabel *addressLabel;
//    @property (strong, nonatomic) IBOutlet UIImageView *selectImage;
    
    self.nameLabel.text = aModel.receiver_username;
    CGFloat width = [LTools widthForText:aModel.receiver_username font:15];
    self.nameLabel.width = width;
    
    self.phoneLabel.left = _nameLabel.right + 10;
    self.phoneLabel.text = aModel.mobile;
    self.addressLabel.text = aModel.address;
    
//    default_address
    
    int isDefault = [aModel.default_address intValue];
    
    NSString *keyword = isDefault ? @"[默认]" : @"";
    
    NSString *content = [NSString stringWithFormat:@"%@%@",keyword,aModel.address];
    NSAttributedString *string = [LTools attributedString:content keyword:keyword color:[UIColor colorWithHexString:@"f98700"]];
    [self.addressLabel setAttributedText:string];
}

@end
