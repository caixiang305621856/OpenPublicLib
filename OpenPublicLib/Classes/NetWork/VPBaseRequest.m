
//
//  VPBaseRequest.m
//
//
//  Created by vernepung on 15/4/7.
//  Copyright (c) 2015年 vernepung. All rights reserved.
//

#ifdef DEBUG
#define VPLog(format, ...) printf("class: <%p %s:(%d) > method: %s \n%s\n", self, [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __PRETTY_FUNCTION__, [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String] )
#else
#define VPLog(format, ...)
#endif

#import "VPBaseRequest.h"
#import <objc/objc.h>
#import <objc/runtime.h>
#import "VPHTTPSessionManager.h"
#import "VPNetConfig.h"

#define BASEREQUEST_METHODNAME_KEY @"BASEREQUEST_METHODNAME_KEY"

@interface VPBaseRequest (){
@private
    void(^_constructingBodyBlock)(id<AFMultipartFormData>);
    void(^_requestSuccFinishBlock)(id);
    void(^_requestBusinessFailureBlock)(NSDictionary *);
    void(^_requestFailFinishBlock)(NSError *);
    void(^_requestFinalBlock)(void);
    NSMutableDictionary *_httpBodyDic;
    NSMutableDictionary *_parametersDic;
    BOOL                _isResetBlock;//是否进行复位block
    BOOL                _isFailBlockFinish; //failBlock调取完成
    NSInteger           _internalRet;//内部使用的ret
    NSInteger           _numOfRepeat; //重复请求次数
    RequestMethod       _requestMethod; //请求方式
    NSString            *_methodName; //请求的方法名
    NSURLSessionDataTask *_currentTask;
}
@end

@implementation VPBaseRequest
#pragma mark -
- (void)dealloc{
    [self cancel];
}

-(id)init{
    return [self initPostMethod:nil];
}

- (id)initGetMethod:(NSString *)methodName{
    return [self initGetMethod:methodName numOfRepeat:1];
}

- (id)initGetMethod:(NSString *)methodName numOfRepeat:(NSInteger)numOfRepeat{
    return [self initMethodName:methodName numOfRepeat:numOfRepeat requestMethod:RequestMethodGet];
}

- (id)initPostMethod:(NSString *)methodName{
    return [self initPostMethod:methodName numOfRepeat:1];
}

- (id)initPostMethod:(NSString *)methodName numOfRepeat:(NSInteger)numOfRepeat{
    return [self initMethodName:methodName numOfRepeat:numOfRepeat requestMethod:RequestMethodPost];
}

- (id)initPostFormMethod:(NSString *)methodName{
    return [self initMethodName:methodName numOfRepeat:1 requestMethod:RequestMethodPostForm];
}

- (id)initMethodName:(NSString *)methodName numOfRepeat:(NSInteger)numOfRepeat requestMethod:(RequestMethod)requestMethod{
    self = [super init];
    if(self){
        _requestMethod = requestMethod;
        _numOfRepeat = numOfRepeat;
        _parametersDic = [[NSMutableDictionary alloc] init];
        _httpBodyDic   = [[NSMutableDictionary alloc] init];
        [self setMethodName:methodName];
    }
    return self;
}

