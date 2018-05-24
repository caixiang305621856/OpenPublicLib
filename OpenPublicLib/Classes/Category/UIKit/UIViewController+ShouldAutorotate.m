//
//  UIViewController+ShouldAutorotate.m
//  FaceTraningForStudent
//
//  Created by caixiang on 2017/8/31.
//  Copyright © 2017年 aopeng. All rights reserved.
//

#import "UIViewController+ShouldAutorotate.h"

@implementation UIViewController (ShouldAutorotate)

// 是否支持自动转屏
- (BOOL)shouldAutorotate {
    return NO;
}
// 支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
// 默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}


@end
