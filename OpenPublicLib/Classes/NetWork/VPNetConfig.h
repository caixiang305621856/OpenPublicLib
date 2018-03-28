//
//  BaseRequestDefaultHelper.h
//  PublicProject
//
//  Created by user on 15/5/8.
//  Copyright (c) 2015年 vernepung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPBaseRequest.h"
@class AFHTTPRequestSerializer;
@class AFHTTPResponseSerializer;
@class AFSecurityPolicy;
/**
 @brief BaseReuqest的helper类，主要是帮助BaseRequest处理跟业务相关的部分，如请求参数的组装、加密解密、是否缓存。
 @note  根据需求不同，需要子类化此类，覆写相关方法。首先必须覆写baseURL（返回服务器地址），其次需要在新建的Helper类中的+(void)load方法中通过+ (void)registerHelper:(Class)helper方法进行注册
 */
@interface VPNetConfig : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
/**
 *@brief 注册helper类
 */
+ (void)registerConfig:(Class)config;
/**
 *@brief 返回注册的对象
 */
+ (instancetype)defaultConfig;
/**
 使用log的模式
 */
@property (nonatomic, assign) VPRequestLogMode logMode;
/**
 *@brief 服务器的地址，默认为空，必须覆写此方法
 */
- (NSString *)requestBaseUrl;
/**
 *@brief 请求成功返回码，默认为10000，根据需求覆写此方法
 */
- (NSInteger)requestSuccessCode;
/**
 *@brief 服务器返回一个状态码，标明客户端登录失效，默认-1
 */
- (NSInteger)requestNeedLoginCode;
/**
 *@brief 服务器返回一个状态码，标明客户端系统维护，默认99999
 */
- (NSInteger)requestNeedMaintenanceCode;
/**
 当服务器踢出用户后触发
 */
- (void)whenServerLogout;
/**
 当服务器启用维护状态时候触发
 
 @param dict 描述信息
 */
- (void)whenServerMaintenance:(NSMutableDictionary *)dict;
/**
 *@brief 取返回码的key值，默认为"code"
 */
- (NSString *)requestCodeKey;
/**
 *@brief 服务器返回一个状态码，标明客户端取缓存数据，默认9999
 */
- (NSInteger)requestCacheCode;
/**
 *@brief 若要获取特殊的key的值,需要传入的keys.
         只获取根部的值,一般用来更新本地的时间/token.
 */
- (NSArray<NSString *> *)specialKeys;
/**
 *@brief 传回获取到的所有特殊key的值,一般用来更新本地的时间/token.
 */
- (void)setSpecialValues:(NSDictionary<NSString*,id> *)values;
/**
 https请求证书
 */
- (AFSecurityPolicy *)securityPolicy;
/**
 @brief 组装最终传递给AF的参数字典，默认是一些公共的参数放在同一个字典当中
 @param parametersDic 每个Request的请求参数
 @return 返回最终传给AF的请求参数
 */
- (NSMutableDictionary *)requestParameters:(NSDictionary *)parametersDic;
/**
 @brief   对请求的body进行处理，若是需要加密，子类请覆写此方法。默认不加密，直接返回bodyDic；若是需加密，则返回一个加密后的NSData类型数据
 @param   request 当前的请求，扩展可用
 @param   parameters 请求参数的参数字典
 @return  在BaseRequest当中判断是否加密，是通过此方法返回的内容来判断；若为NSData类型，则说明加密；否则，说明没有加密
 */
- (id)handleOnRequest:(NSURLRequest *)request parameters:(NSDictionary *)parameters;

/**
 @brief   对返回的数据进行处理，根据业务需求若是需要解密，则可以通过此方法对reponseData的数据进行解密
 @param   response       AF返回的AFHTTPRequestOperation中的response
 @param   responseData  请求返回的数据
 @code
 例子：
 //从服务器中返回的请求头取值判断是否进行了des加密
 BOOL isDes = [response.allHeaderFields[@"des"] boolValue];
 if(isDes){
 //des解密之后，返回解密后的内容
 }
 else{
 return responseData;
 }
 或者解压gzip结果
 ** AFN目前自动解压GZip,不用手动解压
 NSString *isGzip = [httpResonse allHeaderFields][@"Content-Encoding"];
 */
- (id)handleOnResponse:(NSURLResponse *)response data:(NSData *)responseData;
- (void(^)(NSDictionary* response))requestBusinessFailureBlock;
- (void(^)(NSError *error))requestFailFinishBlock;
/**
 *  对返回的数据进行缓存，此处传回的是经过请求处理后的结果，正确情况下为NSDictionary
 *
 *  @param result 结果
 */
- (void)cacheRequestWithMethodName:(NSString *)methodName params:(NSDictionary *)params result:(id)result;
/**
 *  根据请求获取缓存
 *
 *  @param methodName
 *  @param params
 */
- (id)getCacheWithMethodName:(NSString *)methodName params:(NSDictionary *)params;
/**
 @return  返回请求头，默认是Content-Type=application/x-www-form-urlencoded,User-Agent=iPhone
 */
- (NSDictionary *)requestHttpHeader;

/**
 *@breif 返回一个Request序列化器，默认返回nil，一般不需要覆写此方法
 *@note 业务简单时，可以返回AFHTTPRequestSerializer、AFJSONRequestSerializer和AFPropertyListRequestSerializer对Request进行序列化
 *@note 业务复杂需要加密，则使用默认的PPJSONRequestSerializer对Request进行序列化，加密只需要覆写NetworkHelper类中的- (id)handleOnRequest:(NSURLRequest *)request parameters:(NSDictionary *)parameters方法
 *@note 若是以上序列化器都满足不了业务，则可以自定义一个序列化器
 */
- (AFHTTPRequestSerializer *)requestSerializer;

/**
 *@breif 返回一个response序列化器，默认返回VPJSONResponseSerializer，一般不需要覆写此方法
 *@note 业务简单时，可以返回AFHTTPResponseSerializer、AFJSONResponseSerializer和AFPropertyListResponseSerializer对response进行反序列化
 *@note 业务复杂需要加密，则使用默认的PPHTTPResponseSerializer对Request进行反序列化，加密只需要覆写NetworkHelper类中的- (id)handleOnResponse:(NSURLResponse *)response data:(NSData *)responseData方法
 *@note 若是以上序列化器都满足不了业务，则可以自定义一个序列化器
 */
- (AFHTTPResponseSerializer *)responseSerializer;

@end
