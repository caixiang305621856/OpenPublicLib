//
//  BaseModel.m
//  teacherSecretary
//
//  Created by vernepung on 15/11/18.
//  Copyright (c) 2015年 vernepung. All rights reserved.
//

#import "BaseModel.h"
#import "MJExtension.h"
#import "Helper.h"
#import "Helper+Validate.h"
#import "UtilsMacro.h"
#import <objc/runtime.h>

@implementation BaseModel

-(void)setDateTime:(NSString *)dateTime{
    if ([Helper isPureInt:dateTime]){
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:[dateTime longLongValue]/1000];
        _dateTime = [[Helper formatDateWithDate:date format:@"yyyy/MM/dd HH:mm:ss"] copy];
    }else{
        _dateTime = dateTime;
    }
}

/**
 *  解析字典
 */
+ (instancetype)objectFromDictionary:(NSDictionary*)dictionary {
    return [[self class] mj_objectWithKeyValues:dictionary];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    id selfClass;
    @try {
        selfClass = [[self class] mj_objectWithKeyValues:dictionary];
    } @catch (NSException *exception) {
        DLog(@"反序列化错误！ [BaseModel initWithDictionary] line:39");
    }//    NSAssert(selfClass, @"检查返回数据格式是否正确");
    return selfClass;
}

- (instancetype)init {
    self = [super init];
    if (self && ![NSStringFromClass([self class]) hasPrefix:@"Global"]) {
        unsigned int count;
        objc_property_t *propertyList = class_copyPropertyList([self class], &count);
        for (unsigned int i=0; i<count; i++) {
            NSString *key = [NSString stringWithUTF8String:property_getName(propertyList[i])];
            if ([BaseModel isNSStringProperty:[self class] propertyName:key] && ![key isEqualToString:@"description"] &&![key isEqualToString:@"debugDescription"]) {
                if ([BaseModel isPropertyReadOnly:[self class] propertyName:key] ){
                    [self setValue:@"" forKey:[NSString stringWithFormat:@"_%@",key]];
                }else{
                    [self setValue:@"" forKey:key];
                }
            }
        }
        
        objc_property_t *propertyLis = class_copyPropertyList([BaseModel class], &count);
        for (unsigned int i=0; i<count; i++) {
            NSString *key = [NSString stringWithUTF8String:property_getName(propertyLis[i])];
            if ([BaseModel isNSStringProperty:[self class] propertyName:key]) {
                if ([BaseModel isPropertyReadOnly:[self class] propertyName:key]){
                    [self setValue:@"" forKey:[NSString stringWithFormat:@"_%@",key]];
                }else{
                    [self setValue:@"" forKey:key];
                }
            }
        }
    }
    return self;
}

