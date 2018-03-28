//
//  PPAFHTTPClient.h
//  PublicProject
//
//  Created by vernepung on 15/5/5.
//  Copyright (c) 2015年 vernepung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

typedef void (^PPRequestResultBlock)(id result, NSError *err);
@interface VPHTTPSessionManager : AFHTTPSessionManager

/** 发送网络请求的工作队列，此队列是一个线性队列 */
@property (nonatomic, strong) dispatch_queue_t workQueue;

+ (VPHTTPSessionManager*)shareManager;

/** 判断一组请求是否已经请求完成 */
- (BOOL)isHttpQueueFinished:(NSArray*)httpUrlArray;

/** 取消请求 */
- (void)cancelTasksWithUrl:(NSString *)url;

@end
