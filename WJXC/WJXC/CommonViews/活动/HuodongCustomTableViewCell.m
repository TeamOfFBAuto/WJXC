//
//  HuodongCustomTableViewCell.m
//  WJXC
//
//  Created by gaomeng on 15/8/3.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "HuodongCustomTableViewCell.h"

@implementation HuodongCustomTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(CGFloat)loadCustomViewWithModel:(HuodongDetailModel*)theModel index:(NSIndexPath*)theIndexpath{
    CGFloat height = 0.0f;
    if (theIndexpath.row == 0) {//封面图
        CGFloat bili = 1;
        if (theModel.cover_width && theModel.cover_height) {
            CGFloat cor_width = [theModel.cover_width floatValue];
            CGFloat cor_height = [theModel.cover_height floatValue];
            bili = cor_width/cor_height;
        }
        UIImageView *coverImv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 180*bili)];
        [coverImv sd_setImageWithURL:[NSURL URLWithString:theModel.cover_pic] placeholderImage:[UIImage imageNamed:@"default02.png"]];
        [self.contentView addSubview:coverImv];
        //标题
        UILabel *huodongLable = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(coverImv.frame)+10, DEVICE_WIDTH - 20, 0) title:theModel.title font:13 align:NSTextAlignmentLeft textColor:RGBCOLOR(240, 114, 0)];
        [huodongLable setMatchedFrame4LabelWithOrigin:CGPointMake(10, CGRectGetMaxY(coverImv.frame)+10) width:DEVICE_WIDTH - 20];
        [self.contentView addSubview:huodongLable];
        
        //时间图标
        UIImageView *timeImv = [[UIImageView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(huodongLable.frame)+10, 12, 12)];
        [timeImv setImage:[UIImage imageNamed:@"homepage_activity_clock.png"]];
        [self.contentView addSubview:timeImv];
        //时间label
        NSString *startTime = [GMAPI timechangeAll2:theModel.start_time];
        NSString *endTime = [GMAPI timechangeAll2:theModel.end_time];
        NSString *timeStr = [NSString stringWithFormat:@"活动时间%@ - %@",startTime,endTime];
        UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(timeImv.frame)+5, timeImv.frame.origin.y-1, DEVICE_WIDTH - 10-15-10-10, 12) title:timeStr font:12 align:NSTextAlignmentLeft textColor:[UIColor blackColor]];
        [self.contentView addSubview:timeLabel];
        
        height = CGRectGetMaxY(timeImv.frame)+10;
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, height-0.5, DEVICE_WIDTH, 0.5)];
        line.backgroundColor = RGBCOLOR(220, 221, 223);
        [self.contentView addSubview:line];
        
    }else{
        NSArray *desc_format = theModel.desc_format;
        NSDictionary *dic = desc_format[theIndexpath.row - 1];
        if ([[dic stringValueForKey:@"type"]intValue] == 1) {//文字
            UILabel *tt = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, DEVICE_WIDTH-20, 0) title:[dic stringValueForKey:@"content"] font:12 align:NSTextAlignmentLeft textColor:[UIColor blackColor]];
            [self.contentView addSubview:tt];
            [tt setMatchedFrame4LabelWithOrigin:CGPointMake(10, 5) width:DEVICE_WIDTH-20];
            height = CGRectGetMaxY(tt.frame);
            
        }else if ([[dic stringValueForKey:@"type"]intValue] == 2){//图片
            
            CGFloat bili = 1;
            if (theModel.cover_width && theModel.cover_height) {
                CGFloat cor_width = [theModel.cover_width floatValue];
                CGFloat cor_height = [theModel.cover_height floatValue];
                bili = cor_width/cor_height;
            }
            
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 180*bili)];
            [imv sd_setImageWithURL:[NSURL URLWithString:[dic stringValueForKey:@"src"]] placeholderImage:[UIImage imageNamed:@"homepage_activity_clock.png"]];
            [self.contentView addSubview:imv];
            
            if (bili == 1) {
                height = 180;
            }else{
                height = CGRectGetMaxY(imv.frame);
            }
            
        }
    }
    
    
    return height;
}


@end
