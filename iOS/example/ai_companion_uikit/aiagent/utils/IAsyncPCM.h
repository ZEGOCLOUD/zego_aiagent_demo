//
//  IAsynPCM.h
//  produce-consumer-machine,不支持函数重入!
//  Created by applechang(常平) on 2022/11/13.
//  Copyright © 2022 Zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSObjCRuntime.h>
#import <Foundation/NSDictionary.h>

typedef void (^pfnConsumer)(id product);
typedef void (^pfnProduceCallback)(id result);
typedef void (^pfnProducer)(pfnProduceCallback callback);

@protocol IAsyncPCM <NSObject>
@required
- (instancetype)initWith:(pfnProducer)producer;
- (void)doComsume:(pfnConsumer)consumer;
- (void)reset;
- (void)done:(id)product;
@end
