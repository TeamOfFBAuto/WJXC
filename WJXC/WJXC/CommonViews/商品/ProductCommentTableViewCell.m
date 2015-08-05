//
//  ProductCommentTableViewCell.m
//  WJXC
//
//  Created by gaomeng on 15/7/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "ProductCommentTableViewCell.h"
#import "GstartView.h"
#import "GclickedImv.h"

@implementation ProductCommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



-(CGFloat)loadCustomViewWithIndex:(NSIndexPath *)indexPath theModel:(ProductCommentModel*)model{
    CGFloat height = 0;
    self.imvArray = [NSMutableArray arrayWithCapacity:1];
    
    self.headerImv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 36, 36)];
    self.headerImv.layer.cornerRadius = 18;
    self.headerImv.backgroundColor = [UIColor grayColor];
    if ([model.is_anony intValue] == 1) {//匿名
        [self.headerImv setImage:[UIImage imageNamed:@"default.png"]];
    }else if ([model.is_anony intValue] == 0){
        [self.headerImv sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:@"default.png"]];
    }
    
    self.headerImv.layer.masksToBounds = YES;
    [self.contentView addSubview:self.headerImv];
    
    self.userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.headerImv.frame)+10, self.headerImv.frame.origin.y+5, DEVICE_WIDTH - CGRectGetMaxX(self.headerImv.frame)-5-10-10 - 70, 13)];
    self.userNameLabel.font = [UIFont systemFontOfSize:12];
    if ([model.is_anony intValue] == 1) {//匿名
        self.userNameLabel.text = @"匿名";
    }else if ([model.is_anony intValue] == 0){
        self.userNameLabel.text = model.username;
    }
    
    [self.contentView addSubview:self.userNameLabel];
    
    
    self.startView = [[UIView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 10 - 60, self.userNameLabel.frame.origin.y, 70, self.userNameLabel.frame.size.height)];
//    self.startView.backgroundColor = [UIColor purpleColor];
    GstartView *cc = [[GstartView alloc]initWithFrame:self.startView.bounds];
    cc.maxStartNum = 5;
    cc.startNum = [model.star_level floatValue];
    [cc updateStartNum];
    
    [self.startView addSubview:cc];
    [self.contentView addSubview:self.startView];
    
    self.contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.userNameLabel.frame.origin.x, CGRectGetMaxY(self.userNameLabel.frame)+10, self.userNameLabel.frame.size.width, 0)];
    self.contentLabel.font = [UIFont systemFontOfSize:12];
//    self.contentLabel.backgroundColor = [UIColor blueColor];
    self.contentLabel.text = model.content;
    [self.contentLabel setMatchedFrame4LabelWithOrigin:CGPointMake(self.userNameLabel.frame.origin.x, CGRectGetMaxY(self.userNameLabel.frame)+10) width:self.userNameLabel.frame.size.width];
    [self.contentView addSubview:self.contentLabel];
    
    NSInteger count = model.comment_pic.count;
    
    if (count>0) {//有图
        
        //一行
        self.showImvView = [[UIView alloc]initWithFrame:CGRectMake(self.userNameLabel.frame.origin.x, CGRectGetMaxY(self.contentLabel.frame)+10, self.userNameLabel.frame.size.width, (self.userNameLabel.frame.size.width-10)/3)];
//        self.showImvView.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:self.showImvView];
        CGFloat oneImvWithd = self.showImvView.frame.size.height;
        
        if (count>3 && count<7) {//两行
            CGRect r = self.showImvView.frame;
            r.size.height = self.showImvView.frame.size.height *2+5;
            self.showImvView.frame = r;
        }else if (count>6 && count<10){//三行
            CGRect r = self.showImvView.frame;
            r.size.height = self.showImvView.frame.size.height *3+10;
            self.showImvView.frame = r;
        }
        
        
        for (int i = 0; i<count; i++) {
            GclickedImv *imv = [[GclickedImv alloc]initWithFrame:CGRectMake(i%3*(oneImvWithd+5), i/3*(oneImvWithd+5), oneImvWithd, oneImvWithd)];
//            imv.backgroundColor = [UIColor redColor];
            NSDictionary *dic = model.comment_pic[i];
            [imv sd_setImageWithURL:[NSURL URLWithString:[dic stringValueForKey:@"pic"]] placeholderImage:nil];
            imv.userInteractionEnabled = YES;
            imv.url = [dic stringValueForKey:@"pic"];
            [self.imvArray addObject:imv];
            
            [self.showImvView addSubview:imv];
            
        }
        
        
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.userNameLabel.frame.origin.x, CGRectGetMaxY(self.showImvView.frame)+10, self.userNameLabel.frame.size.width, 11)];
        self.timeLabel.text = [GMAPI timechangeAll1:model.add_time];
        self.timeLabel.font = [UIFont systemFontOfSize:10];
//        self.timeLabel.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:self.timeLabel];
        
        
    }else{
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.userNameLabel.frame.origin.x, CGRectGetMaxY(self.contentLabel.frame)+10, self.userNameLabel.frame.size.width, 11)];
        self.timeLabel.text = [GMAPI timechangeAll1:model.add_time];
        self.timeLabel.font = [UIFont systemFontOfSize:10];
//        self.timeLabel.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:self.timeLabel];
    }
    
    
    
    
    if (model.comment_reply) {//有回复
        
        
        NSArray *replyArray = model.comment_reply;
        NSInteger count = replyArray.count;
        UIView *replyView = [[UIView alloc]initWithFrame:CGRectMake(self.timeLabel.frame.origin.x, CGRectGetMaxY(self.timeLabel.frame)+10, self.userNameLabel.frame.size.width+self.startView.frame.size.width, 50*count)];
//        replyView.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:replyView];
        
        
        CGFloat r_y = 0;
        
        
        for (int i = 0; i<count; i++) {
            NSDictionary *dic = replyArray[i];
            UILabel *rpLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, r_y, replyView.frame.size.width, 20)];
            rpLabel.font = [UIFont systemFontOfSize:12];
            rpLabel.text = [NSString stringWithFormat:@"店家回复：%@",[dic stringValueForKey:@"content"]];
            [rpLabel setMatchedFrame4LabelWithOrigin:CGPointMake(0, r_y) width:replyView.frame.size.width];
            [replyView addSubview:rpLabel];
            
            r_y +=rpLabel.frame.size.height+3;
            
            
        }
        
        CGRect rr = replyView.frame;
        rr.size.height = r_y;
        replyView.frame = rr;
        
        
        height = CGRectGetMaxY(replyView.frame)+15;
        
    }else{
        height = CGRectGetMaxY(self.timeLabel.frame)+15;
    }
    
    
    
    
    return height;
}



@end
