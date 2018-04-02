//
//  BaseRequest.h
//  
//
//  Created by vernepung on 15/4/7.
//  Copyright (c) 2015年 vernepung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AFURLRequestSerialization.h"
typedef NS_ENUM(NSInteger,RequestErrorType){
    RequestErrorTypeNone=0,
    RequestErrorTypeBussines=1,
    RequestErrorTypeNetwork=2
};
typedef NS_ENUM(NSInteger,RequestMethod){
    RequestMethodGet=0,
    RequestMethodPost=1,
    RequestMethodPostForm=2
};

/**
 缓存机制
 
 - RequestCacheNone: 不缓存
 - RequestCacheBeforeSend: 发送请求之前使用缓存
 - RequestCacheFailed: 失败之后使用缓存
 */
typedef NS_ENUM(NSInteger,RequestCacheMode) {
    RequestCacheNone = 0,
    RequestCacheBeforeSend = 1,
    RequestCacheFailed = 2
};

@class VPBaseRequest;

@interface VPBaseRequest : NSObject
#pragma mark -
- (instancetype)initPostMethod:(NSString *)methodName;
- (instancetype)initPostMethod:(NSString *)methodName numOfRepeat:(NSInteger)numOfRepeat;
- (instancetype)initGetMethod:(NSString *)methodName;
- (instancetype)initGetMethod:(NSString *)methodName numOfRepeat:(NSInteger)numOfRepeat;
- (instancetype)initPostFormMethod:(NSString *)methodName;
//- (instancetype)initPostFormMethod:(NSString *)methodName withFormDatasArray:(NSDictionary<NSString *,NSData*> *)datasArray mimeType:(NSString *)mimeType;
/**
 *  是否DES加密
 */
@property (nonatomic, assign) BOOL isDES;
/**
 是否是缓存返回
 */
@property (nonatomic, assign, readonly) BOOL cacheCallback;
/**
 *  错误类型
 */
@property (nonatomic, assign) RequestErrorType errorType;
/**
 *  缓存模式
 */
@property (nonatomic, assign) RequestCacheMode cacheMode;
#pragma mark -
/** 设置请求方式，POST还是GET */
- (void)setRequestMethod:(RequestMethod)requestMethod;
/** 设置请求方法名 */
- (void)setMethodName:(NSString *)methodName;
/** 设置网络请求失败后重复的次数 */
- (void)setNumOfRepeat:(NSInteger)numOfRepeat;

/**
 *@brief 每个请求的自定义的参数
 *@code  通过下面的方法进行设置
 */
- (void)setIntegerValue:(NSInteger)value forKey:(NSString *)key;
- (void)setDoubleValue:(double)value forKey:(NSString *)key;
- (void)setLongLongValue:(long long)value forKey:(NSString *)key;
- (void)setBOOLValue:(BOOL)value forKey:(NSString *)key;
- (void)setValue:(id)value forKey:(NSString *)key;

#pragma mark -
/**
 *  发送网络请求，根据业务需求分别调用不同接口
 *
 *  @param requestFinishBlock          请求完成回调
 *  @param requestBusinessFailureBlock 请求完成，业务失败回调
 *  @param requestFailFinishBlock      网络请求失败回调
 *  @param requestFinalBlock           不论何种情况始终会执行此回调，方便统一管理
 *  @param showToastByHelper           是否使用Helper中的通用回调
 */
- (void)sendRequestSuccFinishBlock:(void(^)(id result))requestFinishBlock requestBusinessFailureBlock:(void(^)(NSDictionary* response))requestBusinessFailureBlock requestFailFinishBlock:(void(^)(NSError *error))requestFailFinishBlock requestFinalBlock:(void(^)())requestFinalBlock;

/**
 *  发送网络请求，根据业务需求分别调用不同接口
 *
 *  @param requestFinishBlock          请求完成回调
 *  @param requestBusinessFailureBlock 请求完成，业务失败回调
 *  @param requestFailFinishBlock      网络请求失败回调
 *  @param requestFinalBlock           不论何种情况始终会执行此回调，方便统一管理
 *  @param showToastByHelper           是否使用Helper中的通用回调
 */
- (void)sendRequestSuccFinishBlock:(void(^)(id result))requestFinishBlock requestFinalBlock:(void(^)())requestFinalBlock showToast:(BOOL)show;
- (void)sendRequest;

- (void)sendRequestWithConstructingBodyWithBlock:(void(^)(id<AFMultipartFormData> formData))constructingBodyBlock succFinishBlock:(void(^)(id result))requestFinishBlock requestBusinessFailureBlock:(void(^)(NSDictionary* response))requestBusinessFailureBlock requestFailFinishBlock:(void(^)(NSError *error))requestFailFinishBlock requestFinalBlock:(void(^)())requestFinalBlock;

#pragma mark -
/*
 * @brief 服务器返回的数据解析成功后会调用
 * @warning 此方法为异步调用
 * @note  可以访问self.result得到服务器返回的结果，一定是NSDictionary类型。
 * @note  对网络请求的数据结果进行封装(可选) 子类实现
 */
-(id)processResultWithDic:(NSMutableDictionary*)resultDic;

/** 本地链接，此处用来作为本地搭服务器测试用 */
- (NSString *)getLocalURL;

/*
 *@brief 请使用此方法取消网络请求
 */
+(void)cancelRequest;

/**
 *  取消网络请求
 */
- (void)cancel;

/**
 *  @note 用户初始化子类request，调用完毕self.methodName=@"xxxx"后，此getUrlName方法有效。
 *  @note 否则返回为空字符串. @""
 *  @note 不允许子类实现
 */
+(NSString*)getUrlName;

/**
 *  @brief 此方法可以根据传入的urlArray判断是否http已经完成
 *  @note  don't OVERRIDE this method
 */
+(BOOL)isHttpQueueFinished:(NSArray*)httpUrlArray;

/**
 *  @brief 此方法可以根据传入的class类名判断是否http已经完成
 *  @note  don't OVERRIDE this method
 *  @example
 NSArray* classNameArray = @[@"LSUpdateDataRequest", @"LSSearchGoodsRequest",
 @"LSGoodsListRequest", @"LSCinemaListRequest"];
 BOOL isFinished = [LSBaseRequest isHttpQueueFinishedWithClassNameArray:classNameArray];
 */
+(BOOL)isHttpQueueFinishedWithClassNameArray:(NSArray*)requestClassArray;


@end
