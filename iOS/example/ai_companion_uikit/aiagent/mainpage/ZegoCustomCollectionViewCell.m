//
//  CustomCollectionViewCell.m
//
//  Created by zego on 2024/9/4.
//

#import "ZegoCustomCollectionViewCell.h"
#import <Masonry/Masonry.h>

@interface ZegoCustomCollectionViewCell ()
@end

@implementation ZegoCustomCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    self.contentView.backgroundColor = [UIColor clearColor];
    self.contentView.layer.cornerRadius = 15;
    self.contentView.layer.shadowColor = [UIColor colorWithRed:234/255 green:234/255 blue:234/255 alpha:1.0].CGColor;
        
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    [self.contentView addSubview:self.imageView];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
        make.width.equalTo(self.contentView);
        make.height.equalTo(self.contentView);
    }];
}

-(void)setIsSelected:(BOOL)isSelected{
    [super setSelected:isSelected];
    _isSelected = isSelected;
    if (isSelected) {
        self.contentView.layer.borderColor = [UIColor blueColor].CGColor;
        self.contentView.layer.borderWidth = 2.0;
    } else {
        self.contentView.layer.borderColor = [UIColor clearColor].CGColor;
        self.contentView.layer.borderWidth = 1.0;
    }
}
@end
