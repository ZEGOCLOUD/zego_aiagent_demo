//
//  AVAudioSession+Switch.m
//  ZegoLiveWithRongCloud
//
//  Created by Sky on 2019/9/20.
//  Copyright © 2019 zego. All rights reserved.
//

#import "AVAudioSession+Switch.h"
#import <objc/runtime.h>
#import "AIAgentLogUtil.h"
@implementation AVAudioSession (Switch)

+ (void)load {
    BOOL res = [self swizzleMethod:AVAudioSession.class orgSel:@selector(setCategory:error:) swizzSel:@selector(zg_setCategory:error:)];
    res = [self swizzleMethod:AVAudioSession.class orgSel:@selector(setCategory:withOptions:error:) swizzSel:@selector(zg_setCategory:withOptions:error:)];
    res = [self swizzleMethod:AVAudioSession.class orgSel:@selector(setCategory:mode:options:error:) swizzSel:@selector(zg_setCategory:mode:options:error:)];
    res = [self swizzleMethod:AVAudioSession.class orgSel:@selector(setMode:error:) swizzSel:@selector(zg_setMode:error:)];
    res = [self swizzleMethod:AVAudioSession.class orgSel:@selector(setActive:error:) swizzSel:@selector(zg_setActive:error:)];
    res = [self swizzleMethod:AVAudioSession.class orgSel:@selector(setActive:withOptions:error:) swizzSel:@selector(zg_setActive:withOptions:error:)];
    res = [self swizzleMethod:AVAudioSession.class orgSel:@selector(activateWithOptions:completionHandler:) swizzSel:@selector(zg_activateWithOptions:completionHandler:)];
    res = [self swizzleMethod:AVAudioSession.class orgSel:@selector(overrideOutputAudioPort:error:) swizzSel:@selector(zg_overrideOutputAudioPort:error:)];
    res = [self swizzleMethod:AVAudioSession.class orgSel:@selector(setPreferredSampleRate:error:) swizzSel:@selector(zg_setPreferredSampleRate:error:)];
    res = [self swizzleMethod:AVAudioSession.class orgSel:@selector(setPreferredIOBufferDuration:error:) swizzSel:@selector(zg_setPreferredIOBufferDuration:error:)];
    res = [self swizzleMethod:AVAudioSession.class orgSel:@selector(setPreferredInputNumberOfChannels:error:) swizzSel:@selector(zg_setPreferredInputNumberOfChannels:error:)];
    res = [self swizzleMethod:AVAudioSession.class orgSel:@selector(setPreferredOutputNumberOfChannels:error:) swizzSel:@selector(zg_setPreferredOutputNumberOfChannels:error:)];
    NSLog(@"交换方法:%d",res);
}

+ (BOOL)swizzleMethod:(Class)class orgSel:(SEL)origSel swizzSel:(SEL)altSel {
    Method origMethod = class_getInstanceMethod(class, origSel);
    Method altMethod = class_getInstanceMethod(class, altSel);
    if (!origMethod || !altMethod) {
        return NO;
    }
    BOOL didAddMethod = class_addMethod(class,origSel,
                                        method_getImplementation(altMethod),
                                        method_getTypeEncoding(altMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,altSel,
                            method_getImplementation(origMethod),
                            method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, altMethod);
    }
    
    return YES;
}

- (BOOL)zg_setCategory:(AVAudioSessionCategory)category error:(NSError * _Nullable __autoreleasing *)outError {
    ZAALogLocal(@"AVAudioSession",@"调用:setCategory:%@,error:", category);
    ZAALogLocal(@"AVAudioSession",@"%@",[NSThread callStackSymbols]);
    ZAALogLocal(@"AVAudioSession",@"[current] current category: %@ mode:%@ options:%d", [AVAudioSession sharedInstance].category, [AVAudioSession sharedInstance].mode, (int)[AVAudioSession sharedInstance].categoryOptions);

    return [self zg_setCategory:category error:outError];
}

