//
//  SimpleMessage.m
//  WJXC
//
//  Created by lichaowei on 15/8/4.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "SimpleMessage.h"
#import <RongIMLib/RCUtilities.h>
#import <RongIMLib/RCJSONConverter.h>

@implementation SimpleMessage

+(instancetype)messageWithContent:(NSString *)content {
    SimpleMessage *msg = [[SimpleMessage alloc] init];
    if (msg) {
        msg.content = content;
    }
    
    return msg;
}

+(RCMessagePersistent)persistentFlag {
    return (MessagePersistent_ISPERSISTED | MessagePersistent_ISCOUNTED);
}

#pragma mark – NSCoding protocol methods
#define KEY_TXTMSG_CONTENT @"content"
#define KEY_TXTMSG_EXTRA @"extra"

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.content = [aDecoder decodeObjectForKey:KEY_TXTMSG_CONTENT];
        self.extra = [aDecoder decodeObjectForKey:KEY_TXTMSG_EXTRA]; }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.content forKey:KEY_TXTMSG_CONTENT];
    [aCoder encodeObject:self.extra forKey:KEY_TXTMSG_EXTRA];
    
}

#pragma mark – RCMessageCoding delegate methods

-(NSData *)encode {
    
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    [dataDict setObject:self.content forKey:@"content"];
    if (self.extra) {
        [dataDict setObject:self.extra forKey:@"extra"];
    }
    
    if (self.senderUserInfo) {
        NSMutableDictionary *__dic=[[NSMutableDictionary alloc]init];
        if (self.senderUserInfo.name) {
            [__dic setObject:self.senderUserInfo.name forKeyedSubscript:@"name"];
        }
        if (self.senderUserInfo.portraitUri) {
            [__dic setObject:self.senderUserInfo.portraitUri forKeyedSubscript:@"icon"];
        }
        if (self.senderUserInfo.userId) {
            [__dic setObject:self.senderUserInfo.userId forKeyedSubscript:@"id"];
        }
        [dataDict setObject:__dic forKey:@"user"];
    }
    
    //NSDictionary* dataDict = [NSDictionary dictionaryWithObjectsAndKeys:self.content, @"content", nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict
                                                   options:kNilOptions
                                                     error:nil];
    return data;
}

-(void)decodeWithData:(NSData *)data {
#if 1
    __autoreleasing NSError* __error = nil;
    if (!data) {
        return;
    }
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:kNilOptions
                                                           error:&__error];
#else
    NSString *jsonStream = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *json = [RCJSONConverter dictionaryWithJSONString:jsonStream];
#endif
    if (json) {
        self.content = json[@"content"];
        self.extra = json[@"extra"];
        NSObject *__object = [json objectForKey:@"user"];
        NSDictionary *userinfoDic = nil;
        if (__object &&[__object isMemberOfClass:[NSDictionary class]]) {
            userinfoDic =__object;
        }
        if (userinfoDic) {
            RCUserInfo *userinfo =[RCUserInfo new];
            userinfo.userId = [userinfoDic objectForKey:@"id"];
            userinfo.name =[userinfoDic objectForKey:@"name"];
            userinfo.name =[userinfoDic objectForKey:@"icon"];
            self.senderUserInfo = userinfo;
        }
        
    }
}
- (NSString *)conversationDigest
{
    return @"会话列表要显示的内容";
}
+(NSString *)getObjectName {
    return @"xxxx";
}
#if ! __has_feature(objc_arc)
-(void)dealloc
{
    [super dealloc];
}
#endif//__has_feature(objc_arc)


@end
