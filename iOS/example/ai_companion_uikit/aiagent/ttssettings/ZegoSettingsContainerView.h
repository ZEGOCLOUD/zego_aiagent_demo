//
//  ZegoSettingsContainerView.h
//
//  Created by zego on 2024/9/9.
//

#import <UIKit/UIKit.h>
#import "ZegoAIComponionSettingsDef.h"
#import "AppDataManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZegoSettingsContainerViewDelegate <NSObject>
-(void)onCloseTTSSettingsView:(BOOL)saved withTTSConfig:(TTSConfigInfo*)ttsConfig;
@end

@interface ZegoSettingsContainerView : UIView
@property (readwrite, nonatomic, weak) id<ZegoSettingsContainerViewDelegate> delegate;
-(void)display:(UIView*)parentContainer withTTSConfig:(TTSConfigInfo*) ttsConfig;
-(void)dismiss;
@end

NS_ASSUME_NONNULL_END
