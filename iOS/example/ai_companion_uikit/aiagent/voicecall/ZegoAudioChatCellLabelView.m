//
//  ZegoAudioChatCellLabelView.m
//
//  Created by zego on 2024/5/13.
//  Copyright © 2024 Zego. All rights reserved.
//

#import "ZegoAudioChatCellLabelView.h"
#import <Masonry/Masonry.h>
#include "ZegoAudioChatMsgModel.h"

@interface ZegoAudioChatCellLabelView ()
@property (nonatomic) UIEdgeInsets insets;
@end

@implementation ZegoAudioChatCellLabelView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.insets = UIEdgeInsetsMake(10, 12, 10, 12);
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.insets)];
}

-(void)setMsgModel:(ZegoAudioChatMsgModel*)msgModel{
    self.text = msgModel.content;
    self.numberOfLines =0;
    self.lineBreakMode = NSLineBreakByWordWrapping;
    self.font = [UIFont fontWithName:@"PingFang SC" size:15];
    self.layer.cornerRadius = 12;
    self.layer.masksToBounds = YES;
    
    if(msgModel.isMine){
        self.backgroundColor = [UIColor colorWithRed:52/255.0 green:120/255.0 blue:252/255.0 alpha:1.0];
        self.textColor = [UIColor whiteColor];
    }else{
        self.backgroundColor = [UIColor whiteColor];
        self.textColor = [UIColor blackColor];
    }
}
@end
