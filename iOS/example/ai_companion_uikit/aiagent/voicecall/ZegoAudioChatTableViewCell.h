//
//  ZegoAudioChatTableViewCell.h
//
//  Created by zego on 2024/5/13.
//  Copyright © 2024 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#define CELL_TOP_MARGIN 16
@class ZegoAudioChatMsgModel;
NS_ASSUME_NONNULL_BEGIN
@interface ZegoAudioChatTableViewCell : UITableViewCell
@property (nonatomic, strong) ZegoAudioChatMsgModel *msgModel;
@property (nonatomic, assign) BOOL isSelected;
@end

NS_ASSUME_NONNULL_END
