//
//  Helper+Device.h
//  VPPublicUntilitisForPod
//
//  Created by vernepung on 2017/6/22.
//  Copyright © 2017年 vernepung. All rights reserved.
//

#import "Helper.h"
/**
 屏幕尺寸大小，暂时分四种

 - APDeviceClassical: APDeviceClassical description
 */
typedef NS_ENUM(NSUInteger,APDeviceType){
    APDeviceClassical, //3.5寸
    APDeviceIPhone5, //4.0寸
    APDeviceIPhone6, //iPhone6
    APDeviceIPhone6Plus, //iPhone6 Plus
};
@interface Helper (Device)

/**
 *	@brief 获取当前设备的UDID
 *
 */
+ (NSString*)getCurrentDeviceUDID;
/**
 @brief 获取设备类型，此方法根据设备屏幕大小来进行判断
 @note 屏幕大小参数：
 @note iPhone4s: 320 * 480  iPhone5: 320*568 iPhone6: 375*667 iPhone6Plus:414*736
 */
+ (APDeviceType)getDeciceType;
/**
 *	@brief 获取当前设备类型如ipod，iphone，ipad
 *
 */
+ (NSString *)deviceType;

@end
