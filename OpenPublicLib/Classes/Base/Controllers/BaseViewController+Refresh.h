//
//  BaseViewController+Refresh.h
//  VPPublicUntilitisForPod
//
//  Created by vernepung on 2017/7/11.
//  Copyright © 2017年 vernepung. All rights reserved.
//

#import "BaseViewController.h"
#import "SVPullToRefresh.h"
/**
 拉动的方向
 
 - VPRefreshDirectionUp: 向上拉动(加载更多)
 - VPRefreshDirectionDown: 向下拉动(下拉刷新)
 */
typedef NS_ENUM(NSInteger, VPRefreshDirection) {
    
    VPRefreshDirectionUp = 0,
    VPRefreshDirectionDown = 1,
};
@protocol VPTableViewViewControllerDelegate;
@interface BaseViewController (Refresh)<UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource>
/**
 default NO
 */
@property (assign, nonatomic) BOOL vp_autoRefresh;
/**
 default NO
 */
@property (assign, nonatomic) BOOL vp_supportRefresh;
/**
 default NO
 */
@property (assign, nonatomic) BOOL vp_supportLoadMore;
/**
 default NO,
 
 if you call pullToLoadMore, when you data is load over, you must set property 'completed' = YES;
 
 when you call pullToRefresh, the function will set property 'completed' = NO;
 */
@property (assign, nonatomic) BOOL vp_completed;
/**
 page number
 */
@property (assign, nonatomic) NSInteger vp_pageNumber;
/**
 page count
 */
@property (assign, nonatomic) NSInteger vp_pageCount;
/**
 default NO,
 
 you can use property 'displayRefreshControlBottomLine' to set layer display or not display
 */
@property (assign, nonatomic) BOOL vp_displayRefreshControlBottomLine;
/**
 default nil,
 
 when you set property 'displayRefreshControlBottomLine' YES,
 
 the refreshControlBottomLine layer will be create with
 
 frame (0, tableView.pullToRefreshView.height - kOnePixelWidth, self.tableView.width, kOnePixelWidth),
 
 and defalut color '0xF2F0F0'
 */
@property (assign, nonatomic, readonly) CALayer *vp_refreshControlBottomLine;
/**
 when you support <VPTableViewViewControllerDelegate>, dataSource will init;
 
 otherwise the dataSource is nil.
 */
@property (strong, nonatomic) NSMutableArray *vp_dataSource;
/**
 when the property 'completed' be YES;
 
 completedPlaceholderView will display in the tableview bottom
 
 and when you not set this property
 
 the default View:
 
 bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 60)];
 NSString *noMoreText = @"没有更多数据了...";
 */
@property (strong, nonatomic) UIView *vp_completedPlaceholderView;
/**
 when your viewcontroller support <VPTableViewViewControllerDelegate>,
 
 current viewcontroller offer an tableView with defalut frame (0,0,fullwidth,fullheight - navHeight - statusbarHeight), default don't support pull to refresh
 
 otherwise the tableView is nil.
 
 you can set canRefresh, canLoadmore in [BaseViewController setStaticDatas];
 
 you can set your own Frame in [BaseViewController setupViews];
 */
@property (strong, nonatomic, readonly) UITableView *vp_tableView;

@property (strong, nonatomic) UICollectionView *vp_collectionView;

- (void)vp_setDatas:(NSMutableArray *)datas newPage:(NSInteger)newPage;
// 当起始页的页码不为0的时候,需要调用此方法,告知是否是刷新
- (void)vp_setDatas:(NSMutableArray *)datas newPage:(NSInteger)newPage refresh:(BOOL)refresh;
@end

@protocol VPTableViewViewControllerDelegate <NSObject>
@optional
/**
 下拉刷新
 */
- (void)vp_pullDownAction;
/**
 上拉加载更多
 */
- (void)vp_pullUpAction;
/**
 拖动除非事件
 
 @param direction 拖动放心
 @desc 可以根据枚举Up/Down 来判断是否是刷新
 */
- (void)vp_actionWithPullDirection:(VPRefreshDirection)direction;
@end

@protocol VPCollectionViewControllerDelegate <NSObject>

@optional
/**
 下拉刷新
 */
- (void)vp_collectionViewPullDownAction;
/**
 上拉加载更多
 */
- (void)vp_collectionViewPullUpAction;
/**
 拖动除非事件
 
 @param direction 拖动放心
 @desc 可以根据枚举Up/Down 来判断是否是刷新
 */
- (void)vp_collectionViewActionWithPullDirection:(VPRefreshDirection)direction;
@end
