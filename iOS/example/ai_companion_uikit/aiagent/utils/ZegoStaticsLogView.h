//
//  ZegoStaticsLogView.h
//
//  Created by zego on 2024/9/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ZegoStaticsLogViewDelegate <NSObject>
-(void)onCloseStaticsLogView;
@end
@interface ZegoStaticsLogView : UIView
-(instancetype)initWithRoomID:(NSString*)roomId;
@property (readwrite, nonatomic, weak) id<ZegoStaticsLogViewDelegate> delegate;
-(void)reload;
@end

NS_ASSUME_NONNULL_END
