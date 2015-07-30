//
//  OrderCell.h
//  WJXC
//
//  Created by lichaowei on 15/7/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

/**
 *  订单cell
 */
#import <UIKit/UIKit.h>

@interface OrderCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *iconImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *numLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *realPriceLabel;
@property (strong, nonatomic) IBOutlet UIButton *commentButton;

@property (nonatomic,retain)UIScrollView *contentScroll;//放置多个商品

- (void)setCellWithModel:(id)aModel;

@end
