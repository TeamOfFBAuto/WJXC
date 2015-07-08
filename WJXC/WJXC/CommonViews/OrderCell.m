//
//  OrderCell.m
//  WJXC
//
//  Created by lichaowei on 15/7/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "OrderCell.h"

@implementation OrderCell

- (void)awakeFromNib {
    // Initialization code
    [self.commentButton setBorderWidth:0.5 borderColor:[UIColor colorWithHexString:@"f98702"]];
    [self.commentButton addCornerRadius:3.f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellWithModel:(id)aModel
{
    
}

@end
