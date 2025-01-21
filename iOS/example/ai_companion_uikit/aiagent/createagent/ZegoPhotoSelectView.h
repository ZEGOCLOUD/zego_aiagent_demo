//
//  ZegoGenderSelectView.h
//
//  Created by zego on 2024/9/9.
//

#import <UIKit/UIKit.h>
#import "AppDataManager.h"
@protocol ZegoPhotoSelectViewDelegate <NSObject>
@optional
-(void)onRequestDismissPhotoSelector:(UIImage*)image imageLocalUrl:(NSString*)localUrl;
@end
NS_ASSUME_NONNULL_BEGIN
@interface ZegoPhotoSelectView : UIView
@property (nonatomic, strong)NSString *photoPath;
@property (nonatomic, weak, nullable) id <ZegoPhotoSelectViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
