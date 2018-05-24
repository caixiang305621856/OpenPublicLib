//
//  BaseView.h
//  Hands-Seller
//
//  Created by vernepung on 14-4-18.
//  Copyright (c) 2014年 vernepung. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface BaseView : UIView

+ (id)loadFromXib;

- (void)viewLayoutWithData:(id)data;

+ (CGFloat)viewHeightForObject:(id)object;

@end
 
