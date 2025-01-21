//
//  ZegoCustomNavBarHeaderView.m
//
//  Created by zego on 2024/9/4.
//

#import "ZegoCustomNavBarHeaderView.h"
#import <Masonry/Masonry.h>
#import <YYKit/UIImageView+YYWebImage.h>
#import "AppDataManager.h"
#import "ZegoAiCompanionHttpHelper.h"
#import "UIView+Toast.h"
#import "ZegoAICompanionCallVC.h"
#import "ZegoPopupMenuItem.h"
#import "ZegoPopupMenuWindow.h"
#import "ZegoAIComUpdateAIAgentVC.h"
#import "ZegoAiCompanionUtil.h"

@import ZIMKit;
@import ZIM;



@interface LLMItemView()
@property (nonatomic, strong) UIImageView* llmIconView;
@property (nonatomic, strong) UILabel* llmTextLabel;
@property (nonatomic, strong) UIImageView* switchArronIcon;
@property (nonatomic, strong) NSString* iconUrl;
@property (nonatomic, strong) NSString* text;
@end

@implementation LLMItemView
-(instancetype)initWith:(NSString*)iconUrl llmText:(NSString*)text{
    if(self = [super init]){
        self.iconUrl = iconUrl;
        NSString* truncateText = text;
        if ([text containsString:@"minimax"]) {
            NSArray<NSString *>* textArray = [text componentsSeparatedByString:@"-"]; //"minimax-6.5t"针对超长的问题
            truncateText = textArray[0];
        }

        self.text = truncateText;

        CGFloat scale = [UIScreen mainScreen].scale;
        self.layer.cornerRadius = 16;
        self.layer.borderColor = [[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0] CGColor];
        self.layer.borderWidth = 1.0 / 1;  // 1pt = 1/72 inch
        
        self.llmIconView = [[UIImageView alloc]init];
        NSURL* url = [NSURL URLWithString:iconUrl];
        [self.llmIconView setImageWithURL:url placeholder:nil];
        [self addSubview:self.llmIconView];
        
        self.llmTextLabel = [[UILabel alloc]init];
        self.llmTextLabel.text = self.text;
        self.llmTextLabel.font = [UIFont fontWithName:@"PingFang SC" size:12];
        self.llmTextLabel.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1/1.0];
        [self addSubview:self.llmTextLabel];
        
        // 添加icon_change.png
        self.switchArronIcon = [[UIImageView alloc] init];
        self.switchArronIcon.contentMode = UIViewContentModeScaleToFill;
        self.switchArronIcon.image = [UIImage imageNamed:@"icon_change"];
        [self addSubview:self.switchArronIcon];
        
    }
    return self;
}

-(void)updateUI:(NSString*)iconUrl llmText:(NSString*)text{
    NSString* truncateText = text;
    if ([text containsString:@"minimax"]) {
        NSArray<NSString *>* textArray = [text componentsSeparatedByString:@"-"]; //"minimax-6.5t"针对超长的问题
        truncateText = textArray[0];
    }
    self.text = truncateText;
    self.iconUrl = iconUrl;

    NSURL* url = [NSURL URLWithString:iconUrl];
    [self.llmIconView setImageWithURL:url placeholder:nil];
    self.llmTextLabel.text = self.text;
    [self layoutIfNeeded];
}

- (void)layoutSubviews{
    // 添加约束
    [self.llmIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.width.mas_equalTo(14);
        make.height.mas_equalTo(14);
        make.centerY.equalTo(self);
    }];
    
    [self.llmTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.llmIconView.mas_right).offset(1);
        make.centerY.equalTo(self);
    }];
    
    [self.switchArronIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.llmTextLabel.mas_right).offset(1);
//        make.right.equalTo(self).offset(-8);
        make.width.mas_equalTo(12);
        make.height.mas_equalTo(12);
        make.centerY.equalTo(self);
    }];
}
@end


@interface ZegoCustomNavBarHeaderView ()<ZIMKitDelegate, ZIMKitMessagesListVCDelegate>
@property (nonatomic, strong) LLMItemView *curLLMItemView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UIImageView *moreImg;
@property (nonatomic, strong) UIImageView *myAudioChatImg;
//@property (nonatomic, strong) ZegoSendCallInvitationButton *audioChatImg;
@end

