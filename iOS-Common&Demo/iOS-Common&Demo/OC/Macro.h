//
//  Macro.h
//  BYHttpNetworking_OC
//
//  Created by 侯博野 on 2018/7/1.
//  Copyright © 2018 satelens. All rights reserved.
//

#ifndef Macro_h
#define Macro_h

///------ 应用程序版本号version ------
#define kAppVersion ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"])

///------ iOS系统版本号 ------
#define iOS_Version ([[[UIDevice currentDevice] systemVersion] floatValue])

///------ 区分Debug和Release ------
#ifdef DEBUG //处于开发阶段
/** 测试时用此：配置开发环境下需要在此处配置的东西，比如测试服务器url */

#else //处于发布阶段
/** 正式发布时用此：配置发布环境下需要在此处配置的东西，比如正式服务器url */

#endif

///------ debug下打印，release下不打印 ------
#ifdef DEBUG
//-- 区分设备和模拟器,
//解决Product -> Scheme -> Run -> Arguments -> OS_ACTIVITY_MODE为disable时，真机下 Xcode Debugger 不打印的bug ---
#if TARGET_OS_IPHONE
/*iPhone Device*/
#define DLog(format, ...) printf("%s:Dev: %s [Line %d]\n%s\n\n", [DATE_STRING UTF8String], __PRETTY_FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String])
#else
/*iPhone Simulator*/
#define DLog(format, ...) NSLog((@":Sim: %s [Line %d]\n%@\n\n"), __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:format, ##__VA_ARGS__])
#endif
#else
#define DLog(...)
#endif

///------ Weak-Strong Dance
///省掉多处编写__weak __typeof(self) weakSelf = self; __strong __typeof(weakSelf) strongSelf = weakSelf;代码的麻烦 ------
/**
 使用说明
 Synthsize a weak or strong reference.
 
 Example:
 @weakify(self)
 [self doSomething^{
 @strongify(self)
 if (!self) return;
 ...
 }];
 
 */
#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

///------ 区分ARC和非ARC ------
#if  __has_feature(objc_arc)
//ARC
#else
//非ARC
#endif

///------ 区分设备和模拟器 ------
#if TARGET_OS_IPHONE
//iPhone Device
#endif

#if TARGET_IPHONE_SIMULATOR
//iPhone Simulator
#endif

///当前日期字符串，格式为：YYYY-MM-dd hh:mm:ss
#define DATE_STRING \
({NSDateFormatter *fmt = [[NSDateFormatter alloc] init];\
[fmt setDateFormat:@"YYYY-MM-dd hh:mm:ss"];\
[fmt stringFromDate:[NSDate date]];})

///------ other ------
#define kAppDelegate ([[UIApplication sharedApplication] delegate])
#define kAppWindow (kAppDelegate.window)
#define kAppRootViewController (kAppWindow.rootViewController)

#define UserDefaults ([NSUserDefaults standardUserDefaults])
#define NotificationCenter ([NSNotificationCenter defaultCenter])

///------ 获取当前语言 ------
#define CurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])

///------ 沙盒路径 ------
#define PATH_OF_HOME        NSHomeDirectory()
#define PATH_OF_TEMP        NSTemporaryDirectory()
#define PATH_OF_DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

///------ RGB颜色 ------
#define RGBA(r, g, b, a) ([UIColor colorWithRed:(r)/255. green:(g)/255. blue:(b)/255. alpha:a])
#define RandomColor ([UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1])

#define UIColorFromRGBA(rgbValue, alphaValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:alphaValue]

#define UIColorFromRGB(rgbValue) UIColorFromRGBA(rgbValue, 1.0)

///------ 有效性验证<字符串、数组、字典等> ------
#define VALID_STRING(str)      ((str) && ([(str) isKindOfClass:[NSString class]]) && ([(str) length] > 0))
#define VALID_ARRAY(arr)       ((arr) && ([(arr) isKindOfClass:[NSArray class]]) && ([(arr) count] > 0))
#define VALID_DICTIONARY(dict) ((dict) && ([(dict) isKindOfClass:[NSDictionary class]]) && ([(dict) count] > 0))
#define VALID_NUMBER(number)   ((number) && ([(number) isKindOfClass:NSNumber.class]))

///------ Ratio(Point)基于iPhone6 ------
#define kRatioX_iPhone6 ([UIScreen mainScreen].bounds.size.width / 375.)
#define kRatioY_iPhone6 ([UIScreen mainScreen].bounds.size.height / 667.)

///------ Ratio(Point)基于iPhone5s ------
#define kRatioX_iPhone5 ([UIScreen mainScreen].bounds.size.width / 320)
#define kRatioY_iPhone5 ([UIScreen mainScreen].bounds.size.height / 568)

///------ 尺寸 ------ 注意iphoneX的适配用到了kDevice_Is_iPhoneX
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenRect   [UIScreen mainScreen].bounds
#define kNavigationBarHeight              47.f
#define kStatusBarHeight                  (kDevice_Is_iPhoneX ? 44.f : 20.f)
#define kTabbarSafeBottomMargin           (kDevice_Is_iPhoneX ? 34.f : 0.f)
#define kTabbarHeight                     (kDevice_Is_iPhoneX ? (49.f+34.f) : 49.f)
#define kStatusBarAndNavigationBarHeight  (kDevice_Is_iPhoneX ? 88.f : 64.f)

///------ iOS Device Type ------
#define kDevice_Is_iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define kDevice_Is_iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define kDevice_Is_iPhone6P ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
#define kDevice_Is_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

///------ 子类需实现此方法，否则抛出异常 ------
/*
 * 另一种方式是使用NSAssert
 */
#ifdef DEBUG
#define SuperClassMethodNotImplemented() \
@throw [NSException exceptionWithName:NSInternalInconsistencyException \
reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)] \
userInfo:nil]
#else
#define SuperClassMethodNotImplemented()
#endif

///------ 通知 ------
#define POST_NOTIFY(__NAME, __OBJ, __INFO) [[NSNotificationCenter defaultCenter] postNotificationName:__NAME object:__OBJ userInfo:__INFO];
#define LISTEN_NOTIFY(__NAME, __OBSERVER, __SELECTOR) [[NSNotificationCenter defaultCenter] addObserver:__OBSERVER selector:__SELECTOR name:__NAME object:nil];
#define REMOVE_NOTIFY(__OBSERVER) [[NSNotificationCenter defaultCenter] removeObserver:__OBSERVER];

///------ 主线程 ------
#define dispatch_sync_main_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

#define dispatch_async_main_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

///------ 忽略警告 ------
#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#endif /* Macro_h */
