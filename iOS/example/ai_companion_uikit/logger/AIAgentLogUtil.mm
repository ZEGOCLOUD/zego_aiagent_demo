//
//  AIAgentLogUtil.mm
//
//  Created by applechang on 2022/11/7.
//

#include "AIAgentLogUtil.h"
#include <sstream>
#include <string>

#ifdef USE_ZLOGGER
#include "LogUtil.h"
#else
//#incldue "otherLog.h"
#endif

@interface AIAgentLogUtil(){
}

@end

@implementation AIAgentLogUtil
+ (instancetype)sharedInstance{
    static AIAgentLogUtil* g_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[AIAgentLogUtil alloc] init];
        NSString* version = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        std::string strVersion = [version UTF8String];
        
        NSString *logPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/AICompanionLogs"];
        BOOL isDir = NO;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL existed = [fileManager fileExistsAtPath:logPath isDirectory:&isDir];
        if (!(isDir == YES && existed == YES) ) {
            [fileManager createDirectoryAtPath:logPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        const char* szLogPath = [logPath UTF8String];
#ifdef USE_ZLOGGER
        LogIO::init(strVersion, szLogPath);
#endif
    });
    return g_sharedInstance;
}

- (void)logDebug:(NSString *)filter
            file:(NSString *)file
            func:(const char*)func
            line:(int)line
             tag:(int)tag
          format:(NSString *)format, ...{
    va_list arglist;
    va_start(arglist, format);
    NSString* message = nil;
    if (format) {
        message = [[NSString alloc] initWithFormat:format arguments:arglist];
    }
    va_end(arglist);
    
    NSLog(@"filter=%@, file=%@, msg=%@", filter, file, message);
}


- (void)logTraceInfo:(NSString *)filter
                file:(NSString *)file
                func:(const char*)func
                line:(int)line
                 tag:(int)tag
              format:(NSString*)format, ...{
    va_list arglist;
    va_start(arglist, format);
    NSLogv(format, arglist);
    NSString* message = nil;
    if (format) {
        message = [[NSString alloc] initWithFormat:format arguments:arglist];
    }
    va_end(arglist);
    
    NSRange range = [file rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.length > 0) {
        file = [file substringFromIndex:range.location + 1];
    }
#ifdef USE_ZLOGGER
    LogIO::writeLog(tag, line, 2, [file UTF8String], [message UTF8String]);
#endif

}

- (void)logTraceWarning:(NSString *)filter
                   file:(NSString *)file
                   func:(const char*)func
                   line:(int)line
                    tag:(int)tag
                 format:(NSString*)format, ...{
    va_list arglist;
    va_start(arglist, format);
    NSString* message = nil;
    if (format) {
        message = [[NSString alloc] initWithFormat:format arguments:arglist];
    }
    va_end(arglist);
    
    NSRange range = [file rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.length > 0) {
        file = [file substringFromIndex:range.location + 1];
    }
#ifdef USE_ZLOGGER
    LogIO::writeLog(tag, line, 3, [file UTF8String], [message UTF8String]);
#endif
}

- (void)logTraceError:(NSString *)filter
                 file:(NSString *)file
                 func:(const char*)func
                 line:(int)line
                  tag:(int)tag
               format:(NSString*)format, ...{
    va_list arglist;
    va_start(arglist, format);
    NSString* message = nil;
    if (format) {
        message = [[NSString alloc] initWithFormat:format arguments:arglist];
    }
    va_end(arglist);
    
    NSRange range = [file rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.length > 0) {
        file = [file substringFromIndex:range.location + 1];
    }
#ifdef USE_ZLOGGER
    LogIO::writeLog(tag, line, 4, [file UTF8String], [message UTF8String]);
#endif
}


- (void)logTraceMsg:(int)level msg:(NSString*)message{
#ifdef USE_ZLOGGER
    if (level == 2) {
        LogIO::writeLog(2025, 0, level, nullptr, [message UTF8String]);
    }else if(level == 3){
        LogIO::writeLog(2025, 0, level, nullptr, [message UTF8String]);
    }else if(level == 4){
        LogIO::writeLog(2025, 0, level, nullptr, [message UTF8String]);
    }else{
        NSLog(@"logTraceMsg:%@", message);
    }
#endif
}

- (void)logTraceCacheInfo:(NSString *)filter
                file:(NSString *)file
                func:(const char*)func
                line:(int)line
                 tag:(int)tag
              format:(NSString*)format, ...{
    va_list arglist;
    va_start(arglist, format);
    NSLogv(format, arglist);
    NSString* message = nil;
    if (format) {
        message = [[NSString alloc] initWithFormat:format arguments:arglist];
    }
    va_end(arglist);
    
    NSRange range = [file rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.length > 0) {
        file = [file substringFromIndex:range.location + 1];
    }
    // 获取主目录路径
    NSString *homeDirectory = NSHomeDirectory();
    // 构建缓存目录路径
    NSString *cacheDirectory = [homeDirectory stringByAppendingPathComponent:@"Library/Caches/AICompanionLogs"];
    // 构建完整的文件路径
    NSString *filePath = [cacheDirectory stringByAppendingPathComponent:@"aiAVAudioSession.txt"];

    // 确保缓存目录存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = [fileManager fileExistsAtPath:cacheDirectory isDirectory:&isDir];

    if (!isExist || !isDir) {
        // 目录不存在，创建目录
        [fileManager createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }

    // 尝试打开文件进行更新
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];

    if (!fileHandle) {
        // 文件不存在，创建文件
        NSError *error;
        
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        if (error) {
            NSLog(@"Error creating file: %@", error);
            return;
        }
    }
    
    static NSDateFormatter *sharedFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFormatter = [[NSDateFormatter alloc] init];
        sharedFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        sharedFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    });
    
    NSString *formattedDate = [[sharedFormatter stringFromDate:[NSDate date]] stringByAppendingString:@"\n"];

    NSString *newString = [formattedDate stringByAppendingString:message];

    
    [fileHandle seekToEndOfFile];
    NSData *data = [newString dataUsingEncoding:NSUTF8StringEncoding];
    [fileHandle writeData:data];
    [fileHandle closeFile];

}

- (void)logTreaceMsg:(int)level msg:(NSString*)msg{
    
}
@end
