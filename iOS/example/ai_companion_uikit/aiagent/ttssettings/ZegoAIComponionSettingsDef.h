//
//  ZegoAIComponionSettingsDef.h
//  GoAvatar
//
//  Created by zego on 2022/10/9.
//

#import <UIKit/UIKit.h>
@class TTSConfigInfo;
@protocol ZegoAICompanionSettingsViewDelegate <NSObject>
@optional
-(void)onRequestDismiss:(BOOL)saved withTTSConfig:(TTSConfigInfo*)ttsConfig;
-(void)onRequestSwitchTTSSelectView;
-(void)onRequestSwitchSettingsView;
@end
