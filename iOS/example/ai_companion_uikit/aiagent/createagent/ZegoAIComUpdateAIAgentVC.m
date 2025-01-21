//
//  ZegoAIComCreateAIAgentVC.m
//
//  Created by zego on 2024/5/13.
//  Copyright © 2024 Zego. All rights reserved.
//

#import "ZegoAIComUpdateAIAgentVC.h"
#import <Masonry/Masonry.h>
#import <YYKit/UIImageView+YYWebImage.h>
#import "AppDataManager.h"
#import "ZegoAiCompanionHttpHelper.h"
#import "UIView+Toast.h"
#import "ZegoAiCompanionUtil.h"
#import "ZegoInsetsLabelView.h"
#import "ZegoPopUpContainerView.h"
#import "ZegoGenderSelectView.h"
#import "ZegoSettingsContainerView.h"
#import "ZegoAutoAdjustTextView.h"
#import "ZegoPhotoSelectView.h"
#import "AppDataManager.h"
#import "ZegoAiCompanionUtil.h"

@interface ZegoAIComUpdateAIAgentVC ()
@end

@implementation ZegoAIComUpdateAIAgentVC
-(instancetype)init{
    if(self = [super init]){
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self fillData];
}

-(void)fillData{
    CustomAgentConfig* curAgentConfig = [AppDataManager sharedInstance].curCharacterConfig.curAgentConfig;
    NSString* name = curAgentConfig.Name;
    NSString* avatar = curAgentConfig.Avatar;
    NSString* gender = curAgentConfig.Sex;
    NSString* desc = curAgentConfig.Intro;
    
    self.nameTextField.text = name;
    NSURL* avatarUrl = [NSURL URLWithString:avatar];
    [self.headAvatar setImageWithURL:avatarUrl placeholder:nil];
    
    self.genderContent.text = gender;
    self.curGender = gender;
    
    if (desc && desc.length > 0) {
        self.placeHolderLabel.hidden = YES;
        self.setupContent.text = desc;
    }
    
    if (self.isDefaultRole) {
        self.headAvatar.userInteractionEnabled = NO;
        self.PlusIcon.hidden = YES;
        self.nameTextField.enabled = NO;
        self.genderContent.userInteractionEnabled = NO;
        self.genderArrow.userInteractionEnabled = NO;
        self.setupContent.userInteractionEnabled = NO;
    }
}


-(void)addTipsLabel{
    if (!self.isDefaultRole) {
        [super addTipsLabel];
    }
}

-(void)addPageTitle{
    self.pageTitle = [[UILabel alloc]init];
    self.pageTitle.text = @"智能体设定";
    self.pageTitle.font = [UIFont fontWithName:@"Pingfang-SC-Medium" size:18];
    self.pageTitle.textColor = [UIColor colorWithRed:42/255.0 green:42/255.0 blue:42/255.0 alpha:1/1.0];
    self.pageTitle.backgroundColor = [UIColor clearColor];
    self.pageTitle.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.pageTitle];
    CGFloat barH = [[UIApplication sharedApplication] statusBarFrame].size.height;
    [self.pageTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.navBackIcon);
    }];
}


-(void)addVoiceComponent{
    //donothing
}

-(void)addCopyrightLabel{
    if (!self.isDefaultRole) {
        [super addCopyrightLabel];
    }
}

-(void)addGenderComponent{
    [super addGenderComponent];
    if (self.isDefaultRole) {
        self.genderArrow.hidden = YES;
                
        [self.genderContent mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(48);
            make.height.mas_equalTo(22);
            make.right.mas_equalTo(self.genderBg).offset(-18);
            make.centerY.equalTo(self.genderBg);
        }];
    }
}
-(UIColor*)getFieldTextColor{
    if (!self.isDefaultRole) {
        return [super getFieldTextColor];
    }else{
        return [UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1.0];
    }
}

