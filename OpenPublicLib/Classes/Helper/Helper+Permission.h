//
//  Helper+Authorization.h
//  VPPublicUntilitisForPod
//
//  Created by vernepung on 2017/6/16.
//  Copyright © 2017年 vernepung. All rights reserved.
//

#import "Helper.h"
#import <AVFoundation/AVFoundation.h>

@interface Helper (Permission)

/**
 当前是否有推送权限(只读取,不请求)
 
 @param complete 是否允许推送
 */
+ (void)checkingNotificationPermisssionWithCompleteBlock:(void(^)(BOOL result))complete;
/**
 检查相机权限
 */
+ (void)checkingVideoPermissionWithCompleteBlock:(void(^)(BOOL success, AVAuthorizationStatus status))complete;

/**
 检查相册权限
 */
+ (void)checkingPhotoPermissionWithCompleteBlock:(void(^)(BOOL success))complete;

/**
 打开当前App的权限设置界面
 */
+ (void)openAuthorizatioinSetting;
@end
