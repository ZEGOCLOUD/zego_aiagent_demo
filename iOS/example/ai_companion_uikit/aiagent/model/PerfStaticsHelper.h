//
//  PerfStaticsHelper.h
//  ai_companion_oc
//
//  Created by zego on 2024/8/28.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface AskAnswerStatics : NSObject
@property (nonatomic, assign)uint64_t overhead;
@property (nonatomic, assign)uint64_t seq_id;
@property (nonatomic, assign)uint64_t askTimestamp;
@property (nonatomic, assign)uint64_t answerTimestamp;
@property (nonatomic, assign)uint64_t curTimestamp;
//@property (nonatomic, assign)uint64_t threshold;
@end

@interface PerfStaticsHelper : NSObject
+ (instancetype)sharedInstance;
- (void)pushAskAnswerStatics:(AskAnswerStatics*)item;
- (void)clearAskAnswerStatics;
@property (nonatomic, assign)uint64_t firstAskAnswerOverHead;
@property (nonatomic, assign)uint64_t maxAskAnswerOverHead;
@property (nonatomic, assign)uint64_t minAskAnswerOverHead;
@property (nonatomic, assign)uint64_t meanAskAnswerOverHead;
@property (nonatomic, assign)uint64_t curAskAnswerOverHead;
@property (nonatomic, strong)AskAnswerStatics* lastAskAnswerStatics;
@property (nonatomic, assign)uint64_t askAnswerCounts;
@property (nonatomic, strong)NSMutableArray<AskAnswerStatics*>* askAnswerStaticsList;
@end
