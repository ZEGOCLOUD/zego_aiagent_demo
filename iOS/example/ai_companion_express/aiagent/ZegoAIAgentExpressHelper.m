//
//  ZegoAIAgentExpressHelper.m
//
//  Created by zego on 2024/3/13.
//  Copyright © 2024 Zego. All rights reserved.
//
#import "ZegoAIAgentExpressHelper.h"
#import "ZegoAIComponionExpressMainView.h"
#import "AppDataManager.h"
#import "ZegoAiCompanionUtil.h"
#import "ZegoAiCompanionHttpHelper.h"

@interface ZegoAIAgentExpressHelper ()
@end
static ZegoAIAgentExpressHelper *_sharedInstance;
@implementation ZegoAIAgentExpressHelper
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

-(void)initAIComanion:(UIViewController*)containerVC
            withAppId:(long)appID
          withAppSign:(NSString*)appSign
     withServerSecret:(NSString*)serverSecret
           withUserId:(NSString*)userId
         withUserName:(NSString*)userName
       withUserAvatar:(NSString*)avatarUrl{
    

    [[AppDataManager sharedInstance] setConfigInfo:appID
                                       withAppSign:appSign
                                  withServerSecret:serverSecret
                                        withUserId:userId
                                      withUsername:userName
                                     withAvatarUrl:avatarUrl];

    ZegoAIComponionExpressMainView* mainView = [[ZegoAIComponionExpressMainView alloc]initWithFrame:containerVC.view.bounds];
    [containerVC.view addSubview:mainView];
}

-(void)unInitAIComanion{    
}

-(void)queryCustomAgentTemplate:(AIAgentCommonCallBack)complete{
    [[ZegoAiCompanionHttpHelper sharedInstance] queryCustomAgentTemplate:^(NSInteger errorCode, NSString *errMsg, NSDictionary *configDict) {
        NSArray* AgentConfigList = configDict[@"CustomAgentConfigList"];
        AppExtraConfig* appExtraConfig = [[AppExtraConfig alloc]init];
        appExtraConfig.customAgentList = [[NSMutableArray alloc]initWithCapacity:AgentConfigList.count];
        for (int i=0; i<AgentConfigList.count; i++) {
            NSDictionary* item = [AgentConfigList objectAtIndex:i];
            CustomAgentConfig* agentConfig = [[CustomAgentConfig alloc]init];
            agentConfig.AgentTemplateId = item[@"AgentTemplateId"];
            agentConfig.Name = item[@"Name"];
            agentConfig.Avatar = item[@"Avatar"];
            agentConfig.Intro = item[@"Intro"];
            agentConfig.System = item[@"System"];
            agentConfig.Source = item[@"Source"];
            agentConfig.Sex = item[@"Sex"];
            agentConfig.WelcomeMessage = item[@"WelcomeMessage"];
            
            NSDictionary* LLM = item[@"LLM"];
            agentConfig.llm = [[RawProperties alloc]init];
            agentConfig.llm.Model = LLM[@"Model"];
            agentConfig.llm.Type = LLM[@"Type"];
            
            NSDictionary* TTS = item[@"TTS"];
            agentConfig.tts = [[RawProperties alloc]init];
            agentConfig.tts.Voice = TTS[@"Voice"];
            agentConfig.tts.Type = TTS[@"Type"];
            [appExtraConfig.customAgentList addObject:agentConfig];
        }
        
        [AppDataManager sharedInstance].appExtraConfig = appExtraConfig;
        [[AppDataManager sharedInstance] loadLocalAppExtraConfig];
    }];
}

-(void)extractConversationList:(NSArray*)curConversionList{
    NSString* userId = [AppDataManager sharedInstance].userID;
    for (int i=0; i<curConversionList.count; i++) {
        ConversionConfigInfo* conversationInfo = [[ConversionConfigInfo alloc] init];
        NSDictionary* item = [curConversionList objectAtIndex:i];
        
        NSString* conversionId =item[@"ConversationId"];
        conversationInfo.conversationId = conversionId;
        
        NSString* agentId =item[@"AgentId"];
        conversationInfo.agentId = agentId;
        
        NSString* agentTemplateId =item[@"AgentTemplateId"];
        conversationInfo.agentTemplatedId = agentTemplateId;
        conversationInfo.userId = userId;
        conversationInfo.isChatting = YES;
        CustomAgentConfig* defaultAgentConfig = [[AppDataManager sharedInstance].appExtraConfig getCustomAgentConfigById:agentTemplateId];
        if ([defaultAgentConfig.AgentTemplateId isEqualToString:agentTemplateId]) {
            conversationInfo.isDefAgenttemplated = YES;
            conversationInfo.customAgentConfig = defaultAgentConfig;
        }else{
            //对自定义智能体
            conversationInfo.isDefAgenttemplated = NO;
            CustomAgentConfig* agentConfig = [[CustomAgentConfig alloc] init];
            NSDictionary* customAgentConfigDict =item[@"CustomAgentConfig"];
            agentConfig.Name = customAgentConfigDict[@"Name"];
            agentConfig.AgentTemplateId = nil;
            agentConfig.Avatar = customAgentConfigDict[@"Avatar"];
            agentConfig.Intro = customAgentConfigDict[@"Intro"];
            agentConfig.System = customAgentConfigDict[@"System"];
            agentConfig.Sex = customAgentConfigDict[@"Sex"];
            
            agentConfig.llm = [[RawProperties alloc] init];
            NSDictionary* LLMDict = customAgentConfigDict[@"LLM"];
//                        agentConfig.llm.AccountSource = LLMDict[@"AccountSource"];
            agentConfig.llm.Type = LLMDict[@"Type"];
            agentConfig.llm.Model = LLMDict[@"Model"];
            
            NSDictionary* TTSDict = customAgentConfigDict[@"TTS"];
            agentConfig.tts = [[RawProperties alloc] init];
//                        agentConfig.tts.AccountSource = TTSDict[@"AccountSource"];
            agentConfig.tts.Type = TTSDict[@"Type"];
            agentConfig.tts.Voice = TTSDict[@"Voice"];
            conversationInfo.customAgentConfig = agentConfig;
        }
        
        [[AppDataManager sharedInstance].conversationList addObject:conversationInfo];
    }
}

