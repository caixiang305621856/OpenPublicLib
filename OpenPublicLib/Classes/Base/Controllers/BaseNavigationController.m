//
//  LSBaseNavigationController.m
//
//
//  Created by vernepung on 14-4-17.
//  Copyright (c) 2014年 open. All rights reserved.
//


#import "BaseNavigationController.h"
#import "BaseViewController.h"
#import "UIImage+Additional.h"
#import "ConstMacro.h"
//#import "VPPushAnimation.h"

@interface BaseNavigationController ()<UINavigationControllerDelegate,UIGestureRecognizerDelegate>
@property (assign, nonatomic) BOOL isEnablePop;

//@property(strong,nonatomic)UIImageView *screenshotImgView;
//@property(strong,nonatomic)UIView *coverView;
//@property(strong,nonatomic)NSMutableArray *screenshotImgs;
//@property(nonatomic,strong)UIImage *nextVCScreenShotImg;
//@property(nonatomic,strong)VPPushAnimation *pushAnimation;

@end

@implementation BaseNavigationController

- (void)viewDidLoad{
    [super viewDidLoad];
    __weak BaseNavigationController *weakSelf = self;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = weakSelf;
        self.delegate = weakSelf;
    }
}

#ifdef __IPHONE_11_0
- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
}
#endif

- (id)initWithRootViewController:(UIViewController *)rootViewController{
    BaseNavigationController* nvc = [super initWithRootViewController:rootViewController];
    nvc.delegate = self;
    return nvc;
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if(self.viewControllers.count <= 1){
        return NO;
    }
    return _isEnablePop;
}

//控制根Controller不能右滑动
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    _isEnablePop = YES;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    _isEnablePop = NO;
    if (self.viewControllers.count > 0) {
        [viewController setHidesBottomBarWhenPushed:YES];
    }
    [super pushViewController:viewController animated:animated];
    //解决iPhoneX push页面时tabbar上移问题
    if (iPhoneX()) {
        CGRect frame = self.tabBarController.tabBar.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height;
        self.tabBarController.tabBar.frame = frame;
    }
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    return [super popToRootViewControllerAnimated:animated];
}

