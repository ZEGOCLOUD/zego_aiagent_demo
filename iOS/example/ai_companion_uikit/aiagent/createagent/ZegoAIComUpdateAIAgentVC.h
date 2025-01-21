//
//  ZegoAIComUpdateAIAgentVC.h
//
//  Created by zego on 2024/5/13.
//  Copyright © 2024 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZegoAIComCreateAIAgentVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZegoAIComUpdateAIAgentVC : ZegoAIComCreateAIAgentVC
-(void)addPageTitle;
-(void)addVoiceComponent;
-(void)addCompleteComponent;
-(void)addCopyrightLabel;
-(void)addGenderComponent;
-(UIColor*)getFieldTextColor;
-(void)setState:(FillItemsState)state withRemove:(BOOL)remove;
@property (nonatomic, assign)BOOL isDefaultRole;
@end

NS_ASSUME_NONNULL_END
