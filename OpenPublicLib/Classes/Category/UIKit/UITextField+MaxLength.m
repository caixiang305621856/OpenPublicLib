//
//  UITextField+MaxLength.m
//  teacherSecretary
//
//  Created by verne on 16/6/22.
//  Copyright © 2016年 vernepung. All rights reserved.
//

#import "UITextField+MaxLength.h"
#import <objc/runtime.h>
#import "UIView+Additional.h"
static const void *maxLengthKey = &maxLengthKey;
@implementation UITextField (MaxLength)
+ (void)initialize{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class fieldClass = [UITextField class];
        SEL originalSEL = @selector(willMoveToSuperview:);
        SEL swizzingSEL = @selector(vp_willMoveToSuperview:);
        
        Method originalMethod = class_getInstanceMethod(fieldClass, originalSEL);
        Method swizzingMethod = class_getInstanceMethod(fieldClass, swizzingSEL);
        
        BOOL addSwizzingMethoded = class_addMethod(fieldClass, originalSEL, method_getImplementation(swizzingMethod), method_getTypeEncoding(swizzingMethod));
        if (addSwizzingMethoded){
            class_replaceMethod(fieldClass, swizzingSEL, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        }else{
            method_exchangeImplementations(originalMethod, swizzingMethod);
        }
    });
}

- (void)vp_willMoveToSuperview:(UIView *)newSuperview{
    if (!self.leftView){
        UIView *leftView = [[UIView alloc]initWithFrame:self.bounds];
        leftView.width = 10;
        self.leftView = leftView;
        self.leftViewMode = UITextFieldViewModeAlways;
    }
    [self vp_willMoveToSuperview:newSuperview];
}

- (void)setMaxLength:(NSUInteger)maxLength{
    objc_setAssociatedObject(self, maxLengthKey, [NSNumber numberWithUnsignedInteger:maxLength], OBJC_ASSOCIATION_RETAIN);
    [self removeTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
    [self addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
    
}

- (NSUInteger)maxLength{
    id value = objc_getAssociatedObject(self, maxLengthKey);
    if ([value isKindOfClass:[NSNumber class]]){
        return [((NSNumber *)value) unsignedIntegerValue];
    }
    return 0;
}

- (void)textChanged{
    NSString *toBeString = self.text;
    NSString *lang = [self.textInputMode primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"])// 简体中文输入
    {
        //获取高亮部分
        UITextRange *selectedRange = [self markedTextRange];
        UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position || !selectedRange)
        {
            if (toBeString.length > [self maxLength])
            {
                NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:[self maxLength]];
                if (rangeIndex.length == 1)
                {
                    self.text = [toBeString substringToIndex:[self maxLength]];
                }
                else
                {
                    NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, [self maxLength])];
                    self.text = [toBeString substringWithRange:rangeRange];
                }
            }
        }
        
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else
    {
        if (toBeString.length > [self maxLength])
        {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:[self maxLength]];
            if (rangeIndex.length == 1)
            {
                self.text = [toBeString substringToIndex:[self maxLength]];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, [self maxLength])];
                self.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
    //    DLog(@"xxxx--xxxx-xx-x-x-x");
    //    NSUInteger maxLength = [self maxLength];
    //    bool isChinese;//判断当前输入法是否是中文
    //    NSArray *currentar = [UITextInputMode activeInputModes];
    //    UITextInputMode *current = [currentar firstObject];
    //    if ([current.primaryLanguage isEqualToString: @"zh-Hans"]) {
    //        isChinese = true;
    //    }else{
    //        isChinese = false;
    //    }
    //    //    if(sender == self) {
    //    // length是自己设置的位数
    //    NSString *str = [[self text] stringByReplacingOccurrencesOfString:@"?" withString:@""];
    //    if (isChinese) { //中文输入法下
    //        UITextRange *selectedRange = [self markedTextRange];
    //        //获取高亮部分
    //        UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
    //        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    //        if (!position) {
    //            if ( str.length >= maxLength) {
    //                NSString *strNew = [NSString stringWithString:str];
    //                [self setText:[strNew substringToIndex:maxLength]];
    //            }
    //        }
    //        else
    //        {
    //            // NSLog(@"输入的");
    //
    //        }
    //    }else{
    //        if ([str length] >= maxLength) {
    //            NSString *strNew = [NSString stringWithString:str];
    //            [self setText:[strNew substringToIndex:maxLength]];
    //            DLog(@"xxxx--xxxx-xx-x-x-x");
    //        }
    //    }
    //    //    }
}
@end
