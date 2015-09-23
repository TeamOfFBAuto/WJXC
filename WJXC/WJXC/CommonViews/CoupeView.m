//
//  CoupeView.m
//  YiYiProject
//
//  Created by lichaowei on 15/9/10.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "CoupeView.h"
#import "CouponModel.h"
#import "ButtonProperty.h"

@implementation CoupeView

//使用优惠劵
//修改成可滑动

-(instancetype)initWithCouponArray:(NSArray *)couponArray
                         userStyle:(USESTYLE)userStyle
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
        
        CGFloat left = [LTools fitWidth:25];
        CGFloat aWidth = DEVICE_WIDTH - left * 2;
        
        NSArray *coupeList = couponArray;
        
        _coupeArray = couponArray;
        _userStyle = userStyle;
        
        UIView *listView = [[UIView alloc]initWithFrame:CGRectMake(left, 0, aWidth, 0)];
        [self addSubview:listView];
        listView.backgroundColor = [UIColor whiteColor];
        [listView addCornerRadius:5.f];
        
        NSString *title;
        NSString *title_close;
        UIColor *color_close;
        
        if (userStyle == USESTYLE_Get) {
            title = @"领取优惠劵";
            title_close = @"确定";
            color_close = [UIColor colorWithHexString:@"999999"];
            
        }else if (userStyle == USESTYLE_Use){
            title = @"优惠劵";
            title_close = @"确定";
            color_close = DEFAULT_TEXTCOLOR;
        }
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, listView.width, [LTools fitHeight:40]) title:title font:15 align:NSTextAlignmentCenter textColor:[UIColor blackColor]];
        [listView addSubview:titleLabel];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, titleLabel.bottom, listView.width, 0.5)];
        line.backgroundColor = DEFAULT_LINECOLOR;
        [listView addSubview:line];
        
        //加上个scrollView
        
        CGFloat bottom = line.bottom;
        CGFloat top = line.bottom;
        NSInteger count = coupeList.count;
        
        if (count <= 3) {
            
            for (int i = 0; i < count; i ++) {
                
                CouponModel *aModel = coupeList[i];
                UIView *aView = [self coupeViewWithCoupeModel:aModel frame:CGRectMake(0, top + [LTools fitHeight:50] * i, listView.width, [LTools fitHeight:50]) tag:100 + i];
                [listView addSubview:aView];
                bottom = aView.bottom;
            }
            
            UIButton *closeBtn = [[UIButton alloc]initWithframe:CGRectMake(0,bottom + [LTools fitHeight:15], [LTools fitWidth:173], [LTools fitHeight:25]) buttonType:UIButtonTypeCustom normalTitle:title_close selectedTitle:nil target:self action:@selector(clickToCloseCoupeView)];
            [listView addSubview:closeBtn];
            closeBtn.backgroundColor = color_close;
            [closeBtn addCornerRadius:5.f];
            [closeBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
            closeBtn.centerX = listView.width / 2.f;
            
            listView.height = closeBtn.bottom + [LTools fitHeight:15];
            
        }else //多于3个
        {
            top = 0.f;
            
            CGFloat everyHeight = [LTools fitHeight:50 - 1];//每个优惠劵高度
            listView.height = line.bottom + everyHeight * 3 + [LTools fitHeight:25] + [LTools fitHeight:15] * 2;
            UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, line.bottom, listView.width, everyHeight * 3)];
            scroll.contentSize = CGSizeMake(listView.width, everyHeight * count);
            [listView addSubview:scroll];
            
            //放优惠劵
            for (int i = 0; i < count; i ++) {
                
                CouponModel *aModel = coupeList[i];
                UIView *aView = [self coupeViewWithCoupeModel:aModel frame:CGRectMake(0, top + everyHeight * i, listView.width, everyHeight) tag:100 + i];
                [scroll addSubview:aView];
                bottom = aView.bottom;
            }
            
            line = [[UIView alloc]initWithFrame:CGRectMake(0, scroll.bottom, listView.width, 0.5)];
            line.backgroundColor = DEFAULT_LINECOLOR;
            [listView addSubview:line];
            
            CGFloat closeHeight = [LTools fitHeight:25];
            UIButton *closeBtn = [[UIButton alloc]initWithframe:CGRectMake(0,line.bottom + [LTools fitHeight:15], [LTools fitWidth:173], closeHeight) buttonType:UIButtonTypeCustom normalTitle:title_close selectedTitle:nil target:self action:@selector(clickToCloseCoupeView)];
            [listView addSubview:closeBtn];
            closeBtn.backgroundColor = color_close;
            [closeBtn addCornerRadius:5.f];
            [closeBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
            closeBtn.centerX = listView.width / 2.f;

        }
        
        listView.centerY = DEVICE_HEIGHT / 2.f;

        
    }
    return self;
}

