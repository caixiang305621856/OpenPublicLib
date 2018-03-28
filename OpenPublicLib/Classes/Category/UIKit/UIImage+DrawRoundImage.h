//
//  UIImage+DrawRoundImage.h
//  block
//
//  Created by caixiang on 2017/3/19.
//  Copyright © 2017年 蔡翔. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (DrawRoundImage)

+ (id)createRoundedRectImage:(UIImage*)image size:(CGSize)size radius:(int)radius;

@end
