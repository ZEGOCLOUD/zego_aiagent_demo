//
//  ZegoCallVCNameUIComponent.m
//
//  Created by zego on 2024/5/13.
//  Copyright © 2024 Zego. All rights reserved.
//

#import "ZegoCallVCNameUIComponent.h"
#import <Masonry/Masonry.h>
#import "AppDataManager.h"

@interface ZegoCallVCNameUIComponent ()
@property (nonatomic, strong)UIFont* userNameFont;
@property (nonatomic, strong)UIFont* chatStatusFont;
@property (nonatomic, assign)CGFloat minWidth;
@property (nonatomic, strong)UILabel *userNameLabel;
@property (nonatomic, strong)UILabel *chatStatusLabel;

@end

@implementation ZegoCallVCNameUIComponent

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.minWidth = 104;
        [self setupUI];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
}

-(CGRect)calculateStringLenght:(NSString *)content withFont:(UIFont*)font{
    NSDictionary *attributes = @{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName: [UIColor blackColor]
    };
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:content attributes:attributes];
    
    // 计算文本的大小
    CGSize maxSize = CGSizeMake(239, CGFLOAT_MAX);
    CGRect boundingBox = [attributedString boundingRectWithSize:maxSize
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                        context:nil];
    return boundingBox;
}

-(void)setUserNameText:(NSString *)userNameText{
    _userNameText = userNameText;
    self.userNameLabel.text = _userNameText;
    CGRect newRect = [self calculateStringLenght:_userNameText withFont:self.userNameFont];
    if (newRect.size.width + 20 > self.minWidth) {
        self.minWidth = newRect.size.width + 20;
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.minWidth);
        }];
        [self layoutIfNeeded];
    }
}

-(void)setChatStatusText:(NSString *)chatStatusText{
    _chatStatusText = chatStatusText;
    self.chatStatusLabel.text = _chatStatusText;
    CGRect newRect = [self calculateStringLenght:_chatStatusText withFont:self.chatStatusFont];
    CGFloat newWidth = newRect.size.width + 20;
    if (newWidth > self.minWidth) {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(newWidth);
        }];
    }else{
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.minWidth);
        }];
    }
    
    [self layoutIfNeeded];
}

- (void)setupUI {
    self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
    self.layer.cornerRadius = 8;
    self.layer.masksToBounds =YES;
    self.userNameLabel = [[UILabel alloc]init];
    self.userNameFont = [UIFont fontWithName:@"Pingfang-SC-Medium" size:16];
    self.userNameLabel.font = self.userNameFont;
    self.userNameLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1/1.0];
    self.userNameLabel.backgroundColor = [UIColor clearColor];
    self.userNameLabel.textAlignment = NSTextAlignmentCenter;
//    CGRect boundingBox = [self calculateStringLenght:AIRobotName withFont:self.userNameLabel.font];
    [self addSubview:self.userNameLabel];
    
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.right.equalTo(self).offset(-10);
        make.height.mas_equalTo(25);
        make.top.equalTo(self).offset(7);
//        make.centerX.equalTo(self);
    }];
    
    self.chatStatusLabel = [[UILabel alloc]init];
    self.chatStatusFont = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    self.chatStatusLabel.font = self.chatStatusFont;
    self.chatStatusLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1/1.0];
    self.chatStatusLabel.backgroundColor = [UIColor clearColor];
    self.chatStatusLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.chatStatusLabel];
    
    [self.chatStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.equalTo(self);
        make.left.equalTo(self).offset(10);
        make.right.equalTo(self).offset(-10);
        make.height.mas_equalTo(22);
        make.top.equalTo(self.userNameLabel.mas_bottom);
//        make.centerX.equalTo(self);
    }];
}

@end