#pragma mark -
- (void)setMethodName:(NSString *)methodName{
    objc_setAssociatedObject([self class], BASEREQUEST_METHODNAME_KEY, methodName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    _methodName = methodName;
}

- (void)setNumOfRepeat:(NSInteger)numOfRepeat{
    _numOfRepeat = numOfRepeat;
}

- (void)setRequestMethod:(RequestMethod)requestMethod{
    _requestMethod = requestMethod;
}

- (void)setIntegerValue:(NSInteger)value forKey:(NSString *)key{
    [self setValue:[NSNumber numberWithInteger:value] forKey:key];
}

- (void)setDoubleValue:(double)value forKey:(NSString *)key{
    [self setValue:[NSNumber numberWithFloat:value] forKey:key];
}

- (void)setLongLongValue:(long long)value forKey:(NSString *)key{
    [self setValue:[NSString stringWithFormat:@"%zd", value] forKey:key];
}

- (void)setBOOLValue:(BOOL)value forKey:(NSString *)key{
    [self setValue:[NSString stringWithFormat:@"%d", value] forKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key{
    //value只能是字符串，如果不是字符串类型，[LSHelper getSignParam]会crash，暂时未做处理。
    if(!value){
        value = @"";
    }
    [_parametersDic setValue:value forKey:key];
}

- (void)sendRequest{
    [self sendRequestSuccFinishBlock:nil requestBusinessFailureBlock:nil requestFailFinishBlock:nil requestFinalBlock:nil];
}

- (void)sendRequestSuccFinishBlock:(void (^)(id))requestFinishBlock requestFinalBlock:(void (^)(void))requestFinalBlock showToast:(BOOL)show{
    if (show){
        [self sendRequestSuccFinishBlock:requestFinishBlock requestBusinessFailureBlock:[[VPNetConfig defaultConfig] requestBusinessFailureBlock] requestFailFinishBlock:[[VPNetConfig defaultConfig] requestFailFinishBlock] requestFinalBlock:requestFinalBlock];
    }else{
        [self sendRequestSuccFinishBlock:requestFinishBlock requestBusinessFailureBlock:nil requestFailFinishBlock:nil requestFinalBlock:requestFinalBlock];
    }
}

-(void)sendRequestSuccFinishBlock:(void(^)(id result))requestFinishBlock requestBusinessFailureBlock:(void(^)(NSDictionary * response))requestBusinessFailureBlock requestFailFinishBlock:(void(^)(NSError *error))requestFailFinishBlock requestFinalBlock:(void (^)(void))requestFinalBlock{
    _requestFailFinishBlock = requestFailFinishBlock;
    _requestBusinessFailureBlock = requestBusinessFailureBlock;
    _requestSuccFinishBlock = requestFinishBlock;
    _requestFinalBlock = requestFinalBlock;
    _isResetBlock = NO;
    _errorType = RequestErrorTypeNone;
    _isFailBlockFinish = NO;
    if (_cacheMode == RequestCacheBeforeSend){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            id data = [[VPNetConfig defaultConfig] getCacheWithMethodName:_methodName params:[_parametersDic copy]];
            if (data){
                _cacheCallback = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (_requestSuccFinishBlock){
                        _requestSuccFinishBlock(data);
                    }
                    if (_requestFinalBlock) {
                        _requestFinalBlock();
                    }
                });
            }
            [self execuRequest];
        });
    }else{
        [self execuRequest];
    }
}

- (void)execuRequest {
    dispatch_async([VPHTTPSessionManager shareManager].workQueue, ^{
        if (_requestMethod == RequestMethodGet) {
            [self doGetRequest];
        }else if(_requestMethod == RequestMethodPost){
            [self doPostRequest];
        }else if (_requestMethod == RequestMethodPostForm){
            [self doPostFormRequest];
        }
    });
}

- (void)sendRequestWithConstructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))constructingBodyBlock succFinishBlock:(void (^)(id))requestFinishBlock requestBusinessFailureBlock:(void (^)(NSDictionary *))requestBusinessFailureBlock requestFailFinishBlock:(void (^)(NSError *))requestFailFinishBlock requestFinalBlock:(void (^)(void))requestFinalBlock{
    _constructingBodyBlock = constructingBodyBlock;
    [self sendRequestSuccFinishBlock:requestFinishBlock requestBusinessFailureBlock:requestBusinessFailureBlock requestFailFinishBlock:requestFailFinishBlock requestFinalBlock:requestFinalBlock];
}

#pragma mark -
- (void)doPostFormRequest{
    VPHTTPSessionManager *sessionManager = [VPHTTPSessionManager shareManager];
    [self setparamesDic];
    NSDictionary *dict = _httpBodyDic[@"params"];
    for (NSString *key in dict.allKeys) {
        [_httpBodyDic setObject:dict[key] forKey:key];
    }
    [_httpBodyDic removeObjectForKey:@"params"];
    _currentTask = [sessionManager POST:[_methodName copy] parameters:[_httpBodyDic copy] constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        _constructingBodyBlock(formData);
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self hanleSuccessResponseWithTask:task response:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handlerErrorResponse:error];
    }];
}

-(void)doGetRequest{
    VPHTTPSessionManager *sessionManager = [VPHTTPSessionManager shareManager];
    //设置参数
    [self setparamesDic];
    
    _currentTask = [sessionManager GET:[_methodName copy] parameters:[_httpBodyDic copy] progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self hanleSuccessResponseWithTask:task response:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //[[task.response allHeaderFields] valueForKeyPath:@"Content-Encoding"]
        [self handlerErrorResponse:error];
    }];
}

-(void)doPostRequest{
    [self sendDataNumOfRepeat:_numOfRepeat];
}

-(void)sendDataNumOfRepeat:(NSInteger)numOfRepeat{
    VPHTTPSessionManager *sessionManager = [VPHTTPSessionManager shareManager];
    [self setparamesDic];
    //send Request
    _currentTask = [sessionManager POST:[_methodName copy] parameters:[_httpBodyDic copy] progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self hanleSuccessResponseWithTask:task response:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(numOfRepeat <= 1){
            [self handlerErrorResponse:error];
        }
        else{
            dispatch_async([VPHTTPSessionManager shareManager].workQueue, ^{
                [self sendDataNumOfRepeat:numOfRepeat-1];
            });
        }
    }];
}

