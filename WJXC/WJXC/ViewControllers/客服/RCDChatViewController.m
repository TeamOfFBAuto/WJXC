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
    
    
    UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UILabel *_myTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,100,44)];
    _myTitleLabel.textAlignment = NSTextAlignmentCenter;
    _myTitleLabel.text = self.userName;
    _myTitleLabel.textColor = DEFAULT_TEXTCOLOR;
    _myTitleLabel.font = [UIFont systemFontOfSize:17];
    self.navigationItem.titleView = _myTitleLabel;
    
    UIButton *_my_right_button = [UIButton buttonWithType:UIButtonTypeCustom];
    _my_right_button.frame = CGRectMake(0,0,60,44);
    _my_right_button.titleLabel.textAlignment = NSTextAlignmentRight;
    [_my_right_button setTitle:@"设置" forState:UIControlStateNormal];
    [_my_right_button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    _my_right_button.titleLabel.font = [UIFont systemFontOfSize:15];
    
    [_my_right_button setTitleColor:DEFAULT_TEXTCOLOR forState:UIControlStateNormal];
    
    [_my_right_button addTarget:self action:@selector(rightBarButtonItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItems = @[spaceButton,[[UIBarButtonItem alloc] initWithCustomView:_my_right_button]];
    
    
    //会话页面注册 UI
    [self registerClass:SimpleMessageCell.class forCellWithReuseIdentifier:@"SimpleMessageCell"];
    
    
//    NSString *url = @"http://pic.nipic.com/2007-11-09/2007119122519868_2.jpg";
//    RCImageMessage *msg = [[RCImageMessage alloc]init];
//    msg.imageUrl = url;
//    msg.extra = @"澳洲龙虾a 阿娇是看得见卡数据库了";
//    
//    [self sendImageMessage:msg pushContent:@"小龙虾"];
    
//    SimpleMessage *msg = [[SimpleMessage alloc]init];
//    msg.content = @"哈哈哈";
//    [self sendMessage:msg pushContent:@"hah:123456678"];
    
    
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


//发送产品图文链接

//-(void)sendProductDetailMessage{
//    
//    NSString *url = @"http://pic.nipic.com/2007-11-09/2007119122519868_2.jpg";
//
//    RCRichContentMessage *message = [[RCRichContentMessage alloc] init];
//    message.title = @"购买大龙虾";
//    message.digest = @"skdaksjdklajsdkl";
//    message.imageURL = url;
//    
//    message.extra = @"订单编号:12345678";
//
//    /**
//     *  发送图片消息，上传图片并且发送，使用该方法，默认原图会上传到融云的服务，并且发送消息,如果使用普通的sendMessage方法，
//     *  需要自己实现上传图片，并且添加ImageMessage的URL之后发送
//     *
//     *  @param conversationType 会话类型。
//     *  @param targetId         目标 Id。根据不同的 conversationType，可能是聊天 Id、讨论组 Id、群组 Id 或聊天室 Id。
//     *  @param content          消息内容
//     *  @param pushContent      推送消息内容
//     *  @param progressBlock    进度块
//     *  @param successBlock     成功处理块
//     *  @param errorBlock       失败处理块
//     *
//     *  @return 发送的消息实体。
//     */
//    
////    @property(nonatomic, strong) NSString *extra;
////    /** 缩略图 */
////    @property(nonatomic, strong) UIImage *thumbnailImage;
////    /** 实际图片URL */
////    @property(nonatomic, strong) NSString *imageUrl;
////    /** 原始图 */
////    @property(nonatomic, strong) UIImage *originalImage;
//    
//    RCImageMessage *imageMsg = [RCImageMessage messageWithImage:[UIImage imageNamed:@"default"]];
//    imageMsg.extra = @"发送给客服的消息";
//    
//    [[RCIMClient sharedRCIMClient]sendImageMessage:ConversationType_CUSTOMERSERVICE targetId:SERVICE_ID content:imageMsg pushContent:@"哈哈" progress:^(int progress, long messageId) {
//        
//        NSLog(@"---progress%d",progress);
//        
//    } success:^(long messageId) {
//        
//        NSLog(@"---messageId%ld",messageId);
//        
//    } error:^(RCErrorCode errorCode, long messageId) {
//        
//        NSLog(@"---errorCode%ld",errorCode);
//
//    }];
//
//}


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

@end
