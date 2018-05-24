//
//  LSBaseCell.h
//  
//
//  Created by vernepung on 14-5-12.
//  Copyright (c) 2014年 vernepung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseCell : UITableViewCell
@property (strong ,nonatomic) NSIndexPath *indexPath;

/**
 不希望检测当前Cell是否可以复用需要手动设置为YES
 */
@property (assign ,nonatomic) BOOL dontCheck;
/**
 *  加载UINib文件
 *
 *  @return nib
 */
+ (UINib *)loadNibFromXib;
/**
 *  直接根据Cell注册UINib，并返回实例
 *
 *  @param tableView 需要注册当前Cell类型的TableView
 *
 *  @return 实例
 */
+ (instancetype)initCellFromNibWithTableView:(UITableView *)tableView;
/**
 *  注册UINib文件
 *
 *  @param tableView  需要注册当前Cell类型的TableView
 */
+ (void)registerNibWithTableview:(UITableView *)tableView;
/**
 *  用xib创建Cell
 *
 *  @warning 可根据情况使用UINib方式加载, + (UINib *)loadNibFromXib;
 *
 *  @return self;
 */
+ (id)loadFromXib;

/**
 *  用代码创建Cell时候设置的cellIdentifier
 *
 *  @return cellIdentifier;
 */
+ (NSString*)cellIdentifier;
/**
 *  用代码创建Cell
 *
 *  @return self;
 */

+ (id)loadFromCellStyle:(UITableViewCellStyle)cellStyle;

/**
 *  填充cell的对象
 *  子类去实现
 */

- (void)fillCellWithObject:(id)object;

/**
 *  计算cell高度
 *  子类去实现
 */

+ (CGFloat)rowHeightForObject:(id)object;
/**
 *  初始化Cell
 *
 *  @warning xib较多时，推荐更换为UINib方式加载, + (instancetype)initCellFromNibWithTableView:(UITableView *)tableView;
 *
 *  @param tableView 关联的tableView
 *  @return Cell
 */
+ (instancetype)initCellFromXibWithTableView:(UITableView *)tableView;



@end
