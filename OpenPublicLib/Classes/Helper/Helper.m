//
//  Helper.m
//
//
//  Created by vernepung on 14-5-6.
//

#import "Helper.h"
#include <sys/utsname.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <objc/runtime.h>
#import  <CommonCrypto/CommonCryptor.h>
#import <EventKit/EventKit.h>
#import "PathMacro.h"
#import "Helper+Validate.h"

NSString *const kDefaultDateFormatterStr = @"yyyy-MM-dd HH:mm:ss";

@interface Helper(){
    
}
@end

static NSDateFormatter *dateFormatter;
@implementation Helper
#pragma mark - 一些常用的公共方法
+ (NSDateFormatter *)dateFormatter{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    });
    return dateFormatter;
}

+ (NSMutableAttributedString *)setNSStringCorlor:(NSString *)content positon:(NSDictionary*)positionDict withColor:(UIColor*)color {
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:content];
    for (int i=0;i<positionDict.allKeys.count;i++) {
        NSString* key = positionDict.allKeys[i];
        NSString* val = positionDict[key];
        [str addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange([key intValue],[val intValue])];
    }
    return str;
}

+(void)synchronizedToCalendarTitle:(NSString *)title location:(NSString *)location {
    //事件市场
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    //6.0及以上通过下面方式写入事件
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        // the selector is available, so we must be on iOS 6 or newer
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    // display error message here
                } else if (!granted) {
                    //被用户拒绝，不允许访问日历
                    // display access denied error message here
                } else {
                    // access granted
                    // ***** do the important stuff here *****
                    
                    //事件保存到日历
                    
                    
                    //创建事件
                    EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
                    event.title     = title;
                    event.location = location;
                    
                    NSDateFormatter *tempFormatter = [self dateFormatter];
                    [tempFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
                    
                    event.startDate = [[NSDate alloc]init ];
                    event.endDate   = [[NSDate alloc]init ];
                    event.allDay = YES;
                    
                    //添加提醒
                    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -60.0f * 24]];
                    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -15.0f]];
                    
                    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
                    NSError *err;
                    [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
                    
                }
            });
        }];
    }
}

+ (NSDictionary*)parserJsonData:(NSData *)jsonData {
    NSError *error;
    NSDictionary* jsonResult = nil;
    if (jsonData&&[jsonData isKindOfClass:[NSData class]]) {
        jsonResult = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    }
    if (jsonResult && !error) {
        return jsonResult;
    }else{
        // 解析错误
        return nil;
    }
}

+ (NSString *)jsonStringFromObject:(id)object {
    if([NSJSONSerialization isValidJSONObject:object]){
        NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return jsonString;
    }
    return @"";
}

#pragma mark - 文件系统的操作方法
+ (NSArray<NSString *> *)getAllBundleFilesWithExt:(NSString *)ext {
    NSArray<NSBundle *> *bundles = [NSBundle allBundles];
    NSMutableArray<NSString *> *allFiles = [NSMutableArray array];
    if (bundles.count > 0 && ![self isBlankString:ext]) {
        dispatch_queue_t disqueue =  dispatch_queue_create([[@"getAllBundleFilesWithExt" stringByAppendingString:ext] cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_CONCURRENT);
        dispatch_group_t group = dispatch_group_create();
        [bundles enumerateObjectsUsingBlock:^(NSBundle * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            dispatch_group_async(group, disqueue, ^{
                [allFiles addObjectsFromArray:[self getFilesWithDirectory:obj.bundlePath withExt:ext]];
            });
        }];
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    }else{
        [bundles enumerateObjectsUsingBlock:^(NSBundle * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [allFiles addObjectsFromArray:[self getFilesWithDirectory:obj.bundlePath withExt:ext]];
        }];
    }
    return allFiles;
}

+ (NSArray<NSString *> *)getFilesWithDirectory:(NSString *)dire withExt:(NSString *)ext {
    NSMutableArray<NSString *> *allFiles = [NSMutableArray array];
    NSArray<NSString *> *files = [[NSFileManager defaultManager] subpathsAtPath:dire];
    if (![Helper isBlankString:ext]) {
        [files enumerateObjectsUsingBlock:^(NSString * _Nonnull file, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[file pathExtension] isEqualToString:ext]) {
                [allFiles addObject:[dire stringByAppendingPathComponent:file]];
            }
        }];
        return allFiles;
    }else{
        return files;
    }
}

