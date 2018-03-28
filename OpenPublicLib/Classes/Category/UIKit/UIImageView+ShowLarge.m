//
//  UIImageView+ShowLarge.m
//  StudentStudyNew
//
//  Created by vernepung on 15/10/30.
//  Copyright (c) 2015年 vernepung. All rights reserved.
//

#import "UIImageView+ShowLarge.h"
#import <objc/runtime.h>
#import "UIView+Additional.h"
#import "UtilsMacro.h"
#import "SDWebImageManager.h"

static const void *oldFrameKey = &oldFrameKey;
static const void *oldCornerRadiusKey = &oldCornerRadiusKey;
static const void *oldMasksToBoundsKey = &oldMasksToBoundsKey;
static const void *oneTaBlockpKey = &oneTaBlockpKey;
@interface UIImageView ()
@property (copy,nonatomic) NSValue *oldFrame;
@property (assign,nonatomic) NSNumber *oldCornerRadius;
@property (copy,nonatomic) NSNumber *oldMasksToBounds;
@end
@implementation UIImageView (ShowLarge)
- (void)setOldMasksToBounds:(NSNumber *)oldMasksToBounds
{
    objc_setAssociatedObject(self, oldMasksToBoundsKey, oldMasksToBounds, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSValue *)oldMasksToBounds
{
    return objc_getAssociatedObject(self, oldMasksToBoundsKey);
}

- (void)setOldCornerRadius:(NSNumber *)oldCornerRadius
{
    objc_setAssociatedObject(self, oldCornerRadiusKey, oldCornerRadius, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSValue *)oldCornerRadius
{
    return objc_getAssociatedObject(self, oldCornerRadiusKey);
}

- (void)setOldFrame:(NSValue *)oldFrame
{
    objc_setAssociatedObject(self, oldFrameKey, oldFrame, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSValue *)oldFrame
{
    return objc_getAssociatedObject(self, oldFrameKey);
}

- (void)setOneTap:(VPTapBlock)block
{
    objc_setAssociatedObject(self, oneTaBlockpKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (VPTapBlock)oneTap
{
    return objc_getAssociatedObject(self, oneTaBlockpKey);
}

//- (void)setLongPress:(VPLongPressBlock)longPressBlock
//{
//    objc_setAssociatedObject(self, longPressBlockKey, longPressBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
//}
//
//- (VPLongPressBlock)longPress{
//    return objc_getAssociatedObject(self, longPressBlockKey);
//}

- (void)showWithLargeImageUrl:(NSString *)url {
    [[self viewController].view endEditing:YES];
    UIImage *oldImage = self.image;
    self.oldFrame = [NSValue valueWithCGRect:[self convertRect:self.bounds toView:[self keyWindow]]];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideLargeImage:)];
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight)];
    backgroundView.tag = 5002;
    backgroundView.backgroundColor = [UIColor clearColor];
    [backgroundView addGestureRecognizer:tapGesture];
    
    //    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    //    longPressGesture.minimumPressDuration = 1.0f;
    UIImageView *newImageView = [[UIImageView alloc]initWithFrame:([self.oldFrame CGRectValue])];
    newImageView.backgroundColor = [UIColor blackColor];
    self.oldCornerRadius = @(self.layer.cornerRadius);
    self.oldMasksToBounds = @(self.layer.masksToBounds);
    newImageView.userInteractionEnabled = YES;
    newImageView.tag = 5001;
    newImageView.image = oldImage;
    //    [newImageView addGestureRecognizer:longPressGesture];
    [backgroundView addSubview:newImageView];
    [[self keyWindow] addSubview:backgroundView];
    CGFloat height = self.image.size.height * kMainBoundsWidth / self.image.size.width;
    
    CABasicAnimation *cornerRadiusAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    cornerRadiusAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    cornerRadiusAnimation.fromValue = @([self.oldCornerRadius doubleValue]);
    cornerRadiusAnimation.toValue = @(0.0);
    cornerRadiusAnimation.duration = .25;
    [newImageView.layer addAnimation:cornerRadiusAnimation forKey:@"cornerRadius"];
    newImageView.layer.cornerRadius = 0.0;
    newImageView.layer.masksToBounds = [self.oldMasksToBounds boolValue];
    
    [UIView animateWithDuration:.25 animations:^{
        newImageView.frame = CGRectMake(0, (kMainBoundsHeight - height) / 2, kMainBoundsWidth, height);
        backgroundView.backgroundColor = [UIColor blackColor];
    } completion:^(BOOL finished) {
        
    }];
    if (url && url.length > 0)
    {
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight)];
        indicatorView.backgroundColor = [UIColor clearColor];
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        indicatorView.center = [self keyWindow].center;
        [indicatorView startAnimating];
        [[self keyWindow] addSubview:indicatorView];
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:url] options:SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (!error)
            {
                [newImageView setImage:image];
            }
            [indicatorView stopAnimating];
            [indicatorView removeFromSuperview];
        }];
    }
}

//- (void)longPress:(UILongPressGestureRecognizer *)longPressGesture
//{
//    if (self.longPress)
//    {
//        self.longPress(longPressGesture);
//    }
//    else
//    {
//        if (longPressGesture.state == UIGestureRecognizerStateBegan)
//        {
//            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"保存图片" otherButtonTitles: nil];
//            [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
//        }
//    }
//}

- (UIWindow *)keyWindow{
    return [UIApplication sharedApplication].keyWindow;
}

//#pragma mark - UIActionSheetDelegate
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == 0)
//    {
//        UIImageView *newImageView = (UIImageView *)[[self keyWindow] viewWithTag:5001];
//        UIImageWriteToSavedPhotosAlbum(newImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//    }
//}
//
//- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
//{
//    NSString *msg = @"图片已经保存到相册";
//    if (error)
//    {
//        msg = @"保存图片失败";
//    }
//    [[self keyWindow] makeToast:msg];
//}

- (void)hideLargeImage:(UIGestureRecognizer *)gesture
{
    if (self.oneTap)
    {
        self.oneTap(gesture);
    }
    else
    {
        UIView *backgroundView = (UIView *)[[self keyWindow] viewWithTag:5002];
        UIImageView *newImageView = (UIImageView *)[backgroundView viewWithTag:5001];
        
        CABasicAnimation *cornerRadiusAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        cornerRadiusAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        cornerRadiusAnimation.fromValue = @(0.0);
        cornerRadiusAnimation.toValue = self.oldCornerRadius;
        cornerRadiusAnimation.duration = .25;
        [newImageView.layer addAnimation:cornerRadiusAnimation forKey:@"cornerRadius"];
        newImageView.layer.cornerRadius = [self.oldCornerRadius doubleValue];
        
        [UIView animateWithDuration:.25 animations:^{
            newImageView.frame = [self.oldFrame CGRectValue];
            backgroundView.backgroundColor = [UIColor clearColor];
            //            backgroundView.alpha = 0;
        } completion:^(BOOL finished) {
            [backgroundView removeFromSuperview];
        }];
    }
}
@end
