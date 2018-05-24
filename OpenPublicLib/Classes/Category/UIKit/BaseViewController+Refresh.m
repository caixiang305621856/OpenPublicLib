//
//  BaseViewController+Refresh.m
//  VPPublicUntilitisForPod
//
//  Created by vernepung on 2017/7/11.
//  Copyright © 2017年 vernepung. All rights reserved.
//

#import "BaseViewController+Refresh.h"
#import "NSObject+Addtion.h"
#import <objc/runtime.h>
#import "ConstMacro.h"
#import "UtilsMacro.h"
#import "UIView+Additional.h"
#import "Helper.h"

static NSString * const VPTableViewKey = @"VPTableViewKey";
static NSString * const VPCollectionViewKey = @"VPCollectionViewKey";
static NSString * const VPUseTableViewKey = @"VPUseTableViewKey";
static NSString * const VPRefreshDelegateKey = @"VPRefreshDelegateKey";
static NSString * const VPCollectionViewRefreshDelegateKey = @"VPCollectionViewRefreshDelegateKey";
static NSString * const VPDisplayRefreshControlBottomLineKey = @"VPDisplayRefreshControlBottomLineKey";
static NSString * const VPCompletedKey = @"VPCompletedKey";
static NSString * const VPCompletedPlaceholderViewKey = @"VPCompletedPlaceholderViewKey";
static NSString * const VPDataSourceKey = @"VPDataSourceKey";
static NSString * const VPRefreshControlBottomLineKey = @"VPRefreshControlBottomLineKey";
static NSString * const VPPageKey = @"VPPageKey";
static NSString * const VPPageCountKey = @"VPPageCountKey";
static NSString * const VPSupportLoadMoreKey = @"VPSupportLoadMoreKey";
static NSString * const VPSupportRefreshKey = @"VPSupportRefreshKey";
static NSString * const VPAutoRefreshKey = @"VPAutoRefreshKey";


@interface BaseViewController ()
@property (weak, nonatomic) id<VPTableViewViewControllerDelegate> vprefresh_delegate;
@property (weak, nonatomic) id<VPCollectionViewControllerDelegate> vpCollectionViewRefresh_delegate;


@end
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"
@implementation BaseViewController (Refresh)

#pragma clang diagnostic pop
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[self class] vp_swizzleClassMethodWithOriginalSel:@selector(viewDidLoad) newSel:@selector(vprefresh_viewDidLoad)];
        [[self class] vp_swizzleClassMethodWithOriginalSel:@selector(viewDidAppear:) newSel:@selector(vprefresh_viewDidAppear:)];
    });
}

#pragma mark - life cycle
- (void)vprefresh_viewDidAppear:(BOOL)animated {
    [self vprefresh_viewDidAppear:animated];
    if (self.vp_autoRefresh) {
        if (self.vp_tableView) {
            [self.vp_tableView triggerPullToRefresh];
        } else if (self.vp_collectionView) {
            [self.vp_collectionView triggerPullToRefresh];
        }
    }
}

- (void)vprefresh_viewDidLoad {
    if ([self conformsToProtocol:@protocol(VPTableViewViewControllerDelegate)]) {
        self.vp_tableView = [[UITableView alloc]initWithFrame:kRect(0, 0, kMainBoundsWidth, kMainBoundsHeight - kNavBarHeightWithStatusBarHeight) style:UITableViewStylePlain];
        self.vp_tableView.tableFooterView = [UIView new];
        self.vp_tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        self.vp_tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.vp_tableView.separatorColor = UIColorFromRGB(0xF2F0F0);
        [self.view addSubview:self.vp_tableView];
        self.vprefresh_delegate = (id)self;
        self.vp_dataSource = [NSMutableArray array];
    } else if ([self conformsToProtocol:@protocol(VPCollectionViewControllerDelegate)]) {
        self.vp_collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight - kNavBarHeightWithStatusBarHeight) collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        self.vp_collectionView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.vp_collectionView];
        self.vpCollectionViewRefresh_delegate = (id)self;
        self.vp_collectionView.alwaysBounceVertical = YES;
        self.vp_dataSource = [NSMutableArray array];
    }
    
    [self vprefresh_viewDidLoad];
    if (self.vp_tableView.pullToRefreshView) {
        [self.vp_tableView.pullToRefreshView setTitle:@"释放更新" forState:SVPullToRefreshStateTriggered];
        [self.vp_tableView.pullToRefreshView setTitle:@"下拉刷新" forState:SVPullToRefreshStateStopped];
        [self.vp_tableView.pullToRefreshView setTitle:@"加载中..." forState:SVPullToRefreshStateLoading];
    }
    if (self.vp_collectionView.pullToRefreshView) {
        [self.vp_collectionView.pullToRefreshView setTitle:@"释放更新" forState:SVPullToRefreshStateTriggered];
        [self.vp_collectionView.pullToRefreshView setTitle:@"下拉刷新" forState:SVPullToRefreshStateStopped];
        [self.vp_collectionView.pullToRefreshView setTitle:@"加载中..." forState:SVPullToRefreshStateLoading];
    }
}

