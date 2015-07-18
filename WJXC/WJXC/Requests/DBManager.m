//
//  DBManager.m
//  WJXC
//
//  Created by lichaowei on 15/7/17.
//  Copyright (c) 2015年 lcw. All rights reserved.
//

#import "DBManager.h"
#import "ProductModel.h"

@implementation DBManager

+ (id)shareInstance
{
    static dispatch_once_t once_t;
    static DBManager *manager = nil;
    dispatch_once(&once_t, ^{
        
        manager = [[DBManager alloc]init];
        
    });
    return manager;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        
        _dataBase = [[FMDatabase alloc]initWithPath:[self getPath]];
        
        if (![_dataBase open])
        {
            NSLog(@"OPEN FAIL");

        }
        //创建 ShoppingCar表
        
        [_dataBase executeUpdate:@"CREATE TABLE IF NOT EXISTS ShoppingCar(uid text,product_name text,product_id int,product_num int,current_price text,add_time text,cover_pic text)"];
        
        [_dataBase close];
    }
    return self;
}

/**
 *  获取数据库路径
 *
 *  @return
 */
-(NSString *)getPath
{
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];//获取document路径
    NSString *filePath = [documents stringByAppendingPathComponent:@"WJXC.sqlite"]; //将要存放位置
    NSLog(@"数据库路径 = %@",filePath);
    NSString *bundlePath = [[NSBundle mainBundle]pathForResource:@"WJXC" ofType:@"sqlite"];//bundle中位置
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:filePath]) {
        [fm copyItemAtPath:bundlePath toPath:filePath error:nil]; //拷贝数据文件到document下
    }
    return filePath;
}


//２.查询是否有未同步数据

-(BOOL)isExistUnsyncProduct
{
    if ([_dataBase open]) {
        
        FMResultSet *rs = [_dataBase executeQuery:@"SELECT count(*) FROM ShoppingCar where product_id != 0"];
        
        while ([rs next]){
            
            int num = [rs intForColumnIndex:0];
            
            NSLog(@"有未同步数据 existNum: %d",num);
            
            if (num > 0) {
                
                [rs close];
                
                [_dataBase close];
                
                return YES;
            }
        }
        
    }
    NSLog(@"没有未同步数据");
    
    return NO;
}



-(NSArray *)QueryData
{
    //获取数据
    NSMutableArray *recordArray = [[NSMutableArray  alloc]init];
    
    if ([_dataBase open]) {
        
        FMResultSet *rs = [_dataBase executeQuery:@"SELECT * FROM ShoppingCar"];
        
        while ([rs next]){
            
            //cart_pro_id int,uid text,product_name text,product_id int,product_num int,current_price text,add_time text
            
            ProductModel *OneRecord = [[ProductModel alloc]init];
            
            OneRecord.uid = [rs stringForColumn:@"uid"];
            
            OneRecord.product_name = [rs stringForColumn:@"product_name"];
            
            OneRecord.product_id = [NSString stringWithFormat:@"%d",[rs intForColumn:@"product_id"]];
            
            OneRecord.product_num = [NSString stringWithFormat:@"%d",[rs intForColumn:@"product_num"]];
            
            OneRecord.current_price = [rs stringForColumn:@"current_price"];
            
            OneRecord.cover_pic = [rs stringForColumn:@"cover_pic"];
            
            [recordArray addObject: OneRecord];
            
        }
        
        [rs close];
        
        [_dataBase close];
        
    }
    return recordArray;
}


//３.更新数据 数量

-(void)udpateProductId:(NSString *)productId
                   num:(int)num
{
    
    if ([_dataBase open]) {
        
        [_dataBase beginTransaction];
        
        [_dataBase executeUpdate:@"UPDATE ShoppingCar SET product_num = ? WHERE product_id = ?",[NSNumber numberWithInt:num],[NSNumber numberWithInt:[productId intValue]]];

        [_dataBase commit];
        
        [_dataBase close];
    }
}


//４。插入数据 到购物车

-(void)insertProduct:(ProductModel *)aModel
{
    //插入数据库
    
    if ([_dataBase open]) {
        
        [_dataBase beginTransaction];
       
        //cart_pro_id int,uid text,product_name text,product_id int,product_num int,current_price text,add_time text
        
        NSString *uid = aModel.uid ? : @"";
        NSString *name = aModel.product_name ? : @"";
        NSString *productId = aModel.product_id ? : @"0";
        NSString *addTime = aModel.add_time ? : @"";
//        NSString *num = aModel.product_num ? : @"0";
        NSString *price = aModel.current_price ? : @"0";
        NSString *cover_pic = aModel.cover_pic ? : @"";
        
        
        FMResultSet *rs = [_dataBase executeQuery:@"SELECT count(*) FROM ShoppingCar where product_id = ?",productId];
        
        int num = 0;
        while ([rs next]){
            
            num = [rs intForColumnIndex:0];
            
            NSLog(@"productId %@ existNum: %d",productId,num);

        }
        
        //存在的话 +1 否则 插入新数据
        if (num > 0) {
            
            [_dataBase executeUpdate:@"update ShoppingCar set product_num = product_num + 1 where product_id = ?",[NSNumber numberWithInt:[productId intValue]]];
        }else
        {
            [_dataBase executeUpdate:@"insert into ShoppingCar (uid,product_name,product_id,current_price,add_time,cover_pic,product_num) values (?,?,?,?,?,?,?)",uid,name,[NSNumber numberWithInt:[productId intValue]],price,addTime,cover_pic,[NSNumber numberWithInt:1]];
        }
        
        [_dataBase commit];
        [_dataBase close];
    }
    
}

/**
 *  单品数量 +1 或者 -1
 *  @param num +1代表加 -1代表减
 */
- (void)increasProductId:(NSString *)productId
                   ByNum:(int)num
{
    //插入数据库
    
    if ([_dataBase open]) {
        
        [_dataBase beginTransaction];
        
        if (num > 0) {
           [_dataBase executeUpdate:@"update ShoppingCar set product_num = product_num + 1 where product_id = ?",[NSNumber numberWithInt:[productId intValue]]];
        }else
        {
            [_dataBase executeUpdate:@"update ShoppingCar set product_num = product_num - 1 where product_id = ? and product_num > 0",[NSNumber numberWithInt:[productId intValue]]];
        }
        
        [_dataBase commit];
        [_dataBase close];
    }
}

/**
 *  清空表 自增列归为0
 */
-(void)deleteAll
{
    //插入数据库
    
    if ([_dataBase open]) {
        
        [_dataBase beginTransaction];
        
        [_dataBase executeUpdate:@"DELETE FROM ShoppingCar"];
        
        [_dataBase executeUpdate:@"UPDATE sqlite_sequence set seq = 0 where name = 'ShoppingCar'"];
        
        [_dataBase commit];
        [_dataBase close];
    }
    
}

/**
 *  删除某一条数据
 */
-(void)deleteProductId:(NSString *)productId
{
    //插入数据库
    
    if ([_dataBase open]) {
        
        [_dataBase beginTransaction];
        
        [_dataBase executeUpdate:@"delete from ShoppingCar where product_id = ?",[NSNumber numberWithInt:[productId intValue]]];
        
        [_dataBase commit];
        [_dataBase close];
    }
    
}

@end