- (NSMutableDictionary *)toDictionary {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.mj_keyValues];
    return dic;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
    unsigned int count;
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for (unsigned int i=0; i<count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(propertyList[i])];
        [encoder encodeObject:[self valueForKey:key] forKey:key];
    }
    
    Class superClass = [[[[self class] alloc] superclass] class];
    do {
        if (superClass){
            propertyList = class_copyPropertyList(superClass, &count);
            for (unsigned int i=0; i<count; i++) {
                NSString *key = [NSString stringWithUTF8String:property_getName(propertyList[i])];
                [encoder encodeObject:[self valueForKey:key] forKey:key];
            }
        }
        superClass = [[[superClass alloc] superclass] class];
    } while (superClass && superClass != [NSObject class]);
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        unsigned int count;
        objc_property_t *propertyList = class_copyPropertyList([self class], &count);
        for (unsigned int i=0; i<count; i++) {
            NSString *key = [NSString stringWithUTF8String:property_getName(propertyList[i])];
            if ([BaseModel isPropertyReadOnly:[self class] propertyName:key]) {
                continue;
            }
            id value = [decoder decodeObjectForKey:key];
            if (value != [NSNull null] && value != nil) {
                [self setValue:value forKey:key];
            }
        }
        Class superClass = [[[[self class] alloc] superclass] class];
        do {
            if (superClass){
                propertyList = class_copyPropertyList(superClass, &count);
                for (unsigned int i=0; i<count; i++) {
                    NSString *key = [NSString stringWithUTF8String:property_getName(propertyList[i])];
                    if ([superClass isPropertyReadOnly:[self class] propertyName:key]) {
                        continue;
                    }
                    id value = [decoder decodeObjectForKey:key];
                    if (value != [NSNull null] && value != nil) {
                        [self setValue:value forKey:key];
                    }
                }
            }
            superClass = [[[superClass alloc] superclass] class];
        } while (superClass && superClass != [NSObject class]);
        
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone{
    id newModel = [[[self class] allocWithZone:zone]init];
    unsigned int count;
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for (unsigned int i=0; i<count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(propertyList[i])];
        if ([BaseModel isPropertyReadOnly:[self class] propertyName:key]) {
            continue;
        }
        id value = [self valueForKey:key];
        if (value != [NSNull null] && value != nil) {
            [newModel setValue:value forKey:key];
        }
    }
    Class superClass = [[[[self class] alloc] superclass] class];
    do {
        if (superClass){
            propertyList = class_copyPropertyList(superClass, &count);
            for (unsigned int i=0; i<count; i++) {
                NSString *key = [NSString stringWithUTF8String:property_getName(propertyList[i])];
                if ([superClass isPropertyReadOnly:[self class] propertyName:key]) {
                    continue;
                }
                id value = [self valueForKey:key];
                if (value != [NSNull null] && value != nil) {
                    [newModel setValue:value forKey:key];
                }
            }
        }
        superClass = [[[superClass alloc] superclass] class];
    } while (superClass && superClass != [NSObject class]);
    
    return newModel;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    id newModel = [[[self class] allocWithZone:zone]init];
    unsigned int count;
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for (unsigned int i=0; i<count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(propertyList[i])];
        if ([BaseModel isPropertyReadOnly:[self class] propertyName:key]) {
            continue;
        }
        id value = [self valueForKey:key];
        if (value != [NSNull null] && value != nil) {
            if ([value respondsToSelector:@selector(mutableCopyWithZone:)]){
                [newModel setValue:[value mutableCopyWithZone:zone] forKey:key];
            }else{
                [newModel setValue:value forKey:key];
            }
        }
    }
    
    Class superClass = [[[[self class] alloc] superclass] class];
    do {
        if (superClass){
            propertyList = class_copyPropertyList(superClass, &count);
            for (unsigned int i=0; i<count; i++) {
                NSString *key = [NSString stringWithUTF8String:property_getName(propertyList[i])];
                if ([superClass isPropertyReadOnly:[self class] propertyName:key]) {
                    continue;
                }
                id value = [self valueForKey:key];
                if (value != [NSNull null] && value != nil) {
                    if ([value respondsToSelector:@selector(mutableCopyWithZone:)]){
                        [newModel setValue:[value mutableCopyWithZone:zone] forKey:key];
                    }else{
                        [newModel setValue:value forKey:key];
                    }
                }
            }
        }
        superClass = [[[superClass alloc] superclass] class];
    } while (superClass && superClass != [NSObject class]);
    
    return newModel;
}

+ (BOOL)isNSStringProperty:(Class)klass propertyName:(NSString*)propertyName{
    const char * type = property_getAttributes(class_getProperty(klass, [propertyName UTF8String]));
    NSString * typeString = [NSString stringWithUTF8String:type];
    NSArray * attributes = [typeString componentsSeparatedByString:@","];
    NSString * typeAttribute = [attributes objectAtIndex:0];
    return [typeAttribute rangeOfString:@"T@\"NSString\""].length > 0;
}

+ (BOOL)isPropertyReadOnly:(Class)klass propertyName:(NSString*)propertyName{
    const char * type = property_getAttributes(class_getProperty(klass, [propertyName UTF8String]));
    NSString * typeString = [NSString stringWithUTF8String:type];
    NSArray * attributes = [typeString componentsSeparatedByString:@","];
    NSString * typeAttribute = [attributes objectAtIndex:1];
    return [typeAttribute rangeOfString:@"R"].length > 0;
}

- (NSString *)description {
    NSMutableDictionary *dic = [self toDictionary];
    return [NSString stringWithFormat:@"#<%@: id = %@ %@>", [self class], self.identification, [dic description]];
}

- (BOOL)isEqual:(id)object {
    if (object == nil || ![object isKindOfClass:[BaseModel class]]) return NO;
    BaseModel *model = (BaseModel *)object;
    return [self.identification isEqualToString:model.identification];
}

@end
