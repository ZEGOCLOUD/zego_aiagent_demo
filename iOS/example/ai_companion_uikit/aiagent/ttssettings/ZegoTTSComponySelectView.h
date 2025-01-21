//
//  ZegoTTSComponySelectView.h
//
//  Created by zego on 2024/9/9.
//

#import <UIKit/UIKit.h>
#import "AppDataManager.h"
#import "ZegoAIComponionSettingsDef.h"
NS_ASSUME_NONNULL_BEGIN
@interface ZegoTTSComponySelectView : UIView
@property (nonatomic, strong)NSMutableArray<TTSConfig *> *ttsList;
@property (nonatomic, strong)NSString *selectTTSId;
@property (nonatomic, weak, nullable) id <ZegoAICompanionSettingsViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
