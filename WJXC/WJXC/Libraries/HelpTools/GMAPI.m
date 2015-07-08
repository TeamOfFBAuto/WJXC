//
//  GMAPI.m
//  YiYiProject
//
//  Created by gaomeng on 14/12/13.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import "GMAPI.h"
#import "DataBase.h"
#import "FBCity.h"
#import "AppDelegate.h"
#import <math.h>
//RBG color
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define HUDBACKGOUNDCOLOR  RGBA(0, 0, 0, 0.6)
#define HUDFOREGROUNDCOLOR  RGBA(255, 255, 255, 1)
@implementation GMAPI


+ (AppDelegate *)appDeledate
{
    AppDelegate *aa = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return aa;
}


//获取用户的devicetoken

+(NSString *)getDeviceToken{
    
    NSString *str_devicetoken=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:USER_DEVICE_TOKEN]];
    return str_devicetoken;
    
    
}

//获取用户名
+(NSString *)getUsername{
    
    NSString *str_devicetoken=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:USER_NAME]];
    if ([str_devicetoken isEqualToString:@"(null)"]) {
        str_devicetoken=@"";
    }
    return str_devicetoken;
    
    
}

//获取authkey
+(NSString *)getAuthkey{
    
    NSString *str_authkey=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:USER_AUTHOD]];

    
    

    
    if (str_authkey.length == 0 || [str_authkey isEqualToString:@"(null)"]) {
        return @"";
    }
    return str_authkey;
    
}


//获取用户id
+(NSString *)getUid{
    
    NSString *str_uid=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:USER_UID]];
    return str_uid;
    
}


//获取用户密码
+(NSString *)getUserPassWord{
    NSString *str_password = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:USER_PWD]];
    return str_password;
}

//头像url
+ (NSString *)getUerHeadImageUrl
{
    NSString *url = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:USER_HEAD_IMAGEURL]];
    return url;
}


//距离转化 大于1000m 显示1km
+(NSString *)changeDistanceWithStr:(NSString *)distance{
    NSString *newDistance;
    CGFloat distance_f = [distance floatValue];
    
    if (distance_f >= 1000) {
        newDistance = [NSString stringWithFormat:@"%.1fkm",distance_f*0.001];
    }else{
        newDistance = [NSString stringWithFormat:@"%.1fm",distance_f];
    }
    
    return newDistance;
    
}

//把用户bannerImage写到本地
+(BOOL)setUserBannerImageWithData:(NSData *)data{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pathD = paths[0];
    
    NSString *userBannerName = @"/guserBannerImage.png";
    
    NSString *path = [pathD stringByAppendingString:userBannerName];
    
    NSLog(@"%@",path);
    
    
    BOOL is = [data writeToFile:path atomically:YES];
    
    NSLog(@"%d",is);
    
    if (is) {
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"chagePersonalInformation" object:nil];
        
    }
    
    return is;
}

//把用户头像image写到本地
+(BOOL)setUserFaceImageWithData:(NSData *)data{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pathD = paths[0];
    
    NSString *userFaceName = @"/guserFaceImage.png";
    
    NSString *path = [pathD stringByAppendingString:userFaceName];
    
    NSLog(@"%@",path);
    
    BOOL is = [data writeToFile:path atomically:YES];
    NSLog(@"%d",is);
    
    if (is) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"chagePersonalInformation" object:nil];
    }
    
    
    return is;
}

//读数据=============================================


//获取banner
+(UIImage *)getUserBannerImage{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pathD = paths[0];
    NSString *userBannerName = @"/guserBannerImage.png";
    NSString *path = [pathD stringByAppendingString:userBannerName];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return image;
}

//获取faceImage
+(UIImage *)getUserFaceImage{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pathD = paths[0];
    NSString *userFaceName = @"/guserFaceImage.png";
    NSString *path = [pathD stringByAppendingString:userFaceName];
    
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return image;
}