+ (BOOL)createFolder:(NSString*)folderPath isDirectory:(BOOL)isDirectory {
    NSString *path = nil;
    if (isDirectory) {
        path = folderPath;
    } else {
        path = [folderPath stringByDeletingLastPathComponent];
    }
    
    if (folderPath && [[NSFileManager defaultManager] fileExistsAtPath:path] == NO) {
        NSError *error = nil;
        BOOL ret;
        ret = [[NSFileManager defaultManager] createDirectoryAtPath:path
                                        withIntermediateDirectories:YES
                                                         attributes:nil
                                                              error:&error];
        if(!ret && error) {
            NSLog(@"create folder failed at path '%@',error:%@,%@",folderPath,[error localizedDescription],[error localizedFailureReason]);
            return NO;
        }
    }
    return YES;
}

+ (NSString*)getPathInUserDocument:(NSString*) aPath{
    NSString *fullPath = @"";
    NSString *documentPath = VPDocumentPath();
    if (![Helper isBlankString:documentPath]) {
        fullPath = [fullPath stringByAppendingPathComponent:aPath];
    }
    return fullPath;
}

+ (NSString *)formatFileSize:(int)fileSize {
    float size = fileSize;
    size = size / 1024.0f;
    if (size < 1023) {
        return([NSString stringWithFormat:@"%1.2f KB",size]);
    }
    
    size = size / 1024.0f;
    if (size < 1023) {
        return([NSString stringWithFormat:@"%1.2f MB",size]);
    }
    
    size = size / 1024.0f;
    return [NSString stringWithFormat:@"%1.2f GB",size];
}

+ (NSDate*)dateOfFileCreateWithFolderName:(NSString *)folderName cacheName:(NSString *)cacheName {
    NSString *folder = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:folderName];
    NSString *filePath = [folder stringByAppendingPathComponent:cacheName];
    NSError *error;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
    if(!error) {
        return [attributes objectForKey:NSFileCreationDate];
    }
    return nil;
}

+ (unsigned long long)sizeOfFile:(NSString *)path {
    NSError *error;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    if(!error) {
        return (unsigned long long)[attributes fileSize];
    }
    return 0;
}

+ (unsigned long long)sizeOfFolder:(NSString *)folderPath {
    NSError *error;
    NSArray *contents = [[NSFileManager defaultManager] subpathsAtPath:folderPath];
    NSEnumerator *enumerator = [contents objectEnumerator];
    unsigned long long totalFileSize = 0;
    
    NSString *path = nil;
    while (path = [enumerator nextObject]) {
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:path] error:&error];
        totalFileSize += [attributes fileSize];
    }
    return totalFileSize;
}

+ (void)removeContentsOfFolder:(NSString *)folderPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager subpathsAtPath:folderPath];
    NSEnumerator *enumerator = [contents objectEnumerator];
    NSString *file;
    while (file = [enumerator nextObject]) {
        NSString *path = [folderPath stringByAppendingPathComponent:file];
        [fileManager removeItemAtPath:path error:nil];
    }
}

+ (void)deleteContentsOfFolder:(NSString *)folderPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:folderPath error:nil];
    
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

#pragma mark - calculate font size
+ (CGFloat)widthForLabelWithString:(NSString *)labelString withFontSize:(CGFloat)fontsize withWidth:(CGFloat)width withHeight:(CGFloat)height {
    return [[self class] widthForLabelWithString:labelString font:[UIFont systemFontOfSize:fontsize] maxWidth:width maxHeight:height];
}

