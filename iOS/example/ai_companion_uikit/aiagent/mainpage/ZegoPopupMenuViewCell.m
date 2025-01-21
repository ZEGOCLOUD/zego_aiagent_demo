//
//  ZegoPopupMenuViewCell.m
//
//  Created by zego on 2024/3/13.
//  Copyright © 2024 Zego. All rights reserved.
//


#import "ZegoPopupMenuViewCell.h"
#import <Masonry/Masonry.h>
#include "ZegoPopupMenuItem.h"

@interface ZegoPopupMenuViewCell ()
@property (nonatomic, strong, readwrite) UIImageView *headIcon;
@property (nonatomic, strong, readwrite) UILabel *text;
@property (nonatomic, strong, readwrite) UIImageView *rearIcon;
@property (nonatomic, strong, readwrite) UIImageView *comingIcon;
@end

@implementation ZegoPopupMenuViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
}

-(void)setMenuItem:(ZegoPopupMenuItem*)menuItem{
    // 清除所有子视图
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    self.backgroundColor = [UIColor whiteColor];
    
    _menuItem = menuItem;
    UIImageView *imageView = nil;
    if (menuItem.image) {
        imageView = menuItem.image;
        imageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(14);
            make.width.mas_equalTo(20);
            make.height.mas_equalTo(20);
            make.centerY.equalTo(self);
        }];
    }
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = menuItem.title;
    titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:14];
    titleLabel.textAlignment = menuItem.alignment;
    titleLabel.textColor = menuItem.foreColor ? menuItem.foreColor :[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1/1.0];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.autoresizingMask = UIViewAutoresizingNone;
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        UIView* temp = imageView ? imageView :self;
        make.left.equalTo(temp.mas_right).offset(8);
        make.centerY.equalTo(temp);
    }];
    
    self.rearIcon = [[UIImageView alloc]init];
    self.rearIcon.contentMode = UIViewContentModeScaleToFill;
    self.rearIcon.image = [UIImage imageNamed:@"icon_chose"];
    self.rearIcon.hidden = YES;
    [self addSubview:self.rearIcon];
    [self.rearIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(24);
        make.height.mas_equalTo(24);
        make.right.equalTo(self).offset(-14);
        make.centerY.equalTo(self);
    }];
    
    _canUse = menuItem.canUse;
    
    if(!menuItem.canUse){
        self.comingIcon = [[UIImageView alloc]init];
        self.comingIcon.contentMode = UIViewContentModeScaleToFill;
        self.comingIcon.image = [UIImage imageNamed:@"pic_coming"];
        self.comingIcon.hidden = NO;
        [self addSubview:self.comingIcon];
        [self.comingIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(36);
            make.height.mas_equalTo(14);
            make.right.equalTo(self).offset(-10);
            make.centerY.equalTo(self);
        }];
    }
    
//    self setse
}

-(void)setIsSelected:(BOOL)isSelected{
    [super setSelected:isSelected];
    _isSelected = isSelected;
    if(self.showRearIcon){
        if (isSelected) {
            self.rearIcon.hidden = NO;
        } else {
            self.rearIcon.hidden = YES;
        }
    }
}
@end
