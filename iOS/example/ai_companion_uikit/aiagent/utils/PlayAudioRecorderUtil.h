//
//  ZGAudioToolRecorder.h
//  ZegoExpressExample-iOS-OC
//
//  Created by zego on 2020/7/20.
//  Copyright © 2020 Zego. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlayAudioRecorderUtil : NSObject

+ (PlayAudioRecorderUtil*)sharedInstance;
- (void)start:(NSString*)saveFilePath
 withChannels:(int)channels
withSampleRate:(int)sampleRate
withBitsPerSample:(int)bitsPerSample;
- (void)stop;
- (void)writeToFile:(unsigned char *_Nonnull)data dataLenght:(int)dataLength;
@end
