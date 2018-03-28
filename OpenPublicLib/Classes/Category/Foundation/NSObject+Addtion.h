//
//  NSObject+Addtion.h
//  StudentStudyNew
//
//  Created by vernepung on 15/8/7.
//  Copyright (c) 2015年 vernepung. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface NSObject (Addtion)
- (NSArray *)rt_AllProperties;
- (NSArray *)rt_AllPropertiesByClass:(Class)className;
- (NSArray *)rt_AllMethodsByClass:(Class)className;
+ (BOOL)vp_swizzleClassMethodWithOriginalSel:(SEL)originalSel newSel:(SEL)newSel;
+ (BOOL)vp_swizzleMethodWithClass:(Class)selfClass originalSel:(SEL)originalSel newSel:(SEL)newSel;
@end
