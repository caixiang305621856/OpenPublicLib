//
//  Helper.h
//  
//
//  Created by vernepung on 14-5-6.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const kDefaultDateFormatterStr;

@interface Helper : NSObject
#pragma mark - 一些常用的公共方法
/**
 *@brief 获取默认时间格式化实例对象,默认格式化dateZone为UTC
 */
+ (NSDateFormatter *)dateFormatter;
/**
 根据传入字符串,进行区域颜色更改
 
 @param content 文字
 @param positionDict 位置字典
 @param color 颜色
 @return AttributedString
 */
+ (NSMutableAttributedString *)setNSStringCorlor:(NSString *)content positon:(NSDictionary*)positionDict withColor:(UIColor*)color;

/**
 *@brief 同步日历
 */
+ (void)synchronizedToCalendarTitle:(NSString *)title location:(NSString *)location;

/**
 *    @brief    将json数据转换成NSDictionary
 *    @param jsonData 数据
 *    @return     NSDictionary类型的数据
 */
+ (NSDictionary*)parserJsonData:(NSData *)jsonData;

/**
 *@brief 将对象转化为json字符串
 */
+ (NSString *)jsonStringFromObject:(id)object;

#pragma mark - 文件系统的操作方法
+ (NSArray<NSString *> *)getAllBundleFilesWithExt:(NSString *)ext;
/** 创建文件夹 */
+ (BOOL)createFolder:(NSString*)folderPath isDirectory:(BOOL)isDirectory;

/** 得到用户document中的一个路径 */
+ (NSString*)getPathInUserDocument:(NSString *)fileName;

/** 将文件大小格式化，按照KB\M\G的方式展示*/
+ (NSString *)formatFileSize:(int)fileSize;

/** 文件创建日期 */
+ (NSDate *)dateOfFileCreateWithFolderName:(NSString *)folderName cacheName:(NSString *)cacheName;

/** 统计某个文件的磁盘空间大小 */
+ (unsigned long long)sizeOfFile:(NSString *)path;

/** 统计某个文件夹的磁盘空间大小 */
+ (unsigned long long)sizeOfFolder:(NSString*)folderPath;

/** 移除某个文件夹下的所有文件 */
+ (void)removeContentsOfFolder:(NSString *)folderPath;

/** 移除某个文件夹下的所有文件(非变例)并重新创建被删除的文件夹 */
+ (void) deleteContentsOfFolder:(NSString *)folderPath;

#pragma mark - calculate font size
/**
 *@brief 根据字符串获取label的高度
 *@param labelString label的text
 *@param fontSize label的字体大小，以systemFont为标准
 *@param width 最大宽度
 *@param height 最大高度
 */
+ (CGFloat)heightForLabelWithString:(NSString *)labelString withFontSize:(CGFloat)fontSize withWidth:(CGFloat)width withHeight:(CGFloat)height;
+ (CGFloat)heightForLabelWithString:(NSString *)string font:(UIFont *)font maxWidth:(CGFloat)width maxHeight:(CGFloat)height;

/**
 *@brief 根据字符串获取label的宽度
 *@param labelString label的text
 *@param fontsize label的字体大小，以systemFont为标准
 *@param width 最大宽度
 *@param height 最大高度
 */
+ (CGFloat)widthForLabelWithString:(NSString *)labelString withFontSize:(CGFloat)fontsize withWidth:(CGFloat)width withHeight:(CGFloat)height;
+ (CGFloat)widthForLabelWithString:(NSString *)string font:(UIFont *)font maxWidth:(CGFloat)width maxHeight:(CGFloat)height;

/**
 *@brief 根据字符串获取label的尺寸
 *@param string label的text
 *@param fontsize label的字体
 *@param size 限制的最大尺寸
 */
+ (CGSize)sizeForLabelWithString:(NSString *)string withFontSize:(CGFloat)fontsize constrainedToSize:(CGSize)size;
+ (CGSize)sizeForLabelWithString:(NSString *)string font:(UIFont *)font constrainedToSize:(CGSize)size;

