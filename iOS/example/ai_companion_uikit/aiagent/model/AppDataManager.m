//
//  AppDataManager.m
//  ai_companion_oc
//
//  Created by zego on 2024/8/28.
//

#import "AppDelegate.h"
#import "ViewController.h"

#import "AppDataManager.h"
#import "ZegoAiCompanionHttpHelper.h"
#import "ZegoAiCompanionUtil.h"


static AppDataManager *_sharedInstance;

@implementation AppDataManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}


- (instancetype)init {
    self = [super init];
    if (self) {

        self.appExtraConfig = [[AppExtraConfig alloc]init];
        self.conversationList = [[NSMutableArray alloc]init];
        NSLog(@"AppDataManager init, userID: %@", _userID);
    }
    return self;
}

- (ConversionConfigInfo *)getConversationConfigById:(NSString*)conversationId{
    for (ConversionConfigInfo* item in self.conversationList) {
        if ([item.conversationId isEqualToString:conversationId]) {
            return item;
        }
    }
    return nil;
}

- (ConversionConfigInfo *)getConversationConfigByAgentId:(NSString*)agentId{
    for (ConversionConfigInfo* item in self.conversationList) {
        if ([item.agentId isEqualToString:agentId]) {
            return item;
        }
    }
    return nil;
}

- (BOOL)isDefaultTemplateAgent:(NSString*)agentId{
    for (ConversionConfigInfo* item in self.conversationList) {
        if ([item.agentId isEqualToString:agentId]) {
            return item.isDefAgenttemplated;
        }
    }
    
    return NO;
}

- (BOOL)isDefaultPinnedAgent:(NSString*)agentId{
    for (ConversionConfigInfo* item in self.conversationList) {
        if ([item.agentId isEqualToString:agentId]) {
            return item.isDefPinnedItem;
        }
    }
    
    return NO;
}


- (NSString*)getDefaultPinnedAgentConversionId{
    for (ConversionConfigInfo* item in self.conversationList) {
        if (item.isDefPinnedItem) {
            return item.agentId;
        }
    }
    return  nil;
}

-(void)setConfigInfo:(long)appID
         withAppSign:(NSString*) appsign
    withServerSecret:(NSString*) serverSecret
          withUserId:(NSString*) userId
        withUsername:(NSString*) userName
       withAvatarUrl:(NSString*) userAvatar{
    _appID = appID;
    _appSign = appsign;
    _severSecret = serverSecret;
    if (userId == nil) {
        _userID = [self generateID:@"iu_" isIDMaintain:YES];
    }else{
        _userID = userId;
    }
    
    if (userName == nil) {
        _userName = @"user_ios";
    }else{
        _userName = userName;
    }
    
    if (userAvatar == nil) {
        _userAvatar = @"https://zego-aigc-test.oss-accelerate.aliyuncs.com/airobotdemo/robot_ravatar.png";
    }else{
        _userAvatar = userAvatar;
    }
}

/** json转dict*/
- (NSDictionary *)dictFromJson:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSError *error;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) {
        return nil;
    }
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
    if(error) {
        NSLog(@"ZegoCharacterHelper, dictFromJson: Error, json解析失败：%@", error);
        return nil;
    }
    
    return dic;
}