//-(instancetype)initWithCouponArray:(NSArray *)couponArray
//                         userStyle:(USESTYLE)userStyle
//{
//    self = [super initWithFrame:[UIScreen mainScreen].bounds];
//    if (self) {
//        
//        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
//        
//        CGFloat left = [LTools fitWidth:25];
//        CGFloat aWidth = DEVICE_WIDTH - left * 2;
//        
//        NSArray *coupeList = couponArray;
//        
//        _coupeArray = couponArray;
//        _userStyle = userStyle;
//        
//        UIView *listView = [[UIView alloc]initWithFrame:CGRectMake(left, 0, aWidth, 0)];
//        [self addSubview:listView];
//        listView.backgroundColor = [UIColor whiteColor];
//        [listView addCornerRadius:5.f];
//        
//        NSString *title;
//        NSString *title_close;
//        UIColor *color_close;
//        
//        if (userStyle == USESTYLE_Get) {
//            title = @"领取优惠劵";
//            title_close = @"确定";
//            color_close = [UIColor colorWithHexString:@"999999"];
//
//        }else if (userStyle == USESTYLE_Use){
//            title = @"优惠劵";
//            title_close = @"确定";
//            color_close = DEFAULT_TEXTCOLOR;
//        }
//        
//        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, listView.width, [LTools fitHeight:40]) title:title font:15 align:NSTextAlignmentCenter textColor:[UIColor blackColor]];
//        [listView addSubview:titleLabel];
//        
//        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, titleLabel.bottom, listView.width, 0.5)];
//        line.backgroundColor = DEFAULT_LINECOLOR;
//        [listView addSubview:line];
//        
//        CGFloat bottom = line.bottom;
//        CGFloat top = line.bottom;
//        NSInteger count = coupeList.count;
//        for (int i = 0; i < count; i ++) {
//            
//            CouponModel *aModel = coupeList[i];
//            UIView *aView = [self coupeViewWithCoupeModel:aModel frame:CGRectMake(0, top + [LTools fitHeight:50] * i, listView.width, [LTools fitHeight:50]) tag:100 + i];
//            [listView addSubview:aView];
//            bottom = aView.bottom;
//        }
//        
//        UIButton *closeBtn = [[UIButton alloc]initWithframe:CGRectMake(0,bottom + [LTools fitHeight:15], [LTools fitWidth:173], [LTools fitHeight:25]) buttonType:UIButtonTypeCustom normalTitle:title_close selectedTitle:nil target:self action:@selector(clickToCloseCoupeView)];
//        [listView addSubview:closeBtn];
//        closeBtn.backgroundColor = color_close;
//        [closeBtn addCornerRadius:5.f];
//        [closeBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
//        closeBtn.centerX = listView.width / 2.f;
//        
//        listView.height = closeBtn.bottom + [LTools fitHeight:15];
//        listView.centerY = DEVICE_HEIGHT / 2.f;
//        
//    }
//    return self;
//}

