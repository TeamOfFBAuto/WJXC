//
//  DBManager.h
//  WJXC
//
//  Created by lichaowei on 15/7/17.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMDatabase.h"

@class ProductModel;

@interface DBManager : NSObject
{
    FMDatabase *_dataBase;
}

+ (id)shareInstance;

//２.查询数据

-(NSArray *)QueryData;

//单品总个数

-(int)QueryAllDataNum;

//２.查询是否有未同步数据

-(BOOL)isExistUnsyncProduct;

//３.更新数据 数量

-(void)udpateProductId:(NSString *)productId
                   num:(int)num;
//４。插入数据 到购物车

-(void)insertProduct:(ProductModel *)aModel;

/**
 *  单品数量 +1 或者 -1
 *  @param num +1代表加 -1代表减
 */
- (void)increasProductId:(NSString *)productId
                   ByNum:(int)num;

/**
 *  清空表 自增列归为0
 */
-(void)deleteAll;

/**
 *  删除某一条数据
 */
-(void)deleteProductId:(NSString *)productId;

@end