-(void)setparamesDic{
    _httpBodyDic = [NSMutableDictionary dictionaryWithDictionary:[[VPNetConfig defaultConfig] requestParameters:[_parametersDic copy]]];
}

#pragma mark -
-(void)hanleSuccessResponseWithTask:(NSURLSessionDataTask *)task response:(id)responseObject{
    //    task.currentRequest
    if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]){
        [self handlerSuccFinishResponseWithDic:responseObject];
    }else{
        //数据不是json格式
        [self handlerErrorResponse:[NSError errorWithDomain:_methodName code:-1 userInfo:@{@"msg":@"返回数据不是json"}]];
    }
}

/** 如果缓存先返回，而且设置了resetBlock标记，网络返回99999时候进行reset。 */
-(void)handlerSuccFinishResponseWithNetFlag{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_isResetBlock){
            [self resetFinishBlock];
        }
    });
}
/** @brief 获取数据完毕后的dic
 *  @param resultDic 网络请求字典结果
 */
-(void)handlerSuccFinishResponseWithDic:(NSMutableDictionary*)resultDic{
    VPNetConfig *config = [VPNetConfig defaultConfig];
    NSString *codeKey = [config requestCodeKey];
    NSInteger successCode = [config requestSuccessCode];
    NSInteger needLoginCode = [config requestNeedLoginCode];
    NSInteger needMaintenanceCode = [config requestNeedMaintenanceCode];
    NSInteger code = [resultDic[codeKey] integerValue];
    
    if ([config respondsToSelector:@selector(setSpecialValues:)]) {
        NSMutableDictionary *specDict = [[NSMutableDictionary alloc]init];
        for (NSString *key in [config specialKeys]) {
            id value = resultDic[key];
            if (value) {
                [specDict setObject:value forKey:key];
            }
        }
        if (specDict.allKeys.count > 0) {
            [config setSpecialValues:specDict];
        }
    }
    // async
    if(code == successCode){
#ifdef DEBUG
        VPLog(@"\r\n-------------请求URL---------------\r\n %@ \r\n-------------请求参数---------------\r\n %@\r\n-------------Server返回内容---------\r\n%@--------------END----------------",_methodName, [_parametersDic copy],resultDic);
#endif
        [self handleSuccessBlockWithDic:[self processResultWithDic:resultDic]];
    }else if(code == needLoginCode){
        for (NSURLSessionTask *task in [VPHTTPSessionManager shareManager].tasks) {
            [task cancel];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
#ifdef DEBUG
            VPLog(@"\r\n-------------请求URL---------------\r\n %@ \r\n-------------请求参数---------------\r\n %@\r\n-------------当前用户被踢出--------------END----------------",_methodName, [_parametersDic copy]);
#endif
            [config whenServerLogout];
        });
    }else if(code == needMaintenanceCode){
        for (NSURLSessionTask *task in [VPHTTPSessionManager shareManager].tasks) {
            [task cancel];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
#ifdef DEBUG
            VPLog(@"\r\n-------------请求URL---------------\r\n %@ \r\n-------------请求参数---------------\r\n %@\r\n-------------当前系统维护--------------END----------------",_methodName, [_parametersDic copy]);
#endif
            [config whenServerMaintenance:resultDic];
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_requestBusinessFailureBlock) {
                _errorType = RequestErrorTypeBussines;
#ifdef DEBUG
                VPLog(@"\r\n-------------请求URL---------------\r\n %@ \r\n-------------请求参数---------------\r\n %@\r\n-------------请求逻辑异常---------------\r\n %@--------------END----------------",_methodName, [_parametersDic copy], resultDic);
#endif
                _requestBusinessFailureBlock(resultDic);
            }else if (_requestFailFinishBlock) {
                _errorType = RequestErrorTypeNetwork;
                _requestFailFinishBlock(nil);
            }
            [self callRequestFinalBlock];
        });
    }
}

-(void)handleSuccessBlockWithDic:(id)dic{
    _cacheCallback = NO;
    if (_cacheMode != RequestCacheNone && _requestSuccFinishBlock){
        dispatch_async(dispatch_get_global_queue(0, 0),^{
            [[VPNetConfig defaultConfig] cacheRequestWithMethodName:_methodName params:[_parametersDic mutableCopy] result:[dic mutableCopy]];
        });
    }
    // 此处异步
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_requestSuccFinishBlock) {
            _requestSuccFinishBlock(dic);
            [self callRequestFinalBlock];
        }
    });
}

