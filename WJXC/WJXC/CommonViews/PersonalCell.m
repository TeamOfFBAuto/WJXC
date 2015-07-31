//
//  PersonalCell.m
//  WJXC
//
//  Created by lichaowei on 15/7/6.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "PersonalCell.h"

@implementation PersonalCell

- (void)awakeFromNib {
    // Initialization code
    
    [self.messageNumLabel addRoundCorner];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
