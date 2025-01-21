//
//  ZegoAICompanionSettingsView.h
//
//  Created by zego on 2024/9/9.
//

#import <UIKit/UIKit.h>
#import "ZegoAIComponionSettingsDef.h"
#import "AppDataManager.h"
NS_ASSUME_NONNULL_BEGIN
@interface ZegoAICompanionSettingsView : UIView
-(void)setConfigInfo:(NSString*)ttsId withVoiceId:(NSString*)voiceId withLangId:(NSString*)langId;

@property (nonatomic, weak, nullable) id <ZegoAICompanionSettingsViewDelegate> delegate;
@property (nonatomic, strong) NSString* ttsId;
@end

NS_ASSUME_NONNULL_END
