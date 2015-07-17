//
//  ShoppingCartCell.h
//  WJXC
//
//  Created by lichaowei on 15/7/16.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

/**
 *  购物车cell
 */
#import <UIKit/UIKit.h>

@interface ShoppingCartCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIButton *selectedButton;
@property (strong, nonatomic) IBOutlet UIImageView *productImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UIButton *reduceButton;
@property (strong, nonatomic) IBOutlet UIButton *addButton;
@property (strong, nonatomic) IBOutlet UILabel *numLabel;
@property (strong, nonatomic) IBOutlet UIView *bgView;
@property (strong, nonatomic) IBOutlet UIButton *deleteBtn;

- (void)setCellWithModel:(id)aModel;

@end
