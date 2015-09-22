//
//  GclickedImv.h
//  WJXC
//
//  Created by gaomeng on 15/7/17.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^kuangBlock)(UIImageView *imv,NSString *url,NSMutableArray *urls);//定义block

@interface GclickedImv : UIImageView


@property(nonatomic,copy)kuangBlock kuangBlock;//弄成属性

@property(nonatomic,strong)NSString *url;
@property(nonatomic,strong)NSMutableArray *urls;//一组url

-(id)initWithFrame:(CGRect)frame;


-(void)setKuangBlock:(kuangBlock)kuangBlock;//block的set方法

@end
