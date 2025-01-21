//
//  ZegoGenderSelectView.h
//
//  Created by zego on 2024/9/9.
//

#import <UIKit/UIKit.h>
#import "AppDataManager.h"
@protocol ZegoGenderSelectViewDelegate <NSObject>
@optional
-(void)onRequestDismissGenderSelector;
@end
NS_ASSUME_NONNULL_BEGIN
@interface ZegoGenderSelectView : UIView
@property (nonatomic, strong)NSString *selectGender;
@property (nonatomic, weak, nullable) id <ZegoGenderSelectViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
