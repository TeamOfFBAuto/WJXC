//
//  HuodongCustomTableViewCell.h
//  WJXC
//
//  Created by gaomeng on 15/8/3.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HuodongModel.h"

@interface HuodongCustomTableViewCell : UITableViewCell



-(CGFloat)loadCustomViewWithModel:(HuodongModel*)theModel index:(NSIndexPath*)theIndexpath;


@end
