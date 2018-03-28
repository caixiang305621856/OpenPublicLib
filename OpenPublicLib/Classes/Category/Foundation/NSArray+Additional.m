//
//  NSArray+Check.m
//  VPPublicUntilitisForPod
//
//  Created by verne on 2017/2/9.
//  Copyright © 2017年 vernepung. All rights reserved.
//

#import "NSArray+Additional.h"
#import <objc/runtime.h>
#import "NSObject+Addtion.h"
#import "ConstMacro.h"
@implementation NSArray (Additional)
- (id)objectAtIndexChecked:(NSUInteger)index{
#if !DEBUG
    if (index >= self.count){
        return nil;
    }else{
        id value = [self objectAtIndex:index];
        if (value == [NSNull null]) {
            return nil;
        }
        return value;
    }
#endif
    return [self objectAtIndex:index];
}
@end
