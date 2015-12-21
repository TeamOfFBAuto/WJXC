//
//  SeachCustomTableViewCell.h
//  WJXC
//
//  Created by gaomeng on 15/8/3.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductModel.h"

@interface SeachCustomTableViewCell : UITableViewCell

@property(nonatomic,strong)UIImageView *imv;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *priceLabel;


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;


-(void)loadCustomViewWithModel:(ProductModel *)theModel index:(NSIndexPath *)theIndexPath;


@end
