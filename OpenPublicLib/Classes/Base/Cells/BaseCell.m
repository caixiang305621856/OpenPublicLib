//
//  LSBaseCell.m
//  
//
//  Created by vernepung on 14-5-12.
//  Copyright (c) 2014年 vernepung. All rights reserved.
//

#import "BaseCell.h"
#import "UITableView+Additional.h"

@interface BaseCell()


@end

@implementation BaseCell
#pragma mark - UINib

+ (UINib *)loadNibFromXib {
    return [UINib nibWithNibName:NSStringFromClass(self) bundle:nil];
}

+ (instancetype)initCellFromNibWithTableView:(UITableView *)tableView {
    [self registerNibWithTableview:tableView];
    return [tableView dequeueReusableCellWithIdentifier:[[self class] cellIdentifier]];
}

+ (void)registerNibWithTableview:(UITableView *)tableView {
    if (![tableView registeredIdentifier:[self cellIdentifier]]){
        UINib *nib = [self loadNibFromXib];
        [tableView registerNib:nib forCellReuseIdentifier:[self cellIdentifier]];
    }
}

#pragma mark - Xib
+ (instancetype)initCellFromXibWithTableView:(UITableView *)tableView {
    id cell = [tableView dequeueReusableCellWithIdentifier:[[self class] cellIdentifier]];
    if (!cell)
    {
        cell = [[self class] loadFromXib];
    }
    return cell;
}

#pragma mark - other function
+ (id)loadFromXib {
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:self options:nil] firstObject];
}

+ (id)loadFromCellStyle:(UITableViewCellStyle)cellStyle
{
    return [[self alloc] initWithStyle:cellStyle reuseIdentifier:NSStringFromClass(self)];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // 屏蔽iOS8.2下xib错误间距
//    if (iOSVersion > 8.0) {
        self.preservesSuperviewLayoutMargins = NO;
//    }
    //     self.contentView.backgroundColor = [UIColor whiteColor];
//    UIView* bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, self.bounds.size.height)];
//    bgView.backgroundColor = RGB(240, 240, 240);
//    self.selectedBackgroundView = bgView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
}

+ (CGFloat)rowHeightForObject:(id)object{
    return 0;
}

+ (NSString*)cellIdentifier{
    return NSStringFromClass(self);
}

- (void)fillCellWithObject:(id)object {
    
}
@end
