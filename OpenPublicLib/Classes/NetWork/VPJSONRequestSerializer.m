//
//  PPHTTPRequestSerializer.m
//  PublicProject
//
//  Created by user on 15/5/13.
//  Copyright (c) 2015年 vernepung. All rights reserved.
//

#import "VPJSONRequestSerializer.h"
#import "VPNetConfig.h"

@implementation VPJSONRequestSerializer

- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request withParameters:(id)parameters error:(NSError *__autoreleasing *)error{
    NSParameterAssert(request);
    
    if ([self.HTTPMethodsEncodingParametersInURI containsObject:[[request HTTPMethod] uppercaseString]]) {
        return [super requestBySerializingRequest:request withParameters:parameters error:error];
    }
    // 处理请求
    id requestContent = [[VPNetConfig defaultConfig] handleOnRequest:request parameters:[parameters copy]];
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    // 设置请求头
    NSDictionary *httpRequestHeaderDic = [[VPNetConfig defaultConfig] requestHttpHeader];
    [httpRequestHeaderDic enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
        if (![request valueForHTTPHeaderField:field]) {
            [mutableRequest setValue:value forHTTPHeaderField:field];
        }
    }];
    // 设置传输内容格式
    if (![mutableRequest valueForHTTPHeaderField:@"Content-Type"]) {
        [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    // 开启gzip
    if (![mutableRequest valueForHTTPHeaderField:@"Accept-Encoding"]){
        [mutableRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    }
    // NOTE:RequestBody
    if([requestContent isKindOfClass:[NSData class]]){
        [mutableRequest setHTTPBody:requestContent];
    }else if([NSJSONSerialization isValidJSONObject:requestContent]){
        [mutableRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:requestContent options:0 error:error]];
    }else if(parameters){
        [mutableRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:self.writingOptions error:error]];
    }
    
    return mutableRequest;
}
@end
