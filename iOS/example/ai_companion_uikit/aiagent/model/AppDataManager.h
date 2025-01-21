//
//  AppDataManager.h
//  ai_companion_oc
//
//  Created by zego on 2024/8/28.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class ZegoAiCompanionHttpHelper;

@protocol ConfigDataObserver <NSObject>
- (void)onAppExtraConfigChanged:(NSString *)type newData:(NSString *)newData oldData:(NSString *)oldData;
@end
@interface RawProperties : NSObject
@property (nonatomic, strong) NSString* Model;
@property (nonatomic, strong) NSString* Voice;
@property (nonatomic, strong) NSString* Type;
//@property (nonatomic, strong) NSString* AccountSource;
-(BOOL)isLLMEqualToOther:(RawProperties*)other;
-(BOOL)isTTSEqualToOther:(RawProperties*)other;
@end

@interface LLMConfig : NSObject
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, assign) BOOL isSupported;
@property (nonatomic, strong) RawProperties* rawProperties;
@end

@interface LanguageConfig : NSObject
@property (nonatomic, strong) NSString *langId;
@property (nonatomic, strong) NSString *name;
@end

@interface VoiceConfig : NSObject
@property (nonatomic, strong) NSString *voiceId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray<LanguageConfig *> *language;
- (LanguageConfig*)getLangConfigById:(NSString*)langId;
@end


@interface TTSConfig : NSObject
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, assign) BOOL isSupported;
@property (nonatomic, strong) NSMutableArray<VoiceConfig *> *voiceList;
@property (nonatomic, strong) RawProperties* rawProperties;
- (VoiceConfig*)getVoiceConfigById:(NSString*)voiceId;
@end

@interface CustomAgentConfig : NSObject
@property (nonatomic, strong) NSString* AgentTemplateId;
@property (nonatomic, strong) NSString* Name;
@property (nonatomic, strong) NSString* Avatar;
@property (nonatomic, strong) NSString* Intro;
@property (nonatomic, strong) NSString* System;
@property (nonatomic, strong) RawProperties* llm;
@property (nonatomic, strong) RawProperties* tts;
@property (nonatomic, strong) NSString* Source;
@property (nonatomic, strong) NSString* Sex;
@property (nonatomic, strong) NSString* WelcomeMessage;
- (NSDictionary *)toDict;
- (NSString *)toJson;
- (NSString *)getAvatar;
- (NSString *)getBackground;
- (NSString *)getCalling;
- (NSString *)getEntry;
@end

@interface TTSConfigInfo : NSObject
@property (nonatomic, strong) TTSConfig* ttsConfig;
@property (nonatomic, strong) NSString *voiceId;
@end


@interface CharacterConfig : NSObject
@property (nonatomic, strong) NSString *agentId;
@property (nonatomic, strong) NSString *conversationId;
@property (nonatomic, strong)CustomAgentConfig* curAgentConfig;
@property (nonatomic, strong)NSString* randomString;
//- (NSString *)getStreamID:(NSString*)randomRoomID;
//- (NSString *)getAgentStreamID:(NSString*)randomRoomID;
- (NSString*)getRoomID;
- (NSString*)getStreamID;
- (NSString*)getAgentStreamID;
- (NSString *)getAvatar;
- (NSString *)getBackground;
- (NSString *)getCalling;
- (NSString *)getEntry;
@end

@interface ConversionConfigInfo : NSObject
@property (nonatomic, strong) NSString *agentId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *agentTemplatedId;
@property (nonatomic, assign) BOOL isChatting;
@property (nonatomic, strong) NSString* conversationId;
@property (nonatomic, assign) BOOL isDefAgenttemplated;
@property (nonatomic, assign) BOOL isDefPinnedItem; //缺省置顶的item
@property (nonatomic, strong) CustomAgentConfig* customAgentConfig;
@end

@interface AppExtraConfig : NSObject
@property (nonatomic, strong) NSMutableArray<LLMConfig *> *llmNameList;
@property (nonatomic, strong) NSMutableArray<TTSConfig *> *ttsList;
@property (nonatomic, strong) NSMutableArray<CustomAgentConfig *> *customAgentList;
- (BOOL)isValid;

- (LLMConfig *)getLLMConfigById:(NSString*)llmId;
- (TTSConfig *)getTTSConfigById:(NSString*)ttsId;

- (LLMConfig *)getLLMConfigByProperties:(RawProperties*)llmId;
- (TTSConfig *)getTTSConfigByProperties:(RawProperties*)ttsId;
- (CustomAgentConfig *)getCustomAgentConfigById:(NSString*)AgentTemplateId;
@end


@interface AppDataManager : NSObject
@property (nonatomic, assign) long appID;
@property (nonatomic, strong) NSString *appSign;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userAvatar;
@property (nonatomic, strong) NSString *severSecret;
@property (nonatomic, strong) AppExtraConfig *appExtraConfig;
@property (nonatomic, strong) NSMutableArray<ConversionConfigInfo*> *conversationList;
@property (nonatomic, strong) CharacterConfig* curCharacterConfig;
+ (instancetype)sharedInstance;

- (CharacterConfig *)getCurrentCharacter;
- (void)switchCurrentCharacter:(NSString*)agentId;
- (void)deleteConversionItem:(NSString*)agentId;
- (NSString *)generateID:(NSString *)prefix isIDMaintain:(BOOL)isIDMaintain;
-(void)setConfigInfo:(long)appID
         withAppSign:(NSString*) appsign
    withServerSecret:(NSString*) serverSecret
          withUserId:(NSString*) userId
        withUsername:(NSString*) userName
       withAvatarUrl:(NSString*) userAvatar;
- (void)loadLocalAppExtraConfig;
- (ConversionConfigInfo *)getConversationConfigById:(NSString*)conversationId;
- (ConversionConfigInfo *)getConversationConfigByAgentId:(NSString*)agentId;
- (BOOL)isDefaultTemplateAgent:(NSString*)agentId;
- (BOOL)isDefaultPinnedAgent:(NSString*)agentId;
- (NSString*)getDefaultPinnedAgentConversionId;
@end
