//
//  UITableView+UINib.h
//  TestUINib
//
//  Created by vernepung on 16/5/3.
//  Copyright © 2016年 vernepung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (Additional)
/**
 *  当前tableView已经注册的Nib,readonly 方便debug查看
 */
@property (strong,nonatomic,readonly) NSMutableArray *registerNibArray;

- (BOOL)registeredIdentifier:(NSString *)identifier;
/**
 返回空白行
 
 @param color 背景色
 @return cell
 */
- (UITableViewCell *)getSeparatorCellWithBackgroundColor:(UIColor *)color;

/**
 显示友好界面.并支持下拉刷新
 
 @param msg 提示语
 */
- (void)showFriendlyTipsForRefreshTableViewWithMessage:(NSString *)msg;
- (void)showFriendlyTipsForRefreshTableViewWithMessage:(NSString *)msg withTag:(NSUInteger)tag;
@end
