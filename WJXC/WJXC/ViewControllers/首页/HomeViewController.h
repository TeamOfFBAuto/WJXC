//
//  HomeViewController.h
//  WJXC
//
//  Created by lichaowei on 15/6/25.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "MyViewController.h"

@interface HomeViewController : MyViewController

@property(nonatomic,strong)UILabel *leftLabel;


-(void)setLocationDataWithCityStr:(NSString *)city provinceStr:(NSString *)province;


@end
