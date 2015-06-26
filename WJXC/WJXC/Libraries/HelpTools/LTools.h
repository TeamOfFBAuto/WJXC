//
//  LCWTools.h
//  FBAuto
//
//  Created by lichaowei on 14-7-9.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



#import "MBProgressHUD.h"

#import "LoginViewController.h"


#import "AppDelegate.h"

//#import "LDataInstance.h"

#define RESULT_INFO @"msg" //错误信息

#define RESULT_CODE @"errorcode" //错误code

typedef void(^ urlRequestBlock)(NSDictionary *result,NSError *erro);

typedef void(^versionBlock)(BOOL isNewVersion,NSString *updateUrl,NSString *updateContent);//版本更新

@interface LTools : NSObject<NSURLConnectionDelegate,NSURLConnectionDataDelegate>
{
    urlRequestBlock successBlock;
    urlRequestBlock failBlock;
    versionBlock aVersionBlock;
    
    NSString *requestUrl;
    NSData *requestData;
    BOOL isPostRequest;//是否是post请求
    
    NSURLConnection *connection;
    
    NSString *_appid;
    
    NSString *_downUrl;//更新地址
}

+ (id)shareInstance;

+ (AppDelegate *)appDelegate;

+ (UINavigationController *)rootNavigationController;

+ (BOOL)isLogin:(UIViewController *)viewController;//判读是否登录

+ (BOOL)isLogin:(UIViewController *)viewController loginBlock:(LoginBlock)aBlock;//判断登录状态

//@property(nonatomic,retain)

/**
 *  网络请求
 */
- (id)initWithUrl:(NSString *)url isPost:(BOOL)isPost postData:(NSData *)postData;//初始化请求

- (void)requestCompletion:(void(^)(NSDictionary *result,NSError *erro))completionBlock failBlock:(void(^)(NSDictionary *result,NSError *erro))failedBlock;//处理请求结果
- (void)cancelRequest;

/**
 *  版本更新
 */
+ (void)versionForAppid:(NSString *)appid Block:(void(^)(BOOL isNewVersion,NSString *updateUrl,NSString *updateContent))version;//是否有新版本、新版本更新下地址


- (void)versionForAppid:(NSString *)appid Block:(void(^)(BOOL isNewVersion,NSString *updateUrl,NSString *updateContent))version;

#pragma mark - 融云用户数据

//+ (void)rongCloudChatWithUserId:(NSString *)userId
//                       userName:(NSString *)userName
//                 viewController:(UIViewController *)viewController;

+ (void)cacheRongCloudUserName:(NSString *)userName forUserId:(NSString *)userId;

+ (NSString *)rongCloudUserNameWithUid:(NSString *)userId;

+ (void)cacheRongCloudUserIcon:(NSString *)iconUrl forUserId:(NSString *)userId;

+ (NSString *)rongCloudUserIconWithUid:(NSString *)userId;

/**
 *  融云 记录更新数据时间
 *
 *  @param userId 用户id
 */
+ (void)cacheRongCloudTimeForUserId:(NSString *)userId;

/**
 *  是否需要更新userId对应的信息
 *
 *  @param userId
 *
 *  @return 是否
 */
+ (BOOL)rongCloudNeedRefreshUserId:(NSString *)userId;


#pragma mark - NSUserDefault 缓存

/**
 *  NSUserDefault 缓存
 */
//存
+ (void)cache:(id)dataInfo ForKey:(NSString *)key;
//取
+ (id)cacheForKey:(NSString *)key;

+ (void)cacheBool:(BOOL)boo ForKey:(NSString *)key;

+ (BOOL)cacheBoolForKey:(NSString *)key;


//根据url获取SDWebImage 缓存的图片

+ (UIImage *)sd_imageForUrl:(NSString *)url;

#pragma mark - 常用视图快速创建

+ (UITableViewCell *)cellForIdentify:(NSString *)identify
                            cellName:(NSString *)cellName
                            forTable:(UITableView *)tableView;

+ (UIButton *)createButtonWithType:(UIButtonType)buttonType
                             frame:(CGRect)aFrame
                       normalTitle:(NSString *)normalTitle
                             image:(UIImage *)normalImage
                    backgroudImage:(UIImage *)bgImage
                         superView:(UIView *)superView
                            target:(id)target
                            action:(SEL)action;

+ (UILabel *)createLabelFrame:(CGRect)aFrame
                        title:(NSString *)title
                         font:(CGFloat)size
                        align:(NSTextAlignment)align
                    textColor:(UIColor *)textColor;

#pragma mark - 计算宽度、高度

+ (CGFloat)widthForText:(NSString *)text font:(CGFloat)size;
+ (CGFloat)widthForText:(NSString *)text boldFont:(CGFloat)size;

+ (CGFloat)widthForText:(NSString *)text height:(CGFloat)height font:(CGFloat)size;

+ (CGFloat)heightForText:(NSString *)text width:(CGFloat)width font:(CGFloat)size;
+ (CGFloat)heightForText:(NSString *)text width:(CGFloat)width Boldfont:(CGFloat)size;//加粗

#pragma mark - 小工具

/**
 *  返回距离 大于1000 为km,小于m
 *
 *  @param distance 距离
 *
 *  @return
 */
+ (NSString *)distanceString:(NSString *)distance;

+ (void)alertText:(NSString *)text viewController:(UIViewController *)vc;

+ (void)alertText:(NSString *)text;

