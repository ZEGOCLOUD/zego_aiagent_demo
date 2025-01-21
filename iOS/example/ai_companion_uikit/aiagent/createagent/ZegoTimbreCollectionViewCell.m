//
//  ZegoTimbreCollectionViewCell.m
//
//  Created by zego on 2024/9/9.
//

#import "ZegoTimbreCollectionViewCell.h"
#import <Masonry/Masonry.h>

@interface ZegoTimbreCollectionViewCell ()
@property (nonatomic, strong) UILabel* contentLabel;
@end

@implementation ZegoTimbreCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentLabel = [[UILabel alloc]init];
        self.contentLabel.layer.cornerRadius = 10;
        self.contentLabel.clipsToBounds = YES;
        self.contentLabel.textAlignment = NSTextAlignmentCenter;
        self.contentLabel.font = [UIFont fontWithName:@"PingFang SC" size:15];
        self.contentLabel.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1/1.0];
        self.contentLabel.backgroundColor = [UIColor colorWithRed:245/255.0 green:246/255.0 blue:247/255.0 alpha:1.0];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)setItemTitle:(NSString *)itemTitle{
    // 清除所有子视图
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    [self addSubview:self.contentLabel];
    self.contentLabel.text = itemTitle;
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self);
        make.height.equalTo(self);
    }];
}

-(void)setIsSelected:(BOOL)isSelected{
    [super setSelected:isSelected];
    _isSelected = isSelected;
    if (isSelected) {
        self.contentLabel.textColor = [UIColor colorWithRed:0/255.0 green:85/255.0 blue:255/255.0 alpha:1/1.0];
        self.contentLabel.backgroundColor = [UIColor colorWithRed:225/255.0 green:235/255.0 blue:255/255.0 alpha:1.0];
    } else {
        self.contentLabel.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1/1.0];
        self.contentLabel.backgroundColor = [UIColor colorWithRed:245/255.0 green:246/255.0 blue:247/255.0 alpha:1.0];
    }
}
@end