- (void)loadLocalAppExtraConfig{
    if (self.appExtraConfig == nil) {
        return;
    }
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *filePath = [bundlePath stringByAppendingPathComponent:@"AppExtraConfig.json"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return;
    }

    // 读取数据
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    if (!data) {
        return;
    }
    
    NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *configDict = [self dictFromJson:jsonStr];
    
    //解释dict放入config结构体
    NSArray* llm_name_list = configDict[@"llm_list"];
    for(int i= 0; i< llm_name_list.count; i++){
        NSDictionary* item = [llm_name_list objectAtIndex:i];
        LLMConfig* llmConfig = [[LLMConfig alloc]init];
        llmConfig.Id = item[@"id"];
        llmConfig.icon = item[@"icon"];
        llmConfig.isSupported = [item[@"is_supported"] boolValue];
        llmConfig.name = item[@"name"];
        NSDictionary* rawProperties =item[@"raw_properties"];
        if (rawProperties) {
            llmConfig.rawProperties = [[RawProperties alloc]init];
            llmConfig.rawProperties.Model = rawProperties[@"Model"];
            llmConfig.rawProperties.Type = rawProperties[@"Type"];
//            llmConfig.rawProperties.AccountSource = rawProperties[@"AccountSource"];
        }
        [self.appExtraConfig.llmNameList addObject:llmConfig];
    }
    
    NSArray* tts_list = configDict[@"tts_list"];
    NSUInteger capacity = tts_list ? tts_list.count : 0;
    self.appExtraConfig.ttsList = [[NSMutableArray alloc]initWithCapacity:capacity];
    
    for(int i= 0; i< tts_list.count; i++){
        NSDictionary* item = [tts_list objectAtIndex:i];
        TTSConfig* ttsConfig = [[TTSConfig alloc]init];
        ttsConfig.Id = item[@"id"];
        ttsConfig.icon = item[@"icon"];
        ttsConfig.isSupported  = [item[@"is_supported"] boolValue];
        ttsConfig.name = item[@"name"];
        NSDictionary* rawProperties =item[@"raw_properties"];
        if (rawProperties) {
            ttsConfig.rawProperties = [[RawProperties alloc]init];
            ttsConfig.rawProperties.Type = rawProperties[@"Type"];
//            ttsConfig.rawProperties.AccountSource = rawProperties[@"AccountSource"];
        }
        [self.appExtraConfig.ttsList addObject:ttsConfig];
        
        NSArray* voiceList = item[@"voice_list"];
        NSUInteger capacity = voiceList ? voiceList.count : 0;
        ttsConfig.voiceList = [[NSMutableArray alloc]initWithCapacity:capacity];
        
        for (int j= 0; j<voiceList.count; j++) {
            NSDictionary* voiceItem = [voiceList objectAtIndex:j];
            
            VoiceConfig* voiceCfg = [[VoiceConfig alloc]init];
            voiceCfg.voiceId = voiceItem[@"id"];
            voiceCfg.name = voiceItem[@"name"];
            [ttsConfig.voiceList addObject:voiceCfg];
            NSArray* languageList = voiceItem[@"language"];
            NSUInteger capacity = languageList ? languageList.count : 0;
            voiceCfg.language = [[NSMutableArray alloc]initWithCapacity:capacity];
            for (int k=0; k<languageList.count; k++) {
                NSDictionary* langItem = [languageList objectAtIndex:k];
                LanguageConfig* lang = [[LanguageConfig alloc]init];
                lang.langId =langItem[@"id"];
                lang.name = langItem[@"name"];
                [voiceCfg.language addObject:lang];
            }
        }
    }
}

- (NSString *)generateID:(NSString *)prefix isIDMaintain:(BOOL)isIDMaintain {
    NSString *randomID = [NSString stringWithFormat:@"%@%ld%u", prefix, (long)CFAbsoluteTimeGetCurrent() % 1000000, arc4random_uniform(100)];
    if (isIDMaintain) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *cacheID = [defaults objectForKey:prefix];
        if(cacheID == nil){
            [defaults setObject:randomID forKey:prefix];
            [defaults synchronize];
            cacheID = randomID;
        }
        return cacheID;
    } else {
        return randomID;
    }
}

- (CharacterConfig *)getCurrentCharacter{
    return  self.curCharacterConfig;
}

- (void)switchCurrentCharacter:(NSString*)agentId{
    CharacterConfig* curCharacterConfig = [[CharacterConfig alloc]init];
    ConversionConfigInfo* conversionCfgInfo = [self getConversationConfigByAgentId:agentId];
    NSAssert(conversionCfgInfo != nil, @"出了什么问题，从会话列表里查不到agentId=%@对应的会话", agentId);
    curCharacterConfig.agentId = conversionCfgInfo.agentId;
    curCharacterConfig.conversationId = conversionCfgInfo.conversationId;
    curCharacterConfig.curAgentConfig = conversionCfgInfo.customAgentConfig;
    [AppDataManager sharedInstance].curCharacterConfig = curCharacterConfig;
}


- (void)deleteConversionItem:(NSString*)agentId{
    ConversionConfigInfo* conversionCfgInfo = [self getConversationConfigByAgentId:agentId];
    if (!conversionCfgInfo) {
        NSLog(@"出了什么问题，从会话列表里查不到agentId=%@对应的会话", agentId);
        return;
    }
    
    NSAssert(conversionCfgInfo != nil, @"出了什么问题，从会话列表里查不到agentId=%@对应的会话", agentId);
    [[ZegoAiCompanionHttpHelper sharedInstance] deleteConversation:conversionCfgInfo.conversationId
                                                        withUserId:[AppDataManager sharedInstance].userID
                                                      withCallback:^(NSInteger errorCode, NSString *errMsg, NSString* requestId) {
        NSLog(@"删除会话结果,errorCode=%ld, errMsg=%@", (long)errorCode, errMsg);
        if (errorCode == 0) {
            [self.conversationList removeObject:conversionCfgInfo];
        }
    }];
}
@end