+(BOOL)cleanUserFaceAndBanner{
    //上传标志位
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"gIsUpBanner"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"gIsUpFace"];
    
    
    
    //document路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pathD = paths[0];
    NSString *documentPathStr =pathD;
    NSString *userFace = @"/guserFaceImage.png";
    NSString *userBanner = @"/guserBannerImage.png";
    
    
    //文件管理器
    NSFileManager *fileM = [NSFileManager defaultManager];
    
    //清除 头像和 banner
    
    BOOL isCleanUserFaceSuccess = NO;
    BOOL isCleanUserBannerSuccess = NO;
    BOOL isSuccess = NO;
    isCleanUserFaceSuccess = [fileM removeItemAtPath:[documentPathStr stringByAppendingString:userFace] error:nil];
    isCleanUserBannerSuccess = [fileM removeItemAtPath:[documentPathStr stringByAppendingString:userBanner] error:nil];
    if (isCleanUserFaceSuccess && isCleanUserBannerSuccess) {
        isSuccess = YES;
    }
    
    return isSuccess;
}


+ (NSString *)getDocumentFolderPath{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
}


+(void)setUpUserBannerYes{
    NSString *str = @"yes";
    [[NSUserDefaults standardUserDefaults]setObject:str forKey:ISUPUSERBANNER];
}

+(void)setUpUserBannerNo{
    NSString *str = @"no";
    [[NSUserDefaults standardUserDefaults]setObject:str forKey:ISUPUSERBANNER];
}

+(void)setUpUserFaceYes{
    NSString *str = @"yes";
    [[NSUserDefaults standardUserDefaults]setObject:str forKey:ISUPUSERFACE];
}
+(void)setUpUserFaceNo{
    NSString *str = @"no";
    [[NSUserDefaults standardUserDefaults]setObject:str forKey:ISUPUSERFACE];
}


#pragma mark - NSUserDefault缓存
//存
+ (void)cache:(id)dataInfo ForKey:(NSString *)key
{
    NSLog(@"key===%@",key);
    @try {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:dataInfo forKey:key];
        [defaults synchronize];
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@",exception);
    }
    @finally {
    }
}

//取
+ (id)cacheForKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}








//信息处理
+(NSString *)exchangeStringForDeleteNULL:(id)sender
{
    NSString * temp = [NSString stringWithFormat:@"%@",sender];
    
    if (temp.length == 0 || [temp isEqualToString:@"<null>"] || [temp isEqualToString:@"null"] || [temp isEqualToString:@"(null)"])
    {
        temp = @"暂无";
    }
    
    return temp;
}


//地图相关

+ (GMAPI *)sharedManager
{
    static GMAPI *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    return sharedAccountManagerInstance;
}

//开启定位
-(void)startDingwei{
    
    
    __weak typeof(self)weakSelf = self;
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
        
        NSLog(@"请打开您的位置服务!");
        
    }
    
    [weakSelf startLocation];
    
}


///开始定位
-(void)startLocation{
    
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    [_locService startUserLocationService];
}

///停止定位
-(void)stopLocation{
    
    
    [_locService stopUserLocationService];
    if (_locService) {
        _locService = nil;
    }
}

//用户位置更新后，会调用此函数

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    if (userLocation) {
        self.theLocationDic = @{
                            @"lat":[NSString stringWithFormat:@"%f",userLocation.location.coordinate.latitude],
                            @"long":[NSString stringWithFormat:@"%f",userLocation.location.coordinate.longitude]
                            };
        
        
        [self stopLocation];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(theLocationDictionary:)]) {
            [self.delegate theLocationDictionary:self.theLocationDic];
        }
        
        
    }
}



- (void)didFailToLocateUserWithError:(NSError *)error{
    //金领时代 40.041951,116.33934
    //天安门 39.915187,116.403877
    if (self.delegate && [self.delegate respondsToSelector:@selector(theLocationDictionary:)]) {
        self.theLocationDic = @{
                            @"lat":[NSString stringWithFormat:@"%f",40.041951],
                            @"long":[NSString stringWithFormat:@"%f",116.33934]
                            };
        [self.delegate theLocationFaild:self.theLocationDic];
    }
}



+ (void)showAutoHiddenMBProgressWithText:(NSString *)text addToView:(UIView *)aView
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:aView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    hud.margin = 12.f;
    hud.yOffset = 0.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.5];
}

+ (void)showAutoHiddenMBProgressWithTextTwoline:(NSString *)text addToView:(UIView *)aView
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:aView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    hud.margin = 15.f;
    hud.yOffset = 0.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.5];
}



+ (void)showAutoHiddenQuicklyMBProgressWithText:(NSString *)text addToView:(UIView *)aView
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:aView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    hud.margin = 15.f;
    hud.yOffset = 0.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:0.3];
}

+ (void)showAutoHiddenMidleQuicklyMBProgressWithText:(NSString *)text addToView:(UIView *)aView
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:aView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    hud.margin = 15.f;
    hud.yOffset = 0.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:0.7];
}


