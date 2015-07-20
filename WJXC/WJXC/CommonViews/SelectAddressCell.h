//
//  SelectAddressCell.h
//  WJXC
//
//  Created by lichaowei on 15/7/20.
//  Copyright (c) 2015年 lcw. All rights reserved.
//
/**
 *  选择收货地址cell
 */
#import <UIKit/UIKit.h>

@interface SelectAddressCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;

@property (strong, nonatomic) IBOutlet UIImageView *selectImage;

- (void)setCellWithModel:(id)aModel;

@end