+ (CGFloat)widthForLabelWithString:(NSString *)string font:(UIFont *)font maxWidth:(CGFloat)width maxHeight:(CGFloat)height {
    return [[self class] sizeForLabelWithString:string font:font constrainedToSize:CGSizeMake(width, height)].width;
}

+ (CGFloat)heightForLabelWithString:(NSString *)labelString withFontSize:(CGFloat)fontsize withWidth:(CGFloat)width withHeight:(CGFloat)height {
    return [[self class] heightForLabelWithString:labelString font:[UIFont systemFontOfSize:fontsize] maxWidth:width maxHeight:height];
}

+ (CGFloat)heightForLabelWithString:(NSString *)string font:(UIFont *)font maxWidth:(CGFloat)width maxHeight:(CGFloat)height {
    return [[self class] sizeForLabelWithString:string font:font constrainedToSize:CGSizeMake(width, height)].height;
}

+ (CGSize)sizeForLabelWithString:(NSString *)string withFontSize:(CGFloat)fontsize constrainedToSize:(CGSize)size {
    return [[self class] sizeForLabelWithString:string font:[UIFont systemFontOfSize:fontsize] constrainedToSize:size];
}

+ (CGSize)sizeForLabelWithString:(NSString *)string font:(UIFont *)font constrainedToSize:(CGSize)size {
    if(string.length == 0){
        return CGSizeMake(0, 0);
    }
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    CGSize actualsize = [string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading  attributes:tdic context:nil].size;
    return actualsize;
}
#pragma mark - 时间格式转换
+ (NSString *)getTimeStamp {
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
    return timeString;
}

+ (NSString *)formatDateWithString:(NSString *)dateString format:(NSString *)format {
    return [[self class] formatDateString:dateString withFormatStr:format];
}

+ (NSString *)formatDateString:(NSString *)dateString withFormatStr:(NSString *)formatStr {
    NSDateFormatter *dateFormatter = [self dateFormatter];
    dateFormatter.dateFormat = kDefaultDateFormatterStr;
    NSDate *date = [dateFormatter dateFromString:dateString];
    return [Helper formateDate:date withFormatStr:formatStr];
}

+ (NSDate *)dateValueWithString:(NSString *)dateStr ByFormatter:(NSString *)formatter {
    return [[self class] dateFromDateString:dateStr withOriginFormatStr:formatter];
}

+ (NSDate *)dateFromDateString:(NSString *)dateStr withOriginFormatStr:(NSString *)formatStr {
    NSDateFormatter *dateFormatter = [self dateFormatter];
    dateFormatter.dateFormat = formatStr;
    return [dateFormatter dateFromString:dateStr];
}

+ (NSString *)formatDateWithDate:(NSDate *)date format:(NSString *)format {
    return [[self class] formateDate:date withFormatStr:format];
}

+ (NSString *)formateDate:(NSDate *)date withFormatStr:(NSString *)formatStr {
    NSDateFormatter *dateFormatter = [self dateFormatter];
    [dateFormatter setDateFormat:formatStr];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)weekdayStringValue:(NSDate*)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger unitFlags = NSCalendarUnitWeekOfMonth|NSCalendarUnitWeekday;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    int weekday=(int)[comps weekday];
    switch (weekday)
    {
        case 1:
            return @"周日";
            break;
        case 2:
            return @"周一";
            break;
        case 3:
            return @"周二";
            break;
        case 4:
            return @"周三";
            break;
        case 5:
            return @"周四";
            break;
        case 6:
            return @"周五";
            break;
        case 7:
            return @"周六";
            break;
            
        default:
            break;
    }
    return nil;
}

+ (NSInteger)monthFromDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    return [comps month];
}

+ (NSString *)formatTimeInterval:(NSTimeInterval)timeInterval format:(NSString *)format {
    if (timeInterval <= 0) {
        return [NSDate date];
    }
    return [self dateStringWithTimeInterval:timeInterval withFormatStr:format];
}

+ (NSString *)dateStringWithTimeInterval:(NSTimeInterval)interval withFormatStr:(NSString *)formatStr {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    return [self formateDate:date withFormatStr:formatStr];
}

