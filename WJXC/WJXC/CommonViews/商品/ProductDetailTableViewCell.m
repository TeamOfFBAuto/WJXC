//
//  ProductDetailTableViewCell.m
//  WJXC
//
//  Created by gaomeng on 15/7/8.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "ProductDetailTableViewCell.h"

@implementation ProductDetailTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



-(CGFloat)loadCustomViewWithIndex:(NSIndexPath*)theIndexPath theModel:(ProductDetailModel*)model{
    CGFloat height = 0;
     if (theIndexPath.row == 1) {//产品名字
        UILabel *productNameLable = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, DEVICE_WIDTH-10, 32)];
        productNameLable.text = model.product_name;
        productNameLable.font = [UIFont systemFontOfSize:11];
        [productNameLable setMatchedFrame4LabelWithOrigin:CGPointMake(10, 10) width:DEVICE_WIDTH-20];
        [self.contentView addSubview:productNameLable];
         
        UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(productNameLable.frame)+5, DEVICE_WIDTH - 20, 15)];
        NSString *yuanjia = model.original_price;
        NSString *xianjia = model.current_price;
        NSString *price = [NSString stringWithFormat:@"￥%@ %@",xianjia,yuanjia];
        NSMutableAttributedString  *aaa = [[NSMutableAttributedString alloc]initWithString:price];
        [aaa addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(238, 115, 0) range:NSMakeRange(0, xianjia.length+1)];
        [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, xianjia.length+1)];
        
        [aaa addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(105, 106, 107) range:NSMakeRange(xianjia.length+1, yuanjia.length+1)];
        [aaa addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(xianjia.length+1, yuanjia.length+1)];
        [aaa addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(xianjia.length+2, yuanjia.length)];
        priceLabel.attributedText = aaa;
        [self.contentView addSubview:priceLabel];
        
        
        
        UILabel *kucenLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(priceLabel.frame)+5, DEVICE_WIDTH-20, 15)];
        kucenLabel.font = [UIFont systemFontOfSize:12];
        kucenLabel.text = [NSString stringWithFormat:@"库存：%@件",model.discount];
        [self.contentView addSubview:kucenLabel];

         height = CGRectGetMaxY(kucenLabel.frame)+10;
         
         UIView *fengeView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(kucenLabel.frame)+9.5, DEVICE_WIDTH, 0.5)];
         fengeView.backgroundColor = RGBCOLOR(220, 221, 223);
         [self.contentView addSubview:fengeView];
        
    }else if (theIndexPath.row == 2){//评价晒单
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, DEVICE_WIDTH - 20, 15)];
        titleLabel.text = @"评价晒单";
        titleLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:titleLabel];
        
        UIView *fengeView = [[UIView alloc]initWithFrame:CGRectMake(0, 32-0.5, DEVICE_WIDTH, 0.5)];
        fengeView.backgroundColor = RGBCOLOR(220, 221, 223);
        [self.contentView addSubview:fengeView];
        
        
        //箭头
        UIImageView *jiantou = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH - 15, 10, 7, 12)];
        [jiantou setImage:[UIImage imageNamed:@"my_jiantou.png"]];
        [self.contentView addSubview:jiantou];
        
        height = 32;
        
    }else if (theIndexPath.row == 3){//产品详情
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, DEVICE_WIDTH-20, 15)];
        titleLabel.text = @"产品详情：";
        titleLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:titleLabel];
        height = 32;
        
    }else{
        NSDictionary *dic = model.product_desc[theIndexPath.row -4];
        if ([[dic stringValueForKey:@"type"]intValue] == 1) {//文字
            NSString *content = [dic stringValueForKey:@"content"];
            UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectZero];
            contentLabel.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:contentLabel];
            contentLabel.text = content;
            [contentLabel setMatchedFrame4LabelWithOrigin:CGPointMake(10, 10) width:DEVICE_WIDTH - 20];
            height = contentLabel.frame.size.height +10 +10;
            
        }else if ([[dic stringValueForKey:@"type"]intValue] == 2){//图片
            NSString *src = [dic stringValueForKey:@"src"];
            NSString *width = [dic stringValueForKey:@"width"];
            NSString *height_ = [dic stringValueForKey:@"height"];
            CGFloat width_f = [width floatValue];
            CGFloat height_f = [height_ floatValue];
            
            
            if ([width floatValue]>DEVICE_WIDTH-20) {
                width = [NSString stringWithFormat:@"%f",DEVICE_WIDTH-20];
                
                height_ = [NSString stringWithFormat:@"%f",(DEVICE_WIDTH-20)*height_f/width_f];
            }
            
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, [width floatValue], [height_ floatValue])];
            [imv l_setImageWithURL:[NSURL URLWithString:src] placeholderImage:[UIImage imageNamed:@"default02.png"]];
            [self.contentView addSubview:imv];
            
            height = [height_ floatValue];
        }
        
        
    }
    
    
    return height;
}


@end