@implementation ZegoCustomNavBarHeaderView

-(instancetype)init{
    if(self = [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConversationSuccess:) name:@"updateConversationSuccess" object:nil];
        CharacterConfig* curCharacter = [[AppDataManager sharedInstance] getCurrentCharacter];
        CustomAgentConfig* customAgentConfig = curCharacter.curAgentConfig;
        RawProperties* llmProp = customAgentConfig.llm;
        LLMConfig* curRolellmConfig = [[AppDataManager sharedInstance].appExtraConfig getLLMConfigByProperties:llmProp];
        self.curLLMItemView = [[LLMItemView alloc] initWith:curRolellmConfig.icon llmText:curRolellmConfig.name];
        [self addSubview:self.curLLMItemView];
        // 设置点击事件
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickNavBarChangeLLM:)];
        [self.curLLMItemView addGestureRecognizer: tapGesture];
        [self.curLLMItemView  setUserInteractionEnabled:YES];
        
        self.userNameLabel = [[UILabel alloc] init];
        CharacterConfig* chacterConfig = [AppDataManager sharedInstance].curCharacterConfig;
        NSString* userName = chacterConfig.curAgentConfig.Name;
        NSString* ellipsisName = [ZegoAiCompanionUtil trimStringEllipsis:userName limitCount:4];
        self.userNameLabel.text = ellipsisName;
        self.userNameLabel.textAlignment = NSTextAlignmentCenter;

        self.userNameLabel.font = [UIFont fontWithName:@"PingFang SC" size:18];
        self.userNameLabel.textColor = [UIColor colorWithRed:42/255.0 green:42/255.0 blue:42/255.0 alpha:1/1.0];
        [self addSubview:self.userNameLabel];
        
        
        // 添加更多功能按钮
        self.moreImg =  [[UIImageView alloc] init];
        self.moreImg.contentMode = UIViewContentModeScaleToFill;
        self.moreImg.image = [UIImage imageNamed:@"icon_more"];
        [self addSubview:self.moreImg];
        
        self.moreImg.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickNavBarMoreImg:)];
        [self.moreImg addGestureRecognizer:tapGestureRecognizer1];
        
        // 添加邀请语音聊天
//        self.audioChatImg = [[ZegoSendCallInvitationButton alloc]init:0];
//        self.audioChatImg.icon = [UIImage imageNamed:@"icon_audio"];
//        self.audioChatImg.resourceID = @"call_domestic";
//        NSString *roomId = [[[AppDataManager sharedInstance].appExtraConfig getCurrentCharacter] getRoomID];
//        self.audioChatImg.callID = roomId;
//        ZegoUIKitUser* user = [[ZegoUIKitUser alloc]init:curCharacter.robotID :curCharacter.name :NO :NO];
//        self.audioChatImg.inviteeList =  @[user];
//        [self addSubview:self.audioChatImg];
        
        self.myAudioChatImg = [[UIImageView alloc]init];
        self.myAudioChatImg.contentMode = UIViewContentModeScaleToFill;
        self.myAudioChatImg.image = [UIImage imageNamed:@"icon_audio"];
        self.myAudioChatImg.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickNavBarAudioChat:)];
        [self.myAudioChatImg addGestureRecognizer:tapGestureRecognizer2];
        [self addSubview:self.myAudioChatImg];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateConversationSuccess: (NSNotification *)notification {
    CharacterConfig* chacterConfig = [AppDataManager sharedInstance].curCharacterConfig;
    NSString* userName = chacterConfig.curAgentConfig.Name;
    NSString* ellipsisName = [ZegoAiCompanionUtil trimStringEllipsis:userName limitCount:4];
    self.userNameLabel.text = ellipsisName;
    [ZIMKit updateOtherUserInfoWithUserID:chacterConfig.agentId :chacterConfig.curAgentConfig.Avatar:chacterConfig.curAgentConfig.Name];
}

