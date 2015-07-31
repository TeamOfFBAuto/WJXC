//
//  AppDelegate.h
//  WJXC
//
//  Created by lichaowei on 15/6/25.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^LocationBlock)(NSDictionary *dic);//获取坐标block
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)startDingweiWithBlock:(LocationBlock)location;
@end

