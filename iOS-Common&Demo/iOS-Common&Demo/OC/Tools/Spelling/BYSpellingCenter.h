//
//  BYSpellingCenter.h
//  Common_iOS
//
//  Created by CardiorayT1 on 2019/1/7.
//  Copyright © 2019 houboye. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SpellingUnit : NSObject<NSCoding>
@property (nonatomic,strong)    NSString *fullSpelling;
@property (nonatomic,strong)    NSString *shortSpelling;
@end

@interface BYSpellingCenter : NSObject
{
    NSMutableDictionary *_spellingCache;    //全拼，简称cache
    NSString *_filepath;
}
+ (BYSpellingCenter *)sharedCenter;
- (void)saveSpellingCache;          //写入缓存

- (SpellingUnit *)spellingForString: (NSString *)source;    //全拼，简拼 (全是小写)
- (NSString *)firstLetter: (NSString *)input;               //首字母
@end


NS_ASSUME_NONNULL_END
