//
//  BaseView.m
//  Hands-Seller
//
//  Created by vernepung on 14-4-18.
//  Copyright (c) 2014年 vernepung. All rights reserved.
//

#import "BaseView.h"

@implementation BaseView
+ (id)loadFromXib
{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:self options:nil]firstObject];
}

- (void)viewLayoutWithData:(id)data{
    
    
}

+ (CGFloat)viewHeightForObject:(id)object
{
    return 0;
}

@end
 
