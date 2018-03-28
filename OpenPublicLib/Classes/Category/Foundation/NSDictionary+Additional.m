//
//  NSDictionary+Additional.m
//
//  Created by vernepung on 14-5-16.
//  Copyright (c) 2014年 vernepung. All rights reserved.
//

#import "NSDictionary+Additional.h"
#import "UtilsMacro.h"

@implementation NSDictionary (Additional)
-(BOOL)getBoolValueForKey:(NSString *)key
{
    return [self getBoolValueForKey:key defaultValue:NO];
}

- (BOOL)getBoolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue {
    return [self objectForKey:key] == [NSNull null] ? defaultValue
    : [[self objectForKey:key] boolValue];
}

-(int)getIntValueForKey:(NSString *)key
{
    return [self getIntValueForKey:key defaultValue:0];
}

- (int)getIntValueForKey:(NSString *)key defaultValue:(int)defaultValue {
	return [self objectForKey:key] == [NSNull null]
    ? defaultValue : [[self objectForKey:key] intValue];
}

-(time_t)getTimeValueForKey:(NSString *)key
{
    return [self getTimeValueForKey:key defaultValue:0];
}

- (time_t)getTimeValueForKey:(NSString *)key defaultValue:(time_t)defaultValue {
	NSString *stringTime   = [self objectForKey:key];
    if ((id)stringTime == [NSNull null]) {
        stringTime = @"";
    }
	struct tm created;
    time_t now;
    time(&now);
    
	if (stringTime) {
		if (strptime([stringTime UTF8String], "%a %b %d %H:%M:%S %z %Y", &created) == NULL) {
			strptime([stringTime UTF8String], "%a, %d %b %Y %H:%M:%S %z", &created);
		}
		return mktime(&created);
	}
	return defaultValue;
}

-(long long)getLongLongValueValueForKey:(NSString *)key
{
    return [self getLongLongValueValueForKey:key defaultValue:0];
}

- (long long)getLongLongValueValueForKey:(NSString *)key defaultValue:(long long)defaultValue {
    id obj = [self objectForKey:key];
    if (nil == obj)
    {
        return defaultValue;
    }
    if ([NSNull null] == obj)
    {
        return defaultValue;
    }
    if ([obj isKindOfClass:[NSString class]])
    {
        return [obj longLongValue];
    }
    if ([obj isKindOfClass:[NSNumber class]])
    {
        return [obj longLongValue];
    }
    return defaultValue;
}

-(NSString *)getStringValueForKey:(NSString *)key
{
    return [self getStringValueForKey:key defaultValue:@""];
}

- (NSString *)getStringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    id obj = [self objectForKey:key];
    if (nil == obj) {
        return defaultValue;
    }
    if ([NSNull null] == obj)
    {
        return defaultValue;
    }
    if ([obj isKindOfClass:[NSNumber class]])
    {
        return [NSString stringWithFormat:@"%@",[((NSNumber *)obj) stringValue]];
    }
    if ([obj isKindOfClass:[NSString class]])
    {
        return obj;
    }
    return defaultValue;
}

- (int)getStringIntValueForKey:(NSString *)key defaultValue:(int)defaultValue {
    NSString* str = [self getStringValueForKey:key defaultValue:nil];
    if (nil == str)
    {
        return defaultValue;
    }
    return [str intValue];
    
}

- (id)getObjectForKey:(NSString *)key {
    return [self getObjectForKey:key defaultValue:nil];
}

- (id)getObjectForKey:(NSString*)key defaultValue:(id)defaultValue {
	return ([self objectForKey:key] == nil || [self objectForKey:key] == [NSNull null])? defaultValue : [self objectForKey:key];
}

- (void)logProperties {
#ifdef DEBUG
    NSMutableString *codes = [NSMutableString string];
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *code;
        if ([obj isKindOfClass:[NSString class]]) {
            code = [NSString stringWithFormat:@"@property (copy, nonatomic) NSString *%@",key];
        }else if ([obj isKindOfClass:NSClassFromString(@"__NSCFBoolean")]){
            code = [NSString stringWithFormat:@"@property (assign, nonatomic) BOOL %@",key];
        }else if ([obj isKindOfClass:[NSNumber class]]) {
            code = [NSString stringWithFormat:@"@property (assign, nonatomic) NSInteger %@",key];
        }else if ([obj isKindOfClass:[NSArray class]]) {
            code = [NSString stringWithFormat:@"@property (strong, nonatomic) NSArray *%@",key];
        }else if ([obj isKindOfClass:[NSDictionary class]]) {
            code = [NSString stringWithFormat:@"@property (strong, nonatomic) NSDictionary *%@",key];
        }
        [codes appendFormat:@"\n%@\n", code];
    }];
    DLog(@"%@;",codes);
#endif
}
@end