#pragma mark - 时间格式转换
/**
 *@brief 获取当前时间戳，并转化为字符串
 **/
+ (NSString *)getTimeStamp;
/**
 *@brief 将date按照format格式转化为字符串
 */
+ (NSString *)formatDateWithDate:(NSDate *)date format:(NSString *)format NS_DEPRECATED_IOS(2_0, 5_0, "请使用 [Helper formateDate:withFormatStr:]");
+ (NSString *)formateDate:(NSDate *)date withFormatStr:(NSString *)formatStr;
/**
 *@brief 将时间格式字符串按照format格式转化为需要的时间格式字符串
 */
+ (NSString *)formatDateWithString:(NSString *)dateString format:(NSString *)format NS_DEPRECATED_IOS(2_0, 5_0, "请使用 [Helper formatDateString:withFormatStr:]");
+ (NSString *)formatDateString:(NSString *)dateString withFormatStr:(NSString *)formatStr;
/**
 *@brief 将时间格式字符串转化为date
 */
+ (NSDate *)dateValueWithString:(NSString *)dateStr ByFormatter:(NSString *)formatter NS_DEPRECATED_IOS(2_0, 5_0, "请使用 [Helper dateFromDateString:withOriginFormatStr:]");
+ (NSDate *)dateFromDateString:(NSString *)dateStr withOriginFormatStr:(NSString *)formatStr;
/**
 *@brief 将时间戳按照format格式化为字符串
 *@param timeInterval 1970开始的时间戳
 */
+ (NSString *)formatTimeInterval:(NSTimeInterval)timeInterval format:(NSString *)format NS_DEPRECATED_IOS(2_0, 5_0, "请使用 [Helper dateStringWithTimeInterval:withFormatStr:]");
+ (NSString *)dateStringWithTimeInterval:(NSTimeInterval)interval withFormatStr:(NSString *)formatStr;
/**
 *  @param timeInterval 时间戳
 *
 *  @return 日期
 */
+ (NSDate *)dateFromTimeInterval:(NSTimeInterval)timeInterval withFormatter:(NSString *)formatter NS_DEPRECATED_IOS(2_0, 5_0, "请使用 [Helper dateWithTimeInterval:withFormatStr:]");
+ (NSDate *)dateWithTimeInterval:(NSTimeInterval)interval withFormatStr:(NSString *)formatStr;
/**
 *@brief 给出date，返回这个时间点是周几
 */
+ (NSString *)weekdayStringValue:(NSDate*)date;
/**
 *
 *根据日期 返回月份
 */
+ (NSInteger)monthFromDate:(NSDate *)date;

/**
 *@brief 将时间戳转换成时分秒
 */
+(NSString *)getTimeIntervalWithTime:(NSTimeInterval)timeInterval;
/**
 *  时间补0
 *
 *  @param str str description
 *
 *  @return return value description
 */
+ (NSString *)fillZeroWithString:(NSString *)str;

/**
 *@brief 计算开始时间与结束时间中间相隔xx天
 *@param startTime 开始时间
 *@param endTime 结束时间
 */
+(NSString *)getLeftTimeWithStartTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime;

#pragma mark - 归档，解归档
+ (NSData *)archiverObject:(NSObject *)object forKey:(NSString *)key;
+ (NSObject *)unarchiverObject:(NSData *)archivedData withKey:(NSString *)key;

#pragma mark - 从NSUserDefaults取值或存值
+ (id)valueForKey:(NSString *)key;
+ (void)setValue:(id)value forKey:(NSString *)key;

#pragma mark - 字符串格式化或单位换算
/**
 *@brief 对数字字符串进行友好的格式化，每四个空一格
 */
+ (NSString *)friendFormatString:(NSString *)sourceStr;
/**
 *@brief 去掉小数点后面多余的0并且只保留两位小数
 */
+(NSString *)trimright0:(double )param;

@end
