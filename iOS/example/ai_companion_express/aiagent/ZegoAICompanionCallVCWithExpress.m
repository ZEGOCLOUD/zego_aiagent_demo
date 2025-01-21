//
//  ZegoAICompanionCallVCWithExpress.m
//  基于ZegoExpressEngine而非ZegoUIKit
//  Created by zego on 2024/5/13.
//  Copyright © 2024 Zego. All rights reserved.
//

#import "ZegoAICompanionCallVCWithExpress.h"
#import <Masonry/Masonry.h>
#import <YYKit/UIImageView+YYWebImage.h>
#import <ZegoExpressEngine/ZegoExpressEngine.h>
#import "AppDataManager.h"
#import "UIView+Toast.h"
#import "ZegoAudioChatTableViewCell.h"
#import "ZegoAudioChatMsgModel.h"
#import "ZegoAICompanionSettingsView.h"
#import "ZegoSettingsContainerView.h"
#import "ZegoAiCompanionUtil.h"
#import "UIView+Toast.h"
#import "PerfStaticsHelper.h"
#import "AIAgentLogUtil.h"
#import "UIView+Toast.h"
#import "ZegoVoiceActivityChecker.h"
#import "ZegoAIAgentExpressHelper.h"
#import "ZegoAudioChatTableView.h"
#import "ZegoStaticsLogView.h"


typedef void (^JoinRoomCallback)(int errorCode, NSDictionary *extendedData);

@interface ZegoAICompanionCallVCWithExpress ()<ZegoEventHandler, 
ZegoSettingsContainerViewDelegate, ZegoStaticsLogViewDelegate>

@property (nonatomic, strong) ZegoAudioChatTableView *chatMsgTable;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UIButton *leaveButton;
@property (nonatomic, strong) UIButton *toggleMicButton;
@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) UIImageView* backgroundImage;
@property (nonatomic, strong) ZegoSettingsContainerView* settingsContainerView;
@property (nonatomic, strong) UIImageView* headAvatar;
@property (nonatomic, assign) int64_t lastCMD1Seq; //该标志用来防治消息收取乱序
//@property (nonatomic, strong) AskAnswerStatics* askAnswerStatics;

//下面成员变量是用来实现快速打断逻辑
@property (nonatomic, strong) ZegoVoiceActivityChecker* vadChecker;
@property (nonatomic, assign) int curVolume;

@end

@implementation ZegoAICompanionCallVCWithExpress
-(instancetype)init{
    if(self = [super init]){        
        CharacterConfig* curCharacter = [AppDataManager sharedInstance].curCharacterConfig;

        self.roomId = [curCharacter getRoomID];   //由业务方决定，建议每次进入换一个房间id,防止出现一些异常情况，比如，同一个房间如果立即再一次进入，可能会有流尾音
        self.userID = [AppDataManager sharedInstance].userID; //由业务方决定，本demo是随机生成
        self.userName =[AppDataManager sharedInstance].userName; //由业务方决定，本demo是随机生成
        self.streamID = [curCharacter getStreamID];
        self.agentStreamID = [curCharacter getAgentStreamID];
        
        self.vadChecker = [[ZegoVoiceActivityChecker alloc]init];
        self.curVolume = 100;
        self.lastCMD1Seq = 0;
    }
    return self;
}
-(void)dealloc{
    //用来做问题定位的，接入方请忽略
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[ZegoExpressEngine sharedEngine] stopSoundLevelMonitor];
    /**************************************/
}