+ (MBProgressHUD *)showMBProgressWithText:(NSString *)text addToView:(UIView *)aView
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:aView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    hud.margin = 15.f;
    hud.yOffset = 0.0f;
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}





#pragma mark--------------------------------提示层

#pragma mark - HUD Metod  提示层

+(void)showProgressHasMask:(BOOL)ismask
{
    [SVProgressHUD setBackgroundColor:HUDBACKGOUNDCOLOR];
    [SVProgressHUD setForegroundColor:HUDFOREGROUNDCOLOR];
    [SVProgressHUD setDefaultMaskType:(ismask==YES?SVProgressHUDMaskTypeClear:SVProgressHUDMaskTypeNone)];
    [SVProgressHUD show];
}

+(void)showProgressWithText:(NSString *)string hasMask:(BOOL)ismask
{
    [SVProgressHUD setBackgroundColor:HUDBACKGOUNDCOLOR];
    [SVProgressHUD setForegroundColor:HUDFOREGROUNDCOLOR];
    [SVProgressHUD setDefaultMaskType:(ismask==YES?SVProgressHUDMaskTypeClear:SVProgressHUDMaskTypeNone)];
    [SVProgressHUD showWithStatus:string];
}

+(void)showProgressText:(NSString *)string hasMask:(BOOL)ismask
{
    [SVProgressHUD setBackgroundColor:HUDBACKGOUNDCOLOR];
    [SVProgressHUD setForegroundColor:HUDFOREGROUNDCOLOR];
    [SVProgressHUD setDefaultMaskType:(ismask==YES?SVProgressHUDMaskTypeClear:SVProgressHUDMaskTypeNone)];
    [SVProgressHUD showImage:nil status:string];
}

+(void)showSuccessProgessWithText:(NSString *)string hasMask:(BOOL)ismask
{
    [SVProgressHUD setBackgroundColor:HUDBACKGOUNDCOLOR];
    [SVProgressHUD setForegroundColor:HUDFOREGROUNDCOLOR];
    [SVProgressHUD setDefaultMaskType:(ismask==YES?SVProgressHUDMaskTypeClear:SVProgressHUDMaskTypeNone)];
    [SVProgressHUD showSuccessWithStatus:string];
}

+(void)showFailProgessWithText:(NSString *)string hasMask:(BOOL)ismask
{
    [SVProgressHUD setBackgroundColor:HUDBACKGOUNDCOLOR];
    [SVProgressHUD setForegroundColor:HUDFOREGROUNDCOLOR];
    [SVProgressHUD setDefaultMaskType:(ismask==YES?SVProgressHUDMaskTypeClear:SVProgressHUDMaskTypeNone)];
    [SVProgressHUD showErrorWithStatus:string];
}

+(void)showCustomProgessWithImage:(UIImage *)image andText:(NSString *)string hasMask:(BOOL)ismask
{
    [SVProgressHUD setBackgroundColor:HUDBACKGOUNDCOLOR];
    [SVProgressHUD setForegroundColor:HUDFOREGROUNDCOLOR];
    [SVProgressHUD setDefaultMaskType:(ismask==YES?SVProgressHUDMaskTypeClear:SVProgressHUDMaskTypeNone)];
    [SVProgressHUD showImage:image status:string];
}

+(void)hiddenProgress
{
    [SVProgressHUD dismiss];
}
//地区相关
+ (NSArray *)getSubCityWithProvinceId:(int)privinceId
{
    //打开数据库
    sqlite3 *db = [DataBase openDB];
    //创建操作指针
    sqlite3_stmt *stmt = nil;
    //执行SQL语句
    int result = sqlite3_prepare_v2(db, "select * from area where provinceId = ? and isProvince = 0", -1, &stmt, nil);
    NSLog(@"All subcities result = %d",result);
    NSMutableArray *subCityArray = [NSMutableArray arrayWithCapacity:1];
    if (result == SQLITE_OK) {
        
        sqlite3_bind_int(stmt, 1, privinceId);
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            const unsigned char *cityName = sqlite3_column_text(stmt, 0);
            int cityId = sqlite3_column_int(stmt, 1);
            int provinceId = sqlite3_column_int(stmt, 3);
            
            FBCity *province = [[FBCity alloc]initSubcityWithName:[NSString stringWithUTF8String:(const char *)cityName] cityId:cityId provinceId:provinceId];
            [subCityArray addObject:province];
        }
    }
    sqlite3_finalize(stmt);
    return subCityArray;
    
}


