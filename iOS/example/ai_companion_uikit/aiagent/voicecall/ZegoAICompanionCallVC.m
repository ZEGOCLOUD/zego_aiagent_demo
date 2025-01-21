//
//  ZegoAICompanionCallVC.m
//
//  Created by zego on 2024/5/13.
//  Copyright © 2024 Zego. All rights reserved.
//

#import "ZegoAICompanionCallVC.h"
#import <Masonry/Masonry.h>
#import <YYKit/UIImageView+YYWebImage.h>
#import <ZegoExpressEngine/ZegoExpressEngine.h>
#import "AppDataManager.h"
#import "ZegoAiCompanionHttpHelper.h"
#import "UIView+Toast.h"
#import "ZegoAudioChatTableViewCell.h"
#import "ZegoAiCompanionHttpHelper.h"
#import "ZegoAudioChatMsgModel.h"
#import "ZegoAICompanionSettingsView.h"
#import "ZegoSettingsContainerView.h"
#import "ZegoAiCompanionUtil.h"
#import "UIView+Toast.h"
#import "PerfStaticsHelper.h"
#import "ZegoStaticsLogView.h"
#import "AIAgentLogUtil.h"
#import "PlayAudioRecorderUtil.h"
#import "ZegoVoiceActivityChecker.h"
#import "ZegoAudioChatTableView.h"
#import "ZegoCallVCNameUIComponent.h"

@interface ZegoAICompanionCallVC ()<ZegoStaticsLogViewDelegate>
{
}

@property (nonatomic, strong) AskAnswerStatics* askAnswerStatics;

//问题定位工具
@property (nonatomic, strong) ZegoStaticsLogView* zegoStaticsLogView;

@property (nonatomic, strong) UILabel *counterLabel;
@property (nonatomic, strong) NSTimer *timer;



//下面是用来实现基于VAD本地快速静音逻辑
@property (nonatomic, strong) ZegoVoiceActivityChecker* vadChecker;
@property (nonatomic, assign) BOOL localMuteFlag;

@end

@implementation ZegoAICompanionCallVC
-(instancetype)init{
    if(self = [super init]){
        //添加一个外部开关控制本地静音逻辑
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(switchLocalMuteClick:)
                                                     name:@"switch_local_mute" object:nil];
        self.localMuteFlag = NO;
    }
    return self;
}

-(void)dealloc{
    //关闭VAD
    [[ZegoExpressEngine sharedEngine] stopSoundLevelMonitor];
}

-(void)viewDidLoad{
    [super viewDidLoad];

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(handlelongGesture:)];
    longPress.minimumPressDuration = 2.0;
    [self.view addGestureRecognizer:longPress];
    
    [self setupStaticsLogView]; //用来定位问题的，接入方请注释
    
    // 初始化计数器标签
    self.counterLabel = [[UILabel alloc] init];
    self.counterLabel.textAlignment = NSTextAlignmentLeft;
    self.counterLabel.font = [UIFont systemFontOfSize:16];
    self.counterLabel.textColor =  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1/1.0];
    self.counterLabel.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.counterLabel];
    self.counterLabel.hidden = YES;
    
    [self.counterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(25);
        make.top.equalTo(self.callVCNameStatusCom.mas_bottom).offset(10);
        make.left.equalTo(self.callVCNameStatusCom.mas_right);
    }];
}

// 初始化引擎,子类重载
-(void)initZegoExpressEngine{
    [super initZegoExpressEngine];
//    默认这个VAD侦听逻辑关闭
    ZegoSoundLevelConfig* soundLevelConfig = [[ZegoSoundLevelConfig alloc]init];
    soundLevelConfig.millisecond = 100;
    soundLevelConfig.enableVAD = YES;
    [[ZegoExpressEngine sharedEngine] startSoundLevelMonitorWithConfig:soundLevelConfig];
}

