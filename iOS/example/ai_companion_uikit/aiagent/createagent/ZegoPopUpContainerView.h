//
//  ZegoPopUpContainerView.h
//
//  Created by zego on 2024/9/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZegoPopUpContainerViewDelegate <NSObject>
-(void)onRequestDismiss:(UIView*)curPopupView;
@end

@interface ZegoPopUpContainerView : UIView
@property (readwrite, nonatomic, weak) id<ZegoPopUpContainerViewDelegate> delegate;
-(void)display:(UIView*)parentContainer popUpView:(UIView*)popUp topOffset:(CGFloat)offset;
-(void)dismiss;
@end

NS_ASSUME_NONNULL_END
