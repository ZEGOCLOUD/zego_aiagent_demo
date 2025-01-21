//
//  ZegoAICompanionCallVCWithExpress.h
//  基于ZegoExpressEngine而非ZegoUIKit
//  Created by zego on 2024/5/13.
//  Copyright © 2024 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZegoCallVCNameUIComponent.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ChatSessionState) {
    ChatSessionState_UNINIT = 0, //未初始化状态
    ChatSessionState_AI_SPEAKING,//AI在讲话
    ChatSessionState_AI_THINKING,//AI在想，LLM大模型推理
    ChatSessionState_AI_LISTEN,  //AI在听
};

@interface ZegoAICompanionCallVCWithExpress : UIViewController
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *streamID;
@property (nonatomic, strong) NSString *agentStreamID;
@property (nonatomic, assign) ChatSessionState chatSessionState;
@property (nonatomic, strong) ZegoCallVCNameUIComponent *callVCNameStatusCom;

//暴露出方法给子类重载
-(void)onLeaveButtonClicked:(UIButton *)sender;
-(void)initZegoExpressEngine;
-(void)setPlayVolumeInternal:(int)volume;
@end

NS_ASSUME_NONNULL_END
