//
//  UIAlertController+Extension.h
//  Common_iOS
//
//  Created by CardiorayT1 on 2018/8/27.
//  Copyright © 2018年 houboye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Extension)

- (UIAlertController *_Nonnull)addAction:(NSString *_Nullable)title
                           style:(UIAlertActionStyle)style
                                 handler:(void (^ __nullable)(UIAlertAction * _Nonnull action))handler;

- (void)show;

@end
