//
//  ConstMacro.h
//  teacherSecretary
//
//  Created by verne on 15/12/6.
//  Copyright © 2015年 vernepung. All rights reserved.
//
#import <UIKit/UIKit.h>
#ifndef ConstMacro_h
#define ConstMacro_h

UIKIT_STATIC_INLINE BOOL iPhoneX(){
    // iPhoneX 尺寸 1125, 2436
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)]?CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size):NO);
}

UIKIT_STATIC_INLINE UIEdgeInsets vp_viewSafeArea(UIView *view) {
    
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        return view.safeAreaInsets;
    }
#endif
    return UIEdgeInsetsZero;
}

UIKIT_EXTERN const NSInteger kShowTipsOfNotification;
/**
 *  分页条数
 */
UIKIT_EXTERN const NSInteger kRequestPageCount;
/**
 *  底部TabBar
 */
UIKIT_EXTERN const CGFloat kTabBarHeight;
/**
 *  网络请求等待描述语
 */
UIKIT_EXTERN NSString * const kJustWaiting;
/**
 *  网络加载失败描述语
 */
UIKIT_EXTERN NSString * const kNetworkError;
/**
 *  空白行key
 */
UIKIT_EXTERN NSString * const kSeparatorCellKey;
/**
 *  空白字符串
 */
UIKIT_EXTERN NSString * const kEmptyStringKey;

#endif /* ConstMacro_h */