// 退出房间,子类重载
- (void)onLeaveButtonClicked:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)setupStaticsLogView{
    if (self.zegoStaticsLogView != nil) {
        return;
    }
    
    //用来做问题定个位的小窗
    self.zegoStaticsLogView =  [[ZegoStaticsLogView alloc] initWithRoomID:self.roomId];
    [self.view addSubview:self.zegoStaticsLogView];
    self.zegoStaticsLogView.hidden = YES;
    self.zegoStaticsLogView.delegate = self;
    
    CGFloat barH = [[UIApplication sharedApplication] statusBarFrame].size.height;
    [self.zegoStaticsLogView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(350);
        make.height.mas_equalTo(250);
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(self.view).offset(barH + 100);
    }];
}


// 显示性能监控窗口
- (void)handlelongGesture:(UILongPressGestureRecognizer*)longPress {
    [self setupStaticsLogView];
    self.zegoStaticsLogView.hidden = NO;
    self.counterLabel.hidden = NO;
    // 启动定时器
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                                   target:self
                                                 selector:@selector(updateCounter)
                                                 userInfo:nil
                                                  repeats:YES];
}

-(void)onCloseStaticsLogView{
    [self.zegoStaticsLogView removeFromSuperview];
    self.zegoStaticsLogView = nil;
    self.counterLabel.hidden = YES;
    [self.timer invalidate];
    self.timer = nil;
}

- (void)switchLocalMuteClick: (NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSNumber* isOn = userInfo[@"on"];
    if([isOn boolValue]){
        [self enableLocalMute:YES];
    }else{
        [self enableLocalMute:NO];
    }
}

- (void)enableLocalMute:(BOOL)enable {
    if (enable) {
        //开启vad
        ZegoSoundLevelConfig* soundLevelConfig = [[ZegoSoundLevelConfig alloc]init];
        soundLevelConfig.millisecond = 100;
        soundLevelConfig.enableVAD = YES;
        [[ZegoExpressEngine sharedEngine] startSoundLevelMonitorWithConfig:soundLevelConfig];
    }else{
        //关闭vad
        [[ZegoExpressEngine sharedEngine] stopSoundLevelMonitor];
    }
}

//实现该回调用来实现本地快速打断逻辑
-(void)onCapturedSoundLevelInfoUpdate:(ZegoSoundLevelInfo*)soundLevelInfo{
    VadCheckerInfo* checkerInfo = [self.vadChecker voiceActivityDetection:soundLevelInfo.vad];
//    NSLog(@"applechang-test, onCapturedSoundLevelInfoUpdate soundLevel=%f, vad=%d", soundLevelInfo.soundLevel, soundLevelInfo.vad);
    //方案一：500ms内渐隐效果静音，客户也可以自己定这个渐隐时长
    if(checkerInfo.voiceActivity &&
       self.chatSessionState == ChatSessionState_AI_SPEAKING
       && !self.localMuteFlag){
        int gradually = 100*(1-checkerInfo.weightAverage);
        ZAALogI(@"onCapturedSoundLevelInfoUpdate", @"setPlayVolume gradually=%d, soundLevel=%f, weightAverage=%f, voiceActivity=%d", gradually, soundLevelInfo.soundLevel, soundLevelInfo.vad, checkerInfo.weightAverage, checkerInfo.voiceActivity);
        [self graduallyMutePlayVolumeByTimer:500.0 checkSeq:checkerInfo.checkSeq ];//500ms内渐隐效果静音
        self.localMuteFlag = YES;
    }
    
    //方案二：基于VAD加权和做衰减静音，效果上可能没那么平滑，但能保证200～300ms内静音
    //    if(checkerInfo.voiceActivity &&
    //       self.chatSessionState == ChatSessionState_AI_SPEAKING){
    //        int gradually = 100*(1-checkerInfo.weightAverage);
    //        ZAALogI(@"onCapturedSoundLevelInfoUpdate", @"setPlayVolume gradually=%d, soundLevel=%f, weightAverage=%f, voiceActivity=%d", gradually, soundLevelInfo.soundLevel, soundLevelInfo.vad, checkerInfo.weightAverage, checkerInfo.voiceActivity);
    //        [self graduallyMutePlayVolumeByWeightAverage:checkerInfo.weightAverage];
    //    }
}

-(void)setChatSessionState:(ChatSessionState)sessionState{
    super.chatSessionState = sessionState;
    if (sessionState == ChatSessionState_AI_THINKING) {
        self.localMuteFlag = NO;
    }
}

