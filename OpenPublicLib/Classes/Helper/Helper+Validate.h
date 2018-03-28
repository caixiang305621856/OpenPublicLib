//
//  Helper+Validate.h
//  PublicProject
//
//  Created by verne on 16/6/20.
//  Copyright © 2016年 vernepung. All rights reserved.
//

#import "Helper.h"

@interface Helper (Validate)
/**
 @brief 是否是空字符串
 */
+ (BOOL)isBlankString:(NSString *)string;

/**
 是否是同一天(年月日相等

 @param date1 第一个时间
 @param date2 第二个时间
 @return 是否为同一天
 */
+ (BOOL)isSameDay:(NSDate *)date1 otherDay:(NSDate *)date2;
/**
 @brief 是否为正数
 */
+ (BOOL)isPositiveNumber:(NSString *)numStr;
/**
 @brief 通过正则表达式判断是否是手机号码
 */
+ (BOOL)isMobileNumber:(NSString *)mobileNum;
/**
 @brief 是否为Int
 */
+ (BOOL)isPureInt:(NSString *)string;
+ (BOOL)isPureFloat:(NSString *)string;
/**
 @brief 通过正则表达式判断是否是身份证号码
 */
+ (BOOL)isValidIdentityCard: (NSString *)identityCard;
/**
 @brief 检查银行卡是否合法(Luhn算法)
 */
+ (BOOL)isValidCardNumber:(NSString *)cardNumber;

/**
 @brief 判断是不是正确邮箱
 */
+ (BOOL)isValidEmail:(NSString *)email;
@end