-(void)addCompleteComponent{
    if (self.isDefaultRole) {
        return;
    }
    self.createAIAgentBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.createAIAgentBtn.layer.cornerRadius = 16;
    self.createAIAgentBtn.layer.masksToBounds = YES;
    
    self.createAIAgentBtn.enabled = NO;
    [self.createAIAgentBtn setTitle:@"       完成\n(仅自己可对话)" forState:UIControlStateNormal];
    [self.createAIAgentBtn setTitle:@"       完成\n(仅自己可对话)" forState:UIControlStateDisabled];
    self.createAIAgentBtn.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.createAIAgentBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:16];
    
    
    UIColor* normalColor = [UIColor colorWithRed:0.0 green:85/255.0 blue:255/255.0 alpha:1.0];
    UIColor* disableColor = [UIColor colorWithRed:0.0 green:85/255.0 blue:255/255.0 alpha:0.4];
    
    UIImage* normalBgImage = [ZegoAiCompanionUtil generateImageWithColor:normalColor];
    UIImage* disableBgImage = [ZegoAiCompanionUtil generateImageWithColor:disableColor];
    
    
    [self.createAIAgentBtn setBackgroundImage:normalBgImage forState:UIControlStateNormal];
    [self.createAIAgentBtn setBackgroundImage:disableBgImage forState:UIControlStateDisabled];
    
    [self.createAIAgentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.createAIAgentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [self.createAIAgentBtn addTarget:self action:@selector(updateAIAgentBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.createAIAgentBtn];
    [self.createAIAgentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(SCREEN_WIDTH - 24*2);
        make.height.mas_equalTo(52);
        make.bottom.equalTo(self.view).offset(-74);
        make.centerX.equalTo(self.view);
    }];
}

// 点击事件处理方法
- (void)updateAIAgentBtnClicked:(UIButton *)sender {
    CustomAgentConfig* curAgentConfig = [AppDataManager sharedInstance].curCharacterConfig.curAgentConfig;
    CustomAgentConfig* tempAgentConfig = [[CustomAgentConfig alloc] init];
    tempAgentConfig.Name = self.nameTextField.text;
    tempAgentConfig.Intro = self.setupContent.text;
    tempAgentConfig.Sex = self.genderContent.text;
    NSString* system = [NSString stringWithFormat:@"角色：%@\n性别：%@\n角色设定：%@\n",tempAgentConfig.Name, tempAgentConfig.Sex,tempAgentConfig.Intro];
    tempAgentConfig.System = system;
    tempAgentConfig.WelcomeMessage = curAgentConfig.WelcomeMessage;
    tempAgentConfig.Source = curAgentConfig.Source;
    tempAgentConfig.llm = curAgentConfig.llm;
    tempAgentConfig.tts = curAgentConfig.tts;
    tempAgentConfig.Avatar = self.avatarOSSUrl ? self.avatarOSSUrl : curAgentConfig.Avatar;
    tempAgentConfig.AgentTemplateId = curAgentConfig.AgentTemplateId;
    
    NSString* conversionId = [AppDataManager sharedInstance].curCharacterConfig.conversationId;
    NSString* userId = [AppDataManager sharedInstance].userID;
    [[ZegoAiCompanionHttpHelper sharedInstance] updateConversation:conversionId
                                                        withUserId:userId
                                                   withAgentTempId:tempAgentConfig.AgentTemplateId
                                                  withCustomConfig:tempAgentConfig
                                                      withCallback:^(NSInteger errorCode, NSString *errMsg, NSString *requestId) {
        if (errorCode == 0) {
            curAgentConfig.Name = tempAgentConfig.Name;
            curAgentConfig.Intro = tempAgentConfig.Intro;
            curAgentConfig.Sex = tempAgentConfig.Sex;
            curAgentConfig.System = tempAgentConfig.System;
            curAgentConfig.WelcomeMessage = tempAgentConfig.WelcomeMessage;
            curAgentConfig.Source = tempAgentConfig.Source;
            curAgentConfig.Avatar = tempAgentConfig.Avatar;
            curAgentConfig.AgentTemplateId = tempAgentConfig.AgentTemplateId;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateConversationSuccess" object:self userInfo:nil];
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }else{
            NSString* result = [NSString stringWithFormat:@"更新会话失败请重试:ec=%ld",errorCode];
            [self.view makeToast:result];
        }
    }];
}

-(void)setState:(FillItemsState)state withRemove:(BOOL)remove{
    if (remove) {
        self.fillItemFlag &= ~state;
    }else{
        self.fillItemFlag |= state;
    }
    
    if (self.fillItemFlag & AIAgentFillItems_Boundary) {
        self.createAIAgentBtn.enabled = YES;
    }else{
        self.createAIAgentBtn.enabled = NO;
    }
}

@end
