//
//  BYPinyinConverter.h
//  Common_iOS
//
//  Created by CardiorayT1 on 2019/1/7.
//  Copyright © 2019 houboye. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BYPinyinConverter : NSObject
+ (BYPinyinConverter *)sharedInstance;

- (NSString *)toPinyin: (NSString *)source;
@end

NS_ASSUME_NONNULL_END