- (void)callRequestFinalBlock{
    if (_requestFinalBlock){
        _requestFinalBlock();
    }
    [self resetFinishBlock];
}

//网络返回错误后的处理
-(void)handlerErrorResponse:(NSError*)error{
#ifdef DEBUG
    VPLog(@"\r\n-------------请求URL---------------\r\n %@ \r\n-------------请求参数---------------\r\n %@\r\n-------------请求Error---------------\r\n %@--------------END----------------",_methodName, [_parametersDic copy], error);
#endif
    //取消请求，不调回block
    if (kCFURLErrorCancelled == error.code) {
        return;
    }
    _cacheCallback = NO;
    if (_cacheMode == RequestCacheFailed){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            id data = [[VPNetConfig defaultConfig] getCacheWithMethodName:_methodName params:[_parametersDic copy]];
            if (data){
                _cacheCallback = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (_requestSuccFinishBlock){
                        _requestSuccFinishBlock(data);
                    }
                    if (_requestFinalBlock) {
                        _requestFinalBlock();
                    }
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self handleErroBlock:error];
                });
            }
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleErroBlock:error];
        });
    }
}

-(void)handleErroBlock:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_requestFailFinishBlock) {
            _errorType = RequestErrorTypeBussines;
            _requestFailFinishBlock(error);
            _isFailBlockFinish = YES;
        }
        [self callRequestFinalBlock];
    });
}

#pragma mark -
-(void)resetFinishBlock{
    _requestSuccFinishBlock = nil;
    _requestFailFinishBlock = nil;
    _requestBusinessFailureBlock = nil;
    _requestFinalBlock = nil;
    _constructingBodyBlock = nil;
}

-(id)processResultWithDic:(NSMutableDictionary*)resultDic{
    return resultDic;
}

- (NSString *)getLocalURL
{
    return nil;
}

+ (void)cancelRequest{
    __weak VPHTTPSessionManager *weakSessionManager = [VPHTTPSessionManager shareManager];
    NSString *urlString = [self getUrlName];
    //    dispatch_async([VPHTTPSessionManager shareManager].workQueue, ^{
    if(urlString.length > 0){
        __strong VPHTTPSessionManager *strongSessionManager = weakSessionManager;
        [strongSessionManager cancelTasksWithUrl:urlString];
        objc_setAssociatedObject([self class], BASEREQUEST_METHODNAME_KEY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    //    });
}

- (void)cancel{
    if (_currentTask)
    {
        [_currentTask cancel];
    }
    [self resetFinishBlock];
}

- (NSString *)description{
    NSString *className = NSStringFromClass([self class]);
    NSString *desStr = [NSString stringWithFormat:@"%@\nparam:\n%@", className, _parametersDic];
    return desStr;
}

/**
 *  用户初始化后，此url才有效。
 */
+ (NSString*)getUrlName{
    NSString* urlString =  objc_getAssociatedObject([self class], BASEREQUEST_METHODNAME_KEY);
    //为了外面使用isHttpQueueFinished的方便，不返回nil。
    if(!urlString){
        urlString = @"";
    }
    return urlString;
}

+ (BOOL)isHttpQueueFinished:(NSArray*)httpUrlArray{
    return [[VPHTTPSessionManager shareManager]isHttpQueueFinished:httpUrlArray];
}

+ (BOOL)isHttpQueueFinishedWithClassNameArray:(NSArray*)requestClassArray{
    NSMutableArray* urlArray = [NSMutableArray array];
    
    for (NSString* className in requestClassArray) {
        if (className.length == 0) {
            continue;
        }
        
        Class currentClass = NSClassFromString(className);
        if(!currentClass){
            continue;
        }
        
        if(![currentClass isSubclassOfClass:[VPBaseRequest class]]){
            continue;
        }
        
        NSString* urlName = [currentClass getUrlName];
        if(urlName.length > 0){
            [urlArray addObject:urlName];
        }
    }
    return [self isHttpQueueFinished:urlArray];
}
/**
 *	@brief	将json数据转换成id
 *
 *	@param jsonData 数据
 *
 *	@return	 id类型的数据
 */
- (id)parserJsonData:(id)jsonData{
    NSError *error;
    id jsonResult = nil;
    //json对象
    if([NSJSONSerialization isValidJSONObject:jsonData]){
        return jsonData;
    }
    //NSData
    if (jsonData && [jsonData isKindOfClass:[NSData class]]){
        jsonResult = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    }
    if (jsonResult != nil && error == nil){
        return jsonResult;
    }else{
        // 解析错误
        return nil;
    }
}
@end
