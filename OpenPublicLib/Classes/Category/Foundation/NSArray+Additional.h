//
//  NSArray+Check.h
//  VPPublicUntilitisForPod
//
//  Created by verne on 2017/2/9.
//  Copyright © 2017年 vernepung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray<ObjectType> (Additional)
- (ObjectType)objectAtIndexChecked:(NSUInteger)index;
@end
