//
//  BaseRequestDefaultHelper.m
//  PublicProject
//
//  Created by user on 15/5/8.
//  Copyright (c) 2015年 vernepung. All rights reserved.
//

#import "VPNetConfig.h"
#import "VPHTTPSessionManager.h"
#import "VPJSONRequestSerializer.h"
#import "VPJSONResponseSerializer.h"

/** 成功返回的返回码 */
//static const NSInteger RequestSuccessCode = 10000;
/** 标明客户端需要缓存的返回码 */
//static const NSInteger RequestCacheCode = 9999;
/** 标明客户端需要缓存的返回码 */
//const NSInteger RequestNeedLoginCode = -1;
/** 服务器返回取code的key值 */
//NSString * const RequestCodeKey = @"code";

static VPNetConfig *_sharedInstance = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation VPNetConfig
#pragma clang diagnostic pop

+ (void)registerConfig:(Class)config {
    if (![config isSubclassOfClass:[self class]]) {
        @throw [NSException exceptionWithName:@"registerConfig" reason:@"注册的请求帮助类不是继承与VPNetConfig" userInfo:nil];
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[config alloc] init];
    });
}

+ (instancetype)defaultConfig {
    return _sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //注册的类必须是NetworkHelper的子类
        _sharedInstance = [super allocWithZone:zone];
    });
    return _sharedInstance;
}

- (AFHTTPRequestSerializer *)requestSerializer {
    return nil;
}

- (AFHTTPResponseSerializer *)responseSerializer {
    VPJSONResponseSerializer *serializer = [VPJSONResponseSerializer serializer];
    serializer.removesKeysWithNullValues = YES;
    return serializer;
}

- (NSString *)requestBaseUrl {
    //抛出异常
    @throw [NSException exceptionWithName:@"registerRequestHelper: error" reason:@"请重写[RequestHelper requestBaseUrl];" userInfo:nil];
    //    return @"127.0.0.1";
}

- (NSInteger)requestSuccessCode {
    return 10000;
}

- (NSString *)requestCodeKey {
    return @"serverCode";
}

- (NSInteger)requestNeedLoginCode {
    return -1;
}

- (NSInteger)requestNeedMaintenanceCode {
    return 99999;
}

- (AFSecurityPolicy *)securityPolicy {
    return [AFSecurityPolicy defaultPolicy];
}

- (NSInteger)requestCacheCode {
    return 9999;
}

- (NSArray<NSString *> *)specialKeys {
    return nil;
}

- (void)whenServerLogout { }

- (void)whenServerMaintenance:(NSMutableDictionary *)dict { }

/** 请求的公共参数 */
- (NSMutableDictionary *)requestParameters:(NSDictionary *)parametersDic {
    return [NSMutableDictionary dictionaryWithDictionary:parametersDic];
}

- (id)handleOnRequest:(NSURLRequest *)request parameters:(NSDictionary *)parameters {
    return nil;
}

- (id)handleOnResponse:(NSURLResponse *)response data:(NSData *)responseData {
    return responseData;
}

- (void)cacheRequestWithMethodName:(NSString *)methodName params:(NSDictionary *)params result:(id)result {
    
}

- (id)getCacheWithMethodName:(NSString *)methodName params:(NSDictionary *)params {
    return nil;
}

- (void(^)(NSDictionary* response))requestBusinessFailureBlock {
    return nil;
}

- (void(^)(NSError *error))requestFailFinishBlock {
    return nil;
}

- (NSDictionary *)requestHttpHeader{
    return @{
             @"Content-Type":@"application/x-www-form-urlencoded;charset=utf-8",
             @"User-Agent":@"iPhone"
             };
}
@end
