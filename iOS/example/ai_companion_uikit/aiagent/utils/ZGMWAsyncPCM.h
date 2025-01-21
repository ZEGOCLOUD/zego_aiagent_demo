//
//  ZGMWAsyncPCM.h
//  produce-consumer-machine,不支持函数重入!
//  Created by applechang(常平) on 2022/11/13.
//  Copyright © 2022 Zego. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "IAsyncPCM.h"

@interface ZGMWAsyncPCM : NSObject <IAsyncPCM>
@end