-(void)describeConversationList:(AIAgentCommonCallBack)complete{
    NSString* userId = [AppDataManager sharedInstance].userID;
    __weak typeof(self) weakSelf = self;
    [[ZegoAiCompanionHttpHelper sharedInstance] describeConversationList:userId
                                                            withCallback:^(NSInteger errorCode,
                                                                           NSString *errMsg,
                                                                           NSString* requestID,
                                                                           NSDictionary *configDict) {
        if (errorCode != 0) {
            NSLog(@"describeConversationList fail, need create new Conversation");
        }else{
            NSNumber* totalCount = configDict[@"Total"];
            int nTotalCount = [totalCount intValue];
            if (nTotalCount ==0) {
                //创建所有会话
            }else{
                NSArray* curConversionList = configDict[@"ConversationList"];
                [weakSelf extractConversationList:curConversionList];
            }
        }
        
        complete(errorCode, errMsg, requestID);
    }];
}

-(void)creatConversationWith:(CustomAgentConfig*)config
            convesersationId:(NSString*)convesersationId
                     agentId:(NSString*)agentId
                withCallback:(AIAgentCommonCallBack)complete{
    NSString* userId = [AppDataManager sharedInstance].userID;
    [[ZegoAiCompanionHttpHelper sharedInstance] creatDefaultConversationWithoutIM:convesersationId
                                                                           userId:userId
                                                                          AgentId:agentId
                                                                  AgentTemplateId:config.AgentTemplateId
                                                                     withCallback:^(NSInteger errorCode, NSString *errMsg, NSString *requestId) {
        complete(errorCode, errMsg, requestId);
    }];
}

-(void)createConversationWithoutIM:(NSString*)conversationId
                        withUserId:(NSString*)userId
                       withAgentId:(NSString*)agentId
                   withAgentTempId:(NSString*)agentTemplateId
                  withCustomConfig:(CustomAgentConfig*)config
                      withCallback:(AIAgentCommonCallBack)complete{
    [[ZegoAiCompanionHttpHelper sharedInstance] createConversationWithoutIM:conversationId 
                                                                 withUserId:userId
                                                                withAgentId:agentId
                                                            withAgentTempId:agentTemplateId
                                                           withCustomConfig:config
                                                               withCallback:^(NSInteger errorCode, NSString *errMsg, NSString *requestId) {
        complete(errorCode,errMsg,requestId);
    }];
}

-(void)updateConversation:(NSString*)conversationId
               withUserId:(NSString*)userId
          withAgentTempId:(NSString*)agentTemplateId
         withCustomConfig:(CustomAgentConfig*)config
             withCallback:(AIAgentCommonCallBack)complete{
    [[ZegoAiCompanionHttpHelper sharedInstance] updateConversation:conversationId
                                                        withUserId:userId
                                                   withAgentTempId:agentTemplateId
                                                  withCustomConfig:config
                                                      withCallback:^(NSInteger errorCode, NSString *errMsg, NSString *requestId) {
        complete(errorCode, errMsg, requestId);
    }];
}

-(void)startRtcChat:(NSString*)conversationId
         withUserId:(NSString*)userId
         withRoomId:(NSString*)roomId
       withStreamId:(NSString*)streamId
  withAgentStreamId:(NSString*)agentStreamId
       withCallback:(AIAgentCommonCallBack)complete{
    
    [[ZegoAiCompanionHttpHelper sharedInstance] StartRtcChat:conversationId
                                                  withUserId:userId
                                                  withRoomId:roomId
                                                withStreamId:streamId
                                           withAgentStreamId:agentStreamId
                                                withCallback:^(NSInteger errorCode, NSString *errMsg, NSString* requestId){
        complete(errorCode, errMsg, requestId);
    }];
}

-(void)stopRtcChat:(NSString*)conversationId
        withUserId:(NSString*)userId
      withCallback:(AIAgentCommonCallBack)complete{
    [[ZegoAiCompanionHttpHelper sharedInstance] StopRtcChat:conversationId
                                                 withUserId:(NSString*)userId
                                               withCallback:^(NSInteger errorCode, NSString *errMsg, NSString *requestId) {
        complete(errorCode, errMsg, requestId);
    }];
}
@end