-(void)startRtcChatInternal{
    CharacterConfig* characterConfig = [AppDataManager sharedInstance].curCharacterConfig;
    NSString* conversationId = characterConfig.conversationId;
    NSString* roomID = self.roomId;
    NSString* streamID = self.streamID;
    NSString* agentStreamID = self.agentStreamID;
    
    NSString* userId = self.userID;
    NSLog(@"StartRtcChat params, userId=%@, conversationId=%@, roomID=%@, streamID=%@, agentStreamID=%@",
          userId,
          conversationId,
          roomID, streamID,
          agentStreamID);
    [[ZegoAIAgentExpressHelper sharedInstance] startRtcChat:conversationId
                                                 withUserId:self.userID
                                                 withRoomId:roomID
                                               withStreamId:streamID
                                          withAgentStreamId:agentStreamID
                                               withCallback:^(NSInteger errorCode, NSString *errMsg, NSString* requestId) {
        if (errorCode != 0 && errorCode != 410003101) {
            NSString* errorMsg =[NSString stringWithFormat:@"发起语音聊天失败:%@", errMsg];
            [self.view makeToast:errorMsg];
            return;
        }
        
        if(errorCode == 410003101){
            //这个错误码表示该会话还在后台维持着，这里接入方可考虑，方案1:终止当前会话，发起一个新的会话，方案2:不终止当前会话，但RoomID,streamID,agentStreamID要保持跟上一次创建会话一致
            [[ZegoAIAgentExpressHelper sharedInstance] stopRtcChat:conversationId
                                                        withUserId:self.userID
                                                      withCallback:^(NSInteger errorCode, NSString *errMsg, NSString *requestId) {
                if (errorCode !=0 ) {
                    NSLog(@"errorCode=%ld, 终止已有会话出现问题", (long)errorCode);
                    NSString* errorMsg =[NSString stringWithFormat:@"终止已有会话出现问题，请退出重试errorCode=%ld", errorCode];
                    [self.view makeToast:errorMsg];
                    return;
                }
                [[ZegoAIAgentExpressHelper sharedInstance] startRtcChat:conversationId
                                                             withUserId:self.userID
                                                             withRoomId:roomID
                                                           withStreamId:streamID
                                                      withAgentStreamId:agentStreamID
                                                           withCallback:^(NSInteger errorCode, NSString *errMsg, NSString* requestId) {
                    if (errorCode != 0 && errorCode != 410003101) {
                        NSString* errorMsg =[NSString stringWithFormat:@"网络异常，发起语音聊天失败:ec=%ld", (long)errorCode];
                        [self.view makeToast:errorMsg];
                        return;
                    }
                    
                    if ([self.callVCNameStatusCom.chatStatusText isEqualToString:@"等待连接..."]) {
                        self.callVCNameStatusCom.chatStatusText = @"已连接";
                    }
                }];
                
            }];
        }else{
            if ([self.callVCNameStatusCom.chatStatusText isEqualToString:@"等待连接..."]) {
                self.callVCNameStatusCom.chatStatusText = @"已连接";
            }
        }
    }];
}

-(void)unInit{
    CharacterConfig* curCharacter = [AppDataManager sharedInstance].curCharacterConfig;
    //请求业务后台退出RTC语音聊天
    [[ZegoAIAgentExpressHelper sharedInstance] stopRtcChat:curCharacter.conversationId 
                                                withUserId:self.userID
                                              withCallback:^(NSInteger errorCode, NSString *errMsg, NSString *requestId) {
        if (errorCode!=0) {
            NSLog(@"StopRtcChat", @"ec=%d, errMsg=%@, cmd=%d, requestId=%@", errorCode,errMsg ?:@"", requestId);
        }
    }];
    
    [self setPlayVolumeInternal:0];
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.agentStreamID];
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    [[ZegoExpressEngine sharedEngine] logoutRoom];
    [ZegoExpressEngine destroyEngine:^{
        NSLog(@"destroyEngine");
    }];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self setupUI];
    [self initZegoExpressEngine];
    
    [self joinRoom:^(int errorCode, NSDictionary *extendedData) {
        if (errorCode!=0) {
            NSString* errorMsg =[NSString stringWithFormat:@"进入语音房间失败:%d", errorCode];
            [self.view makeToast:errorMsg];
            return;
        }
        [self startRtcChatInternal];
    }];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self unInit];
}

