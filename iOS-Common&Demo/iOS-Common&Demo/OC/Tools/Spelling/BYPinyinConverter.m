//
//  BYPinyinConverter.m
//  Common_iOS
//
//  Created by CardiorayT1 on 2019/1/7.
//  Copyright © 2019 houboye. All rights reserved.
//

#import "BYPinyinConverter.h"

@implementation BYPinyinConverter
+ (BYPinyinConverter *)sharedInstance
{
    static BYPinyinConverter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BYPinyinConverter alloc] init];
    });
    return instance;
}


- (NSString *)toPinyin: (NSString *)source
{
    if ([source length] == 0)
    {
        return nil;
    }
    NSMutableString *piyin = [NSMutableString stringWithString:source];
    CFStringTransform((__bridge CFMutableStringRef)piyin, NULL, kCFStringTransformToLatin, false);
    
    NSString *py = [piyin stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    return [py stringByReplacingOccurrencesOfString:@"'" withString:@""];
}



@end

