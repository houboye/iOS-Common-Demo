//
//  UIScrollView+PullToRefresh.h
//  Common_iOS
//
//  Created by CardiorayT1 on 2018/8/27.
//  Copyright © 2018年 houboye. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BYPullToRefreshView;

@interface UIScrollView (BYPullToRefresh)

typedef NS_ENUM(NSUInteger, BYPullToRefreshPosition) {
    BYPullToRefreshPositionTop = 0,
    BYPullToRefreshPositionBottom,
};

- (void)addPullToRefreshWithActionHandler:(void (^)(void))actionHandler;
- (void)addPullToRefreshWithActionHandler:(void (^)(void))actionHandler position:(BYPullToRefreshPosition)position;
- (void)triggerPullToRefresh;

@property (nonatomic, strong, readonly) BYPullToRefreshView *pullToRefreshView;
@property (nonatomic, assign) BOOL showsPullToRefresh;

@end


typedef NS_ENUM(NSUInteger, BYPullToRefreshState) {
    BYPullToRefreshStateStopped = 0,
    BYPullToRefreshStateTriggered,
    BYPullToRefreshStateLoading,
    BYPullToRefreshStateAll = 10
};

@interface BYPullToRefreshView : UIView

@property (nonatomic, strong) UIColor *arrowColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *subtitleLabel;
@property (nonatomic, strong, readwrite) UIColor *activityIndicatorViewColor;
@property (nonatomic, readwrite) UIActivityIndicatorViewStyle activityIndicatorViewStyle;

@property (nonatomic, readonly) BYPullToRefreshState state;
@property (nonatomic, readonly) BYPullToRefreshPosition position;

- (void)setTitle:(NSString *)title forState:(BYPullToRefreshState)state;
- (void)setSubtitle:(NSString *)subtitle forState:(BYPullToRefreshState)state;
- (void)setCustomView:(UIView *)view forState:(BYPullToRefreshState)state;

- (void)startAnimating;
- (void)stopAnimating;


@end
