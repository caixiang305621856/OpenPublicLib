//
//  Helper+Authorization.m
//  VPPublicUntilitisForPod
//
//  Created by vernepung on 2017/6/16.
//  Copyright © 2017年 vernepung. All rights reserved.
//

#import "Helper+Permission.h"
#import "UtilsMacro.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <UserNotifications/UserNotifications.h>


@implementation Helper (Permission)

+ (void)checkingNotificationPermisssionWithCompleteBlock:(void(^)(BOOL result))complete {
    if (@available(iOS 10.0, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
            ExecBlock(complete, settings.authorizationStatus == UNAuthorizationStatusAuthorized);
        }];
    } else{
        ExecBlock(complete, [[UIApplication sharedApplication] currentUserNotificationSettings].types != UIUserNotificationTypeNone);
    }
}

+ (void)checkingPhotoPermissionWithCompleteBlock:(void(^)(BOOL success))complete {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status != PHAuthorizationStatusAuthorized) {
                    ExecBlock(complete, NO);
                    DLog(@"%@",@"user denied photo permission");
                }else{
                    ExecBlock(complete, YES);
                }
            }];
        }
            break;
        case PHAuthorizationStatusAuthorized:
            ExecBlock(complete, YES);
            break;
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied:
            ExecBlock(complete, NO);
            break;
    }
}

+ (void)checkingVideoPermissionWithCompleteBlock:(void(^)(BOOL success, AVAuthorizationStatus status))complete {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
            case AVAuthorizationStatusNotDetermined:{
                ExecBlock(complete, NO, status);
            // 许可对话没有出现，发起授权许可
//            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
//                ExecBlock(complete, granted);
//                if (!granted) {
//                    DLog(@"%@",@"user denied video permission");
//                }
//            }];
//            break;
        }
        case AVAuthorizationStatusAuthorized:{
            ExecBlock(complete, YES, status);
            // 已经开启授权，可继续
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            // 用户明确地拒绝授权，或者相机设备无法访问
            ExecBlock(complete, NO, status);
            break;
    }
}

+ (void)openAuthorizatioinSetting {
    openUrlInSafari(UIApplicationOpenSettingsURLString);
}


@end
