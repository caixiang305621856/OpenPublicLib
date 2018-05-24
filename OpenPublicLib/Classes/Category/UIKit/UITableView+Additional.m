//
//  UITableView+UINib.m
//  TestUINib
//
//  Created by vernepung on 16/5/3.
//  Copyright © 2016年 vernepung. All rights reserved.
//

#import "UITableView+Additional.h"
#import <objc/runtime.h>
#import "NSObject+Addtion.h"
#import "SVPullToRefresh.h"
#import "UIView+Empty.h"
static const void *registerNibArrayKey = &registerNibArrayKey;
@implementation UITableView (Additional)
- (void)dealloc {
    [self.registerNibArray removeAllObjects];
    objc_setAssociatedObject(self, registerNibArrayKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self vp_swizzleClassMethodWithOriginalSel:@selector(registerNib:forCellReuseIdentifier:) newSel:@selector(vp_registerNib:forCellReuseIdentifier:)];
        [self vp_swizzleClassMethodWithOriginalSel:@selector(reloadData) newSel:@selector(vprefresh_reloadData)];
    });
}

- (void)vprefresh_reloadData {
    if (self.pullToRefreshView && self.pullToRefreshView.state == SVPullToRefreshStateLoading) {
        [self.pullToRefreshView stopAnimating];
    }
    if(self.infiniteScrollingView && self.infiniteScrollingView.state == SVInfiniteScrollingStateLoading){
        [self.infiniteScrollingView stopAnimating];
    }
    [self vprefresh_reloadData];
}

- (NSMutableArray *)registerNibArray {
    NSMutableArray *array = objc_getAssociatedObject(self, registerNibArrayKey);
    if (!array) {
        array = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, registerNibArrayKey, array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return array;
}

- (void)vp_registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier {
    if (![self.registerNibArray containsObject:identifier])
    {
        [self.registerNibArray addObject:identifier];
    }
    [self vp_registerNib:nib forCellReuseIdentifier:identifier];
}

- (BOOL)registeredIdentifier:(NSString *)identifier {
    return [self.registerNibArray containsObject:identifier];
}

- (UITableViewCell *)getSeparatorCellWithBackgroundColor:(UIColor *)color {
    static NSString *emptyCellIdentifier = @"emptyCellIdentifier";
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:emptyCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = cell.backgroundColor = color;
    }
    return cell;
}

- (void)showFriendlyTipsForRefreshTableViewWithMessage:(NSString *)msg {
    [self showFriendlyTipsForRefreshTableViewWithMessage:msg withTag:12343];
}

- (void)showFriendlyTipsForRefreshTableViewWithMessage:(NSString *)msg withTag:(NSUInteger)tag {
    [self showFriendlyTipsWithMessage:msg];
    [self.superview bringSubviewToFront:self];
}

@end
