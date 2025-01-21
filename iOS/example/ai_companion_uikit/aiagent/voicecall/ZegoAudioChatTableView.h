//
//  ZegoAudioChatTableView.h
//
//  Created by zego on 2024/5/13.
//  Copyright © 2024 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZegoAudioChatMsgModel;
NS_ASSUME_NONNULL_BEGIN
@interface ZegoAudioChatTableView : UITableView
-(void)handleRecvAsrChatMsg:(NSDictionary*)msgDict;
-(void)handleRecvLLMChatMsg:(NSDictionary*)msgDict;
@end

NS_ASSUME_NONNULL_END
