//
//  GMAPI.h
//  YiYiProject
//
//  Created by gaomeng on 14/12/13.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import <Foundation/Foundation.h>
//是否上传本地用户banner 头像
#define ISUPUSERBANNER @"gIsUpBanner"
#define ISUPUSERFACE @"gIsUpFace"

//代码屏幕适配（设计图为320*568）
#define GscreenRatio_320 DEVICE_WIDTH/320.00
//代码屏幕适配 (设计图为320*568)
#define GscreenRatio_568 DEVICE_HEIGHT/568.00


//首页缓存
#define GNEARSTORE @"gnearStore"
#define GNEARPINPAI @"gnearPinpai"
#define GTOPIMAGES @"gTopImages"

#import "BMapKit.h"


//from  wl
#import "SVProgressHUD.h"        //提示层

@protocol GgetllocationDelegate <NSObject>

@optional

- (void)theLocationDictionary:(NSDictionary *)dic;

- (void)theLocationFaild:(NSDictionary *)dic;


@end



@interface GMAPI : NSObject<BMKMapViewDelegate,BMKLocationServiceDelegate>
{
    BMKLocationService* _locService;//定位服务
//    NSDictionary *_theLocationDic;//经纬度
    
}

@property(nonatomic,strong)NSDictionary *theLocationDic;
@property(nonatomic,assign)id<GgetllocationDelegate> delegate;

+(NSString *)getUsername;


+(NSString *)getDeviceToken;

+(NSString *)getAuthkey;

+(NSString *)getUid;

+(NSString *)getUserPassWord;

+ (NSString *)getUerHeadImageUrl;//头像url

+ (AppDelegate *)appDeledate;


+(NSString *)changeDistanceWithStr:(NSString *)distance;


//写数据=========================

//保存用户banner到本地
+(BOOL)setUserBannerImageWithData:(NSData *)data;

//保存用户头像到本地
+(BOOL)setUserFaceImageWithData:(NSData *)data;



//获取document路径
//+ (NSString *)documentFolder;


//读数据=========================

//获取用户bannerImage
+(UIImage *)getUserBannerImage;

//获取用户头像Image
+(UIImage *)getUserFaceImage;


//获取document路径
+ (NSString *)getDocumentFolderPath;

//清除banner和头像
+(BOOL)cleanUserFaceAndBanner;

//在userdefaul里设置是否上传banner标志位为yes
+(void)setUpUserBannerYes;
//在userdefaul里设置是否上传banner标志位为no
+(void)setUpUserBannerNo;
//在userdefaul里设置是否上传头像标志位为yes
+(void)setUpUserFaceYes;
//在userdefaul里设置是否上传头像标志位为no
+(void)setUpUserFaceNo;



//NSUserDefault 缓存
//存
+ (void)cache:(id)dataInfo ForKey:(NSString *)key;
//取
+ (id)cacheForKey:(NSString *)key;


//提示浮层
+ (void)showAutoHiddenMBProgressWithText:(NSString *)text addToView:(UIView *)aView;
+ (MBProgressHUD *)showMBProgressWithText:(NSString *)text addToView:(UIView *)aView;
+ (void)showAutoHiddenQuicklyMBProgressWithText:(NSString *)text addToView:(UIView *)aView;
+ (void)showAutoHiddenMidleQuicklyMBProgressWithText:(NSString *)text addToView:(UIView *)aView;

//信息处理
+(NSString *)exchangeStringForDeleteNULL:(id)sender;



//地图相关

//获取单例
+ (GMAPI *)sharedManager;
//开启定位
-(void)startDingwei;


//地区选择相关
+ (int)cityIdForName:(NSString *)cityName;



#pragma mark ---------------------提示层
/**
 *  显示正在加载提示层
 */
+(void)showProgressHasMask:(BOOL)ismask;

/**
 *  隐藏提示层
 */
+(void)hiddenProgress;

/**
 *  显示加载动画和提示语
 */
+(void)showProgressWithText:(NSString *)string hasMask:(BOOL)ismask;

/**
 *  显示提示语
 */
+(void)showProgressText:(NSString *)string hasMask:(BOOL)ismask;

/**
 *  显示成功提示语
 */
+(void)showSuccessProgessWithText:(NSString *)string hasMask:(BOOL)ismask;

/**
 *  显示失败提示语
 */
+(void)showFailProgessWithText:(NSString *)string hasMask:(BOOL)ismask;

/**
 *  显示自定义提示层
 *
 *  @image 图片  string 提示语
 */
+(void)showCustomProgessWithImage:(UIImage *)image andText:(NSString *)string hasMask:(BOOL)ismask;



//时间戳相关
+(NSString*)getTimeWithDate:(NSDate*)theDate;
+(NSString *)timechangeAll:(NSString *)placetime;
+(NSString *)timechangeAll1:(NSString *)placetime;
+(NSString*)getTimeWithDate1:(NSDate*)theDate;
+(NSString *)timechangeAll2:(NSString *)placetime;


//首页缓存
//存
+(void)setHomeClothCacheOfNearStoreWithDic:(NSDictionary*)data;//附近的商家
+(void)setHomeClothCacheOfNearPinpai:(NSDictionary *)data;//附近的品牌
+(void)setHomeClothCacheOfTopImage:(NSDictionary *)data;//广告图
//取
+(NSDictionary*)getHomeClothCacheOfNearStore;//商家
+(NSDictionary*)getHomeClothCacheOfNearPinpai;//品牌
+(NSDictionary*)getHomeClothCacheOfTopimage;//广告图
//清理
+(void)cleanHomeClothCacheOfNearStore;//清理首页缓存

//清除缓存
+(void)cleanUserDefaulWithHomeCloth;



@end
