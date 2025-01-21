//
//  PerfStaticsHelper.m
//  ai_companion_oc
//
//  Created by zego on 2024/8/28.
//

#import "PerfStaticsHelper.h"

@implementation AskAnswerStatics
@end



static PerfStaticsHelper *_sharedInstance;
@interface PerfStaticsHelper()
@end

@implementation PerfStaticsHelper

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        self.askAnswerStaticsList = [[NSMutableArray alloc]init];
        [self clearAskAnswerStatics];
    }
    return self;
}

- (void)clearAskAnswerStatics{
    [self.askAnswerStaticsList removeAllObjects];
    self.minAskAnswerOverHead = 100000;
    self.maxAskAnswerOverHead = 0;
    self.firstAskAnswerOverHead = 0;
    self.lastAskAnswerStatics = nil;
    self.curAskAnswerOverHead = 0;
    self.askAnswerCounts = 0;
}

- (void)pushAskAnswerStatics:(AskAnswerStatics*)item{
    NSInteger total = self.askAnswerStaticsList.count;
    
    for (int i=0; i<total; i++) {
        AskAnswerStatics* temp = [self.askAnswerStaticsList objectAtIndex:i];
        if (temp.seq_id == item.seq_id) {
            NSLog(@"applechang-pushAskAnswerStatics, same seq_id=%llu", temp.seq_id);
            return;
        }
    }

    [self.askAnswerStaticsList addObject:item];
    
    if (self.askAnswerCounts == 0) {
        self.firstAskAnswerOverHead = item.overhead;
    }
    
    self.lastAskAnswerStatics = item;
    self.curAskAnswerOverHead = item.overhead;
    if (item.overhead > self.maxAskAnswerOverHead) {
        self.maxAskAnswerOverHead = item.overhead;
    }
    if (item.overhead < self.minAskAnswerOverHead) {
        self.minAskAnswerOverHead = item.overhead;
        NSLog(@"applechang-minAskAnswerOverHead=%llu", self.minAskAnswerOverHead);
    }
    
    float elapseTotalOverhead = self.askAnswerCounts * self.meanAskAnswerOverHead;
    self.askAnswerCounts ++;
    self.meanAskAnswerOverHead = (elapseTotalOverhead + item.overhead)/self.askAnswerCounts;
}

@end