+ (NSDate *)dateFromTimeInterval:(NSTimeInterval)timeInterval withFormatter:(NSString *)formatter{
    if (timeInterval >= 0) {
        if (formatter.length <= 0) {
            formatter = kDefaultDateFormatterStr;
        }
        NSDateFormatter *inputFormatter = [self dateFormatter];
        NSString *timeString = [Helper formatTimeInterval:timeInterval format:formatter];
        return [inputFormatter dateFromString:[timeString copy]];
    }
    return [NSDate date];
}

+ (NSDate *)dateWithTimeInterval:(NSTimeInterval)interval withFormatStr:(NSString *)formatStr {
    if (interval <= 0) {
        return [NSDate date];
    }
    NSDateFormatter *inputFormatter = [self dateFormatter];
    NSString *timeString = [Helper dateStringWithTimeInterval:interval withFormatStr:formatStr];
    return [inputFormatter dateFromString:[timeString copy]];
}

+ (NSString *)getTimeIntervalWithTime:(NSTimeInterval)timeInterval {
    NSInteger intTime = timeInterval;
    NSInteger seconds = intTime % 60;
    NSInteger minutes = (intTime / 60) % 60;
    NSInteger hours = (intTime / 3600);
    NSString *timeStr = [NSString stringWithFormat:@"%2zd小时%2zd分%2zd秒", hours, minutes, seconds];
    return timeStr;
}

+ (NSString *)fillZeroWithString:(NSString *)str {
    if (str && str.length == 1)
    {
        return [NSString stringWithFormat:@"0%@",str];
    }
    return str;
}

+ (NSString *)getLeftTimeWithStartTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime {
    double timeInterval = endTime - startTime;
    NSInteger secondsInDay = 24*60*60;
    NSInteger day = (NSInteger)timeInterval/secondsInDay;
    //    NSInteger hour = (timeInterval - day*secondsInDay)/(60*60);
    //    NSInteger mini = (timeInterval - day*secondsInDay - hour*60*60)/60;
    //    NSInteger second = timeInterval - day*secondsInDay - hour*60*60 - mini*60;
    return [NSString stringWithFormat:@"%zd天",day];
}

#pragma mark - 归档，解归档
+ (NSData *)archiverObject:(NSObject *)object forKey:(NSString *)key {
    if(object == nil) {
        return nil;
    }
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:object forKey:key];
    [archiver finishEncoding];
    return data;
}

+ (NSObject *)unarchiverObject:(NSData *)archivedData withKey:(NSString *)key {
    if(archivedData == nil) {
        return nil;
    }
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:archivedData];
    NSObject *object = [unarchiver decodeObjectForKey:key];
    [unarchiver finishDecoding];
    
    return object;
}

#pragma mark - 从NSUserDefaults取值或存值
+ (id)valueForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}

+ (void)setValue:(id)value forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
#pragma mark - 字符串格式化或单位换算
+ (NSString *)friendFormatString:(NSString *)sourceStr{
    if(![Helper isBlankString:sourceStr]){
        return nil;
    }
    //各四个字符插入一个空字符
    NSMutableString *targetStr = [NSMutableString stringWithString:sourceStr];
    for(int i = 4, k = 4; i < sourceStr.length; i += 4, k = i+1){
        [targetStr insertString:@" " atIndex:k];
    }
    return [NSString stringWithFormat:@"%@", targetStr];
}

+(NSString *)trimright0:(double )param {
    NSString *str = [NSString stringWithFormat:@"%.2lf",param];
    NSUInteger len = str.length;
    for (int i = 0; i < len; i++)
    {
        if (![str  hasSuffix:@"0"])
            break;
        else
            str = [str substringToIndex:[str length]-1];
    }
    if ([str hasSuffix:@"."])//避免像2.0000这样的被解析成2.
    {
        //        return [NSString stringWithFormat:@"%@0", str];
        return  [str substringToIndex:[str length]-1];
    }
    else
    {
        return str;
    }
}
@end
