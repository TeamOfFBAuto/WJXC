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





-(void)loadCustomViewWithModel:(ProductModel *)theModel index:(NSIndexPath *)theIndexPath;


@end
