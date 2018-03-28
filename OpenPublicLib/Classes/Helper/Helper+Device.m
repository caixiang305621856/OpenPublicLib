//
//  Helper+Device.m
//  VPPublicUntilitisForPod
//
//  Created by vernepung on 2017/6/22.
//  Copyright © 2017年 vernepung. All rights reserved.
//

#import "Helper+Device.h"
#import "OpenUDID.h"
#include <sys/utsname.h>

@implementation Helper (Device)
+ (NSString*)getCurrentDeviceUDID{
    return [OpenUDID value];
}

+ (APDeviceType)getDeciceType{
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    CGFloat width = CGRectGetWidth(screenFrame);
    CGFloat height = CGRectGetHeight(screenFrame);
    if(width == 320.0f && height == 568.0f) {
        return APDeviceIPhone5;
    }else if(width == 375.0f) {
        return APDeviceIPhone6;
    }else if(width == 414.0f) {
        return APDeviceIPhone6Plus;
    }
    return APDeviceClassical;
}

/**
 *	@brief 获取当前设备类型如ipod，iphone，ipad
 *
 */
+ (NSString *)deviceType {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}
@end
