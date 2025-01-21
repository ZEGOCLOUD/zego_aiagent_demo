//
//  ZegoAiCompanionHttpHelper.h
//
//  Created by zego on 2024/5/13.
//  Copyright © 2024 Zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDataManager.h"
@class AppExtraConfig;

typedef void (^AICompanionCommonCallBack)(NSInteger errorCode, NSString* errMsg, NSString* requestId);
typedef void (^AICompanionExtraConfigCallBack)(int errorCode, NSString* errMsg, AppExtraConfig *config);
typedef void (^AICompanionLoginSvrCallBack)(int errorCode, NSString* errMsg, NSDictionary* configDict);
typedef void (^AICompanionCleanRoomContextCallBack)(int errorCode, NSString* errMsg, NSDictionary* configDict);
typedef void (^AICompanionSetConfigCallBack)(int errorCode, NSString* errMsg);
typedef void (^AICompanionQueryCustomTemplateCallBack)(NSInteger errorCode, NSString* errMsg, NSDictionary* configDict);
typedef void (^AICompanionCreateCustomTemplateCallBack)(NSInteger errorCode, NSString* errMsg, NSDictionary* configDict);
typedef void (^AICompanionQueryConversationCallBack)(NSInteger errorCode, NSString* errMsg, NSString* requestId, NSDictionary* configDict);
typedef void (^AICompanionUploadImageCallBack)(NSInteger errorCode, NSString* errMsg, NSString* requestId, NSDictionary* configDict);
typedef void (^AICompanionOtherCommonCallBack)(NSInteger errorCode, NSString* errMsg);

@interface ZegoAiCompanionHttpHelper : NSObject
+ (instancetype)sharedInstance;

-(void)queryCustomAgentTemplate:(AICompanionQueryCustomTemplateCallBack)complete;
-(void)createCustomAgentTemplate:(CustomAgentConfig*)config
                    withCallback:(AICompanionCreateCustomTemplateCallBack)complete;
-(void)StartRtcChat:(NSString*)conversationId
         withUserId:(NSString*)userId
         withRoomId:(NSString*)roomId
         withStreamId:(NSString*)streamId
    withAgentStreamId:(NSString*)agentStreamId
         withCallback:(AICompanionCommonCallBack)complete;
-(void)StopRtcChat:(NSString*)conversationId
        withUserId:(NSString*)userId
      withCallback:(AICompanionCommonCallBack)complete;

-(void)createConversation:(NSString*)conversationId
               withUserId:(NSString*)userId
              withAgentId:(NSString*)agentId
          withAgentTempId:(NSString*)agentTemplateId
         withCustomConfig:(CustomAgentConfig*)config
             withCallback:(AICompanionCommonCallBack)complete;

-(void)createConversationWithoutIM:(NSString*)conversationId
               withUserId:(NSString*)userId
              withAgentId:(NSString*)agentId
          withAgentTempId:(NSString*)agentTemplateId
         withCustomConfig:(CustomAgentConfig*)config
             withCallback:(AICompanionCommonCallBack)complete;

-(void)updateConversation:(NSString*)conversationId
               withUserId:(NSString*)userId
            withAgentTempId:(NSString*)agentTemplateId
            withCustomConfig:(CustomAgentConfig*)config
             withCallback:(AICompanionCommonCallBack)complete;

-(void)deleteConversation:(NSString*)conversationId
               withUserId:(NSString*)userId
             withCallback:(AICompanionCommonCallBack)complete;

-(void)describeConversationList:(NSString*)userId
                   withCallback:(AICompanionQueryConversationCallBack)complete;

-(void)resetConversationMsg:(NSString*)conversationId
                 withUserId:(NSString*)userId
               withCallback:(AICompanionCommonCallBack)complete;

//创建所有缺省智能体会话
-(void)createAllDefaultConversation:(AICompanionCommonCallBack)complete;

//创建缺省智能体会话
-(void)creatDefaultIMConversation:(NSString*)conversationId
                           userId:(NSString*)userId
                          AgentId:(NSString*)agentId
                  AgentTemplateId:(NSString*)agentTemplateId
                     withCallback:(AICompanionCommonCallBack)complete;
//创建缺省智能体会话,即告诉后台不依赖IM
-(void)creatDefaultConversationWithoutIM:(NSString*)conversationId
                                  userId:(NSString*)userId
                                 AgentId:(NSString*)agentId
                         AgentTemplateId:(NSString*)agentTemplateId
                            withCallback:(AICompanionCommonCallBack)complete;

-(void)uploadAvatarHeaderImage:(NSString*)userId
                withLoacalPath:(NSString*)localPath
withCallback:(AICompanionUploadImageCallBack)complete;

//demo相关
- (void)POSTImage:(NSString *)URLString
                       path:(NSString*)path
                       data:(NSData *)imageData
                       name:(NSString*)name
              withOtherData:(NSDictionary*)keyValues
               withCallback:(AICompanionOtherCommonCallBack)complete;
@end
