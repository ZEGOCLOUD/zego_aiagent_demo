//
//  ZGMWAsyncPCM.m
//  produce-consumer-machine,不支持函数重入!
//  Created by applechang(常平) on 2022/11/13.
//  Copyright © 2022 Zego. All rights reserved.
//

#import "ZGMWAsyncPCM.h"

typedef NS_ENUM(NSInteger, AsynPCMState) {
    PCM_STATE_UNINIT = 1, //未初始化状态
    PCM_STATE_INIT,       //初始化状态
    PCM_STATE_DOING,      //异步请求中
    PCM_STATE_END,        //异步请求结束
};

typedef id (^pfnAsynPCM)(pfnProducer producer);
typedef void (^pfnOneVariableFun)(pfnConsumer consumer);

@interface ZGMWAsyncPCM ()
@property (nonatomic, copy) pfnAsynPCM pcm;
@property (nonatomic, copy) pfnOneVariableFun consumerFun;
@property (nonatomic, assign) AsynPCMState state;
@property (nonatomic, retain) id product;
@end

@implementation ZGMWAsyncPCM
- (instancetype)init {
    if (self = [super init]) {
        self.state = PCM_STATE_UNINIT;
        [self creatPCM];
    }

    return self;
}

- (instancetype)initWith:(pfnProducer)producer {
    if ([self init]) {
        self.consumerFun = self.pcm(producer);
    }
    return self;
}

- (void)creatPCM {
    __weak typeof(self) weak_self = self;
    self.pcm = (id) ^ (pfnProducer producer) {
        weak_self.state = PCM_STATE_INIT;
//        __block id product;
        __block NSMutableArray *cachedConsumer = [[NSMutableArray alloc] init];
        return ^(pfnConsumer consumer) {
            if (weak_self.state == PCM_STATE_END) {
                consumer(weak_self.product);
            } else {
                if (consumer) {
                    [cachedConsumer addObject:consumer];
                }

                if (PCM_STATE_DOING != weak_self.state) {
                    weak_self.state = PCM_STATE_DOING;
                    producer(^(id result) {
                        weak_self.product = result;
                        weak_self.state = PCM_STATE_END;
                        if (cachedConsumer) {
                            for (pfnConsumer consumer in cachedConsumer) {
                                consumer(weak_self.product);
                            }
                            [cachedConsumer removeAllObjects];
                        }
                    });
                }
            }
        };
    };
}

- (void)doComsume:(pfnConsumer)consumer {
    if (self.consumerFun) {
        self.consumerFun(consumer);
    }
}

- (void)reset {
    self.state = PCM_STATE_INIT;
}

- (void)done:(id)product{
    if (self.state != PCM_STATE_END) {
        self.state = PCM_STATE_END;
        self.product = product;
    }
}
@end
