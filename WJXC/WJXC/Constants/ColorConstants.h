//
//  ColorConstants.h
//  WJXC
//
//  Created by lichaowei on 15/6/25.
//  Copyright (c) 2015年 lcw. All rights reserved.
//
/**
 *  常用的一些颜色常量
 */

#ifndef WJXC_ColorConstants_h
#define WJXC_ColorConstants_h

///颜色
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f \
alpha:(a)]

//随机颜色
#define RGBCOLOR_ONE RGBCOLOR(arc4random()%255, arc4random()%255, arc4random()%255)

/**
 *  自定义一些颜色
 */

#define DEFAULT_VIEW_BACKGROUNDCOLOR RGBCOLOR(239, 239, 239)
#define DEFAULT_TEXTCOLOR RGBCOLOR(255, 45, 120) //主题颜色一致


#endif
