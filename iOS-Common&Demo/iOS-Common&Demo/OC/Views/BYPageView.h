//
//  BYPageView.h
//  Common_iOS
//
//  Created by CardiorayT1 on 2019/1/7.
//  Copyright © 2019 houboye. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <UIKit/UIKit.h>
@class BYPageView;

@protocol BYPageViewDataSource <NSObject>
- (NSInteger)numberOfPages:(BYPageView *)pageView;
- (UIView *)pageView:(BYPageView *)pageView viewInPage:(NSInteger)index;
@end

@protocol BYPageViewDelegate <NSObject>
@optional
- (void)pageViewScrollEnd:(BYPageView *)pageView
             currentIndex:(NSInteger)index
               totolPages:(NSInteger)pages;

- (void)pageViewDidScroll:(BYPageView *)pageView;
- (BOOL)needScrollAnimation;
@end


@interface BYPageView : UIView<UIScrollViewDelegate>
@property (nonatomic,strong)    UIScrollView   *scrollView;
@property (nonatomic,weak)    id<BYPageViewDataSource>  dataSource;
@property (nonatomic,weak)    id<BYPageViewDelegate>    pageViewDelegate;
- (void)scrollToPage: (NSInteger)pages;
- (void)reloadData;
- (UIView *)viewAtIndex: (NSInteger)index;
- (NSInteger)currentPage;


//旋转相关方法,这两个方法必须配对调用,否则会有问题
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration;

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration;
@end

