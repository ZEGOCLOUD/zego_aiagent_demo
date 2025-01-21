//
//  ZegoAIAgentExpressHelper.h
//
//  Created by zego on 2024/3/13.
//  Copyright © 2024 Zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CustomAgentConfig;
typedef void (^AIAgentCommonCallBack)(NSInteger errorCode, NSString* errMsg, NSString* requestId);
@interface ZegoAIAgentExpressHelper: NSObject

+ (instancetype)sharedInstance;
/**
 * 初始化 AI 陪伴服务，基于ExpressSDK,不依赖UIkit,ZimKit
 * 初始化时需要填入用户账号信息，用户需要确保 userID 唯一
 * @param containerVC 容器VC
 * @param appID       app id
 * @param appSign     app sign
 * @param serverSecret  服务key
 * @param userId    用户id
 * @param userName    用户名称
 * @param avatarUrl  用户头像url
**/
-(void)initAIComanion:(UIViewController*)containerVC
            withAppId:(long)appID
          withAppSign:(NSString*)appSign
     withServerSecret:(NSString*)serverSecret
           withUserId:(NSString*)userId
         withUserName:(NSString*)userName
       withUserAvatar:(NSString*)avatarUrl;
/**
 * 反初始化AI陪伴相关设置
**/
-(void)unInitAIComanion;

/**
 * 第一步：查询所有该账号的缺省智能体配置模版，并解释其配置内容保存在本地
 * 对应pass接口：Action：DescribeCustomAgentTemplate,描述：查询可用的智能体模版。https://zegocloud.feishu.cn/wiki/KOLEwLlEni2qDjkmBujczjMcnGc
 * @param complete 返回结果
**/
-(void)queryCustomAgentTemplate:(AIAgentCommonCallBack)complete;

/**
 * 第二步：查询所有该账号拥有的所有会话
 * 对应pass接口：Action：DescribeConversationList,描述：获取会话列表，APP可以用做维护已存在的会话列表或用ZIM SDK。https://zegocloud.feishu.cn/wiki/KOLEwLlEni2qDjkmBujczjMcnGc
 * @param complete 返回结果
**/
-(void)describeConversationList:(AIAgentCommonCallBack)complete;

/**
 * 第三步：创建会话，不依赖IM
 * 对应pass接口：Action：CreateConversation, 描述：创建会话，后续IM与RTC对话时使用。https://zegocloud.feishu.cn/wiki/KOLEwLlEni2qDjkmBujczjMcnGc
 * @param conversationId 会话Id，创建会话步骤得到的
 * @param userId 用户Id
 * @param agentId 智能体Id,以@RBT#开头的字符串
 * @param agentTemplateId 智能体配置模版Id，如果存在则config参数可为空，如果不存在则需要提供config参数
 * @param config 智能体配置模版
 * @param complete 回调，返回结果
**/
-(void)createConversationWithoutIM:(NSString*)conversationId
                        withUserId:(NSString*)userId
                       withAgentId:(NSString*)agentId
                   withAgentTempId:(NSString*)agentTemplateId
                  withCustomConfig:(CustomAgentConfig*)config
                      withCallback:(AIAgentCommonCallBack)complete;

/**
 * 更新会话
 * 对应pass接口：Action：UpdateConversation, 描述：更新会话。https://zegocloud.feishu.cn/wiki/KOLEwLlEni2qDjkmBujczjMcnGc
 * @param conversationId 会话Id，创建会话步骤得到的
 * @param agentTemplateId 智能体配置模版Id，如果存在则config参数可为空，如果不存在则需要提供config参数
 * @param config 智能体配置模版
 * @param complete 回调，返回结果
**/
-(void)updateConversation:(NSString*)conversationId
               withUserId:(NSString*)userId
          withAgentTempId:(NSString*)agentTemplateId
         withCustomConfig:(CustomAgentConfig*)config
             withCallback:(AIAgentCommonCallBack)complete;

/**
 * 第四步：发送开始RTC通话业务协议
 * 对应pass接口：Action：StartRtcChat, 描述：需要进行语音对话时，用于发起一次语音对话。https://zegocloud.feishu.cn/wiki/KOLEwLlEni2qDjkmBujczjMcnGc
 * @param conversationId 会话Id，创建会话步骤得到的
 * @param roomId 房间Id,可以随机字符串
 * @param streamId 本地推流Id，可以随机字符串，但要符合ZegoRTC的流id规范，具体参考官网文档
 * @param agentStreamId 智能体推流Id，可以随机字符串，但要符合ZegoRTC的流id规范，具体参考官网文档
**/
-(void)startRtcChat:(NSString*)conversationId
         withUserId:(NSString*)userId
         withRoomId:(NSString*)roomId
       withStreamId:(NSString*)streamId
  withAgentStreamId:(NSString*)agentStreamId
       withCallback:(AIAgentCommonCallBack)complete;

/**
 * 发送终止RTC通话业务协议
 * 对应pass接口：Action：StopRtcChat, 描述：用于结束已发起的语音对话，释放资源。https://zegocloud.feishu.cn/wiki/KOLEwLlEni2qDjkmBujczjMcnGc
 * @param conversationId 会话Id，创建会话步骤得到的
 * @param complete 回调，返回结果
**/
-(void)stopRtcChat:(NSString*)conversationId
        withUserId:(NSString*)userId
      withCallback:(AIAgentCommonCallBack)complete;
@end
