//
//  VPRequestCacheManager.h
//  Admissions
//
//  Created by verne on 16/7/18.
//  Copyright © 2016年 vernepung. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface VPNetCacheManager : NSObject

+ (instancetype)shareManager;
- (void)cleanupCache;
- (void)removeExpiredCache;
- (BOOL)existsCacheWithEncryptKey:(NSString *)encryptKey;
- (void)cacheWithEncryptKey:(NSString *)encryptKey cacheKey:(NSString *)cacheKey;

- (NSString *)filePathWithFileName:(NSString *)fileName;
    
@end
