//
//  SimpleMessageCell.m
//  WJXC
//
//  Created by lichaowei on 15/8/4.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "SimpleMessageCell.h"

@interface SimpleMessageCell ()

- (void)initialize;

@end

@implementation SimpleMessageCell

- (NSDictionary *)attributeDictionary {
    if (self.messageDirection == MessageDirection_SEND) {
        return @{
                 @(NSTextCheckingTypeLink) : @{NSForegroundColorAttributeName : [UIColor blueColor]},
                 @(NSTextCheckingTypePhoneNumber) : @{NSForegroundColorAttributeName : [UIColor blueColor]}
                 };
    } else {
        return @{
                 @(NSTextCheckingTypeLink) : @{NSForegroundColorAttributeName : [UIColor blueColor]},
                 @(NSTextCheckingTypePhoneNumber) : @{NSForegroundColorAttributeName : [UIColor blueColor]}
                 };
    }
    return nil;
}

- (NSDictionary *)highlightedAttributeDictionary {
    return [self attributeDictionary];
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}
- (void)initialize {
    self.bubbleBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.messageContentView addSubview:self.bubbleBackgroundView];
    
    self.textLabel = [[RCAttributedLabel alloc] initWithFrame:CGRectZero];
    self.textLabel.attributeDictionary = [self attributeDictionary];
    self.textLabel.highlightedAttributeDictionary = [self highlightedAttributeDictionary];
    [self.textLabel setFont:[UIFont systemFontOfSize:Text_Message_Font_Size]];
    
    self.textLabel.numberOfLines = 0;
    [self.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.textLabel setTextAlignment:NSTextAlignmentLeft];
    [self.textLabel setTextColor:[UIColor blackColor]];
    //[self.textLabel setBackgroundColor:[UIColor yellowColor]];
    
    //图片
    self.iconImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    [self.bubbleBackgroundView addSubview:_iconImageView];
    
    [self.bubbleBackgroundView addSubview:self.textLabel];
    self.bubbleBackgroundView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self.bubbleBackgroundView addGestureRecognizer:longPress];
    
}

