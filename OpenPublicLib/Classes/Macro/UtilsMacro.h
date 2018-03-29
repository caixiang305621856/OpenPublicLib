//
//  UtilsMacro.h
//  PublicProject
//
//  Created by vernepung on 16/4/21.
//  Copyright © 2016年 vernepung. All rights reserved.
//
#import <UIKit/UIKit.h>
#ifndef UtilsMacro_h
#define UtilsMacro_h

#define isBeta (BETA==1)
#define isMgr (MGR==1)
#define isStu (STU==1)

#pragma mark - 颜色相关
#define RGB(r, g, b) [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:1.0f]
#define RGBA(r,g,b,a) [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:a]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0f green:((float)((rgbValue & 0xFF00) >> 8))/255.0f blue:((float)(rgbValue & 0xFF))/255.0f alpha:1.0]
#define UIColorFromRGBWihtAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0f green:((float)((rgbValue & 0xFF00) >> 8))/255.0f blue:((float)(rgbValue & 0xFF))/255.0f alpha:a]

#pragma mark - 状态栏
#define kStatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height

#pragma mark - 导航栏 + 状态栏
#define kNavBarHeightWithStatusBarHeight (kStatusBarHeight + 44.f)

#pragma mark - 常用属性
#define kMainBoundsHeight   ([UIScreen mainScreen].bounds).size.height //屏幕的高度
#define kMainBoundsWidth    ([UIScreen mainScreen].bounds).size.width //屏幕的宽度

#pragma mark - 格式字符串简写
#define kRect(x, y, w, h)                   CGRectMake(x, y, w,            h)
#define kSize(w, h)                         CGSizeMake(w,  h)
#define kPoint(x, y)                        CGPointMake(x, y)

#pragma mark - 1像素宽度/高度
#define kOnePixelWidth  1.0f / [UIScreen mainScreen].scale

#pragma mark - 系统版本号
#define iOSVersion [[[UIDevice currentDevice] systemVersion] floatValue]

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define NSLog(...)
#   define DLog(...)
#endif

#pragma mark - 弱引用self
#if DEBUG
#define ext_keywordify autoreleasepool {}
#else
#define ext_keywordify try {} @catch (...) {}
#endif

#define weakify(VAR) \
ext_keywordify \
__weak __typeof(&*VAR) __weak##VAR = VAR;
#define strongify(VAR) \
ext_keywordify \
__strong __typeof(&*VAR) VAR = __weak##VAR;


#define dispatch_global_async(block)\
dispatch_async(dispatch_get_global_queue(0, 0),block);\

#define dispatch_global_sync(block)\
dispatch_sync(dispatch_get_global_queue(0, 0),block);\

#define ExecBlock(block, ...) if (block) { block(__VA_ARGS__); };
#endif /* UtilsMacro_h */
/** 获取app的名称 **/
UIKIT_STATIC_INLINE NSString *appName(){
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
}
/** 获取APP的版本号 */
UIKIT_STATIC_INLINE NSString *appVersion(){
    return ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]);
}
///** 获取app内部的版本号 */
UIKIT_STATIC_INLINE NSString *appBuildVersion(){
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
}

UIKIT_STATIC_INLINE NSString *appBundleIdentifier(){
    return [[NSBundle mainBundle] bundleIdentifier];
}

/**
 *  打开Url
 */
UIKIT_STATIC_INLINE void openUrlInSafariWithCompleteBlock(NSString *url,NSDictionary<NSString *,id> *options, void (^completed)(BOOL success)){
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:options completionHandler:^(BOOL success) {
            ExecBlock(completed, success);
        }];
    }else{
        BOOL openSuccess = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        ExecBlock(completed, openSuccess);
    }
}

/**
 *  打开Url
 */
UIKIT_STATIC_INLINE void openUrlInSafari(NSString *url){
    openUrlInSafariWithCompleteBlock(url, nil, nil);
}

UIKIT_STATIC_INLINE void callPhoneWithNumber(NSString *number) {
    openUrlInSafari([NSString stringWithFormat:@"telprompt:%@",number]);
}






