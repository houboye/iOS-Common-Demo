//
//  BYDevice.m
//  Common_iOS
//
//  Created by CardiorayT1 on 2019/1/7.
//  Copyright © 2019 houboye. All rights reserved.
//

#import "BYDevice.h"
#import "Reachability.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <sys/sysctl.h>
#import <sys/utsname.h>

#define NormalImageSize       (1280 * 960)

@interface BYDevice ()

@property (nonatomic,copy)      NSDictionary    *networkTypes;

@end

@implementation BYDevice

- (instancetype)init
{
    if (self = [super init])
    {
        [self buildDeviceInfo];
    }
    return self;
}


+ (BYDevice *)currentDevice{
    static BYDevice *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BYDevice alloc] init];
    });
    return instance;
}

- (void)buildDeviceInfo
{
    _networkTypes = @{
                      CTRadioAccessTechnologyGPRS:@(BYNetworkType2G),
                      CTRadioAccessTechnologyEdge:@(BYNetworkType2G),
                      CTRadioAccessTechnologyWCDMA:@(BYNetworkType3G),
                      CTRadioAccessTechnologyHSDPA:@(BYNetworkType3G),
                      CTRadioAccessTechnologyHSUPA:@(BYNetworkType3G),
                      CTRadioAccessTechnologyCDMA1x:@(BYNetworkType3G),
                      CTRadioAccessTechnologyCDMAEVDORev0:@(BYNetworkType3G),
                      CTRadioAccessTechnologyCDMAEVDORevA:@(BYNetworkType3G),
                      CTRadioAccessTechnologyCDMAEVDORevB:@(BYNetworkType3G),
                      CTRadioAccessTechnologyeHRPD:@(BYNetworkType3G),
                      CTRadioAccessTechnologyLTE:@(BYNetworkType4G),
                      };
    
}


//图片/音频推荐参数
- (CGFloat)suggestImagePixels{
    return NormalImageSize;
}

- (CGFloat)compressQuality{
    return 0.5;
}


//App状态
- (BOOL)isUsingWifi{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus status =  [reachability currentReachabilityStatus];
    return status == ReachableViaWiFi;
}

- (BOOL)isInBackground{
    return [[UIApplication sharedApplication] applicationState] != UIApplicationStateActive;
}

- (BYNetworkType)currentNetworkType{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus status =  [reachability currentReachabilityStatus];
    switch (status) {
        case ReachableViaWiFi:
            return BYNetworkTypeWifi;
        case ReachableViaWWAN:
        {
            CTTelephonyNetworkInfo *telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
            NSNumber *number = [_networkTypes objectForKey:telephonyInfo.serviceCurrentRadioAccessTechnology];
            return number ? (BYNetworkType)[number integerValue] : BYNetworkTypeWwan;
        }
        default:
            return BYNetworkTypeUnknown;
    }
}


- (NSString *)networkStatus:(BYNetworkType)networkType
{
    switch (networkType) {
        case BYNetworkType2G:
            return @"2G";
        case BYNetworkType3G:
            return @"3G";
        case BYNetworkType4G:
            return @"4G";
        default:
            return @"WIFI";
    }
}

- (NSInteger)cpuCount{
    size_t size = sizeof(int);
    int results;
    
    int mib[2] = {CTL_HW, HW_NCPU};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger) results;
}

- (BOOL)isLowDevice{
#if TARGET_IPHONE_SIMULATOR
    return NO;
#else
    return [[NSProcessInfo processInfo] processorCount] <= 1;
#endif
}

- (BOOL)isIphone{
    NSString *deviceModel = [UIDevice currentDevice].model;
    if ([deviceModel isEqualToString:@"iPhone"]) {
        return YES;
    }else {
        return NO;
    }
}

- (NSString *)machineName{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}


- (CGFloat)statusBarHeight{
    CGFloat height = [UIApplication sharedApplication].statusBarFrame.size.height;
    return height;
}

@end