@implementation ConversionConfigInfo
-(void)setAgentTemplatedId:(NSString *)agentTemplatedId{
    _agentTemplatedId = agentTemplatedId;
    if ([agentTemplatedId isEqualToString:@"xiaozhi"]) {
        self.isDefPinnedItem = YES;
    }
}
@end

@implementation AppExtraConfig

- (instancetype)init{
    if(self = [super init]){
        self.llmNameList = [[NSMutableArray alloc]init];
        self.ttsList = [[NSMutableArray alloc]init];
//        self.characterList =[[NSMutableArray alloc]init];
    }
    return self;
}

- (BOOL)isValid {
    if (!_llmNameList || !_ttsList) {
        return NO;
    }
    for (TTSConfig *ttsConfig in _ttsList) {
        if (![ttsConfig.voiceList count]) {
            return NO;
        }
        for (VoiceConfig *voiceConfig in ttsConfig.voiceList) {
            if (![voiceConfig.language count]) {
                return NO;
            }
        }
    }
    return YES;
}

//- (CharacterConfig *)getCurrentCharacter {
//    return self.curCharacterConfig;
//}

- (LLMConfig *)getLLMConfigById:(NSString*)llmId{
    for (LLMConfig *item in _llmNameList) {
        if ([item.Id isEqualToString: llmId]) {
            return item;
        }
    }
    return nil;
}

- (TTSConfig *)getTTSConfigById:(NSString*)ttsId{
    for (TTSConfig *item in self.ttsList) {
        if ([item.Id isEqualToString: ttsId]) {
            return item;
        }
    }
    return nil;
}

- (LLMConfig *)getLLMConfigByProperties:(RawProperties*)llmId{
    for (LLMConfig *item in _llmNameList) {
        if ([item.rawProperties.Model isEqualToString:llmId.Model] &&
            [item.rawProperties.Type isEqualToString:llmId.Type]) {
            return item;
        }
    }
    return nil;
}

- (TTSConfig *)getTTSConfigByProperties:(RawProperties*)ttsId{
    for (TTSConfig* item in _ttsList) {
        if ([item.rawProperties.Type isEqualToString:ttsId.Type]) {
            return item;
        }
    }
    return nil;
}

- (CustomAgentConfig *)getCustomAgentConfigById:(NSString*)AgentTemplateId{
    if (AgentTemplateId == nil) {
        return nil;
    }
    
    for (CustomAgentConfig* item in _customAgentList) {
        if ([item.AgentTemplateId isEqualToString:AgentTemplateId]) {
            return item;
        }
    }
    return nil;
}
@end

@implementation CharacterConfig
-(instancetype)init{
    if (self = [super init]) {
        self.randomString = [ZegoAiCompanionUtil generateRandomNumberString]; //@RBT#在流id里面属于非法字符，因此用个随机数替代
    }
    return self;
}

-(NSString *)getRoomID {
    return [NSString stringWithFormat:@"ir_%@",self.randomString];
}

- (NSString *)getStreamID {
    return [NSString stringWithFormat:@"%@_%@_main",[self getRoomID], [AppDataManager sharedInstance].userID];
}
    
- (NSString *)getAgentStreamID {
    return [NSString stringWithFormat:@"%@_%@_agent",[self getRoomID], [AppDataManager sharedInstance].userID];
}

- (NSString *)getAvatar {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *iconPath = [NSString stringWithFormat:@"/icon/%@/m_avatar_%@.png", self.curAgentConfig.AgentTemplateId, self.curAgentConfig.AgentTemplateId];
    NSString *localEntryIcon = [bundlePath stringByAppendingString:iconPath];
    return localEntryIcon;

}

- (NSString *)getBackground {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *iconPath = [NSString stringWithFormat:@"/icon/%@/m_bg_%@.png", self.curAgentConfig.AgentTemplateId, self.curAgentConfig.AgentTemplateId];
    NSString *localEntryIcon = [bundlePath stringByAppendingString:iconPath];
    return localEntryIcon;
}

- (NSString *)getCalling {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *iconPath = [NSString stringWithFormat:@"/icon/%@/m_calling_%@.png", self.curAgentConfig.AgentTemplateId, self.curAgentConfig.AgentTemplateId];
    NSString *localEntryIcon = [bundlePath stringByAppendingString:iconPath];
    return localEntryIcon;
}

