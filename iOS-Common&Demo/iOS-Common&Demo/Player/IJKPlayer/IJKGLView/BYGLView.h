//
//  BYGLView.h
//  Common_iOS
//
//  Created by CardiorayT1 on 2019/1/8.
//  Copyright © 2019 houboye. All rights reserved.
//

#import "IJKSDLGLView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BYGLView : BYIJKSDLGLView

- (void) render: (NSData *)yuvData
          width:(NSUInteger)width
         height:(NSUInteger)height;

@end

NS_ASSUME_NONNULL_END