- (void)layoutSubviews{
    [self.curLLMItemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(98);
//        make.width.mas_equalTo(120);
        make.height.mas_equalTo(28);
        make.centerY.equalTo(self);
    }];
    
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.superview);
        make.centerY.equalTo(self);
    }];
    
    [self.moreImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
        make.centerY.equalTo(self);
        make.right.equalTo(self);
    }];
    
    [self.myAudioChatImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
        make.centerY.equalTo(self);
        make.right.equalTo(self.moreImg.mas_left).offset(-4);
    }];
    
//    [self.audioChatImg mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(20);
//        make.height.mas_equalTo(20);
//        make.centerY.equalTo(self);
//        make.right.equalTo(self.myAudioChatImg.mas_left).offset(-4);
//    }];
}

- (void)onClickNavBarChangeLLM:(UIGestureRecognizer *) recognizer {
    NSArray* llmNameList = [AppDataManager sharedInstance].appExtraConfig.llmNameList;
    NSUInteger count = llmNameList.count;
    NSMutableArray* menuItems = [[NSMutableArray alloc]initWithCapacity:count];
    CharacterConfig* curCharacter = [AppDataManager sharedInstance].curCharacterConfig;
    LLMConfig* curRolellmConfig = [[AppDataManager sharedInstance].appExtraConfig getLLMConfigByProperties:curCharacter.curAgentConfig.llm];
    
    for (int i=0; i<count; i++) {
        LLMConfig* item = [llmNameList objectAtIndex:i];
        UIImageView* llmIconView = [[UIImageView alloc]init];
        NSURL* url = [NSURL URLWithString:item.icon];
        [llmIconView setImageWithURL:url placeholder:nil];
        
        ZegoPopupMenuItem *memuItem =  [[ZegoPopupMenuItem alloc] initWith:item.name
                                                                    canUse:item.isSupported
                                                                       tag:item.Id
                                                                     image:llmIconView
                                                                    target:self
                                                                    action:@selector(onClickLLVMMenuItem:)];
        if ([item.Id isEqualToString: curRolellmConfig.Id]) {
            memuItem.initSelected = YES;
        }else{
            memuItem.initSelected = NO;
        }
        
        [menuItems addObject:memuItem];
    }
    
    
    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
    UIViewController *topViewController = keyWindow.rootViewController;
    CGRect frame = [self.curLLMItemView convertRect:self.curLLMItemView.bounds toView:nil];
    ZegoPopupMenuConfig* config = [[ZegoPopupMenuConfig alloc]init];
    config.width = 200;
    config.topMargin = 12;
    config.cellShowRearIcon = YES;
    [[ZegoPopupMenuWindow shareInstance] showMenuInView:topViewController.view fromRect:frame menuItems:menuItems config:config];
    NSLog(@"onClickChangeLLM");
}

-(void)onClickLLVMMenuItem:(id)menuItem{
    ZegoPopupMenuItem* item = (ZegoPopupMenuItem*)menuItem;
    NSString* llvmId = item.tag;
    
    LLMConfig* llmConfig = [[AppDataManager sharedInstance].appExtraConfig getLLMConfigById:llvmId];

    CharacterConfig* characterConfig = [AppDataManager sharedInstance].curCharacterConfig;
    if ([llmConfig.rawProperties isLLMEqualToOther:characterConfig.curAgentConfig.llm]) {
        return;
    }
    
    //临时保存，防止服务请求失败
    RawProperties* temp = characterConfig.curAgentConfig.llm;
    //更新内存中llm.rawProperties
    characterConfig.curAgentConfig.llm = llmConfig.rawProperties;
    NSString* userId = [AppDataManager sharedInstance].userID;
    
    [[ZegoAiCompanionHttpHelper sharedInstance] updateConversation:characterConfig.conversationId
                                                        withUserId:userId
                                                   withAgentTempId:characterConfig.curAgentConfig.AgentTemplateId
                                                  withCustomConfig:characterConfig.curAgentConfig withCallback:^(NSInteger errorCode, NSString *errMsg, NSString* requestId) {
        if (errorCode != 0) {
            NSString* errorMsg =[NSString stringWithFormat:@"更新配置失败:%@", errMsg];
            [self makeToast:errorMsg];
            characterConfig.curAgentConfig.llm = temp;
        }else{
            [self.curLLMItemView updateUI:llmConfig.icon llmText:llmConfig.name];
        }
    }];
}


