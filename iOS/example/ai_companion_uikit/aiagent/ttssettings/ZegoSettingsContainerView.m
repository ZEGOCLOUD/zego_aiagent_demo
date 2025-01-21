//
//  ZegoSettingsContainerView.m
//
//  Created by zego on 2024/9/4.
//

#import "ZegoSettingsContainerView.h"
#import <Masonry/Masonry.h>
#import "ZegoAICompanionSettingsView.h"
#import "ZegoTTSComponySelectView.h"
#import "ZegoAiCompanionUtil.h"

@interface ZegoSettingsContainerView ()<ZegoAICompanionSettingsViewDelegate>
@property(nonatomic, strong)ZegoAICompanionSettingsView* settingsView;
@property(nonatomic, strong)ZegoTTSComponySelectView* ttsComponaySelectView;
@property(nonatomic, strong)TTSConfigInfo* ttsConfigInfo;
@end

@implementation ZegoSettingsContainerView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
    [self dismiss];
}
-(void)display:(UIView*)parentContainer withTTSConfig:(TTSConfigInfo*)ttsConfig{
    [parentContainer addSubview:self];
    self.ttsConfigInfo = ttsConfig;
    
    [self setupSettingsView];
    [self setupLLMSelectView];
    [self showAnimatedView:self.settingsView topOffset:SCREEN_HEIGHT - 515];
}
-(void)dismiss{
    [self closeWithAnimate:^(BOOL finished) {
        [self.delegate onCloseTTSSettingsView:NO withTTSConfig:nil];
    }];
}

- (void)setupUI {
    // 创建一个 UIView
    UIView *transparentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    transparentView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4]; // 半透明背景色
    [self addSubview:transparentView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [transparentView addGestureRecognizer:tapGesture];
    transparentView.userInteractionEnabled = YES;
}

-(void)closeWithAnimate:(void(^ __nullable)(BOOL finished))complete{
    [UIView animateWithDuration:0.2
                      delay:0.0
                    options:UIViewAnimationOptionTransitionFlipFromBottom
                     animations:^{
        self.alpha = 0.0; // 淡出效果
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
        complete(finished);
        NSLog(@"Animation completed.");
    }];
}

- (void)showAnimatedView:(UIView *)view topOffset:(CGFloat)offset{
    // 设置动画的持续时间和曲线
    [UIView animateWithDuration:0.3
                      delay:0.0
                    options:UIViewAnimationOptionCurveEaseInOut
     animations:^{
         // 动画结束时的目标位置
        view.frame = CGRectMake(0, offset, self.bounds.size.width, SCREEN_HEIGHT - offset);
     }
     completion:^(BOOL finished) {
         // 动画完成后的回调
         NSLog(@"Animation completed.");
     }];
}

- (void)setupSettingsView {
    // 创建 ZegoAICompanionSettingsView
    self.settingsView = [[ZegoAICompanionSettingsView alloc] init];
    self.settingsView.backgroundColor = [UIColor whiteColor];
    self.settingsView.layer.cornerRadius = 24;
    self.settingsView.delegate= self;
    
    [self.settingsView setConfigInfo:self.ttsConfigInfo.ttsConfig.Id withVoiceId:self.ttsConfigInfo.voiceId withLangId:@""];
    [self addSubview:self.settingsView];
    self.settingsView.frame = CGRectMake(0, SCREEN_HEIGHT, self.bounds.size.width, SCREEN_HEIGHT - 292);
}

- (void)setupLLMSelectView {
    // 创建 ZegoLLMSelectView
    self.ttsComponaySelectView = [[ZegoTTSComponySelectView alloc]init];
    self.ttsComponaySelectView.backgroundColor = [UIColor whiteColor];
    self.ttsComponaySelectView.layer.cornerRadius = 24;
    self.ttsComponaySelectView.ttsList = [AppDataManager sharedInstance].appExtraConfig.ttsList;
    self.ttsComponaySelectView.delegate = self;
    self.ttsComponaySelectView.selectTTSId = self.ttsConfigInfo.ttsConfig.Id;
    [self addSubview:self.ttsComponaySelectView];
    
    [self.ttsComponaySelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self);
        make.height.equalTo(self).offset(305);
        make.top.equalTo(self).offset(SCREEN_HEIGHT - 305);
    }];
    self.ttsComponaySelectView.hidden = YES;
}

#pragma delegate ZegoAICompanionSettingsViewDelegate
-(void)onRequestDismiss:(BOOL)saved withTTSConfig:(TTSConfigInfo*)ttsConfig{
    self.settingsView.hidden = YES;
    self.ttsComponaySelectView.hidden = YES;
    [self removeFromSuperview];
    [self.delegate onCloseTTSSettingsView:saved withTTSConfig:ttsConfig];
}

-(void)onRequestSwitchTTSSelectView{
    self.settingsView.hidden = YES;
    self.ttsComponaySelectView.hidden = NO;
}

-(void)onRequestSwitchSettingsView{
    NSString* ttsId = self.ttsComponaySelectView.selectTTSId;
    if (ttsId != self.settingsView.ttsId) {
        [self.settingsView setConfigInfo:ttsId withVoiceId:nil withLangId:nil];
    }
    self.settingsView.hidden = NO;
    self.ttsComponaySelectView.hidden = YES;
}


@end
