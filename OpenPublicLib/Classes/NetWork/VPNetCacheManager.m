//
//  VPRequestCacheManager.m
//  teacherSecretary
//
//  Created by verne on 16/7/18.
//  Copyright © 2016年 vernepung. All rights reserved.
//
#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import "VPNetCacheManager.h"
#import "FMDB.h"

NSString * const requestCacheFloderName = @"vpnetworkCache";
NSString * const cacheDBFileName = @"vpcache.db";
NSString * const cacheDBVersionKey = @"cacheDBVersionKey";
VPNetCacheManager *cacheManager;
@interface VPNetCacheManager(){
    
}
@property (strong, nonatomic) FMDatabase *cacheDB;
@property (strong, nonatomic) FMDatabaseQueue *cacheQueue;
@end


@implementation VPNetCacheManager
- (void)dealloc{
    
}

- (void)createDB{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbFloderPath = [cachePath stringByAppendingPathComponent:requestCacheFloderName];
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if (![manager fileExistsAtPath:dbFloderPath isDirectory:&isDir]){
        [manager createDirectoryAtPath:dbFloderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *dbPath = [dbFloderPath stringByAppendingPathComponent:[cacheDBFileName copy]];
    cacheManager.cacheDB = [[FMDatabase alloc]initWithPath:dbPath];
    cacheManager.cacheQueue = [[FMDatabaseQueue alloc]initWithPath:dbPath];
    
    [cacheManager.cacheQueue inDatabase:^(FMDatabase *db) {
        // 创建缓存表
        BOOL createSuccess = [db executeUpdate:@"CREATE TABLE if not exists requestCache (cacheId integer PRIMARY KEY AUTOINCREMENT NOT NULL,encryptKey char(128) UNIQUE NOT NULL,usedTime float NOT NULL,cacheKey char(128));"];
        if (!createSuccess) {
            @throw [NSException new];
        }else{
            
        }
    }];
}

- (NSInteger)dbVersion{
    return [[NSUserDefaults standardUserDefaults] integerForKey:[cacheDBVersionKey copy]];
}

- (void)setDBVersion:(NSInteger)version{
    [[NSUserDefaults standardUserDefaults] setInteger:version forKey:[cacheDBVersionKey copy]];
}

+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cacheManager = [[VPNetCacheManager alloc]init];
        [cacheManager createDB];
    });
    return cacheManager;
}

- (void)cleanupCache{
    [cacheManager.cacheDB close];
//    NSString *sql = @"delete from requestCache;";
//    [cacheManager.cacheQueue inDatabase:^(FMDatabase *db) {
//        [db executeUpdate:sql];
//    }];
//
    
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbFloderPath = [cachePath stringByAppendingPathComponent:requestCacheFloderName];
    NSArray<NSString *> *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dbFloderPath error:NULL];
    [files enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[NSFileManager defaultManager]
         removeItemAtPath:[self filePathWithFileName:obj] error:NULL];
    }];
    [[NSFileManager defaultManager] removeItemAtPath:dbFloderPath error:NULL];
    [cacheManager createDB];
}

/**
 *  删除过期缓存和缓存文件
 */
- (void)removeExpiredCache{
    NSTimeInterval interval = 7 * 24 * 60 * 60;
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval oldestInterval = now - interval;
    
    NSString *sql = [NSString stringWithFormat:@"select cacheId,encryptKey from requestCache where usedTime < %f;",oldestInterval];
    [cacheManager.cacheQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql];
        while (resultSet.next) {
            int index = [resultSet intForColumnIndex:0];
            NSString *fileName = [resultSet stringForColumnIndex:1];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSString *filePath = [self filePathWithFileName:[fileName stringByAppendingPathExtension:@"cache"]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                }
            });
            NSString *sql1 = [NSString stringWithFormat:@"delete from requestCache where cacheId = %zd;",index];
            [db executeUpdate:sql1];
        }
        [resultSet close];
    }];
}

- (void)cacheWithEncryptKey:(NSString *)encryptKey cacheKey:(NSString *)cacheKey{
    BOOL isExists = [self existsCacheWithEncryptKey:encryptKey];
    [cacheManager.cacheQueue inDatabase:^(FMDatabase *db) {
        if (!isExists){
            NSString *sql = [NSString stringWithFormat:@"insert into requestCache (encryptKey,usedTime,cacheKey) VALUES ('%@',%f,'%@');",encryptKey,[[NSDate date] timeIntervalSince1970],cacheKey?:@""];
            BOOL insertSuccess = [db executeUpdate:sql];
            if (!insertSuccess){
                [[NSFileManager defaultManager] removeItemAtPath:[self filePathWithFileName:[encryptKey stringByAppendingPathComponent:@"cache"]] error:nil];
                return ;
            }
        }else{
            NSString *sql = [NSString stringWithFormat:@"update requestCache set usedTime = %f ,cacheKey = '%@' where encryptKey = '%@';",[[NSDate date] timeIntervalSince1970],cacheKey?:@"",encryptKey];
            BOOL updateSuccess = [db executeUpdate:sql];
            if (!updateSuccess){
                NSAssert(!updateSuccess, @"update fail");
                return;
            }
        }
    }];
}

- (BOOL)existsCacheWithEncryptKey:(NSString *)encryptKey{
    __block BOOL isExists = NO;
    NSString *sql = [NSString stringWithFormat:@"select usedTime from requestCache where encryptKey = '%@';",encryptKey];
    [cacheManager.cacheQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql];
        isExists = resultSet.next;
        [resultSet close];
    }];
    return isExists;
}

//- (BOOL)updateCacheWithEncryptKey:(NSString *)encryptKey{
//    __block BOOL isUpdated = NO;
//    [cacheManager.cacheQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
//        BOOL updateSuccess = [db executeUpdate:@"update requestCache set usedTime = ? where encryptKey = ?",[[NSDate date] timeIntervalSince1970],encryptKey];
//        if (updateSuccess){
//            isUpdated = YES;
//        }else{
//            *rollback = YES;
//        }
//    }];
//    return isUpdated;
//}

- (NSString *)filePathWithFileName:(NSString *)fileName{
    
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbFloderPath = [cachePath stringByAppendingPathComponent:requestCacheFloderName];
    return [dbFloderPath stringByAppendingPathComponent:fileName];
}

//- (BOOL)existsTableWithTableName:(NSString *)tableName{
//    NSString *sql = @"select count(*) as 'count' from sqlite_master where type ='table' and name = ?";
//    return YES;
//}

@end
