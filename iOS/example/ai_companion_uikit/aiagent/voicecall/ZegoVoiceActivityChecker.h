#import <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

@interface VadCheckerInfo : NSObject
@property (nonatomic, assign) float weightAverage;
@property (nonatomic, assign) BOOL voiceActivity;
@property (nonatomic, assign) int64_t checkSeq;
@end

@interface ZegoVoiceActivityChecker : NSObject
- (instancetype)init;
- (VadCheckerInfo*)voiceActivityDetection:(NSUInteger)vadValue; //返回值判断是否检测到声音
@end
