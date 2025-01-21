//
//  CustomCollectionViewCell.h
//
//  Created by zego on 2024/9/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface ZegoCustomCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) BOOL isSelected;
@end

NS_ASSUME_NONNULL_END