+ (NSArray *)getAllProvince
{
    //打开数据库
    sqlite3 *db = [DataBase openDB];
    //创建操作指针
    sqlite3_stmt *stmt = nil;
    //执行SQL语句
    int result = sqlite3_prepare_v2(db, "select * from area where isProvince = 1", -1, &stmt, nil);
    NSLog(@"All subcities result = %d",result);
    NSMutableArray *subCityArray = [NSMutableArray arrayWithCapacity:1];
    if (result == SQLITE_OK) {
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            const unsigned char *cityName = sqlite3_column_text(stmt, 0);
            int cityId = sqlite3_column_int(stmt, 1);
            FBCity *province = [[FBCity alloc]initProvinceWithName:[NSString stringWithUTF8String:(const char *)cityName] provinceId:cityId];
            [subCityArray addObject:province];
        }
    }
    sqlite3_finalize(stmt);
    return subCityArray;
    
}

+ (NSString *)cityNameForId:(int)cityId
{
    //打开数据库
    sqlite3 *db = [DataBase openDB];
    //创建操作指针
    sqlite3_stmt *stmt = nil;
    //执行SQL语句
    int result = sqlite3_prepare_v2(db, "select * from area where id = ?", -1, &stmt, nil);
    
    NSLog(@"All subcities result = %d %d",result,cityId);
    
    if (result == SQLITE_OK) {
        
        sqlite3_bind_int(stmt, 1, cityId);
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            
            const unsigned char *cityName = sqlite3_column_text(stmt, 0);
            
            return [NSString stringWithUTF8String:(const char *)cityName];
        }
    }
    sqlite3_finalize(stmt);
    return @"";
}

+ (int)cityIdForName:(NSString *)cityName//根据城市名获取id
{
    //打开数据库
    sqlite3 *db = [DataBase openDB];
    //创建操作指针
    sqlite3_stmt *stmt = nil;
    //执行SQL语句
    int result = sqlite3_prepare_v2(db, "select * from area where name = ?", -1, &stmt, nil);
    
    NSLog(@"All subcities result = %d %@",result,cityName);
    
    if (result == SQLITE_OK) {
        
        sqlite3_bind_text(stmt, 1, [cityName UTF8String], -1, nil);
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            
            int cityId = sqlite3_column_int(stmt, 1);
            
            return cityId;
        }
    }
    sqlite3_finalize(stmt);
    return 0;
}

+(NSString*)getTimeWithDate:(NSDate*)theDate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *theTime = [formatter stringFromDate:theDate];
    return theTime;
}

+(NSString *)timechangeAll:(NSString *)placetime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[placetime doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}
+(NSString *)timechangeAll1:(NSString *)placetime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[placetime doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}
+(NSString *)timechangeAll2:(NSString *)placetime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[placetime doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}

+(NSString*)getTimeWithDate1:(NSDate*)theDate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *theTime = [formatter stringFromDate:theDate];
    return theTime;
}


//首页缓存
+(void)setHomeClothCacheOfNearStoreWithDic:(NSDictionary *)data{
    [[NSUserDefaults standardUserDefaults]setObject:data forKey:GNEARSTORE];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
+(void)setHomeClothCacheOfNearPinpai:(NSDictionary *)data{
    [[NSUserDefaults standardUserDefaults]setObject:data forKey:GNEARPINPAI];
}
+(void)setHomeClothCacheOfTopImage:(NSDictionary *)data;{
    [[NSUserDefaults standardUserDefaults]setObject:data forKey:GTOPIMAGES];
}

+(NSDictionary*)getHomeClothCacheOfNearStore{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults]objectForKey:GNEARSTORE];
    return dic;
}
+(NSDictionary*)getHomeClothCacheOfNearPinpai{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults]objectForKey:GNEARPINPAI];
    return dic;
}
+(NSDictionary*)getHomeClothCacheOfTopimage{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults]objectForKey:GTOPIMAGES];
    return dic;
}

+(void)cleanHomeClothCacheOfNearStore{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:GNEARSTORE];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


//清除缓存 首页衣加衣部分
+(void)cleanUserDefaulWithHomeCloth{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:GNEARSTORE];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:GNEARPINPAI];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:GTOPIMAGES];
}


@end
