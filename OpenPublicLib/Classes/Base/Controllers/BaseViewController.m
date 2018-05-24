//
//  LSBaseViewController.m
//  _6.0
//
//  Created by vernepung on 13-10-21.
//  Copyright (c) 2013年 vernepung. All rights reserved.
//
//#import "EmptyNotionView.h"

#import "BaseViewController.h"
#import "MBProgressHUD.h"
#import "BaseNavigationController.h"
#import "UIView+Additional.h"
#import "UIImage+Additional.h"
#import "Helper.h"
#import "ConstMacro.h"

static UIColor *backgroundColor;
static UIColor *barItemColor;
static UIImage *backButtonImage;

@interface BaseViewController ()<UIGestureRecognizerDelegate> {
    BOOL _shownBackButton;
}
@property (strong, nonatomic) MBProgressHUD *progressView;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation BaseViewController
#pragma clang diagnostic pop

@dynamic shownBackButton;

+ (void)regisiterWithBackgroundColor:(UIColor *)bgColor navBackgroundImage:(UIImage *)bgImage tintColor:(UIColor *)color titleTextAttributies:(NSDictionary *)setting shadowImage:(UIImage *)image andBackButtonImageName:(NSString *)imageName andItemTintColor:(UIColor *)itemColor{
    backButtonImage = [UIImage imageNamed:imageName];
    NSAssert(backButtonImage, @"must be set backButtonImage");
    backgroundColor = bgColor;
    barItemColor = itemColor;
    // 整体处理Nav
    [[UINavigationBar appearanceWhenContainedIn:[BaseNavigationController class], nil] setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearanceWhenContainedIn:[BaseNavigationController class], nil] setTintColor:color];
    [[UINavigationBar appearanceWhenContainedIn:[BaseNavigationController class], nil] setTitleTextAttributes:setting];
    [[UINavigationBar appearance] setShadowImage:image];
    
    [[UIScrollView appearance] setLayoutMargins:UIEdgeInsetsZero];
    // 整体处理TableView
    [[UITableView appearance] setSeparatorInset:UIEdgeInsetsZero];
//    [[UITableView appearance] setSeparatorStyle:(UITableViewCellSeparatorStyleNone)]; /*因为这句代码让很多页面使用系统分隔线的cell消失了 所以注释这句 侯锐 */
    [[UITableView appearance] setLayoutMargins:UIEdgeInsetsZero];
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        [[UITableView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        [UITableView appearance].estimatedRowHeight = 0;
        [UITableView appearance].estimatedSectionHeaderHeight = 0;
        [UITableView appearance].estimatedSectionFooterHeight = 0;
    }
#endif
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _navigationBarState = VPNavigationBarStateNone;
        _statusBarStype = VPStatusBarStyleDefault;
        _currentInsets = UIEdgeInsetsZero;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layoutControllerSubViews) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // iOS 11之前,更改VC的automaticallyAdjustsScrollViewInsets
    // iOS 11之后,更改为TableView的contentInsetAdjustmentBehavior(查看UITableView+Additional.h的+load)
    self.automaticallyAdjustsScrollViewInsets = NO;
    _currentViewControllers = self.navigationController.viewControllers.count;
    self.navigationItem.hidesBackButton = YES;
    self.shownBackButton = YES;
    self.view.backgroundColor = backgroundColor;
    if ([self respondsToSelector:@selector(setStaticDatas)]) {
        [self setStaticDatas];
    }
    if ([self respondsToSelector:@selector(setupViews)]) {
        [self setupViews];
    }
    if ([self respondsToSelector:@selector(requestDatas)]) {
        [self requestDatas];
    }
}

#ifdef __IPHONE_11_0
- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    if (!UIEdgeInsetsEqualToEdgeInsets(self.currentInsets, vp_viewSafeArea(self.view))){
        _currentInsets = vp_viewSafeArea(self.view);
        if ([self respondsToSelector:@selector(vp_safeAreaInsetsDidChange)]) {
            [self vp_safeAreaInsetsDidChange];
        }
    }
}
#endif