#pragma mark - MD5

/**
 *  获取验证码的时候加此参数
 *
 *  @param phone 手机号
 *
 *  @return 手机号和特定字符串MD5之后的结果
 */
+ (NSString *)md5Phone:(NSString *)phone;

+ (NSString *) md5:(NSString *) text;

#pragma - mark 时间相关

/**
 *  时间戳转化为响应格式时间
 *
 *  @param placetime 时间线
 *  @param format    时间格式 @"YYYY-MM-dd HH:mm:ss"
 *
 *  @return 返回时间字符串
 */
+(NSString *)timeString:(NSString *)placetime withFormat:(NSString *)format;

+(NSString *)timechange:(NSString *)placetime;
+(NSString *)timechange2:(NSString *)placetime;
+(NSString *)timechange3:(NSString *)placetime;

+(NSString *)timechangeMMDD:(NSString *)placetime;

+(NSString *)timechangeAll:(NSString *)placetime;//时间戳 显示全

/**
 *  显示间隔时间 一天内显示时分、几天前、几周前、大于一周 显示具体日期
 *
 *  @param myTime 时间线
 *  @param format 时间格式 “HH:mm”
 *
 *  @return
 */
+ (NSString*)showIntervalTimeWithTimestamp:(NSString*)myTime
                                withFormat:(NSString *)format;

+(NSString*)showTimeWithTimestamp:(NSString*)myTime;//不满一天显示时、分 大于一天显示时间间隔

+(NSDate *)timeFromString:(NSString *)timeString;//时间戳转NSDate

+(NSString *)timechangeToDateline;//转换为时间戳

+(NSString*)timestamp:(NSString*)myTime;//模糊时间,如几天前

+ (NSString *)currentTime;//当前时间 yyyy-mm-dd

+ (BOOL)needUpdateForHours:(CGFloat)hours recordDate:(NSDate *)recordDate;//计算既定时间段是否需要更新

#pragma mark - 加载提示

+ (void)showMBProgressWithText:(NSString *)text addToView:(UIView *)aView;

+ (MBProgressHUD *)MBProgressWithText:(NSString *)text addToView:(UIView *)aView;

#pragma mark - 字符串的处理

+(NSString *)numberToString:(long)number;//千分位

+ (NSString *)safeString:(NSString *)string;

/**
 *  去掉开头空格
 *
 *  @param string
 *
 *  @return 
 */
+ (NSString *)stringHeadNoSpace:(NSString *)string;

/**
 *  排除NSNull null 和 (null)
 *
 *  @param text
 *
 *  @return 空格
 */
+ (NSString *)NSStringNotNull:(NSString *)text;

+ (NSString *)NSStringAddComma:(NSString *)string; //添加逗号

+ (NSAttributedString *)attributedString:(NSString *)string lineSpaceing:(CGFloat)lineSpage;//行间距string

/**
 *  行间距string 字体大小
 */

+ (NSAttributedString *)attributedString:(NSString *)string
                            lineSpaceing:(CGFloat)lineSpage
                                fontSize:(CGFloat)fontSize;

/**
 *  行间距string 字体大小 字体颜色
 */

+ (NSAttributedString *)attributedString:(NSString *)string
                            lineSpaceing:(CGFloat)lineSpage
                                fontSize:(CGFloat)fontSize
                               textColor:(UIColor *)textColor;

+ (NSAttributedString *)attributedString:(NSString *)content keyword:(NSString *)aKeyword color:(UIColor *)textColor;//关键词高亮

+ (NSAttributedString *)attributedString:(NSMutableAttributedString *)attibutedString originalString:(NSString *)string AddKeyword:(NSString *)keyword color:(UIColor *)color;//每次一个关键词高亮,多次调用

+ (BOOL)NSStringIsNull:(NSString *)string;//判断字符串是否全为空格

#pragma mark - 验证有效性

+ (BOOL) isEmpty:(NSString *) str;//是否为空

+ (BOOL)isDictinary:(id)object;//是否是字典

/**
 *  验证 邮箱、电话等
 */

+ (BOOL)isValidateInt:(NSString *)digit;
+ (BOOL)isValidateFloat:(NSString *)digit;
+ (BOOL)isValidateEmail:(NSString *)email;
+ (BOOL)isValidateName:(NSString *)userName;
+ (BOOL)isValidatePwd:(NSString *)pwdString;
+ (BOOL)isValidateMobile:(NSString *)mobileNum;

/**
 *  切图
 */
+(UIImage *)scaleToSizeWithImage:(UIImage *)img size:(CGSize)size;

#pragma mark - 适配尺寸计算

/**
 *  计算等比例高度
 *
 *  @param image_height   图片的高度
 *  @param image_width    图片的宽度
 *  @param original_Width 实际显示宽度
 *
 *  @return 实际显示高度
 */
+ (CGFloat)heightForImageHeight:(CGFloat)image_height
                     imageWidth:(CGFloat)image_width
                  originalWidth:(CGFloat)original_Width;

#pragma mark - 分类论坛图片获取

+ (UIImage *)imageForBBSId:(NSString *)bbsId;

#pragma mark - 动画

/**
 *  view先变大再恢复原样
 *
 *  @param annimationView 需要做动画的view
 *  @param duration       动画时间
 *  @param scacle         变大比例
 */
+ (void)animationToBigger:(UIView *)annimationView
                 duration:(CGFloat)duration
                   scacle:(CGFloat)scacle;

@end
