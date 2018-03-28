//
//  UIView+Empty.m
//  teacherSecretary
//
//  Created by verne on 16/5/31.
//  Copyright © 2016年 vernepung. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "UIView+Additional.h"
#import "UtilsMacro.h"
#import "UIView+Additional.h"
#import "UIView+Empty.h"
const NSUInteger VPEmptyDefalutTag = NSUIntegerMax - 100000;
// 40 + 140 + 40
const CGFloat  MINEMPTYVIEWHEIGHT = 180;
static UIImage *emptyImage;

@implementation UIView (Empty)

+ (void)registerEmptyImage:(NSString *)imageName {
    emptyImage = [UIImage imageNamed:imageName];
    NSAssert(emptyImage, @"dont find empty image");
}

- (void)showFriendlyTipsWithMessage:(NSString *)msg {
    [self showFriendlyTipsWithMessage:msg withTag:VPEmptyDefalutTag];
}

- (void)showFriendlyTipsWithMessage:(NSString *)msg withTag:(NSUInteger)tag {
    [self showFriendlyTipsWithMessage:msg frame:self.bounds withTag:tag];
}

- (void)showFriendlyTipsWithMessage:(NSString *)msg frame:(CGRect)frame {
    [self showFriendlyTipsWithMessage:msg frame:frame withTag:VPEmptyDefalutTag];
}

- (void)showFriendlyTipsWithMessage:(NSString *)msg frame:(CGRect)frame withTag:(NSUInteger)tag {
    [self hideFriendlyTipsWithTag:tag];
    UIView *emptyView = [self getEmptyViewWithTag:tag];
    emptyView.userInteractionEnabled = NO;
    emptyView.frame = frame;
    if (![emptyView isDescendantOfView:self]){
        [self addSubview:emptyView];
    }
    CGFloat height = CGRectGetHeight(self.bounds);
    UIImageView *imageView = [self getEmptyImageViewWithTag:tag];
    if (![imageView isDescendantOfView:emptyView]){
        [emptyView addSubview:imageView];
    }
    imageView.left = (CGRectGetWidth(frame) - imageView.width) / 2;
    imageView.top = (CGRectGetHeight(frame) - imageView.height) * .25;
    
    
    if (height >= MINEMPTYVIEWHEIGHT){
        UILabel *msgLabel = [self getEmptyLabelWithTag:tag];
        if (![msgLabel isDescendantOfView:emptyView]){
            [emptyView addSubview:msgLabel];
        }
        msgLabel.text = msg;
        msgLabel.width = kMainBoundsWidth * 0.85;
        msgLabel.height = 40;
        msgLabel.numberOfLines = 2;
        msgLabel.left = (CGRectGetWidth(frame) - msgLabel.width) / 2;
        msgLabel.hidden = NO;
    }else{
        [[self getEmptyViewWithTag:tag] removeFromSuperview];
    }
    [self addSubview:emptyView];
    [self bringSubviewToFront:emptyView];
    
}

- (void)hideFriendlyTips {
    [self hideFriendlyTipsWithTag:VPEmptyDefalutTag];
}

- (void)hideFriendlyTipsWithTag:(NSUInteger)tag {
    UIView *emptyView = [self getEmptyViewWithTag:tag];
    if (!emptyView){
        return;
    }
    [emptyView removeAllSubviews];
    [emptyView removeFromSuperview];
}

- (UIView *)getEmptyViewWithTag:(NSUInteger)tag {
    UIView *_emptyView = [self viewWithTag:tag];
    if (!_emptyView) {
        _emptyView = [UIView new];
        _emptyView.tag = tag;
    }
    return _emptyView;
}

- (UIImageView *)getEmptyImageViewWithTag:(NSUInteger)tag {
    NSUInteger imageTag = 10000 + tag;
    UIImageView *_emptyImageView = (UIImageView *)[[self getEmptyViewWithTag:tag] viewWithTag:imageTag];
    if (!_emptyImageView){
        NSAssert(emptyImage, @"dont find empty image");
        CGSize size = emptyImage.size;
        _emptyImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        [_emptyImageView setImage:emptyImage];
        _emptyImageView.tag = imageTag;
    }
    return _emptyImageView;
}

- (UILabel *)getEmptyLabelWithTag:(NSUInteger)tag {
    NSUInteger labelTag = 10001 + tag;
    UILabel *_emptyLabel = (UILabel *)[[self getEmptyViewWithTag:tag] viewWithTag:labelTag];
    if (!_emptyLabel){
        _emptyLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, [self getEmptyImageViewWithTag:tag].bottom + 20, CGRectGetWidth(self.bounds), 20)];
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.font = [UIFont systemFontOfSize:16];
        _emptyLabel.textColor = UIColorFromRGB(0x666666);
        _emptyLabel.tag = labelTag;
    }
    return _emptyLabel;
}

@end
