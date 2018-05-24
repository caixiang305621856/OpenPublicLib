//
//  BaseViewController.h
//  _6.0
//
//  Created by vernepung on 13-10-21.
//  Copyright (c) 2013年 vernepung. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,VPNavigationBarState) {
    VPNavigationBarStateNone = -1,
    VPNavigationBarStateHide = 1,
    VPNavigationBarStateShow = 0
};

typedef NS_ENUM(NSInteger,VPStatusBarState) {
    VPStatusBarStateShow = 0,
    VPStatusBarStateHide = 1
};

typedef NS_ENUM(NSInteger,VPStatusBarStyle) {
    VPStatusBarStyleDefault = 0,
    VPStatusBarStyleLight = 1,
};

@interface BaseViewController : UIViewController<UIGestureRecognizerDelegate>
/**
 当前view的安全区域.(viewWillLayoutSubviews之后被赋值)
 */
@property (assign, nonatomic, readonly) UIEdgeInsets currentInsets;
/**
 导航栏状态
 */
@property (assign, nonatomic) VPNavigationBarState navigationBarState;
/**
 状态栏样式
 */
@property (assign, nonatomic) VPStatusBarStyle statusBarStype;
/**
 是否隐藏状态栏
 */
@property (assign, nonatomic) VPStatusBarState statusBarState;
/**
 是否显示返回按钮
 */
@property (assign,nonatomic) BOOL shownBackButton;
/**
 当前栈里的VC总数
 */
@property (assign,readonly,nonatomic) NSUInteger currentViewControllers;

/**
 注册BaseViewController的基本元素
 
 @param bgColor VC背景色
 @param bgImage 导航栏背景
 @param color 导航栏字体色
 @param setting 导航栏文字
 @param image 导航栏阴影
 @param imageName 返回按钮图片（必须填写）
 @param itemColor 按钮文字颜色
 */
+ (void)regisiterWithBackgroundColor:(UIColor *)bgColor navBackgroundImage:(UIImage *)bgImage  tintColor:(UIColor *)color titleTextAttributies:(NSDictionary *)setting shadowImage:(UIImage *)image andBackButtonImageName:(NSString *)imageName andItemTintColor:(UIColor *)itemColor;
/**
 *  填充页面静态或者本地数据
 */
- (void)setStaticDatas;
/**
 *  初始化Views
 */
- (void)setupViews;
/**
 *  请求数据
 */
- (void)requestDatas;
/**
  当前view的安全区域改变
    * viewWillLayoutSubviews之后若safeArea被改变则自动被调用
    * 若需要多次计算,自行实现系统的VC/View的change方法
 */
- (void)vp_safeAreaInsetsDidChange;
/**
 状态栏改变frame的时候调用此方法，可在方法内重置UI
 */
- (void)layoutControllerSubViews;
/** 左右按钮设置方法(多个按钮自己设置items) **/
- (void)setNavRightButtonwithImg:(NSString *)normalImg selImg:(NSString *)selImg title:(NSString *)title action:(SEL)action;
- (void)setNavLeftButtonwithImg:(NSString *)normalImg selImg:(NSString *)selImg title:(NSString *)title action:(SEL)action;
- (void)setNavLeftButtonwithImg:(NSString *)normalImg selImg:(NSString *)selImg title:(NSString *)title action:(SEL)action isBorder:(BOOL)isBorder;
- (void)setNavRightButtonwithImg:(NSString *)normalImg selImg:(NSString *)selImg title:(NSString *)title action:(SEL)action isBorder:(BOOL)isBorder;
- (void)setNavRightButtonEnable:(BOOL)enable;
- (void)setNavLeftButtonEnable:(BOOL)enable;
/** 显示Loading */
- (void)showProgressViewWithTitle:(NSString *)title;
- (void)hideProgressView;
/** 返回按钮点击后事件 **/
- (void)navBackButtonClicked:(UIButton *)sender;
/** 获得一个返回按钮 **/
- (UIButton *)navBackButton;
@end