- (UIView *)coupeViewWithCoupeModel:(CouponModel *)aModel
                              frame:(CGRect)frame
                                tag:(int)tag
{
    UIView *view = [[UIView alloc]initWithFrame:frame];
    
    UIImage *aImage = [LTools imageForCoupeColorId:aModel.color];
    
    //券
    UIButton *btn = [[UIButton alloc]initWithframe:CGRectMake([LTools fitWidth:10], [LTools fitHeight:8] , [LTools fitWidth:88], [LTools fitHeight:35]) buttonType:UIButtonTypeCustom normalTitle:nil selectedTitle:nil nornalImage:aImage selectedImage:nil target:self action:nil];
    [view addSubview:btn];
    
    
    int type = [aModel.type intValue];
    
    NSString *title_minus;
    NSString *title_full;
    NSString *title;
    //满减
    if (type == 1) {
        
        title_minus = [NSString stringWithFormat:@"￥%@",aModel.minus_money];
        title_full = [NSString stringWithFormat:@"满%@即可使用",aModel.full_money];
        title = [NSString stringWithFormat:@"满%@减%@",aModel.full_money,aModel.minus_money];
    }
    //折扣
    else if (type == 2){
        
        NSString *discount = [NSString stringWithFormat:@"%.1f",[aModel.discount_num floatValue] * 10];
        discount = [NSString stringWithFormat:@"%@",[discount stringByRemoveTrailZero]];
        title_minus = @"优惠券";
        title_full = [NSString stringWithFormat:@"尊享%@折优惠",discount];
        title = [NSString stringWithFormat:@"%@折",discount];
    }
    
    CGFloat aHeight = btn.height / 2.f - 5;
    UILabel *minusLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, btn.width - 10, aHeight) title:title_minus font:8 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
    [btn addSubview:minusLabel];
    UILabel *fullLabel = [[UILabel alloc]initWithFrame:CGRectMake(minusLabel.left, minusLabel.bottom, minusLabel.width, aHeight) title:title_full font:8 align:NSTextAlignmentCenter textColor:[UIColor whiteColor]];
    [btn addSubview:fullLabel];
    
    //优惠标题
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(btn.right + 5, btn.top, [LTools fitWidth:140], btn.height / 2.f) title:title font:8 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"5c5c5c"]];
    [view addSubview:label];
    label.font = [UIFont boldSystemFontOfSize:8];
    
    NSString *title2 = [NSString stringWithFormat:@"有效期:%@-%@",[LTools timeString:aModel.use_start_time withFormat:@"yyyy.MM.dd"],[LTools timeString:aModel.use_end_time withFormat:@"yyyy.MM.dd"]];
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(btn.right + 5, label.bottom, [LTools fitWidth:140], btn.height / 2.f) title:title2 font:8 align:NSTextAlignmentLeft textColor:[UIColor colorWithHexString:@"ababab"]];
    [view addSubview:label2];
    
    
    UIImage *image_normal;
    UIImage *image_selected;
    if (_userStyle == USESTYLE_Get) {
        
        image_normal = [UIImage imageNamed:@"youhui_lingqu"];
        image_selected = [UIImage imageNamed:@"youhui_yilingqu"];
        
    }else if (_userStyle == USESTYLE_Use){
        
        image_normal = [UIImage imageNamed:@"shopping cart_normal"];
        image_selected = [UIImage imageNamed:@"shopping cart_selected"];
    }
    
    //点击获取优惠劵
    CGFloat aWidth = [LTools fitWidth:55];
    
    ButtonProperty *btn_get = [ButtonProperty buttonWithType:UIButtonTypeCustom];
    btn_get.frame = CGRectMake(view.width - [LTools fitWidth:10] - aWidth, [LTools fitHeight:16], aWidth, [LTools fitHeight:30]);
//    btn_get.backgroundColor = [UIColor orangeColor];
    [btn_get setImage:image_normal forState:UIControlStateNormal];
    [btn_get setImage:image_selected forState:UIControlStateSelected];
    [btn_get addTarget:self action:@selector(clickToGetCoupe:) forControlEvents:UIControlEventTouchUpInside];
    btn_get.tag = tag;
    [view addSubview:btn_get];
    btn_get.centerY = btn.centerY;
    btn_get.object = aModel;
    
    if (_userStyle == USESTYLE_Get) {
        
        int isGet = [aModel.enable_receive intValue];
        btn_get.selected = !isGet;
        if (btn_get.selected) {
            btn_get.userInteractionEnabled = NO;
        }
    }else if (_userStyle == USESTYLE_Use){
        btn_get.selected = aModel.isUsed;
        
    }
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, btn.bottom + btn.top, view.width, 0.5)];
    line.backgroundColor = DEFAULT_LINECOLOR;
    [view addSubview:line];
    
    return view;
}

- (void)setCoupeBlock:(COUPEBLOCK)coupeBlock
{
    _coupeBlock = coupeBlock;
}

/**
 *  获取优惠券
 *
 *  @param sender
 */
- (void)clickToGetCoupe:(ButtonProperty *)sender
{
    //使用
    CouponModel *aModel = sender.object;
    
    if (_userStyle == USESTYLE_Use) {
        
        int count = (int)_coupeArray.count;
        for (int i = 0; i < count; i ++) {
            
            ButtonProperty *btn = (ButtonProperty *)[self viewWithTag:100 + i];
            CouponModel *aModel = btn.object;
            
            if (btn == sender) {
                
                btn.selected = !btn.selected;
            }else
            {
                btn.selected = NO;
            }
            aModel.isUsed = btn.selected;
        }
        
        if (sender.selected == NO) { //取消选择优惠劵
            
            if (self.coupeBlock) {
                self.coupeBlock(nil);
            }
            return;
        }
        
        //更新选择优惠劵
        if (aModel && [aModel isKindOfClass:[CouponModel class]]) {
            
            if (self.coupeBlock) {
                NSDictionary *params = @{@"button":sender,
                                         @"model":aModel};
                self.coupeBlock(params);
            }
        }
        
    }else if(_userStyle == USESTYLE_Get)
    {
        if (aModel && [aModel isKindOfClass:[CouponModel class]]) {
            
            if (self.coupeBlock) {
                NSDictionary *params = @{@"button":sender,
                                         @"model":aModel};
                self.coupeBlock(params);
            }
        }
    }
}

- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

/**
 *  关闭领取优惠券界面
 */
- (void)clickToCloseCoupeView
{
    [self removeFromSuperview];
}

@end
