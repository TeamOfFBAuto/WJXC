//
//  ProductCommentTableViewCell.h
//  WJXC
//
//  Created by gaomeng on 15/7/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//


//商品评论自定义cell
#import <UIKit/UIKit.h>

#import "ProductCommentModel.h"

@interface ProductCommentTableViewCell : UITableViewCell

@property(nonatomic,strong)UIImageView *headerImv;//头像
@property(nonatomic,strong)UILabel *userNameLabel;//用户名
@property(nonatomic,strong)UILabel *contentLabel;//内容Label
@property(nonatomic,strong)UIView *showImvView;//展示图片view
@property(nonatomic,strong)UILabel *timeLabel;//展示时间view
@property(nonatomic,strong)UIView *startView;//星星view

@property(nonatomic,strong)NSMutableArray *imvArray;//图片数组


-(CGFloat)loadCustomViewWithIndex:(NSIndexPath *)indexPath theModel:(ProductCommentModel*)model;

@end
