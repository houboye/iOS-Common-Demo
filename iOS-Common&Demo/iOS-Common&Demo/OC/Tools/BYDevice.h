//
//  BYDevice.h
//  Common_iOS
//
//  Created by CardiorayT1 on 2019/1/7.
//  Copyright © 2019 houboye. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger,BYNetworkType) {
    BYNetworkTypeUnknown,
    BYNetworkTypeWifi,
    BYNetworkTypeWwan,
    BYNetworkType2G,
    BYNetworkType3G,
    BYNetworkType4G,
};

@interface BYDevice : NSObject

+ (BYDevice *)currentDevice;

//图片/音频推荐参数
- (CGFloat)suggestImagePixels;

- (CGFloat)compressQuality;

//App状态
- (BOOL)isUsingWifi;
- (BOOL)isInBackground;

- (BYNetworkType)currentNetworkType;
- (NSString *)networkStatus:(BYNetworkType)networkType;

- (NSInteger)cpuCount;

- (BOOL)isLowDevice;
- (BOOL)isIphone;
- (NSString *)machineName;


- (CGFloat)statusBarHeight;

@end

NS_ASSUME_NONNULL_END
