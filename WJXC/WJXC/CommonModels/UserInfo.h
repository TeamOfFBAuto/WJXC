//
//  UserInfo.h
//  YiYiProject
//
//  Created by lichaowei on 14/12/13.
//  Copyright (c) 2014年 lcw. All rights reserved.
//

#import "BaseModel.h"

/**
 *  用户信息 model
 */
@interface UserInfo : BaseModel<NSCoding>

@property(nonatomic,retain)NSString *id;
@property(nonatomic,retain)NSString *uid;
@property(nonatomic,retain)NSString *user_name;
@property(nonatomic,retain)NSString *password;
@property(nonatomic,retain)NSString *admin_id;
@property(nonatomic,retain)NSString *user_grade;
@property(nonatomic,retain)NSString *gender;
@property(nonatomic,retain)NSString *age;
@property(nonatomic,retain)NSString *email;
@property(nonatomic,retain)NSString *mobile;
@property(nonatomic,retain)NSString *dateline;
@property(nonatomic,retain)NSString *state;
@property(nonatomic,retain)NSString *type;
@property(nonatomic,retain)NSString *photo;
@property(nonatomic,retain)NSString *third_photo;
@property(nonatomic,retain)NSString *thirdid;
@property(nonatomic,retain)NSString *score;
@property(nonatomic,retain)NSString *devicetoken;
@property(nonatomic,retain)NSString *job;
@property(nonatomic,retain)NSString *decription;
@property(nonatomic,retain)NSString *role;
@property(nonatomic,retain)NSString *birthday;
@property(nonatomic,retain)NSString *friends_num;
@property(nonatomic,retain)NSString *fans_num; //粉丝数
@property(nonatomic,retain)NSString *attend_num;//关注数
@property(nonatomic,retain)NSString *favor_num;
@property(nonatomic,retain)NSString *authcode;
@property(nonatomic,retain)NSString *attentions_num; //关注数
@property(nonatomic,retain)NSString *division_t;//值表示1=》待审核搭配师 2=》已是搭配师 0=》普通
@property(nonatomic,retain)NSString *gold_coin;
@property(nonatomic,retain)NSString *recommend_uid;
@property(nonatomic,retain)NSString *shopman;//shopman的值表示 1=》店主审核 2=》已是店主 0=》普通
@property(nonatomic,retain)NSString *user_banner;
@property(nonatomic,strong)NSString *tt_num;

@property(nonatomic,retain)NSString *mall_type;//店铺类型 2 精品店 3 品牌店  1 商场
@property(nonatomic,retain)NSString *mall_name;//店铺名称

@property(nonatomic,retain)NSString *brand_name;//品牌name

@property(nonatomic,retain)NSString *shop_id;//店铺id 可能会没有
@property(nonatomic,retain)NSString *mall_id;//id 一定有


@property(nonatomic,strong)NSString *is_sign;//是否签到

@property(nonatomic,assign)int relation;//0 互相未关注 1关注了别人 2别人关注你 3互相关注

/**
 *  归档的方式存model对象 重写了编码解码方法
 *
 *  @param aModel
 *  @param modelKey
 */
- (void)cacheForKey:(NSString *)modelKey;

/**
 *  获取存在本地的model
 *
 *  @param modelKey key
 *
 *  @return
 */
+ (id)cacheResultForKey:(NSString *)modelKey;

@end
