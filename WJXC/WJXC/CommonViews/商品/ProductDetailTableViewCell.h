//
//  ProductDetailTableViewCell.h
//  WJXC
//
//  Created by gaomeng on 15/7/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

//商品详情自定义cell

#import <UIKit/UIKit.h>
#import "ProductDetailModel.h"

@interface ProductDetailTableViewCell : UITableViewCell



-(CGFloat)loadCustomViewWithIndex:(NSIndexPath*)theIndexPath theModel:(ProductDetailModel*)model;


@end