-(void)initZegoExpressEngine{
    ZegoEngineProfile* profile = [[ZegoEngineProfile alloc]init];
    profile.appID = [AppDataManager sharedInstance].appID;
    profile.appSign = [AppDataManager sharedInstance].appSign;
    profile.scenario = ZegoScenarioStandardVoiceCall; //设置该场景可以避免申请相机权限，接入方应按自己的业务场景设置具体值
    ZegoEngineConfig* engineConfig = [[ZegoEngineConfig alloc] init];
    engineConfig.advancedConfig = @{
        @"notify_remote_device_unknown_status": @"true",
        @"notify_remote_device_init_status":@"true",
        @"enforce_audio_loopback_in_sync": @"true", /**该配置用来做应答延迟优化的，需要集成对应版本的ZegoExpressEngine sdk，请联系即构同学**/
    };
    
    [ZegoExpressEngine setEngineConfig:engineConfig];
    [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];
}


-(void)setPlayVolumeInternal:(int)volume{
    ZAALogI(@"AudioPlay", @"setPlayVolumeInternal volume=%d", volume);
    self.curVolume = volume;
    [ZegoExpressEngine.sharedEngine setPlayVolume:volume streamID:self.agentStreamID];
}

-(void)enable3A:(BOOL)enable{
    [[ZegoExpressEngine sharedEngine] enableAEC:enable];
    [[ZegoExpressEngine sharedEngine] enableAGC:enable];
    [[ZegoExpressEngine sharedEngine] enableANS:enable];
    if (enable) {
        [[ZegoExpressEngine sharedEngine] setANSMode:ZegoANSModeAIAggressive];
    }
}

-(void)startPushlishStream{
    [[ZegoExpressEngine sharedEngine] muteMicrophone:NO];
    [[ZegoExpressEngine sharedEngine] startPublishingStream:self.streamID channel:ZegoPublishChannelMain];
}

-(void)startPlayStream:(NSString*)streamId{
    [[ZegoExpressEngine sharedEngine] startPlayingStream:self.agentStreamID];
    [self onAfterStartPlayStream:self.agentStreamID channel:ZegoPublishChannelAux];
}

-(void)onAfterStartPlayStream:(NSString *)streamID channel:(ZegoPublishChannel)channel{
    NSLog(@"onAfterStartPlayStream, streamID=%@, channel =%lu",streamID,(unsigned long)channel);
    /**下面用来做应答延迟优化的，需要集成对应版本的ZegoExpressEngine sdk，请联系即构同学**/
    NSString *params = [NSString stringWithFormat:@"{\"method\":\"liveroom.audio.set_play_latency_mode\",\"params\":{\"mode\":1,\"stream_id\":\"%@\"}}", streamID];
    [[ZegoExpressEngine sharedEngine] callExperimentalAPI:params];
    /*********************************************************************************************************/
}

-(void)joinRoom:(JoinRoomCallback)complete{
    /**下面用来做应答延迟优化的，需要集成对应版本的ZegoExpressEngine sdk，请联系即构同学**/
    ZegoEngineConfig *engineConfig = [[ZegoEngineConfig alloc] init];
    engineConfig.advancedConfig = @{
        @"enforce_audio_loopback_in_sync": @"true"
    };
    [ZegoExpressEngine setEngineConfig:engineConfig];
    /*********************************************************************************************************/
    
    //这个设置只影响AEC（回声消除），我们这里设置为ModeGeneral，是会走我们自研的回声消除，这比较可控，
    //如果其他选项，可能会走系统的回声消除，这在iphone手机上效果可能会更好，但如果在一些android机上效果可能不好
    [[ZegoExpressEngine sharedEngine] setAudioDeviceMode:ZegoAudioDeviceModeGeneral];
    
    //请注意：开启AI降噪需要联系即构同学拿对应的ZegoExpressionEngine.xcframework，具备该能力的版本还未发布
    [self enable3A:YES];
        
    ZegoRoomConfig* roomConfig = [[ZegoRoomConfig alloc]init];
    roomConfig.isUserStatusNotify = YES;
    ZegoUser* user = [[ZegoUser alloc]init];
    user.userName = self.userName;
    user.userID = self.userID;
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomId user:user config:roomConfig callback:^(int errorCode, NSDictionary * _Nonnull extendedData) {
        ZAALogI(@"joinRoom", @"result code=%d", errorCode);
        
        /**下面用来做应答延迟优化的，需要集成对应版本的ZegoExpressEngine sdk，请联系即构同学**/
        NSString *params_publish = @"{\"method\":\"liveroom.audio.set_publish_latency_mode\",\"params\":{\"mode\":1,\"channel\":0}}";
        [[ZegoExpressEngine sharedEngine] callExperimentalAPI:params_publish];
        /*********************************************************************************************************/
        
        //进房后开始推流
        [self startPushlishStream];
        
        complete(errorCode, extendedData);
    }];
}

