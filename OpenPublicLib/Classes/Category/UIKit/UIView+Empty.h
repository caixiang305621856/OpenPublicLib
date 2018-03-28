//
//  UIView+Empty.h
//  teacherSecretary
//
//  Created by verne on 16/5/31.
//  Copyright © 2016年 vernepung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Empty)
+ (void)registerEmptyImage:(NSString *)imageName;

- (void)showFriendlyTipsWithMessage:(NSString *)msg;
- (void)showFriendlyTipsWithMessage:(NSString *)msg withTag:(NSUInteger)tag;

- (void)showFriendlyTipsWithMessage:(NSString *)msg frame:(CGRect)frame;
- (void)showFriendlyTipsWithMessage:(NSString *)msg frame:(CGRect)frame withTag:(NSUInteger)tag;


- (void)hideFriendlyTips;
- (void)hideFriendlyTipsWithTag:(NSUInteger)tag;

@end