- (void)setDataModel:(RCMessageModel *)model {
    
    [super setDataModel:model];
    
    [self setAutoLayout];
}
- (void)setAutoLayout {
    RCTextMessage *_textMessage = (RCTextMessage *)self.model.content;
    if (_textMessage) {
        self.textLabel.text = _textMessage.content;
        
    } else {
        //DebugLog(@”[RongIMKit]: RCMessageModel.content is NOT RCTextMessage object”);
    }
    
    
    BOOL isImageText = NO;//是否是图文消息
    
    if (_textMessage.extra) {
        
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:_textMessage.extra] placeholderImage:DEFAULT_YIJIAYI];
        
        isImageText = YES;
    }
    
    // ios 7
    CGSize __textSize =
    [_textMessage.content boundingRectWithSize:CGSizeMake(self.baseContentView.bounds.size.width -
                                     (10 + [RCIM sharedRCIM].globalMessagePortraitSize.width + 10) * 2 - 5 -35,
                                     MAXFLOAT)
     options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |
     NSStringDrawingUsesFontLeading
     attributes:@{
                  NSFontAttributeName : [UIFont systemFontOfSize:Text_Message_Font_Size]
                  } context:nil]
    .size;
    __textSize = CGSizeMake(ceilf(__textSize.width), ceilf(__textSize.height));
    CGSize __labelSize = CGSizeMake(__textSize.width + 5, __textSize.height + 5);
    
    CGFloat __bubbleWidth = __labelSize.width + 15 + 20 < 50 ? 50 : (__labelSize.width + 15 + 20);
    CGFloat __bubbleHeight = __labelSize.height + 5 + 5 < 35 ? 35 : (__labelSize.height + 5 + 5);
    
    CGSize __bubbleSize = CGSizeMake(__bubbleWidth, __bubbleHeight);
    
    CGRect messageContentViewRect = self.messageContentView.frame;
    
    if (MessageDirection_RECEIVE == self.messageDirection) {
        messageContentViewRect.size.width = __bubbleSize.width;
        self.messageContentView.frame = messageContentViewRect;
        
        self.bubbleBackgroundView.frame = CGRectMake(0, 0, __bubbleSize.width, __bubbleSize.height);
        
        self.textLabel.frame = CGRectMake(20, 5, __labelSize.width, __labelSize.height);
        self.bubbleBackgroundView.image = [self imageNamed:@"chat_from_bg_normal" ofBundle:@"RongCloud.bundle"];
        UIImage *image = self.bubbleBackgroundView.image;
        self.bubbleBackgroundView.image = [self.bubbleBackgroundView.image
                                           resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.8,
                                                                                        image.size.height * 0.2, image.size.width * 0.2)];
    } else {
        
        
        if (isImageText) {
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, 50, 20)];
            label.text = @"我在看:";
            label.font = [UIFont boldSystemFontOfSize:14];
            label.textColor = [UIColor blackColor];
            [self.bubbleBackgroundView addSubview:label];
            
            self.iconImageView.frame = CGRectMake(15, label.bottom + 5, 80, 80);
            _iconImageView.backgroundColor = [UIColor orangeColor];
            
            messageContentViewRect.size.width = __bubbleSize.width;
            messageContentViewRect.origin.x =
            self.baseContentView.bounds.size.width -
            (messageContentViewRect.size.width + 10 + [RCIM sharedRCIM].globalMessagePortraitSize.width + 10);
            
            self.messageContentView.frame = messageContentViewRect;
            self.messageContentView.height = messageContentViewRect.size.height + 5 + 50;
            
            self.bubbleBackgroundView.frame = CGRectMake(0, 0, __bubbleSize.width, __bubbleSize.height + 5 + 50);
            
            self.textLabel.frame = CGRectMake(15, _iconImageView.bottom + 5, __labelSize.width, __labelSize.height);
            
            self.bubbleBackgroundView.image = [self imageNamed:@"chat_to_bg_normal" ofBundle:@"RongCloud.bundle"];
            UIImage *image = self.bubbleBackgroundView.image;
            self.bubbleBackgroundView.image = [self.bubbleBackgroundView.image
                                               resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.2,
                                                                                            image.size.height * 0.2, image.size.width * 0.8)];
            
            return;
        }
        
        messageContentViewRect.size.width = __bubbleSize.width;
        messageContentViewRect.origin.x =
        self.baseContentView.bounds.size.width -
        (messageContentViewRect.size.width + 10 + [RCIM sharedRCIM].globalMessagePortraitSize.width + 10);

        self.messageContentView.frame = messageContentViewRect;
        
        self.bubbleBackgroundView.frame = CGRectMake(0, 0, __bubbleSize.width, __bubbleSize.height);
        
        self.textLabel.frame = CGRectMake(15, _iconImageView.bottom + 5, __labelSize.width, __labelSize.height);
        
        self.bubbleBackgroundView.image = [self imageNamed:@"chat_to_bg_normal" ofBundle:@"RongCloud.bundle"];
        UIImage *image = self.bubbleBackgroundView.image;
        self.bubbleBackgroundView.image = [self.bubbleBackgroundView.image
                                           resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.2,
                                                                                        image.size.height * 0.2, image.size.width * 0.8)];
    }
    
}
- (UIImage *)imageNamed:(NSString *)name ofBundle:(NSString *)bundleName {
    UIImage *image = nil;
    NSString *image_name = [NSString stringWithFormat:@"%@.png", name];
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *bundlePath = [resourcePath stringByAppendingPathComponent:bundleName];
    NSString *image_path = [bundlePath stringByAppendingPathComponent:image_name];
    image = [[UIImage alloc] initWithContentsOfFile:image_path];
    
    return image;
}

- (void)longPressed:(id)sender {
    UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
    if (press.state == UIGestureRecognizerStateEnded) {
        //DebugLog(@”long press end”);
        return;
    } else if (press.state == UIGestureRecognizerStateBegan) {
        [self.delegate didLongTouchMessageCell:self.model inView:self.bubbleBackgroundView];
    }
}



@end