-(void)graduallyMutePlayVolumeByWeightAverage:(float)weightAverage{
    int gradually = 100*(1-weightAverage);
    [self setPlayVolumeInternal:gradually];
}

-(void)graduallyMutePlayVolumeByTimer:(float)duration checkSeq:(int64_t)checkSeq{
    //每隔一分钟执行一次打印
    // GCD定时器
    static dispatch_source_t _timer;
    static int kOriginVolume = 100;
    static int64_t kCheckSeq = 0;
    static int kCycles = 10;  //分10次递减
    
    NSLog(@"applechang-test, graduallyMutePlayVolumeByTimer, checkSeq:%lld", checkSeq);
    
    if (_timer || kCheckSeq == checkSeq) {
        return;
    }
    kCheckSeq = checkSeq;
    
    //设置时间间隔
    NSTimeInterval period = (duration/kCycles)/1000.0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);

    // 第一次会立刻执行，然后再间隔执行
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
    kOriginVolume -= 10;
    [self setPlayVolumeInternal:kOriginVolume];
    NSLog(@"applechang-test, graduallyMutePlayVolumeByTimer:%d", kOriginVolume);
    // 事件回调
    dispatch_source_set_event_handler(_timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.chatSessionState == ChatSessionState_AI_SPEAKING) {
                kOriginVolume -= 10;
                [self setPlayVolumeInternal:kOriginVolume];
                NSLog(@"applechang-test, graduallyMutePlayVolumeByTimer:%d", kOriginVolume);
                if (kOriginVolume == 0) {
                    // 关闭定时器
                    if (_timer) {
                        dispatch_source_cancel(_timer);
                        _timer = nil;
                    }
                    kOriginVolume = 100;
                }
            }else{
                // 关闭定时器
                if (_timer) {
                    dispatch_source_cancel(_timer);
                    _timer = nil;
                }
                kOriginVolume = 100;
            }
 
        });
    });
        
    // 开启定时器
    if (_timer) {
        dispatch_resume(_timer);
    }
}

- (void)onPlayerRecvAudioSideInfo:(NSData *)data streamID:(NSString *)streamID{
    NSString* seiString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (seiString == nil) {
        return;
    }
    NSDictionary* seiDict = [ZegoAiCompanionUtil dictFromJson:seiString];
    if(seiDict == nil){
        return;
    }
    
    NSNumber* seq_id = seiDict[@"seq_id"];
    NSNumber* send_timestamp =seiDict[@"timestamp"];
    uint64_t seq_id_n = [seq_id unsignedLongLongValue];

    
    if (self.askAnswerStatics == nil) {
        self.askAnswerStatics = [[AskAnswerStatics alloc]init];
        self.askAnswerStatics.askTimestamp = 0;
        self.askAnswerStatics.answerTimestamp = 0;
    }
    
    uint64_t sendTs = [send_timestamp unsignedLongLongValue];
    ZegoNetworkTimeInfo* curNetworkTime = [[ZegoExpressEngine sharedEngine] getNetworkTimeInfo];
    uint64_t curTs = curNetworkTime.timestamp;
    self.askAnswerStatics.curTimestamp = curTs;
    self.askAnswerStatics.answerTimestamp = sendTs;
    self.askAnswerStatics.overhead = curTs - sendTs;
    self.askAnswerStatics.seq_id = seq_id_n;

    NSLog(@"applechang-onPlayerRecvAudioSideInfo, seq_id=%@, overhead=%llu ms", seq_id, self.askAnswerStatics.overhead);
    [[PerfStaticsHelper sharedInstance]pushAskAnswerStatics:self.askAnswerStatics];
    self.askAnswerStatics = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.zegoStaticsLogView reload];
    });
}

- (void)updateCounter {
    // 计算经过的时间
    ZegoNetworkTimeInfo* curNetworkTime = [[ZegoExpressEngine sharedEngine] getNetworkTimeInfo];
    uint64_t curTs = curNetworkTime.timestamp;
    // 更新标签文本
    
    NSTimeInterval time=curTs/1000.0;
    NSDate *detailDate=[NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //实例化一个NSDateFormatter对象
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
    NSString *currentDateStr = [dateFormatter stringFromDate: detailDate];
    self.counterLabel.text = currentDateStr;
}

@end