- (void)vpRefresh_pullToRefresh {
    if ([self.vprefresh_delegate respondsToSelector:@selector(vp_actionWithPullDirection:)]) {
        [self.vprefresh_delegate vp_actionWithPullDirection:VPRefreshDirectionDown];
    }else if ([self.vprefresh_delegate respondsToSelector:@selector(vp_pullDownAction)]) {
        [self.vprefresh_delegate vp_pullDownAction];
    }
}

- (void)vpRefresh_pullToLoadMore {
    if ([self.vprefresh_delegate respondsToSelector:@selector(vp_actionWithPullDirection:)]) {
        [self.vprefresh_delegate vp_actionWithPullDirection:VPRefreshDirectionUp];
    }else if ([self.vprefresh_delegate respondsToSelector:@selector(vp_pullUpAction)]) {
        [self.vprefresh_delegate vp_pullUpAction];
    }
}
- (void)vpCollectionViewRefresh_pullToRefresh {
    if ([self.vpCollectionViewRefresh_delegate respondsToSelector:@selector(vp_collectionViewPullDownAction)]) {
        [self.vpCollectionViewRefresh_delegate vp_collectionViewPullDownAction];
    } else if ([self.vpCollectionViewRefresh_delegate respondsToSelector:@selector(vp_collectionViewActionWithPullDirection:)]){
        [self.vpCollectionViewRefresh_delegate vp_collectionViewActionWithPullDirection:VPRefreshDirectionDown];
    }
}
- (void)vpCollectionViewRefresh_pullToLoadMore {
    if ([self.vpCollectionViewRefresh_delegate respondsToSelector:@selector(vp_collectionViewPullUpAction)]) {
        [self.vpCollectionViewRefresh_delegate vp_collectionViewPullUpAction];
    } else if ([self.vpCollectionViewRefresh_delegate respondsToSelector:@selector(vp_collectionViewActionWithPullDirection:)]){
        [self.vpCollectionViewRefresh_delegate vp_collectionViewActionWithPullDirection:VPRefreshDirectionUp];
    }
}
#pragma mark - public function
- (void)vp_setDatas:(NSMutableArray *)datas newPage:(NSInteger)newPage {
    BOOL refresh = newPage == 0;
    [self vp_setDatas:datas newPage:newPage refresh:refresh];
}

- (void)vp_setDatas:(NSMutableArray *)datas newPage:(NSInteger)newPage refresh:(BOOL)refresh {
    self.vp_pageNumber = newPage;
    if (refresh) {
        self.vp_dataSource = datas ?: [NSMutableArray array];
    }else{
        [self.vp_dataSource addObjectsFromArray:datas];
    }
    NSInteger size = 0;
    if (self.vp_pageCount > 0) {
        size = self.vp_pageCount;
    } else {
        size = kRequestPageCount;
    }
    if (datas.count < size) {
        if (self.vp_supportLoadMore) {
            self.vp_completed = YES;
        }
    }else{
        if (refresh) {
            self.vp_supportLoadMore = YES;// 是否支持加载更多
        }
        self.vp_completed = NO;
    }
}

#pragma mark - getter & setter
- (UITableView *)vp_tableView {
    return (UITableView *)objc_getAssociatedObject(self, &VPTableViewKey);
}