- (BOOL)zg_setCategory:(AVAudioSessionCategory)category withOptions:(AVAudioSessionCategoryOptions)options error:(NSError *__autoreleasing  _Nullable *)outError {
    ZAALogLocal(@"AVAudioSession",@"调用:setCategory:%@,withOptions:%d, error:", category, (int)options);
    ZAALogLocal(@"AVAudioSession",@"%@",[NSThread callStackSymbols]);
    ZAALogLocal(@"AVAudioSession",@"[current] current category: %@ mode:%@ options:%d", [AVAudioSession sharedInstance].category, [AVAudioSession sharedInstance].mode, (int)[AVAudioSession sharedInstance].categoryOptions);
    return [self zg_setCategory:category withOptions:options error:outError];
}

- (BOOL)zg_setCategory:(AVAudioSessionCategory)category mode:(AVAudioSessionMode)mode options:(AVAudioSessionCategoryOptions)options error:(NSError *__autoreleasing  _Nullable *)outError {
    ZAALogLocal(@"AVAudioSession",@"调用:setCategory:%@,mode:%@,options:%d,error:", category, mode, (int)options);
    ZAALogLocal(@"AVAudioSession",@"%@",[NSThread callStackSymbols]);
    ZAALogLocal(@"AVAudioSession",@"[current] current category: %@ mode:%@ options:%d", [AVAudioSession sharedInstance].category, [AVAudioSession sharedInstance].mode, (int)[AVAudioSession sharedInstance].categoryOptions);
    return [self zg_setCategory:category mode:mode options:options error:outError];
}

- (BOOL)zg_setMode:(AVAudioSessionMode)mode error:(NSError *__autoreleasing  _Nullable *)outError {
    ZAALogLocal(@"AVAudioSession",@"调用:setMode:%@,error:", mode);
    ZAALogLocal(@"AVAudioSession",@"%@",[NSThread callStackSymbols]);
    ZAALogLocal(@"AVAudioSession",@"[current] current category: %@ mode:%@ options:%d", [AVAudioSession sharedInstance].category, [AVAudioSession sharedInstance].mode, (int)[AVAudioSession sharedInstance].categoryOptions);
    return [self zg_setMode:mode error:outError];
}

- (BOOL)zg_setActive:(BOOL)active error:(NSError *__autoreleasing  _Nullable *)outError {
    ZAALogLocal(@"AVAudioSession",@"调用:setActive:%@,error:", active?@"YES":@"NO");
    ZAALogLocal(@"AVAudioSession",@"%@",[NSThread callStackSymbols]);
    ZAALogLocal(@"AVAudioSession",@"[current] current category: %@ mode:%@ options:%d", [AVAudioSession sharedInstance].category, [AVAudioSession sharedInstance].mode, (int)[AVAudioSession sharedInstance].categoryOptions);
    return [self zg_setActive:active error:outError];
}

- (BOOL)zg_setActive:(BOOL)active withOptions:(AVAudioSessionSetActiveOptions)options error:(NSError *__autoreleasing  _Nullable *)outError {
    ZAALogLocal(@"AVAudioSession",@"调用:setActive:%d,withOptions:%d,error:", active?@"YES":@"NO", (int)options);
    ZAALogLocal(@"AVAudioSession",@"%@",[NSThread callStackSymbols]);
    ZAALogLocal(@"AVAudioSession",@"[current] current category: %@ mode:%@ options:%d", [AVAudioSession sharedInstance].category, [AVAudioSession sharedInstance].mode, (int)[AVAudioSession sharedInstance].categoryOptions);

    return [self zg_setActive:active withOptions:options error:outError];
}

- (void)zg_activateWithOptions:(AVAudioSessionActivationOptions)options completionHandler:(void (^)(BOOL activated, NSError * _Nullable error))handler {
    ZAALogLocal(@"AVAudioSession",@"调用:activateWithOptions:%@,completionHandler:", [NSString stringWithFormat:@"%d",(int)options]);
    ZAALogLocal(@"AVAudioSession",@"%@",[NSThread callStackSymbols]);
    ZAALogLocal(@"AVAudioSession",@"[current] current category: %@ mode:%@ options:%d", [AVAudioSession sharedInstance].category, [AVAudioSession sharedInstance].mode, (int)[AVAudioSession sharedInstance].categoryOptions);

    [self zg_activateWithOptions:options completionHandler:handler];
}