- (void)setShownBackButton:(BOOL)shownBackButton{
    if (_shownBackButton == shownBackButton){
        return;
    }
    _shownBackButton = shownBackButton;
    if (_shownBackButton && _currentViewControllers > 1){
        [self setNavBackButton];
    }
    else{
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (UIButton *)navBackButton{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.exclusiveTouch = YES;
    [button setImage:backButtonImage forState:UIControlStateNormal];
    [button setImage:backButtonImage forState:UIControlStateHighlighted];
    [button setImage:backButtonImage forState:UIControlStateDisabled];
    button.size = backButtonImage.size;
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
    [button addTarget:self action:@selector(navBackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.left = 16;
    button.top = 2 + CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    return button;
}

- (void)setNavBackButton{
    UIButton *btn = [self navBackButton];
    btn.top = btn.left = 0;
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    UIOffset offset;
    offset.horizontal = -500;
    [backItem setBackButtonTitlePositionAdjustment:offset forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.leftBarButtonItem = backItem;
}

- (BOOL)shownBackButton{
    return _shownBackButton;
}

- (void)layoutControllerSubViews{
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setNavigationBarState:self.navigationBarState];
    [self setStatusBarState:self.statusBarState];
}

#pragma mark - UIGestureRecongnizerDelegate
- (void)handleSwipeGR:(UIGestureRecognizer*)gestureRecognizer{
    if (UISwipeGestureRecognizerDirectionLeft){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setNavRightButtonwithImg:(NSString *)normalImg selImg:(NSString *)selImg title:(NSString *)title action:(SEL)action{
    self.navigationItem.rightBarButtonItem = [self getButtonItemWithImg:normalImg selImg:selImg title:title action:action isBorder:NO];
}

- (void)setNavLeftButtonwithImg:(NSString *)normalImg selImg:(NSString *)selImg title:(NSString *)title action:(SEL)action{
    self.navigationItem.leftBarButtonItem = [self getButtonItemWithImg:normalImg selImg:selImg title:title action:action isBorder:NO];
}

- (void)setNavLeftButtonwithImg:(NSString *)normalImg selImg:(NSString *)selImg title:(NSString *)title action:(SEL)action isBorder:(BOOL)isBorder{
    self.navigationItem.leftBarButtonItem = [self getButtonItemWithImg:normalImg selImg:selImg title:title action:action isBorder:isBorder];
}

-(void)setNavRightButtonwithImg:(NSString *)normalImg selImg:(NSString *)selImg title:(NSString *)title action:(SEL)action isBorder:(BOOL)isBorder{
    self.navigationItem.rightBarButtonItem = [self getButtonItemWithImg:normalImg selImg:selImg title:title action:action isBorder:isBorder];
}

- (void)setNavRightButtonEnable:(BOOL)enable{
    [self.navigationItem.rightBarButtonItem setEnabled:enable];
}

- (void)setNavLeftButtonEnable:(BOOL)enable{
    [self.navigationItem.leftBarButtonItem setEnabled:enable];
}

#pragma mark - NavButton Clicked
- (void)navGoHomeButtonClicked:(UIButton *)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)navBackButtonClicked:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MG_NavBaseViewController private
- (UIBarButtonItem *)getButtonItemWithImg:(NSString *)norImg selImg:(NSString *)selImg title:(NSString *)title action:(SEL)action isBorder:(BOOL)isBorder{
    CGSize navbarSize = self.navigationController.navigationBar.bounds.size;
    CGRect frame = CGRectMake(0, 0, navbarSize.width / 3, navbarSize.height - 3);
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.exclusiveTouch = YES;
    if (norImg){
        UIImage* norImage = [UIImage imageNamed:norImg];
        [button setImage:norImage forState:UIControlStateNormal];
        [button setImage:norImage forState:UIControlStateHighlighted];
        [button setImage:norImage forState:UIControlStateDisabled];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
        button.size = norImage.size;
    }
    if (selImg){
        UIImage* selImage = [UIImage imageNamed:selImg];
        [button setImage:selImage forState:UIControlStateHighlighted];
    }
    if (title) {
        CGSize strSize = [Helper sizeForLabelWithString:title withFontSize:16 constrainedToSize:frame.size];
        [button setTitleColor:barItemColor forState:UIControlStateNormal];
        [button setTitleColor:barItemColor forState:UIControlStateHighlighted];
        [button setTitleColor:barItemColor forState:UIControlStateDisabled];
        [button setTitle:title forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
        frame.size.width = MIN(frame.size.width, strSize.width);
        frame.size.height = strSize.height+5;
        if (isBorder) {
            button.layer.cornerRadius = 2.f;
            button.layer.masksToBounds = YES;
            button.layer.borderColor = [UIColor whiteColor].CGColor;
            button.layer.borderWidth = 0.5f;
        }
        button.frame = frame;
    }
    button.top = 0;
    button.left = 0;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* tmpBarBtnItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return tmpBarBtnItem;
}

#pragma mark - ProgressView Event
- (void)showProgressViewWithTitle:(NSString *)title{
    [self.view addSubview:self.progressView];
    if (title){
        self.progressView.label.text = title;
    }
    [self.progressView showAnimated:YES];
    [self.view bringSubviewToFront:self.progressView];
}

- (void)hideProgressView{
    [self.progressView hideAnimated:YES];
}

#pragma mark - private
- (NSUInteger)viewControllersCount{
    return self.navigationController.viewControllers.count;
}

#pragma mark - getter & setter
- (MBProgressHUD *)progressView{
    if (!_progressView) {
        _progressView = [[MBProgressHUD alloc] initWithView:self.view];
    }
    return _progressView;
}

- (void)setStatusBarState:(VPStatusBarState)statusBarState{
    if (_statusBarState == statusBarState && statusBarState == [UIApplication sharedApplication].statusBarHidden){
        return;
    }
    _statusBarState = statusBarState;
    [[UIApplication sharedApplication] setStatusBarHidden:_statusBarState withAnimation:UIStatusBarAnimationFade];
}

- (void)setStatusBarStype:(VPStatusBarStyle)statusBarStype{
    if (_statusBarStype == statusBarStype && [self preferredStatusBarStyle] == [UIApplication sharedApplication].statusBarStyle) {
        return;
    }
    _statusBarStype = statusBarStype;
    [[UIApplication sharedApplication] setStatusBarStyle:[self preferredStatusBarStyle] animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return self.statusBarStype != VPStatusBarStyleDefault ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (void)setNavigationBarState:(VPNavigationBarState)navigationBarState{
    _navigationBarState = navigationBarState;
    if (self.navigationBarState != VPNavigationBarStateNone && self.navigationBarState != self.navigationController.navigationBarHidden){
        [self.navigationController setNavigationBarHidden:self.navigationBarState animated:YES];
    }
}

@end