-(void)setupChatMsgTableView{
    self.chatMsgTable = [[ZegoAudioChatTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.chatMsgTable];
    CGFloat barH = [[UIApplication sharedApplication] statusBarFrame].size.height;
    [self.chatMsgTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(self.view).offset(342+barH);
        make.bottom.equalTo(self.view).offset(-154);
    }];
}

- (void)setupUI {
    CharacterConfig* curCharacter = [AppDataManager sharedInstance].curCharacterConfig;
    self.view.backgroundColor = [UIColor whiteColor];
    // 设置背景图像
    self.backgroundImage =  [[UIImageView alloc] init];
    self.backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    
    NSString * callingImagePath = [curCharacter getBackground];
    UIImage* temp = [[UIImage alloc] initWithContentsOfFile:callingImagePath];
    if (temp == nil) {
        [self.backgroundImage setImageURL:[NSURL URLWithString:curCharacter.curAgentConfig.Avatar]];
    }else{
        self.backgroundImage.image = temp;
    }
    
    [self.view addSubview:self.backgroundImage];
    [self.backgroundImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(self.view);
    }];
    
    
    CGFloat barH = [[UIApplication sharedApplication] statusBarFrame].size.height;
    self.callVCNameStatusCom = [[ZegoCallVCNameUIComponent alloc]initWithFrame:CGRectZero];
    [self.view addSubview:self.callVCNameStatusCom];
    [self.callVCNameStatusCom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(104);
        make.height.mas_equalTo(61);
        make.top.equalTo(self.view).offset(10+barH);
        make.centerX.equalTo(self.view);
    }];
    
    self.callVCNameStatusCom.chatStatusText = @"等待连接...";
    NSString* AIRobotName = curCharacter.curAgentConfig.Name;
    self.callVCNameStatusCom.userNameText = AIRobotName;

    self.settingsButton = [[UIButton alloc]init];
    UIImage* settingsNormalImage = [UIImage imageNamed:@"icon_setting"];
    [self.settingsButton setImage:settingsNormalImage forState:UIControlStateNormal];
    [self.settingsButton addTarget:self action:@selector(onSettingsButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.settingsButton];
    
    [self.settingsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
        make.right.equalTo(self.view.mas_right).offset(-12);
        make.top.equalTo(self.view).offset(7+barH);
    }];
    
    
    self.toggleMicButton = [[UIButton alloc]init];
    self.toggleMicButton.layer.cornerRadius = 30;
    self.toggleMicButton.clipsToBounds = YES;
    self.toggleMicButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25];
    UIImage* micNormalImage = [UIImage imageNamed:@"icon_mic_normal"];
    UIImage* micOffImage = [UIImage imageNamed:@"icon_mic_jinyong"];
    [self.toggleMicButton setImage:micNormalImage forState:UIControlStateNormal];
    [self.toggleMicButton setImage:micOffImage forState:UIControlStateSelected];
    
    [self.toggleMicButton addTarget:self action:@selector(onToggleMicButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.toggleMicButton];
    
    [self.toggleMicButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(60);
        make.left.equalTo(self.view.mas_left).offset(44);
        make.bottom.equalTo(self.view.mas_bottom).offset(-60);
    }];
    
    
    self.leaveButton = [[UIButton alloc]init];
    UIImage* leaveImage = [UIImage imageNamed:@"icon_iphone"];
    [self.leaveButton setImage:leaveImage forState:UIControlStateNormal];
    [self.leaveButton addTarget:self action:@selector(onLeaveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.leaveButton];
    
    [self.leaveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(60);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-60);
    }];

    [self setupChatMsgTableView];
}