/*
- (void)viewDidLoad{
    [super viewDidLoad];
    __weak BaseNavigationController *weakSelf = self;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = weakSelf;
        self.delegate = weakSelf;
    }
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOffset = CGSizeMake(-0.8, 0);
    self.view.layer.shadowOpacity = 0.6;
    _panGestureRec = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureRec:)];
    _panGestureRec.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:_panGestureRec];
    _screenshotImgView = [[UIImageView alloc] init];
    _screenshotImgView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    _coverView = [[UIView alloc] init];
    _coverView.frame = _screenshotImgView.frame;
    _coverView.backgroundColor = [UIColor blackColor];
    _screenshotImgs = [NSMutableArray array];
}

#pragma mark - UINavigationControllerDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC  NS_AVAILABLE_IOS(7_0)
{
    self.pushAnimation.navigationOperation = operation;
    self.pushAnimation.navigationController = self;
    return self.pushAnimation;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count >= 1) {
        [viewController setHidesBottomBarWhenPushed:YES];
        [self screenShot];
    }
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    NSInteger index = self.viewControllers.count;
    NSString * className = nil;
    if (index >= 2) {
        className = NSStringFromClass([self.viewControllers[index -2] class]);
    }
    if (_screenshotImgs.count >= index - 1) {
        [_screenshotImgs removeLastObject];
    }
    return [super popViewControllerAnimated:animated];
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
    NSInteger removeCount = 0;
    for (NSInteger i = self.viewControllers.count - 1; i > 0; i--) {
        if (viewController == self.viewControllers[i]) {
            break;
        }
        [_screenshotImgs removeLastObject];
        removeCount ++;
    }
    _pushAnimation.removeCount = removeCount;
    return [super popToViewController:viewController animated:animated];
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
{
    [_screenshotImgs removeAllObjects];
    [_pushAnimation removeAllScreenShot];
    return [super popToRootViewControllerAnimated:animated];
}

#pragma private
- (void)screenShot
{
    // 将要被截图的view,即窗口的根控制器的view(必须不含状态栏,默认ios7中控制器是包含了状态栏的)
    UIViewController *beyondVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    // 背景图片 总的大小
    CGSize size = beyondVC.view.frame.size;
    // 开启上下文,使用参数之后,截出来的是原图（YES  0.0 质量高）
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    // 要裁剪的矩形范围
    CGRect rect = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    //注：iOS7以后renderInContext：由drawViewHierarchyInRect：afterScreenUpdates：替代
    //判读是导航栏是否有上层的Tabbar  决定截图的对象
    if (self.tabBarController == beyondVC) {
        [beyondVC.view drawViewHierarchyInRect:rect  afterScreenUpdates:NO];
    }else{
        [self.view drawViewHierarchyInRect:rect afterScreenUpdates:NO];
    }
    // 从上下文中,取出UIImage
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    // 添加截取好的图片到图片数组
    if (snapshot) {
        [_screenshotImgs addObject:snapshot];
        //self.lastVCScreenShotImg = snapshot;
    }
    // 千万记得,结束上下文(移除栈顶的基于当前位图的图形上下文)
    UIGraphicsEndImageContext();
}


// 监听手势的方法,只要是有手势就会执行
- (void)panGestureRec:(UIScreenEdgePanGestureRecognizer *)panGestureRec{
    // 如果当前显示的控制器已经是根控制器了，不需要做任何切换动画,直接返回
    if(self.visibleViewController == self.viewControllers[0]) return;
    // 判断pan手势的各个阶段
    switch (panGestureRec.state) {
        case UIGestureRecognizerStateBegan:
            // 开始拖拽阶段
            [self dragBegin];
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded:
            // 结束拖拽阶段
            [self dragEnd];
            break;
        default:
            // 正在拖拽阶段
            [self dragging:panGestureRec];
            break;
    }
}


#pragma mark 开始拖动,添加图片和遮罩
- (void)dragBegin
{
    // 重点,每次开始Pan手势时,都要添加截图imageview 和 遮盖cover到window中
    [[UIApplication sharedApplication].keyWindow insertSubview:_screenshotImgView atIndex:0];
    [[UIApplication sharedApplication].keyWindow insertSubview:_coverView aboveSubview:_screenshotImgView];
    // 并且,让imgView显示截图数组中的最后(最新)一张截图
    _screenshotImgView.image = [_screenshotImgs lastObject];
}
// 默认的将要变透明的遮罩的初始透明度(全黑)
#define kDefaultAlpha 0.6
// 当拖动的距离,占了屏幕的总宽高的3/4时, 就让imageview完全显示，遮盖完全消失
#define kTargetTranslateScale 0.75
- (void)dragging:(UIPanGestureRecognizer *)pan{
    // 得到手指拖动的位移
    CGFloat offsetX = [pan translationInView:self.view].x;
    // 让整个view都平移     // 挪动整个导航view
    if (offsetX > 0) {
        self.view.transform = CGAffineTransformMakeTranslation(offsetX, 0);
    }
    // 计算目前手指拖动位移占屏幕总的宽高的比例,当这个比例达到3/4时, 就让imageview完全显示，遮盖完全消失
    double currentTranslateScaleX = offsetX/self.view.frame.size.width;
    if (offsetX < ScreenWidth) {
        _screenshotImgView.transform = CGAffineTransformMakeTranslation((offsetX - ScreenWidth) * 0.6, 0);
    }
    // 让遮盖透明度改变,直到减为0,让遮罩完全透明,默认的比例-(当前平衡比例/目标平衡比例)*默认的比例
    double alpha = kDefaultAlpha - (currentTranslateScaleX/kTargetTranslateScale) * kDefaultAlpha;
    _coverView.alpha = alpha;
}

- (void)dragEnd
{
    // 取出挪动的距离
    CGFloat translateX = self.view.transform.tx;
    // 取出宽度
    CGFloat width = self.view.frame.size.width;
    
    if (translateX <= 40) {
        // 如果手指移动的距离还不到屏幕的一半,往左边挪 (弹回)
        [UIView animateWithDuration:0.3 animations:^{
            // 重要~~让被右移的view弹回归位,只要清空transform即可办到
            self.view.transform = CGAffineTransformIdentity;
            // 让imageView大小恢复默认的translation
            _screenshotImgView.transform = CGAffineTransformMakeTranslation(-ScreenWidth, 0);
            // 让遮盖的透明度恢复默认的alpha 1.0
            _coverView.alpha = kDefaultAlpha;
        } completion:^(BOOL finished) {
            // 重要,动画完成之后,每次都要记得 移除两个view,下次开始拖动时,再添加进来
            [_screenshotImgView removeFromSuperview];
            [_coverView removeFromSuperview];
        }];
    } else {
        // 如果手指移动的距离还超过了屏幕的一半,往右边挪
        [UIView animateWithDuration:0.3 animations:^{
            // 让被右移的view完全挪到屏幕的最右边,结束之后,还要记得清空view的transform
            self.view.transform = CGAffineTransformMakeTranslation(width, 0);
            // 让imageView位移还原
            _screenshotImgView.transform = CGAffineTransformMakeTranslation(0, 0);
            // 让遮盖alpha变为0,变得完全透明
            _coverView.alpha = 0;
        } completion:^(BOOL finished) {
            // 重要~~让被右移的view完全挪到屏幕的最右边,结束之后,还要记得清空view的transform,不然下次再次开始drag时会出问题,因为view的transform没有归零
            self.view.transform = CGAffineTransformIdentity;
            // 移除两个view,下次开始拖动时,再加回来
            [_screenshotImgView removeFromSuperview];
            [_coverView removeFromSuperview];
            // 执行正常的Pop操作:移除栈顶控制器,让真正的前一个控制器成为导航控制器的栈顶控制器
            [self popViewControllerAnimated:NO];
            // 重要~记得这时候,可以移除截图数组里面最后一张没用的截图了
            [self.pushAnimation removeLastScreenShot];
        }];
    }
}

- (BOOL)shouldAutorotate{
    return [self.topViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return [self.topViewController supportedInterfaceOrientations];
}

- (VPPushAnimation *)pushAnimation
{
    if (_pushAnimation == nil) {
        _pushAnimation = [[VPPushAnimation alloc]init];
    }
    return _pushAnimation;
}
*/
@end