- (NSString *)getEntry {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *iconPath = [NSString stringWithFormat:@"/icon/%@/m_entry_%@.png", self.curAgentConfig.AgentTemplateId, self.curAgentConfig.AgentTemplateId];
    NSString *localEntryIcon = [bundlePath stringByAppendingString:iconPath];
    return localEntryIcon;
}

@end

@implementation CustomAgentConfig
-(NSDictionary*)toDict{
    // 使用NSJSONSerialization实现序列化
    NSDictionary* llm_dict =[NSDictionary dictionaryWithObjectsAndKeys:
                             self.llm.Type,@"Type",
                             self.llm.Model,@"Model", nil];
    NSDictionary* tts_dict =[NSDictionary dictionaryWithObjectsAndKeys:self.tts.Voice,@"Voice",
                             self.tts.Type, @"Type",nil];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.AgentTemplateId ?:@"",@"AgentTemplateId",
                          self.Name,@"Name",
                          self.Avatar ?:@"",@"Avatar",
                          self.Intro ?:@"", @"Intro",
                          self.System ?:@"", @"System",
                          llm_dict, @"LLM",
                          tts_dict, @"TTS",
                          self.Source ?:@"", @"Source",
                          self.Sex ?:@"", @"Sex",
                          self.WelcomeMessage ?:@"", @"WelcomeMessage",
                          nil];
    return dict;
}

- (NSString *)toJson{
    // 使用NSJSONSerialization实现序列化
    NSDictionary* llm_dict =[NSDictionary dictionaryWithObjectsAndKeys:
                             self.llm.Type,@"Type",
                             self.llm.Model,@"Model", nil];
    NSDictionary* tts_dict =[NSDictionary dictionaryWithObjectsAndKeys:self.tts.Voice,@"Voice",
                             self.tts.Type, @"Type", nil];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.AgentTemplateId,@"AgentTemplateId",
                          self.Name,@"Name",
                          self.Avatar,@"Avatar",
                          self.Intro, @"Intro",
                          self.System, @"System",
                          llm_dict, @"LLM",
                          tts_dict, @"TTS",
                          nil];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"Error converting dictionary to JSON: %@", error.localizedDescription);
        return nil;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (NSString *)getAvatar {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *iconPath = [NSString stringWithFormat:@"/icon/%@/m_avatar_%@.png", self.AgentTemplateId, self.AgentTemplateId];
    NSString *localEntryIcon = [bundlePath stringByAppendingString:iconPath];
    return localEntryIcon;

}

- (NSString *)getBackground {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *iconPath = [NSString stringWithFormat:@"/icon/%@/m_bg_%@.png", self.AgentTemplateId, self.AgentTemplateId];
    NSString *localEntryIcon = [bundlePath stringByAppendingString:iconPath];
    return localEntryIcon;
}

- (NSString *)getCalling {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *iconPath = [NSString stringWithFormat:@"/icon/%@/m_calling_%@.png", self.AgentTemplateId,self.AgentTemplateId];
    NSString *localEntryIcon = [bundlePath stringByAppendingString:iconPath];
    return localEntryIcon;
}

- (NSString *)getEntry {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *iconPath = [NSString stringWithFormat:@"/icon/%@/m_entry_%@.png", self.AgentTemplateId, self.AgentTemplateId];
    NSString *localEntryIcon = [bundlePath stringByAppendingString:iconPath];
    return localEntryIcon;
}
@end

@implementation RawProperties

-(BOOL)isLLMEqualToOther:(RawProperties*)other{
    if ([self.Model isEqualToString:other.Model] &&
        [self.Type isEqualToString:other.Type]) {
        return YES;
    }
    return NO;
}

-(BOOL)isTTSEqualToOther:(RawProperties*)other{
    if ([self.Voice isEqualToString:other.Voice] &&
        [self.Type isEqualToString:other.Type]) {
        return YES;
    }
    return NO;
}
@end

@implementation LLMConfig
@end

@implementation TTSConfig
- (VoiceConfig*)getVoiceConfigById:(NSString*)voiceId{
    for (VoiceConfig* item in self.voiceList) {
        if([item.voiceId isEqualToString:voiceId]){
            return item;
        }
    }
    return nil;
}
@end

@implementation VoiceConfig
- (LanguageConfig*)getLangConfigById:(NSString*)langId{
    for (LanguageConfig* item in self.language) {
        if ([item.langId isEqualToString: langId]) {
            return item;
        }
    }
    return nil;
}
@end

@implementation LanguageConfig
@end

@implementation TTSConfigInfo
@end
