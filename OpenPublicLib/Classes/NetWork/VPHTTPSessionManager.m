//
//  PPAFHTTPClient.m
//  PublicProject
//
//  Created by vernepung on 15/5/5.
//  Copyright (c) 2015年 vernepung. All rights reserved.
//

#import "VPHTTPSessionManager.h"
#import "VPNetConfig.h"
#import "VPJSONRequestSerializer.h"
#import "VPJSONResponseSerializer.h"

@implementation VPHTTPSessionManager

+ (VPHTTPSessionManager*)shareManager
{
    static VPHTTPSessionManager* _shareClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        VPNetConfig *config = [VPNetConfig defaultConfig];
        NSString *serverAddress = [config requestBaseUrl];
        _shareClient = [[VPHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:serverAddress]];
        // 设置请求序列化
        _shareClient.requestSerializer = [config requestSerializer];
        // 设置response序列化
        _shareClient.responseSerializer = [config responseSerializer];
        // 设置Https证书
        _shareClient.securityPolicy = [config securityPolicy];
        //一个工作队列，一个读写缓存的io队列
        _shareClient.workQueue = dispatch_queue_create("com.shareClient.workQueue", DISPATCH_QUEUE_SERIAL);
        // AFHTTPSessionManager的完成队列，先使其进入异步线程队列，baseRequest再回去主线程
        _shareClient.completionQueue = dispatch_queue_create("com.shareClient.completionQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    return _shareClient;
}

- (id)initWithBaseURL:(NSURL *)url{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    return self;
}

- (BOOL)isHttpQueueFinished:(NSArray *)httpUrlArray{
    if(self.tasks.count == 0){
        return YES;
    }
    
    //add filter urlString.length==0
    NSMutableArray* urlArray = [NSMutableArray array];
    for (NSString* currentUrl in httpUrlArray) {
        if (currentUrl.length != 0) {
            [urlArray addObject:currentUrl];
        }
    }
    
    //urlArray is empty
    if(urlArray.count == 0){
        return YES;
    }
    
    for (NSURLSessionTask *task in self.tasks) {
        NSString *taskUrl = task.currentRequest.URL.absoluteString;
        for (NSString *baseUrl in urlArray) {
            if([taskUrl rangeOfString:baseUrl].location != NSNotFound){
                return NO;
            }
        }
    }
    
    return YES;
}

- (void)cancelTasksWithUrl:(NSString *)url{
    for (NSURLSessionTask *task in self.tasks) {
        NSString *taskUrl = task.currentRequest.URL.absoluteString;
        if([taskUrl rangeOfString:url].location != NSNotFound){
            [task cancel];
        }
    }
}

@end
