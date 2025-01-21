//
//  ZegoCustomNavBarHeaderView.h
//
//  Created by zego on 2024/9/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoCustomNavBarHeaderView : UIView
@end

@interface LLMItemView : UIView
-(instancetype)initWith:(NSString*)iconUrl llmText:(NSString*)text;
-(void)updateUI:(NSString*)iconUrl llmText:(NSString*)text;
@end

NS_ASSUME_NONNULL_END
