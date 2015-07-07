//
//  UserInfo.m
//  YiYiProject
//
//  Created by lichaowei on 14/12/13.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import "UserInfo.h"
#import <objc/runtime.h>

@implementation UserInfo

/**
 *  编码
 *
 *  @param coder
 */
- (void)encodeWithCoder:(NSCoder *)coder
{
    //    [super encodeWithCoder:coder];
    unsigned int num = 0;
    Ivar *ivars = class_copyIvarList([self class], &num);
    
    for (int i = 0; i < num; i ++) {
        
        //取出i位置成员变量
        Ivar ivar = ivars[i];
        
        //查看成员变量
        const char *name = ivar_getName(ivar);
        
        //归档
        
        NSString *key = [NSString stringWithUTF8String:name];
        
//        NSLog(@"归档 key %@",key);
        
        id value = [self valueForKey:key];
        
        [coder encodeObject:value forKey:key];
    }
    free(ivars);
    
}

/**
 *  解码
 *
 *  @param coder
 *
 *  @return
 */
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        unsigned int num = 0;
        Ivar *ivars = class_copyIvarList([self class], &num);
        
        for (int i = 0; i < num; i ++) {
            
            Ivar ivar = ivars[i];
            
            const char *name = ivar_getName(ivar);
            
            NSString *key = [NSString stringWithUTF8String:name];
            
            //解档
            
            id value = [coder decodeObjectForKey:key];
            
            if (value == nil ||[value isKindOfClass:[NSNull class]]) {
                value = @"";
            }
            
            [self setValue:value forKey:key];
        }
    }
    return self;
}

/**
 *  归档的方式存model对象 重写了编码解码方法
 *
 *  @param aModel
 *  @param modelKey
 */
- (void)cacheForKey:(NSString *)modelKey
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    [userDefaults setObject:data forKey:modelKey];
    [userDefaults synchronize];
}

/**
 *  获取存在本地的model
 *
 *  @param modelKey key
 *
 *  @return
 */
+ (id)cacheResultForKey:(NSString *)modelKey
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [userDefaults objectForKey:modelKey];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}


@end
