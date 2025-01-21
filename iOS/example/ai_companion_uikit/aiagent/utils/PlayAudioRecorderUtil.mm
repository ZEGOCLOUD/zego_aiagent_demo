//
//  AudioRecorder.m
//  ZegoExpressExample-iOS-OC
//
//  Created by zego on 2020/7/20.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "PlayAudioRecorderUtil.h"
#include "WavFileWriter.h"

#define INPUT_BUS 1
#define OUTPUT_BUS 0

@interface PlayAudioRecorderUtil(){
    WavFileWriter* fileWriter_;
    dispatch_queue_t fileWriteQueue_;
}

@end

@implementation PlayAudioRecorderUtil

+ (PlayAudioRecorderUtil *)sharedInstance
{
    static PlayAudioRecorderUtil *sharedRecorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRecorder = [[PlayAudioRecorderUtil alloc] init];
    });

    return sharedRecorder;
}

-(instancetype)init{
    if (self = [super init]) {
        fileWriter_ = nullptr;
        fileWriteQueue_ = dispatch_queue_create("com.aicom.audiorecoder", NULL);

    }
    return self;
}

- (void)start:(NSString*)saveFilePath
 withChannels:(int)channels
withSampleRate:(int)sampleRate
withBitsPerSample:(int)bitsPerSample
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(fileWriteQueue_, ^{
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf->fileWriter_ != nullptr) {
            strongSelf->fileWriter_->CloseFile();
            delete strongSelf->fileWriter_;
            strongSelf->fileWriter_  = nullptr;
        }
        
        strongSelf->fileWriter_ = new WavFileWriter();
        strongSelf->fileWriter_->CreateWavFile([saveFilePath UTF8String], channels, sampleRate, bitsPerSample);
    });
        

}

- (void)stop{
    __weak typeof(self) weakSelf = self;
    dispatch_async(fileWriteQueue_, ^{
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf->fileWriter_ == nullptr) {
            return;
        }
        strongSelf->fileWriter_->CloseFile();
        delete strongSelf->fileWriter_;
        strongSelf->fileWriter_ = nullptr;
    });
    

}

- (void)writeToFile:(unsigned char *_Nonnull)data dataLenght:(int)dataLength{
    __weak typeof(self) weakSelf = self;
    dispatch_async(fileWriteQueue_, ^{
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf->fileWriter_ == nullptr) {
            return;
        }
        strongSelf->fileWriter_->WriteToFile(data, dataLength);
    });
}
@end

