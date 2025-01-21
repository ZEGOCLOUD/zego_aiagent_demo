#import "ZegoVoiceActivityChecker.h"

@implementation VadCheckerInfo
@end

@interface ZegoVoiceActivityChecker(){
    NSMutableArray<NSNumber*> *_queue;
    NSUInteger _capacity;
    float _threshold; //>=0,<=1,目前设置为10/15
    BOOL _voiceActivity; //YES表示说话状态，NO反之
    int64_t _checkSeq; //
}

@end

@implementation ZegoVoiceActivityChecker

- (instancetype)init {
    self = [super init];
    if (self) {
        _capacity = 7; //默认窗口500ms尺寸
        _queue = [[NSMutableArray alloc]initWithCapacity:_capacity];
        _voiceActivity = NO;
        _threshold = 23/28.0;
        _checkSeq = 0;
        for (int i=0; i<_capacity; i++) {
            [self enqueue:0];
        }
    }
    return self;
}

-(void)enqueue:(NSUInteger)vadValue{
    if ([self isFull]) {
        [self dequeue];
    }
    [_queue addObject:[NSNumber numberWithUnsignedInteger:vadValue]];
    
}

- (VadCheckerInfo*)voiceActivityDetection:(NSUInteger)vadValue {
    [self enqueue:vadValue];
    float weightAverage=0.0;
    for (int i= _queue.count; i>0; i--) {
        NSNumber* item = [_queue objectAtIndex:i-1];
        weightAverage += (i*[item intValue])/28.0;
    }
    if (weightAverage >= _threshold) {
        if (_voiceActivity == NO) {
            _checkSeq++;
        }
        _voiceActivity = YES;
    }else{
        _voiceActivity = NO;
    }
    
    VadCheckerInfo* chekerInfo = [[VadCheckerInfo alloc] init];
    chekerInfo.weightAverage = weightAverage;
    chekerInfo.voiceActivity = _voiceActivity;
    chekerInfo.checkSeq = _checkSeq;
    
    return chekerInfo;
}

- (id)dequeue {
    if (![self isEmpty]) {
        id object = _queue[0];
        [_queue removeObjectAtIndex:0];
        return object;
    } else {
        NSLog(@"Queue is empty. Cannot dequeue object.");
        return nil;
    }
}

- (BOOL)isEmpty {
    return [_queue count] == 0;
}

- (BOOL)isFull {
    return [_queue count] >= _capacity;
}
@end
