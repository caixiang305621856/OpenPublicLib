//
//  Helper+Validate.m
//  PublicProject
//
//  Created by verne on 16/6/20.
//  Copyright © 2016年 vernepung. All rights reserved.
//

#import "Helper+Validate.h"

@implementation Helper (Validate)
+ (BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return ([scan scanInt:&val] && [scan isAtEnd]);
}

+ (BOOL)isPureFloat:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return ([scan scanFloat:&val] && [scan isAtEnd]);
}

// 正则判断手机号码
+ (BOOL)isMobileNumber:(NSString *)mobileNum {
    //NSString *str = @"^13\\d{9}|14[57]\\d{8}|15[012356789]\\d{8}|18\\d{9}$";
    //增加170字段判断
    NSString *str = @"^13\\d{9}|14[57]\\d{8}|15[012356789]\\d{8}|1\\d{10}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)) {
        return YES;
    } else {
        return NO;
    }
}

//身份证号
+ (BOOL)isValidIdentityCard: (NSString *)identityCard{
    if (identityCard.length != 18) {
        return  NO;
    }
    NSArray* codeArray = [NSArray arrayWithObjects:@"7",@"9",@"10",@"5",@"8",@"4",@"2",@"1",@"6",@"3",@"7",@"9",@"10",@"5",@"8",@"4",@"2", nil];
    NSDictionary* checkCodeDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"1",@"0",@"X",@"9",@"8",@"7",@"6",@"5",@"4",@"3",@"2", nil]  forKeys:[NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10", nil]];
    
    NSScanner* scan = [NSScanner scannerWithString:[identityCard substringToIndex:17]];
    
    int val;
    BOOL isNum = [scan scanInt:&val] && [scan isAtEnd];
    if (!isNum) {
        return NO;
    }
    int sumValue = 0;
    
    for (int i =0; i<17; i++) {
        sumValue+=[[identityCard substringWithRange:NSMakeRange(i , 1) ] intValue]* [[codeArray objectAtIndex:i] intValue];
    }
    
    NSString* strlast = [checkCodeDic objectForKey:[NSString stringWithFormat:@"%d",sumValue%11]];
    
    if ([strlast isEqualToString: [[identityCard substringWithRange:NSMakeRange(17, 1)]uppercaseString]]) {
        return YES;
    }
    return  NO;
}
/**
 *	@brief	判断是不是电话号码
 *
 *	@return	 bool
 */
+ (BOOL)isPhoneNumber:(NSString*) number
{
    NSString *str = @"^((0\\d{2,3}-\\d{7,8})|(1[3458]\\d{9}))$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
    if (([regextestmobile evaluateWithObject:number] == YES)) {
        return YES;
    } else {
        return NO;
    }
}



/**
 判断是不是正确邮箱

 @param email 邮箱账号
 @return YES 正确邮箱  NO 错误邮箱
 */
+ (BOOL)isValidEmail:(NSString *)email {
    NSString *regex = @"^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)+$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [emailTest evaluateWithObject:email];
}

//剔除卡号里的非法字符
+ (NSString *)getDigitsOnly:(NSString*)s
{
    NSString *digitsOnly = @"";
    char c;
    for (int i = 0; i < s.length; i++)
    {
        c = [s characterAtIndex:i];
        if (isdigit(c))
        {
            digitsOnly =[digitsOnly stringByAppendingFormat:@"%c",c];
        }
    }
    return digitsOnly;
}

+ (BOOL)isValidCardNumber:(NSString *)cardNumber
{
    NSString *digitsOnly = [self getDigitsOnly:cardNumber];
    int sum = 0;
    int digit = 0;
    int addend = 0;
    BOOL timesTwo = false;
    for (NSInteger i = digitsOnly.length - 1; i >= 0; i--)
    {
        digit = [digitsOnly characterAtIndex:i] - '0';
        if (timesTwo)
        {
            addend = digit * 2;
            if (addend > 9) {
                addend -= 9;
            }
        }
        else {
            addend = digit;
        }
        sum += addend;
        timesTwo = !timesTwo;
    }
    int modulus = sum % 10;
    return modulus == 0;
}

+(BOOL) isPostalcode:(NSString*) code{
    
    NSString *str = @"^[0-9]\\d{5}$";
    NSPredicate *regextestPostalcode = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
    if (([regextestPostalcode evaluateWithObject:code] == YES)) {
        return YES;
    } else {
        return NO;
    }
}

/** 是否为数字字符串 */
+ (BOOL)isPositiveNumber:(NSString *)numStr{
    NSString *regexStr = @"\\d+|\\d+\\.\\d+|\\.\\d+|\\d+.";
    NSPredicate *regextestPostalcode = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexStr];
    if (([regextestPostalcode evaluateWithObject:numStr] == YES)) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL) isBlankString:(NSString *)string {
    if (![string isKindOfClass:[NSString class]]) {
        return YES;
    }
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

+ (BOOL)isSameDay:(NSDate *)date1 otherDay:(NSDate *)date2 {
    if (!date1 || !date2) {
        return NO;
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents*comp1, *comp2;
    comp1 = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date1];
    comp2 = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date2];
    return ([comp1 day] == [comp2 day] && [comp1 month] == [comp2 month] && [comp1 year] == [comp2 year]);
}

@end
