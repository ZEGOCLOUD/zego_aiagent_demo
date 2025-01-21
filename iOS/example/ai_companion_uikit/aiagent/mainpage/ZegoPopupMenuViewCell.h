//
//  ZegoPopupMenuViewCell.h
//
//  Created by zego on 2024/3/13.
//  Copyright © 2024 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZegoPopupMenuItem;
NS_ASSUME_NONNULL_BEGIN
@interface ZegoPopupMenuViewCell : UITableViewCell
@property (nonatomic, strong) ZegoPopupMenuItem *menuItem;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL canUse;
@property (nonatomic, assign) BOOL showRearIcon;
@end

NS_ASSUME_NONNULL_END