- (BOOL)zg_overrideOutputAudioPort:(AVAudioSessionPortOverride)portOverride error:(NSError **)outError {
    ZAALogLocal(@"AVAudioSession",@"调用:overrideOutputAudioPort:%@,error:", [NSString stringWithFormat:@"%d",(int)portOverride]);
    ZAALogLocal(@"AVAudioSession",@"%@",[NSThread callStackSymbols]);
    ZAALogLocal(@"AVAudioSession",@"[current] current category: %@ mode:%@ options:%d", [AVAudioSession sharedInstance].category, [AVAudioSession sharedInstance].mode, (int)[AVAudioSession sharedInstance].categoryOptions);

    return [self zg_overrideOutputAudioPort:portOverride error:outError];
}

- (BOOL)zg_setPreferredSampleRate:(double)sampleRate error:(NSError **)outError {
    ZAALogLocal(@"AVAudioSession",@"调用:setPreferredSampleRate:%@,error:", [NSString stringWithFormat:@"%f",sampleRate]);
    ZAALogLocal(@"AVAudioSession",@"%@",[NSThread callStackSymbols]);
    ZAALogLocal(@"AVAudioSession",@"[current] current category: %@ mode:%@ options:%d", [AVAudioSession sharedInstance].category, [AVAudioSession sharedInstance].mode, (int)[AVAudioSession sharedInstance].categoryOptions);

    return [self zg_setPreferredSampleRate:sampleRate error:outError];
}

- (BOOL)zg_setPreferredIOBufferDuration:(NSTimeInterval)duration error:(NSError **)outError {
    ZAALogLocal(@"AVAudioSession",@"调用:setPreferredIOBufferDuration:%@,error:", [NSString stringWithFormat:@"%f",duration]);
    ZAALogLocal(@"AVAudioSession",@"%@",[NSThread callStackSymbols]);
    ZAALogLocal(@"AVAudioSession",@"[current] current category: %@ mode:%@ options:%d", [AVAudioSession sharedInstance].category, [AVAudioSession sharedInstance].mode, (int)[AVAudioSession sharedInstance].categoryOptions);

    return [self zg_setPreferredIOBufferDuration:duration error:outError];
}

- (BOOL)zg_setPreferredInputNumberOfChannels:(NSInteger)count error:(NSError **)outError {
    ZAALogLocal(@"AVAudioSession",@"调用:setPreferredInputNumberOfChannels:%@,error:", [NSString stringWithFormat:@"%ld",(long)count]);
    ZAALogLocal(@"AVAudioSession",@"%@",[NSThread callStackSymbols]);
    ZAALogLocal(@"AVAudioSession",@"[current] current category: %@ mode:%@ options:%d", [AVAudioSession sharedInstance].category, [AVAudioSession sharedInstance].mode, (int)[AVAudioSession sharedInstance].categoryOptions);

    return [self zg_setPreferredInputNumberOfChannels:count error:outError];
}

- (BOOL)zg_setPreferredOutputNumberOfChannels:(NSInteger)count error:(NSError **)outError {
    ZAALogLocal(@"AVAudioSession",@"调用:setPreferredOutputNumberOfChannels:%@,error:", [NSString stringWithFormat:@"%ld",(long)count]);
    ZAALogLocal(@"AVAudioSession",@"%@",[NSThread callStackSymbols]);
    ZAALogLocal(@"AVAudioSession",@"[current] current category: %@ mode:%@ options:%d", [AVAudioSession sharedInstance].category, [AVAudioSession sharedInstance].mode, (int)[AVAudioSession sharedInstance].categoryOptions);

    return [self zg_setPreferredOutputNumberOfChannels:count error:outError];
}

@end
