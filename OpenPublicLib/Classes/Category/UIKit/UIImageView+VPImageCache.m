//
//  UIImageView+VPImageView.m
//  block
//
//  Created by caixiang on 2017/3/19.
//  Copyright © 2017年 蔡翔. All rights reserved.
//

#import "UIImageView+VPImageCache.h"
#import "UIImageView+WebCache.h"
#import "UIImage+DrawRoundImage.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSString+Additional.h"

static NSString *const kradiusCache = @"_radiusCache";

@implementation UIImageView (VPImageCache)

- (void)vp_setImageWithURL:(NSURL *)url{
    [self vp_setImageWithURL:url placeholderImage:nil];
}

- (void)vp_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder{
    [self vp_setImageWithURL:url placeholderImage:placeholder radius:0];
}


- (void)vp_setImageWithURL:(NSURL *)url round:(BOOL)round{
    [self vp_setImageWithURL:url placeholderImage:nil round:round];
}

- (void)vp_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder round:(BOOL)round{
    if (round) {
        [self vp_setImageWithURL:url placeholderImage:placeholder radius:CGFLOAT_MIN];
    }else{
        [self vp_setImageWithURL:url placeholderImage:placeholder radius:0];
    }
}

- (void)vp_setImageWithURL:(NSURL *)url radius:(CGFloat)radius{
    [self vp_setImageWithURL:url placeholderImage:nil radius:radius];
}

- (void)vp_setImageWithURL:(NSURL *)url
          placeholderImage:(UIImage *)placeholder
                    radius:(CGFloat)radius{
    if (self.superview) {
        [self.superview layoutIfNeeded];
    }else {
        [self layoutIfNeeded];
    }
    if (radius == CGFLOAT_MIN) {
        radius = self.frame.size.width/2.0;
    }
    __weak __typeof(self)weakSelf = self;
    if (radius > 0.0) {
        //原来可能缓存的头像key
        NSString *cacheurlStr = [self checkUrl:url];
        //圆角头像缓存的key
        NSString *radiusCacheurlStr = [cacheurlStr stringByAppendingString:kradiusCache];
        radiusCacheurlStr = [[NSString stringWithFormat:@"%@_%f", radiusCacheurlStr,radius] md5];
        UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:radiusCacheurlStr];
        self.image = placeholder;
        if (cacheImage) {
            self.image = cacheImage;
        } else {
            [[SDWebImageManager sharedManager] loadImageWithURL:url options:SDWebImageCacheMemoryOnly | SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                dispatch_async(dispatch_get_main_queue(), ^{
                    //设置默认图片
                    strongSelf.image = placeholder;
                });
            } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                if (!error&&finished) {
                    UIImage *radiusImage = [UIImage createRoundedRectImage:image size:strongSelf.frame.size radius:radius];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        [[SDImageCache sharedImageCache] storeImage:radiusImage forKey:radiusCacheurlStr completion:nil];
                        [[SDImageCache sharedImageCache] removeImageForKey:cacheurlStr withCompletion:nil];
                        dispatch_main_async_safe(^{
                            strongSelf.image = radiusImage;
                            if (image && (cacheType == SDImageCacheTypeNone || cacheType == SDImageCacheTypeDisk))  {
                                [strongSelf animation];
                            }
                        });
                    });
                } else{
                    strongSelf.image = placeholder;
                }
            }];
        }
    } else {
        //非圆角图片
        [self sd_setImageWithURL:url placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (!error) {
                strongSelf.image = image;
                if (image && (cacheType == SDImageCacheTypeNone || cacheType == SDImageCacheTypeDisk))  {
                    [strongSelf animation];
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    NSString *cacheurlStr = [strongSelf checkUrl:url];
                    NSString *radiusCacheurlStr = [cacheurlStr stringByAppendingString:kradiusCache];
                    radiusCacheurlStr = [[NSString stringWithFormat:@"%@_%f", radiusCacheurlStr,radius] md5];
                    [[SDImageCache sharedImageCache] removeImageForKey:radiusCacheurlStr withCompletion:nil];
                });
            }
        }];
    }
}

- (void)animation{
    CATransition *fadeIn = [CATransition animation];
    fadeIn.duration = 0.35f;
    fadeIn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    fadeIn.subtype = kCATransitionFade;
    [self.layer addAnimation:fadeIn forKey:kCATransitionFade];
}

- (NSString *)checkUrl:(NSURL *)url{
    NSString *urlString = [url absoluteString];
    NSDictionary *param = [self getParameterOfUrl:urlString];
    if (param && [[param allKeys] containsObject:@"security-token"]) {
        //是阿里云
        NSString *x_oss_process  = @"";
        if ([[param allKeys] containsObject:@"x-oss-process"]) {
            x_oss_process = param[@"x-oss-process"];
        }
        NSString *newKey = [NSString stringWithFormat:@"%@?%@",param[@"localhost"],x_oss_process];
        return newKey;
    }else{
        return urlString;
    }
}


- (NSDictionary *)getParameterOfUrl:(NSString *)urlString {
    NSRange range = [urlString rangeOfString:@"?"];
    if (range.length) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        NSString *parameterUrl = [urlString substringFromIndex:range.location+1];
        NSArray *parameterArr = [parameterUrl componentsSeparatedByString:@"&"];
        for (NSString *parameter in parameterArr) {
            NSArray *parameterBoby = [parameter componentsSeparatedByString:@"="];
            if (parameterBoby.count == 2) {
                [dic setObject:parameterBoby[1] forKey:parameterBoby[0]];
            }else{
                return nil;
            }
        }
        NSString *localhostStr = [urlString substringToIndex:range.location];
        [dic setObject:localhostStr forKey:@"localhost"];
        return dic;
    }else{
        return nil;
    }
}

@end
