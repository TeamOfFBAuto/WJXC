//
//  GtopScrollView.h
//  YiYiProject
//
//  Created by gaomeng on 15/1/4.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GRootScrollView;
@class GRTabView;

typedef enum{
    GTOPFLOOR = 0,
    GTOPPINPAI,
    GTOPSHENQINGDIANPU,
}GTOPTYPE;


@interface GtopScrollView : UIScrollView <UIScrollViewDelegate>


@property(nonatomic,strong)NSArray *nameArray;//标题数组
@property(nonatomic,assign)NSInteger userSelectedChannelID;//点击按钮选择名字ID
@property(nonatomic,assign)NSInteger scrollViewSelectedChannelID;  //滑动列表选择名字ID

@property(nonatomic,retain)NSMutableArray *buttonOriginYArray;//里面装btn的原点Y坐标
@property(nonatomic,retain)NSMutableArray *buttonWithArray;//里面装btn的高度
@property(nonatomic,strong)NSMutableArray *buttonWithAll;//里面装所有的Btn

@property(nonatomic,strong)UIButton *theLastSelectBtn;//上一个选择按钮

@property(nonatomic,assign)GRTabView *myRootScrollView;

@property(nonatomic,assign)BOOL noChange;



/**
 *  加载顶部标签
 */
- (void)initWithNameButtons;
/**
 *  滑动撤销选中按钮
 */
- (void)setButtonUnSelect;
/**
 *  滑动选择按钮
 */
- (void)setButtonSelect;
/**
 *  滑动顶部标签位置适应
 */
-(void)setScrollViewContentOffset;

@end
