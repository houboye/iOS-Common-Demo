//
//  UITextField+Extension.m
//  Common_iOS
//
//  Created by CardiorayT1 on 2018/8/27.
//  Copyright © 2018年 houboye. All rights reserved.
//

#import "UITextField+Extension.h"

@implementation UITextField (Extension)

- (BOOL)checkText {
    if (self.text == nil
        || [self.text isEqualToString:@""]
        || [self.text isEqualToString:@" "]) {
        return NO;
    }
    return YES;
}

@end
