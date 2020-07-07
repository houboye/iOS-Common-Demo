//
//  BYRootTabBarController.m
//  Common_iOS
//
//  Created by CardiorayT1 on 2019/1/4.
//  Copyright © 2019 houboye. All rights reserved.
//

#import "BYRootTabBarController.h"
#import "BYFirstViewController.h"
#import "BYSecondViewController.h"
#import "BYThirdViewController.h"
#import "BYFourthViewController.h"
#import "Macro.h"
#import "iOS_Common_Demo-Swift.h"

typedef enum : NSUInteger {
    BYTabBarTypeFirst = 0,
    BYTabBarTypeSecond = 1,
    BYTabBarTypeThird = 2,
    BYTabBarTypeFourth = 3,
} BYTabBarType;

static const NSString *TabbarVC = @"vc";
static const NSString *TabbarTitle = @"title";
static const NSString *TabbarImage = @"image";
static const NSString *TabbarSelectedImage = @"selectedImage";
static const NSString *TabbarItemBadgeValue = @"badgeValue";
static const NSInteger TabBarCount = 4;

@interface BYRootTabBarController ()

@property (nonatomic, strong) NSMutableArray *navigationHandlers;

@end

@implementation BYRootTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubNavitationController];
}

- (void)setupSubNavitationController {
    self.navigationHandlers = [NSMutableArray array];
    
    @weakify(self)
    [[self tabbars] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self)
        if (!self) return;
        BYTabBarType type = ((NSNumber *)obj).integerValue;
        NSDictionary *item = [self vcInfoWithType:type];
        Class vcClass = NSClassFromString(item[TabbarVC]);
        NSString *title = item[TabbarTitle];
        NSString *image = item[TabbarImage];
        NSString *selectedImage = item[TabbarSelectedImage];
        
        UIViewController *vc = [[vcClass alloc] init];
        UINavigationController *nc = [self setupChildViewController:vc title:title image:image selectedImage:selectedImage];
        NavigationHandler *ncHandler = [[NavigationHandler alloc] initWithNavigationController:nc];
        nc.delegate = ncHandler;
        
        [self.navigationHandlers addObject:ncHandler];
    }];
}

- (UINavigationController *)setupChildViewController:(UIViewController *)viewContoller title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage {
    viewContoller.title = title;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:viewContoller];
    
    UIImage *bgImage = [UIImage imageNamed:image];
    bgImage = [bgImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *bgSelectedImage = [UIImage imageNamed:selectedImage];
    bgSelectedImage = [bgSelectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    nc.tabBarItem.image = bgImage;
    nc.tabBarItem.selectedImage = bgSelectedImage;
    nc.tabBarItem.title = title;
    
    [self addChildViewController:nc];
    
    return nc;
}

- (NSArray *)tabbars {
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < TabBarCount; i++) {
        [array addObject:@(i)];
    }
    return array;
}

- (NSDictionary *)vcInfoWithType:(BYTabBarType)type {
    NSDictionary *config = @{@(BYTabBarTypeFirst): @{TabbarVC: NSStringFromClass([BYFirstViewController class]),
                                                  TabbarTitle: @"OC-1",
                                                  TabbarImage: @"B1",
                                                  TabbarSelectedImage: @"A1"},
                          @(BYTabBarTypeSecond): @{TabbarVC: NSStringFromClass([BYSecondViewController class]),
                                                   TabbarTitle: @"OC-2",
                                                   TabbarImage: @"B2",
                                                   TabbarSelectedImage: @"A2"},
                          @(BYTabBarTypeThird): @{TabbarVC: NSStringFromClass([BYThirdViewController class]),
                                                  TabbarTitle: @"OC-3",
                                                  TabbarImage: @"B3",
                                                  TabbarSelectedImage: @"A3"},
                          @(BYTabBarTypeFourth): @{TabbarVC: NSStringFromClass([BYFourthViewController class]),
                                                   TabbarTitle: @"OC-4",
                                                   TabbarImage: @"B4",
                                                   TabbarSelectedImage: @"A4"}
                          };
    return config[@(type)];
}

@end
