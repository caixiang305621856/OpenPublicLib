//
//  UIImageView+VPImageView.h
//  block
//
//  Created by caixiang on 2017/3/19.
//  Copyright © 2017年 蔡翔. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UIImageView (VPImageCache)

- (void)vp_setImageWithURL:(NSURL *)url;

- (void)vp_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

- (void)vp_setImageWithURL:(NSURL *)url round:(BOOL)round;

- (void)vp_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder round:(BOOL)round;

- (void)vp_setImageWithURL:(NSURL *)url radius:(CGFloat)radius;

- (void)vp_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder radius:(CGFloat)radius;

@end
