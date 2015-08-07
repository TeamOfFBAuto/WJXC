//
//  RCDChatViewController.m
//  RCloudMessage
//
//  Created by Liv on 15/3/13.
//  Copyright (c) 2015年 胡利武. All rights reserved.
//

#import "RCDChatViewController.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDChatViewController.h"

#import "ProductDetailViewController.h"
#import "SimpleMessageCell.h"
#import "SimpleMessage.h"

@interface RCDChatViewController ()

@end

@implementation RCDChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
    if([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] )
    {
        //iOS 5 new UINavigationBar custom background
        
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:IOS7_OR_LATER?IOS7DAOHANGLANBEIJING_PUSH:IOS6DAOHANGLANBEIJING] forBarMetrics: UIBarMetricsDefault];
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];

   
//    NSString *__string = @"返回";
//    
//    
//    int unreadMsgCount = [[RCIMClient sharedRCIMClient]getUnreadCount: @[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION), @(ConversationType_APPSERVICE), @(ConversationType_PUBLICSERVICE),@(ConversationType_GROUP)]];
//    if (0 < unreadMsgCount) {
//        __string = [NSString  stringWithFormat:@"返回(%d)",unreadMsgCount];
//    }
    
    UIBarButtonItem * spaceButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButton1.width = IOS7_OR_LATER ? -10 : 5;
    
    UIButton *button_back=[[UIButton alloc]initWithFrame:CGRectMake(0,8,40,44)];
    [button_back addTarget:self action:@selector(leftBarButtonItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button_back setImage:BACK_DEFAULT_IMAGE forState:UIControlStateNormal];
    //        button_back.backgroundColor = [UIColor orangeColor];
    [button_back setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    UIBarButtonItem *back_item=[[UIBarButtonItem alloc]initWithCustomView:button_back];
    self.navigationItem.leftBarButtonItems=@[spaceButton1,back_item];
    
    
//    UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UILabel *_myTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,100,44)];
    _myTitleLabel.textAlignment = NSTextAlignmentCenter;
    _myTitleLabel.text = self.userName;
    _myTitleLabel.textColor = DEFAULT_TEXTCOLOR;
    _myTitleLabel.font = [UIFont systemFontOfSize:17];
    self.navigationItem.titleView = _myTitleLabel;
    
//    UIButton *_my_right_button = [UIButton buttonWithType:UIButtonTypeCustom];
//    _my_right_button.frame = CGRectMake(0,0,60,44);
//    _my_right_button.titleLabel.textAlignment = NSTextAlignmentRight;
//    [_my_right_button setTitle:@"设置" forState:UIControlStateNormal];
//    [_my_right_button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
//    _my_right_button.titleLabel.font = [UIFont systemFontOfSize:15];
//    
//    [_my_right_button setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
//    
//    [_my_right_button addTarget:self action:@selector(rightBarButtonItemClicked:) forControlEvents:UIControlEventTouchUpInside];
//    
//    self.navigationItem.rightBarButtonItems = @[spaceButton,[[UIBarButtonItem alloc] initWithCustomView:_my_right_button]];
    
    //会话页面注册 UI
    [self registerClass:SimpleMessageCell.class forCellWithReuseIdentifier:@"SimpleMessageCell"];
    
}

#pragma - mark 自定义消息重写方法

-(RCMessageBaseCell *)rcConversationCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RCMessageModel *model = self.conversationDataRepository[indexPath.row];
    NSString * cellIndentifier=@"SimpleMessageCell";
    RCMessageBaseCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIndentifier           forIndexPath:indexPath];
    [cell setDataModel:model];
    return cell;
}
-(CGSize)rcConversationCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //返回自定义cell的实际高度
    return CGSizeMake(300, 60 + 5 + 50);
}

-(void) leftBarButtonItemPressed:(id)sender
{
    //需要调用super的实现
    [super leftBarButtonItemPressed:sender];
    
    [self.navigationController popViewControllerAnimated:YES];
}


/**
 *  此处使用自定义设置，开发者可以根据需求自己实现
 *  不添加rightBarButtonItemClicked事件，则使用默认实现。
 */
-(void) rightBarButtonItemClicked:(id) sender
{
    //客服设置
    if(self.conversationType == ConversationType_CUSTOMERSERVICE){
        RCSettingViewController *settingVC = [[RCSettingViewController alloc] init];
        settingVC.conversationType = self.conversationType;
        settingVC.targetId = self.targetId;
        //清除聊天记录之后reload data
        __weak RCDChatViewController *weakSelf = self;
        settingVC.clearHistoryCompletion = ^(BOOL isSuccess)
        {
            if (isSuccess) {
                [weakSelf.conversationDataRepository removeAllObjects];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.conversationMessageCollectionView reloadData];
                });
            }
        };
        [self.navigationController pushViewController:settingVC animated:YES];
    }
    
}


/**
 *  更新左上角未读消息数
 */
-(void)notifyUpdateUnReadMessageCount
{
    __weak typeof(&*self) __weakself = self;
    int count = [[RCIMClient sharedRCIMClient]getUnreadCount: @[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION), @(ConversationType_APPSERVICE), @(ConversationType_PUBLICSERVICE),@(ConversationType_GROUP)]];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (count > 0) {
            [__weakself.navigationItem.leftBarButtonItem setTitle:[NSString stringWithFormat:@"返回(%d)",count]];
        }else
        {
            [__weakself.navigationItem.leftBarButtonItem setTitle:@"返回"];
        }
    });
}

/**
 *  点击消息内容中的链接，此事件不会再触发didTapMessageCell
 *
 *  @param url   Url String
 *  @param model 数据
 */
- (void)didTapUrlInMessageCell:(NSString *)url model:(RCMessageModel *)model
{
    RCRichContentMessage *msg = (RCRichContentMessage *)model.content;
    
    NSLog(@"model %@",msg.extra);

    NSMutableString *string = [NSMutableString stringWithString:msg.extra];
    [string replaceOccurrencesOfString:@"productId:" withString:@"" options:0 range:NSMakeRange(0, string.length)];
    NSString *productId = string;
    if (productId.length) {
        
        ProductDetailViewController *cc = [[ProductDetailViewController alloc]init];
        cc.product_id = productId;
        cc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:cc animated:YES];
    }else
    {
        NSLog(@"单品id有误");
    }
}

/**
 *  点击消息内容中的电话号码，此事件不会再触发didTapMessageCell
 *
 *  @param phoneNumber Phone number
 *  @param model       数据
 */
- (void)didTapPhoneNumberInMessageCell:(NSString *)phoneNumber model:(RCMessageModel *)model
{
    
}

@end