// 退出房间
- (void)onLeaveButtonClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

// 开关麦点击事件
- (void)onToggleMicButtonClicked:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if(sender.selected){
        NSLog(@"applechang-test, muteMicrophone=%d", YES);
        [[ZegoExpressEngine sharedEngine] muteMicrophone:YES];
    }else{
        NSLog(@"applechang-test, muteMicrophone=%d", NO);
        [[ZegoExpressEngine sharedEngine] muteMicrophone:NO];
    }
}

-(void)onClickCloseContainer{
    if (self.settingsContainerView == nil) {
        return;
    }

    [UIView animateWithDuration:0.2
                      delay:0.0
                    options:UIViewAnimationOptionTransitionFlipFromBottom
                     animations:^{
        self.settingsContainerView.alpha = 0.0; // 淡出效果
    }
                     completion:^(BOOL finished) {
        [self.settingsContainerView removeFromSuperview];
        self.settingsContainerView = nil;
        NSLog(@"Animation completed.");
    }];
}

#pragma delegate ZegoSettingsContainerViewDelegate
-(void)onCloseTTSSettingsView:(BOOL)saved withTTSConfig:(TTSConfigInfo*)ttsConfigInfo{
    if(saved){
        CharacterConfig* curCharacter = [AppDataManager sharedInstance].curCharacterConfig;
        CustomAgentConfig* tempCustomAgentConfig = [[CustomAgentConfig alloc] init];
        tempCustomAgentConfig.AgentTemplateId = curCharacter.curAgentConfig.AgentTemplateId;
        tempCustomAgentConfig.Name = curCharacter.curAgentConfig.Name;
        tempCustomAgentConfig.Avatar = curCharacter.curAgentConfig.Avatar;
        tempCustomAgentConfig.Intro = curCharacter.curAgentConfig.Intro;
        tempCustomAgentConfig.System = curCharacter.curAgentConfig.System;
        tempCustomAgentConfig.llm = curCharacter.curAgentConfig.llm;
        tempCustomAgentConfig.tts = [[RawProperties alloc]init];
        tempCustomAgentConfig.tts.Voice = ttsConfigInfo.voiceId;
        tempCustomAgentConfig.tts.Type = ttsConfigInfo.ttsConfig.rawProperties.Type;
//        tempCustomAgentConfig.tts.AccountSource = ttsConfigInfo.ttsConfig.rawProperties.AccountSource;
    
        [[ZegoAIAgentExpressHelper sharedInstance] updateConversation:curCharacter.conversationId
                                                           withUserId:self.userID
                                                      withAgentTempId:curCharacter.curAgentConfig.AgentTemplateId
                                                     withCustomConfig:tempCustomAgentConfig 
                                                         withCallback:^(NSInteger errorCode, NSString *errMsg, NSString* requestId) {
            if (errorCode != 0) {
                NSString* errorMsg =[NSString stringWithFormat:@"更新会话TTS信息失败:%@", errMsg];
                [self.view makeToast:errorMsg];
                return;
            }
            curCharacter.curAgentConfig.tts = tempCustomAgentConfig.tts;
        }];
    }
    
    self.settingsContainerView = nil;
}

