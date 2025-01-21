//
//  ZegoAudioChatTableViewCell.m
//
//  Created by zego on 2024/5/13.
//  Copyright © 2024 Zego. All rights reserved.
//

#import "ZegoAudioChatTableViewCell.h"
#import <Masonry/Masonry.h>
#import "ZegoAudioChatMsgModel.h"
#import "ZegoAudioChatCellLabelView.h"

@interface ZegoAudioChatTableViewCell ()
@property (nonatomic, strong, readwrite) ZegoAudioChatCellLabelView *text;
@end

@implementation ZegoAudioChatTableViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.backgroundColor = [UIColor clearColor];
}

-(void)setMsgModel:(ZegoAudioChatMsgModel*)msgModel{
    // 清除所有子视图
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    self.text = [[ZegoAudioChatCellLabelView alloc]init];
    [self.text setMsgModel:msgModel];
    [self addSubview:self.text];

    if (msgModel.isMine) {
        [self.text mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(msgModel.boundingBox.size.width);
            make.height.mas_equalTo(msgModel.boundingBox.size.height);
            make.right.equalTo(self).offset(-20);
            make.centerY.equalTo(self).offset(CELL_TOP_MARGIN);
        }];
    }else{
        [self.text mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(msgModel.boundingBox.size.width);
            make.height.mas_equalTo(msgModel.boundingBox.size.height);
            make.left.equalTo(self).offset(20);
            make.centerY.equalTo(self).offset(CELL_TOP_MARGIN);
        }];
    }
}
@end
