//
//  ZegoInsetsLabelView.m
//
//  Created by zego on 2024/5/13.
//  Copyright © 2024 Zego. All rights reserved.
//

#import "ZegoInsetsLabelView.h"
#import <Masonry/Masonry.h>

@interface ZegoInsetsLabelView ()
@property (nonatomic, assign) UIEdgeInsets insets;
@end

@implementation ZegoInsetsLabelView

- (instancetype)initWithInsets:(UIEdgeInsets)insets {
    self = [super init];
    if (self) {
        self.insets = insets;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.insets)];
}
@end