// 设置按钮
- (void)onSettingsButtonClicked:(UIButton *)sender {
    NSLog(@"onSettingsButtonClicked");
    if (self.settingsContainerView != nil) {
        return;
    }
    self.settingsContainerView = [[ZegoSettingsContainerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.settingsContainerView.delegate = self;
    
    CharacterConfig* characterCofig = [AppDataManager sharedInstance].curCharacterConfig;
    
    TTSConfig* ttsConfig = [[AppDataManager sharedInstance].appExtraConfig getTTSConfigByProperties:characterCofig.curAgentConfig.tts];
    NSString* voiceId =characterCofig.curAgentConfig.tts.Voice;
    
    TTSConfigInfo* ttsConfigInfo = [[TTSConfigInfo alloc]init];
    ttsConfigInfo.ttsConfig = ttsConfig;
    ttsConfigInfo.voiceId = voiceId;
    [self.settingsContainerView display:self.view withTTSConfig:ttsConfigInfo];
}

-(CGRect)calculateStringLength:(NSString *)content withFont:(UIFont*)font{
    NSDictionary *attributes = @{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName: [UIColor blackColor]
    };
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:content attributes:attributes];
    
    // 计算文本的大小
    CGSize maxSize = CGSizeMake(239, CGFLOAT_MAX);
    CGRect boundingBox = [attributedString boundingRectWithSize:maxSize
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                        context:nil];
    return boundingBox;
}


#pragma delegate ZegoEventHandler
//监听房间流信息更新状态，调用智能体流播放
- (void)onRoomStreamUpdate:(ZegoUpdateType)updateType
                streamList:(NSArray<ZegoStream *> *)streamList
              extendedData:(nullable NSDictionary *)extendedData
                    roomID:(NSString *)roomID{
    if (updateType == ZegoUpdateTypeAdd) {
        for (int i=0; i<streamList.count; i++) {
            ZegoStream* item =  [streamList objectAtIndex:i];
            ZAALogI(@"onRoomStreamUpdate", @"ZegoUpdateTypeAdd userID=%@, userName=%@, streamID=%@", item.user.userID,
                    item.user.userName, item.streamID);
            if ([item.streamID isEqualToString: self.agentStreamID]) {
                [self startPlayStream:self.agentStreamID];
                break;
            }
        }
    }else if(updateType == ZegoUpdateTypeDelete){
        for (int i=0; i<streamList.count; i++) {
            ZegoStream* item =  [streamList objectAtIndex:i];
            ZAALogI(@"onRoomStreamUpdate", @"ZegoUpdateTypeDelete userID=%@, userName=%@, streamID=%@", item.user.userID,
                    item.user.userName, item.streamID);
        }
    }
}

//监听房间推流信息更新
- (void)onPublisherStateUpdate:(ZegoPublisherState)state
                     errorCode:(int)errorCode
                  extendedData:(nullable NSDictionary *)extendedData
                      streamID:(NSString *)streamID{
    ZAALogI(@"onPublisherStateUpdate", @"state=%d, errorCode=%d, streamID=%@",state,errorCode, streamID);
}

//监听房间推流信息更新
- (void)onPublisherQualityUpdate:(ZegoPublishStreamQuality *)quality streamID:(NSString *)streamID{
    ZAALogI(@"onPublisherQualityUpdate", @"quality=%d, streamID=%@",quality, streamID);
}

//v2.1.0版本后台广播消息修改为自定义消息
//https://zegocloud.feishu.cn/wiki/FpwqwwQeyiIs3KkhlQhcDfFvn5i
//2. RTC房间事件消息协议
//实时音视频 服务端 API 推送自定义消息 - 开发者中心 - ZEGO即构科技
//描述： 用户与Agent进行语音对话期间，服务端通过RTC房间自定义消息下发一些状态信息，比如用户说话状态、机器人说话状态、ASR识别的文本、大模型回答的文本。客户端监听房间自定义消息，解析对应的状态事件来渲染UI
//MessageContent协议：
- (void)onIMRecvCustomCommand:(NSString *)command
                     fromUser:(ZegoUser *)fromUser
                       roomID:(NSString *)roomID{
    if (command == nil) {
        NSLog(@"onIMRecvCustomCommand command is nil");
        return;
    }
    
    NSDictionary* msgDict = [ZegoAiCompanionUtil dictFromJson:command];
    
    int cmd = [msgDict[@"cmd"] intValue];
    long long seqId = [msgDict[@"seq_id"] longLongValue];
    long long round = [msgDict[@"round"] longLongValue];
    long timeStamp = [msgDict[@"timestamp"] longValue];
    NSDictionary* dataMap = msgDict[@"data"];
    
    if(cmd == 3){
        // 收到 asr 文本，更新聊天信息
        NSString* content = dataMap[@"text"];
        NSString* message_id = dataMap[@"message_id"];
        BOOL end_flag =dataMap[@"end_flag"];
        
        ZAALogI(@"onInRoomMessageReceived", @"recvasr userID=%@, userName=%@, cmd=%d, seqId=%llu, round=%llu, timeStamp=%llu, content=%@, message_id=%@, end_flag=%d", fromUser.userID,
                fromUser.userName,cmd,seqId,round,timeStamp,content,message_id,end_flag);
        
        [self.chatMsgTable handleRecvAsrChatMsg: msgDict];
        
    }else if(cmd == 4){
        // 收到 LLM 文本，更新聊天信息
        NSString* content = dataMap[@"text"];
        NSString* message_id = dataMap[@"message_id"];
        BOOL end_flag =[dataMap[@"end_flag"] boolValue];
        
        ZAALogI(@"onInRoomMessageReceived", @"recvllmtts userID=%@, userName=%@, cmd=%d, seqId=%llu, round=%llu, timeStamp=%llu, content=%@, message_id=%@, end_flag=%d",
                fromUser.userID,fromUser.userName,cmd,seqId,round,timeStamp,content,message_id,end_flag);
        [self.chatMsgTable handleRecvLLMChatMsg:msgDict];
    }else if(cmd == 1){
        int speakStatus = [dataMap[@"speak_status"]intValue];
        
        if (seqId < self.lastCMD1Seq) {
            ZAALogI(@"onInRoomMessageReceived", @"recvcmdstate 收到cmd=1, _lastCMD1Seq=%lld, curSeqId=%lld, 丢弃该消息",self.lastCMD1Seq, seqId);
            return;
        }
        ZAALogI(@"onInRoomMessageReceived", @"recvcmdstate userID=%@, userName=%@, cmd=%d, seqId=%llu, timeStamp=%llu, speakStatus=%d", fromUser.userID,
                fromUser.userName, cmd, seqId, timeStamp, speakStatus);
        if(speakStatus ==1){
            self.callVCNameStatusCom.chatStatusText = @"正在听...";
            ZAALogI(@"onInRoomMessageReceived cmd=1 speakStatus=1", @"正在听, setPlayVolume:0");
            [self setPlayVolumeInternal:0];
            self.chatSessionState = ChatSessionState_AI_LISTEN;
        }else if(speakStatus == 2){
            self.callVCNameStatusCom.chatStatusText = @"正在想...";
            ZAALogI(@"onInRoomMessageReceived cmd=1 speakStatus=2", @"正在想, setPlayVolume:100");
            [self setPlayVolumeInternal:100];
            self.chatSessionState = ChatSessionState_AI_THINKING;
        }
        self.lastCMD1Seq = seqId;
    }else if(cmd == 2){
        int speakStatus = [dataMap[@"speak_status"]intValue];
        ZAALogI(@"onInRoomMessageReceived", @"recvcmdstate userID=%@, userName=%@, cmd=%d, seqId=%llu, timeStamp=%llu, speakStatus=%d", fromUser.userID,
                fromUser.userName, cmd, seqId, timeStamp, speakStatus);
        if(speakStatus == 1){
            self.callVCNameStatusCom.chatStatusText = @"可以随时说话打断我";
            self.chatSessionState = ChatSessionState_AI_SPEAKING;
        }else if(speakStatus == 2){
            self.callVCNameStatusCom.chatStatusText= @"正在听...";
            self.chatSessionState = ChatSessionState_AI_LISTEN;
        }
    }
}

@end
