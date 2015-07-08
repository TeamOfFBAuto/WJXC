//
//  UILabel+GautoMatchedText.m
//  FBCircle
//
//  Created by gaomeng on 14-5-27.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "UILabel+GautoMatchedText.h"

@implementation UILabel (GautoMatchedText)


//设定宽度 自适应高度
-(void)setMatchedFrame4LabelWithOrigin:(CGPoint)o width:(CGFloat)theWidth{
    CGRect r = [self matchedRectWithWidth:theWidth];
    [self setFrame:CGRectMake(o.x, o.y, r.size.width, r.size.height)];
    
}

-(CGRect)matchedRectWithWidth:(CGFloat)width{
    self.numberOfLines = 0;
    CGRect r = CGRectZero;
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        r = [self.text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.font} context:nil];
    }
    return r;
    
}




//设定高度 最大宽度  自适应宽度
-(void)setMatchedFrame4LabelWithOrigin:(CGPoint)o height:(CGFloat)theHeight limitMaxWidth:(CGFloat)theWidth{
    CGRect r = [self matchedrectWithHeight:theHeight];
    if (r.size.width>theWidth) {
        [self setFrame:CGRectMake(o.x, o.y, theWidth, r.size.height)];
    }else{
        [self setFrame:CGRectMake(o.x, o.y, r.size.width, r.size.height)];
    }
    
}

-(CGRect)matchedrectWithHeight:(CGFloat)height{
    self.numberOfLines = 1;
    CGRect r = CGRectZero;
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        r = [self.text boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.font} context:nil];
    }
    return r;
}


@end
