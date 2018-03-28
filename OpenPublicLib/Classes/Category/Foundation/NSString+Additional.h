//
//  NSString+Additional.h
//  
//
//  Created by vernepung on 15/4/8.
//  Copyright (c) 2015年 vernepung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additional)

/**
 * Returns the MD5 value of the string
 */
- (NSString*)md5;

- (NSString *)encodeURL;

- (NSString *)decodeURL;
@end
