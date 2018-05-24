//
//  BaseModel.h
//  teacherSecretary
//
//  Created by vernepung on 15/11/18.
//  Copyright © 2015年 vernepung. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface BaseModel : NSObject<NSCoding,NSCopying,NSMutableCopying>
@property (copy, nonatomic)NSString *identification;
@property (copy, nonatomic)NSString *orderList;
/**
 *  cell行高
 */
@property (assign, nonatomic) CGFloat rowHeight;
/**
 *  时间
 */
@property (copy, nonatomic) NSString *dateTime;
/**
 *  解析字典
 */
+ (instancetype)objectFromDictionary:(NSDictionary*)dictionary;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end