- (void)setVp_tableView:(UITableView *)vp_tableView {
    objc_setAssociatedObject(self, &VPTableViewKey, vp_tableView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UICollectionView *)vp_collectionView {
    return (UICollectionView *)objc_getAssociatedObject(self, &VPCollectionViewKey);
}

- (void)setVp_collectionView:(UITableView *)vp_collectionView {
    objc_setAssociatedObject(self, &VPCollectionViewKey, vp_collectionView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - getter & setter
- (BOOL)vp_supportRefresh {
    return [objc_getAssociatedObject(self, &VPSupportRefreshKey) boolValue];
}

- (void)setVp_supportRefresh:(BOOL)vp_supportRefresh {
    if (vp_supportRefresh == [self vp_supportRefresh]) {
        return;
    }
    if (vp_supportRefresh && self.vp_tableView) {
        @weakify(self);
        [self.vp_tableView addPullToRefreshWithActionHandler:^{
            @strongify(self);
            [self vpRefresh_pullToRefresh];
        }];
        self.vp_tableView.showsPullToRefresh = vp_supportRefresh;
    } else if (vp_supportRefresh && self.vp_collectionView) {
        @weakify(self);
        [self.vp_collectionView addPullToRefreshWithActionHandler:^{
            @strongify(self);
            [self vpCollectionViewRefresh_pullToRefresh];
        }];
        self.vp_collectionView.showsPullToRefresh = vp_supportRefresh;
    }
    objc_setAssociatedObject(self, &VPSupportRefreshKey, @(vp_supportRefresh), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)vp_supportLoadMore {
    return [objc_getAssociatedObject(self, &VPSupportLoadMoreKey) boolValue];
}

- (void)setVp_supportLoadMore:(BOOL)vp_supportLoadMore {
    if (vp_supportLoadMore == [self vp_supportLoadMore]) {
        return;
    }
    if (self.vp_tableView) {
        if (vp_supportLoadMore && self.vp_tableView) {
            @weakify(self);
            [self.vp_tableView addInfiniteScrollingWithActionHandler:^{
                @strongify(self);
                [self vpRefresh_pullToLoadMore];
            }];
        }else{
            self.vp_tableView.infiniteScrollingView.enabled = NO;
        }
    } else if (self.vp_collectionView) {
        if (vp_supportLoadMore && self.vp_collectionView) {
            @weakify(self);
            [self.vp_collectionView addInfiniteScrollingWithActionHandler:^{
                @strongify(self);
                [self vpCollectionViewRefresh_pullToLoadMore];
            }];
        }else{
            self.vp_collectionView.infiniteScrollingView.enabled = NO;
        }
    }
    objc_setAssociatedObject(self, &VPSupportLoadMoreKey, @(vp_supportLoadMore), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)vp_completed {
    return [objc_getAssociatedObject(self, &VPCompletedKey) boolValue];
}

- (void)setVp_completed:(BOOL)vp_completed {
    if (vp_completed == [self vp_completed] || ![self vp_supportLoadMore]) {
        return;
    }
    if (vp_completed) {
        UIView *bgView = nil;
        if (self.vp_completedPlaceholderView) {
            bgView = self.vp_completedPlaceholderView;
        }else{
            bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 60)];
            if (self.vp_tableView) {
                bgView.backgroundColor = self.vp_tableView.backgroundColor;
            } else if (self.vp_collectionView) {
                bgView.backgroundColor = self.vp_collectionView.backgroundColor;
            }
            NSString *noMoreText = @"没有更多数据了...";
            UIFont *font = [UIFont systemFontOfSize:14];
            CGSize textSize = [Helper sizeForLabelWithString:noMoreText withFontSize:font.pointSize constrainedToSize:CGSizeMake(kMainBoundsWidth, CGFLOAT_MAX)];
            UILabel *desLabel = [[UILabel alloc]initWithFrame:kRect((bgView.width - textSize.width) / 2, (bgView.height - textSize.height) / 2, textSize.width, textSize.height)];
            desLabel.textColor = UIColorFromRGB(0xA0A0A0);
            desLabel.font = font;
            desLabel.text = noMoreText;
            [bgView addSubview:desLabel];
        }
        if (self.vp_tableView) {
            [self.vp_tableView.infiniteScrollingView setCustomView:bgView forState:SVInfiniteScrollingStateStopped];
        } else if (self.vp_collectionView) {
            [self.vp_collectionView.infiniteScrollingView setCustomView:bgView forState:SVInfiniteScrollingStateStopped];
        }
    }
    if (self.vp_tableView) {
        self.vp_tableView.infiniteScrollingView.enabled = !vp_completed;
    } else if (self.vp_collectionView) {
        self.vp_collectionView.infiniteScrollingView.enabled = !vp_completed;
    }
    objc_setAssociatedObject(self, &VPCompletedKey, @(vp_completed), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)vp_displayRefreshControlBottomLine {
    return [objc_getAssociatedObject(self, &VPDisplayRefreshControlBottomLineKey) boolValue];
}

- (void)setVp_displayRefreshControlBottomLine:(BOOL)vp_displayRefreshControlBottomLine {
    if (vp_displayRefreshControlBottomLine == [self vp_displayRefreshControlBottomLine] || ![self vp_tableView]) {
        return;
    }
    if (vp_displayRefreshControlBottomLine == [self vp_displayRefreshControlBottomLine] || ![self vp_collectionView]) {
        return;
    }
    if (vp_displayRefreshControlBottomLine) {
        if (!self.vp_refreshControlBottomLine) {
            self.vp_refreshControlBottomLine = [CALayer layer];
            if (self.vp_tableView) {
                self.vp_refreshControlBottomLine.frame = kRect(0, self.vp_tableView.pullToRefreshView.height - kOnePixelWidth, self.vp_tableView.width, kOnePixelWidth);
                self.vp_refreshControlBottomLine.backgroundColor = UIColorFromRGB(0xf0f0f0).CGColor;
                [self.vp_tableView.pullToRefreshView.layer addSublayer:self.vp_refreshControlBottomLine];
            } else if (self.vp_collectionView) {
                self.vp_refreshControlBottomLine.frame = kRect(0, self.vp_collectionView.pullToRefreshView.height - kOnePixelWidth, self.vp_collectionView.width, kOnePixelWidth);
                self.vp_refreshControlBottomLine.backgroundColor = UIColorFromRGB(0xf0f0f0).CGColor;
                [self.vp_collectionView.pullToRefreshView.layer addSublayer:self.vp_refreshControlBottomLine];
            }
        }
        self.vp_refreshControlBottomLine.hidden = NO;
    }else{
        self.vp_refreshControlBottomLine.hidden = YES;
    }
    objc_setAssociatedObject(self, &VPDisplayRefreshControlBottomLineKey, @(vp_displayRefreshControlBottomLine), OBJC_ASSOCIATION_ASSIGN);
}

- (id<VPCollectionViewControllerDelegate>)vpCollectionViewRefresh_delegate {
    return objc_getAssociatedObject(self, &VPCollectionViewRefreshDelegateKey);
}
- (void)setVpCollectionViewRefresh_delegate:(id<VPCollectionViewControllerDelegate>)vpCollectionViewRefresh_delegate {
    objc_setAssociatedObject(self, &VPCollectionViewRefreshDelegateKey, vpCollectionViewRefresh_delegate, OBJC_ASSOCIATION_ASSIGN);
}
- (id<VPTableViewViewControllerDelegate>)vprefresh_delegate {
    return objc_getAssociatedObject(self, &VPRefreshDelegateKey);
}

- (void)setVprefresh_delegate:(id<VPTableViewViewControllerDelegate>)vprefresh_delegate {
    objc_setAssociatedObject(self, &VPRefreshDelegateKey, vprefresh_delegate, OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)vp_autoRefresh {
    return [objc_getAssociatedObject(self, &VPAutoRefreshKey) boolValue];
}

- (void)setVp_autoRefresh:(BOOL)vp_autoRefresh {
    objc_setAssociatedObject(self, &VPAutoRefreshKey, @(vp_autoRefresh), OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)vp_pageNumber {
    return [objc_getAssociatedObject(self, &VPPageKey) integerValue];
}

- (void)setVp_pageNumber:(NSInteger)vp_pageNumber {
    objc_setAssociatedObject(self, &VPPageKey, @(vp_pageNumber), OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)vp_pageCount {
    return [objc_getAssociatedObject(self, &VPPageCountKey) integerValue];
}

- (void)setVp_pageCount:(NSInteger)vp_pageCount {
    objc_setAssociatedObject(self, &VPPageCountKey, @(vp_pageCount), OBJC_ASSOCIATION_ASSIGN);
}

- (UIView *)vp_completedPlaceholderView {
    return (UIView *)objc_getAssociatedObject(self, &VPCompletedPlaceholderViewKey);
}

- (void)setVp_completedPlaceholderView:(UIView *)vp_completedPlaceholderView {
    objc_setAssociatedObject(self, &VPCompletedPlaceholderViewKey, vp_completedPlaceholderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)vp_dataSource {
    return (NSMutableArray *)objc_getAssociatedObject(self, &VPDataSourceKey);
}

- (void)setVp_dataSource:(NSMutableArray *)vp_dataSource {
    objc_setAssociatedObject(self, &VPDataSourceKey, vp_dataSource, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CALayer *)vp_refreshControlBottomLine {
    return (CALayer *)objc_getAssociatedObject(self, &VPRefreshControlBottomLineKey);
}

- (void)setVp_refreshControlBottomLine:(CALayer *)vp_refreshControlBottomLine {
    objc_setAssociatedObject(self, &VPRefreshControlBottomLineKey, vp_refreshControlBottomLine, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
