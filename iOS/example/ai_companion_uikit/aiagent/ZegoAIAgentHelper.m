//
//  ZegoAIAgentHelper.m
//
//  Created by zego on 2024/3/13.
//  Copyright © 2024 Zego. All rights reserved.
//
#import "ZegoAIAgentHelper.h"
#import "ZegoAIComponionMainView.h"
#import "AppDataManager.h"
#include "AIAgentLogUtil.h"
@import YYKit;
@import ZIMKit;

@interface ZegoAIAgentHelper ()<ZIMKitLogDelegate>
@end
static ZegoAIAgentHelper *_sharedInstance;
@implementation ZegoAIAgentHelper
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
    
    ZIMKitConfig* zimKitConfig = [[ZIMKitConfig alloc]init];
    zimKitConfig.bottomConfig.smallButtons_OC=@[];

    //这里会决定聊天消息输入框默认提示文本
    NSString* originStr = @"一起聊聊天吧（文生图，拍照识图等功能，敬请期待）";
    NSMutableAttributedString *inputPlaceholder = [[NSMutableAttributedString alloc] initWithString:originStr];
    NSDictionary *attrDict = @{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size:15],NSForegroundColorAttributeName: [UIColor colorWithRed:142/255.0 green:144/255.0 blue:147/255.0 alpha:1/1.0]};
    [inputPlaceholder addAttributes: attrDict range:NSMakeRange(0, 6)];
    NSDictionary *attrDict2 = @{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size:12],NSForegroundColorAttributeName: [UIColor colorWithRed:142/255.0 green:144/255.0 blue:147/255.0 alpha:1/1.0]};
    [inputPlaceholder addAttributes: attrDict2 range:NSMakeRange(6, originStr.length-6)];
    zimKitConfig.inputPlaceholder =inputPlaceholder;
    
    zimKitConfig.advancedConfig = @{ZIMKitAdvancedKey.showLoadingWhenSend : @"1", ZIMKitAdvancedKey.navigationBarShadowColor: UIColorHex(0xE6E6E6)};
    [ZIMKit initWithAppID:appID appSign:appSign config:zimKitConfig];
    [ZIMKit registerZIMKitLogDelegate:self];
    
    
    [[AppDataManager sharedInstance] setConfigInfo:appID
                                       withAppSign:appSign
                                  withServerSecret:serverSecret
                                        withUserId:userId
                                      withUsername:userName
                                     withAvatarUrl:avatarUrl];

    ZegoAIComponionMainView* mainView = [[ZegoAIComponionMainView alloc]initWithFrame:containerVC.view.bounds];
    [containerVC.view addSubview:mainView];
}

-(void)unInitAIComanion{
    
}
-(long)getCurrentAppID{
    return [AppDataManager sharedInstance].appID;
}

-(NSString*)getCurrentUserID{
    return [AppDataManager sharedInstance].userID;
}

#pragma ZIMKitLogDelegate zimkit的日志委托接口
-(void)writeLog:(enum ZIMKitLogLevel)level msg:(NSString *)msg{
    [[AIAgentLogUtil sharedInstance] logTraceMsg:(int)level msg:msg];
}

@end