- (void)onClickNavBarAudioChat:(UIGestureRecognizer *) recognizer {
    ZegoAICompanionCallVC* vc = [[ZegoAICompanionCallVC alloc]init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
    UIViewController *topViewController = keyWindow.rootViewController;
    [topViewController presentViewController:vc animated:YES completion:^{}];
}

- (void)onClickNavBarMoreImg:(UIGestureRecognizer *) recognizer {
    
    NSMutableArray* menuItems = [[NSMutableArray alloc]initWithCapacity:2];
    
    UIImageView* setAIAgentIconView = [[UIImageView alloc]init];
    setAIAgentIconView.contentMode = UIViewContentModeScaleAspectFit;
    setAIAgentIconView.image = [UIImage imageNamed:@"icon_edit"];
    
    ZegoPopupMenuItem* memuItem0 =  [[ZegoPopupMenuItem alloc] initWith:@"智能体设定"
                                             canUse:YES
                                                tag:@""
                                              image:setAIAgentIconView
                                             target:self
                                             action:@selector(onClickUpdateAIAgent:)];
    [menuItems addObject:memuItem0];
    
    UIImageView* clearContextIconView = [[UIImageView alloc]init];
    clearContextIconView.contentMode = UIViewContentModeScaleAspectFit;
    clearContextIconView.image = [UIImage imageNamed:@"icon_clean"];
    
    ZegoPopupMenuItem *memuItem =  [[ZegoPopupMenuItem alloc] initWith:@"清除上下文"
                                                                canUse:YES
                                                                   tag:@""
                                                                 image:clearContextIconView
                                                                target:self
                                                                action:@selector(onClickCleanContextMenuItem:)];
    [menuItems addObject:memuItem];
    

    
    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
    UIViewController *topViewController = keyWindow.rootViewController;
    CGRect frame = [recognizer.view convertRect:recognizer.view.bounds toView:nil];
    ZegoPopupMenuConfig* config = [[ZegoPopupMenuConfig alloc]init];
    config.width = 130;
    config.topMargin = 6;
    config.cellShowRearIcon = NO;
    [[ZegoPopupMenuWindow shareInstance] showMenuInView:topViewController.view fromRect:frame menuItems:menuItems config:config];
    NSLog(@"onClickMoreImg");
}

-(void)onClickUpdateAIAgent:(id)menuItem{
    CharacterConfig* characterConfig = [AppDataManager sharedInstance].curCharacterConfig;
    NSString* conversationId = characterConfig.conversationId;
    ConversionConfigInfo* curConversion = [[AppDataManager sharedInstance] getConversationConfigById:conversationId];

    
    ZegoAIComUpdateAIAgentVC* vc = [[ZegoAIComUpdateAIAgentVC alloc]init];
    vc.isDefaultRole = curConversion.isDefAgenttemplated ;
    
    vc.needAddNavBackIcon = YES;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
    UIViewController *topViewController = keyWindow.rootViewController;
    [topViewController presentViewController:vc animated:YES completion:^{}];
    [[ZegoPopupMenuWindow shareInstance] dismissMenu];
}

-(void)onClickCleanContextMenuItem:(id)menuItem{
    CharacterConfig* characterConfig = [AppDataManager sharedInstance].curCharacterConfig;
    NSString* conversationId = characterConfig.conversationId;
    NSString* userId = [AppDataManager sharedInstance].userID;
    [[ZegoAiCompanionHttpHelper sharedInstance] resetConversationMsg:conversationId
                                                          withUserId:userId
                                                        withCallback:^(NSInteger errorCode, NSString *errMsg, NSString* requestId) {
        if (errorCode == 0) {
            CharacterConfig* currentConfig = [AppDataManager sharedInstance].curCharacterConfig;
            NSString* conversationID = currentConfig.agentId;
            NSString* userId = [AppDataManager sharedInstance].userID;
            [ZIMKit insertSystemMessage:@"开启新会话" conversationID:conversationID groupConversation:NO];
        }else{
            NSString* errorMsg =[NSString stringWithFormat:@"清除上下文失败:%@", errMsg];
            [self makeToast:errorMsg];
        }
    }];
    [[ZegoPopupMenuWindow shareInstance] dismissMenu];
}

@end
