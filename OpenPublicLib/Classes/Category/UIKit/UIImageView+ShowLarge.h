//
//  UIImageView+ShowLarge.h
//  StudentStudyNew
//
//  Created by vernepung on 15/10/30.
//  Copyright (c) 2015年 vernepung. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^VPTapBlock)(UIGestureRecognizer *);
typedef void (^VPLongPressBlock)(UILongPressGestureRecognizer *);

@interface UIImageView (ShowLarge)
@property (copy,nonatomic) VPTapBlock oneTap;
- (void)showWithLargeImageUrl:(NSString *)url;
@end
