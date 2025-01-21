//
//  ZegoAIComCreateAIAgentVC.h
//
//  Created by zego on 2024/5/13.
//  Copyright © 2024 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZegoInsetsLabelView.h"
#import "ZegoSettingsContainerView.h"
#import "AppDataManager.h"
#import "ZegoAutoAdjustTextView.h"

typedef enum _FillItemsState{
    AIAgentFillItems_None = 0,
    AIAgentFillItems_Avatar = 1<<0,
    AIAgentFillItems_Name   = 1<<1,
    AIAgentFillItems_Gender = 1<<2,
    AIAgentFillItems_Intro = 1<<3,
    AIAgentFillItems_CreateNecessary = ((1<<0) + (1<<1) + (1<<2)),
    AIAgentFillItems_Boundary = ((1<<0) + (1<<1) + (1<<2) + (1<<3)),
} FillItemsState;


NS_ASSUME_NONNULL_BEGIN

@interface ZegoAIComCreateAIAgentVC : UIViewController
@property (nonatomic, strong) UILabel *pageTitle;
@property (nonatomic, strong) UIView *nameBg;
@property (nonatomic, strong) UILabel *nameTitle;
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UIButton *createAIAgentBtn;
@property (nonatomic, strong) UIImageView* PlusIcon;
@property (nonatomic, strong) UIImageView* headAvatar;
@property (nonatomic, strong) UIView *voiceBg;
@property (nonatomic, strong) UILabel *voiceTitle;
@property (nonatomic, strong) UILabel *voiceContent;
@property (nonatomic, strong) UIImageView* voiceArrow;
@property (nonatomic, strong) ZegoInsetsLabelView *tipsLabel;
@property (nonatomic, strong) ZegoSettingsContainerView* settingsContainerView;
@property (nonatomic, strong) TTSConfigInfo* ttsConfigInfo;
@property (nonatomic, strong) ZegoAutoAdjustTextView *setupContent;
@property (nonatomic, strong) UILabel *genderContent;
@property (nonatomic, strong) UIView *genderBg;
@property (nonatomic, strong) UILabel *genderTitle;
@property (nonatomic, strong) UIImageView* genderArrow;

@property (nonatomic, strong) UIView *setupBg;
@property (nonatomic, strong) UILabel *setupTitle;
@property (nonatomic, strong) UILabel *placeHolderLabel;
@property (nonatomic, strong) UIImageView* navBackIcon;

@property (nonatomic, strong) NSString *avatarOSSUrl;
@property (nonatomic, assign) BOOL needAddNavBackIcon;
@property (nonatomic, assign) FillItemsState fillItemFlag;
@property (nonatomic, copy)NSString* curGender;

-(UIColor*)getFieldTextColor;
-(UIColor*)geFieldNameColor;
-(void)addPageTitle;
-(void)addBackgroundColor;
-(void)addHeadAvatar;
-(void)addTipsLabel;
-(void)addNameComponent;
-(void)addGenderComponent;
-(void)addSettingDescComponent;
-(void)addVoiceComponent;
-(void)addCompleteComponent;
-(void)addCopyrightLabel;
-(void)setState:(FillItemsState)state withRemove:(BOOL)remove;
@end

NS_ASSUME_NONNULL_END
