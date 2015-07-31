//
//  ClassCustomTableViewCell.h
//  WJXC
//
//  Created by gaomeng on 15/7/28.
//  Copyright (c) 2015年 lcw. All rights reserved.
//


//分类界面自定义cell

#import <UIKit/UIKit.h>
#import "ProductModel.h"


typedef void (^gouwucheBlock)(NSInteger index);//定义block

@interface ClassCustomTableViewCell : UITableViewCell


@property(nonatomic,copy)gouwucheBlock gouwucheBlock;

@property(nonatomic,strong)NSString *type;


-(CGFloat)loadCustomViewWithModel:(ProductModel*)model index:(NSIndexPath*)theIndexPath;



-(void)setGouwucheBlock:(gouwucheBlock)gouwucheBlock;

@end
