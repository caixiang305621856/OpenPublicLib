

//
//  NSObject+Addtion.m
//  StudentStudyNew
//
//  Created by vernepung on 15/8/7.
//  Copyright (c) 2015年 vernepung. All rights reserved.
//

#import "NSObject+Addtion.h"
#import <objc/runtime.h>

@implementation NSObject (Addtion)
+ (BOOL)vp_swizzleClassMethodWithOriginalSel:(SEL)originalSel newSel:(SEL)newSel{
    return [[self class] vp_swizzleMethodWithClass:[self class] originalSel:originalSel newSel:newSel];
}

+ (BOOL)vp_swizzleMethodWithClass:(Class)selfClass originalSel:(SEL)originalSel newSel:(SEL)newSel{
    Method originalMethod = class_getInstanceMethod(selfClass, originalSel);
    Method swizzingMethod = class_getInstanceMethod(selfClass, newSel);
    if (!originalMethod || !swizzingMethod) return NO;
    
    BOOL addSwizzingMethoded = class_addMethod(selfClass, originalSel, method_getImplementation(swizzingMethod), method_getTypeEncoding(swizzingMethod));
    if (addSwizzingMethoded){
        class_replaceMethod(selfClass, newSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else{
        method_exchangeImplementations(originalMethod, swizzingMethod);
    }
    return YES;
}

- (NSArray *)rt_AllProperties{
    return [self rt_AllPropertiesByClass:[self class]];
}

- (NSArray *)rt_AllPropertiesByClass:(Class)className
{
    u_int count;
    objc_property_t *properties = class_copyPropertyList(className, &count);
    
    NSMutableArray *propertiesArr = [NSMutableArray arrayWithCapacity:count];
    while (count > 0) {
        count --;
        const char* propertyName = property_getName(properties[count]);
        [propertiesArr addObject:[NSString stringWithUTF8String:propertyName]];
    }
    return propertiesArr;
}

- (NSArray *)rt_AllMethodsByClass:(Class)className
{
    u_int count;
    
    Method *methods = class_copyMethodList(className, &count);
    
    NSMutableArray *methodsArr = [NSMutableArray arrayWithCapacity:count];
    while (count > 0) {
        count --;
        SEL sel = method_getName(methods[count]);
        [methodsArr addObject:[NSString stringWithUTF8String:sel_getName(sel)]];
    }
    return methodsArr;
}


@end
