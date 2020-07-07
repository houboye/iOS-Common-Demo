//
//  UIScrollView+Direction.h
//  Common_iOS
//
//  Created by CardiorayT1 on 2018/8/27.
//  Copyright © 2018年 houboye. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum BYScrollViewDirection {
    BYScrollViewDirectionNone,
    BYScrollViewDirectionRight,
    BYScrollViewDirectionLeft,
    BYScrollViewDirectionUp,
    BYScrollViewDirectionDown,
} BYScrollViewDirection;

@interface UIScrollView (Direction)

- (void)startObservingDirection;
- (void)stopObservingDirection;

@property (readonly, nonatomic) BYScrollViewDirection horizontalScrollingDirection;
@property (readonly, nonatomic) BYScrollViewDirection verticalScrollingDirection;

@end
