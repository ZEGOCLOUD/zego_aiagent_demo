//
//  AIAgentLogUtil.h
//
//  Created by applechang on 2022/11/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface AIAgentLogUtil : NSObject
+ (instancetype)sharedInstance;
- (void)logDebug:(NSString *)filter file:(NSString *)file func:(const char*)func line:(int)line tag:(int)tag format:(NSString *)format, ...;
- (void)logTraceInfo:(NSString *)filter  file:(NSString *)file func:(const char*)func line:(int)line tag:(int)tag format:(NSString*)format, ...;
- (void)logTraceWarning:(NSString *)filter  file:(NSString *)file func:(const char*)func line:(int)line tag:(int)tag format:(NSString*)format, ...;
- (void)logTraceError:(NSString *)filter file:(NSString *)file func:(const char*)func line:(int)line tag:(int)tag format:(NSString*)format, ...;
- (void)logTraceCacheInfo:(NSString *)filter file:(NSString *)file func:(const char*)func line:(int)line tag:(int)tag format:(NSString*)format, ...;
- (void)logTraceMsg:(int)level msg:(NSString*)msg;
@end

#ifdef USE_ZLOGGER
#define ZAALogD(filterName,frmt,...) \
[[AIAgentLogUtil sharedInstance] logDebug:filterName file:[NSString stringWithUTF8String:__FILE__] func:__FUNCTION__ line:__LINE__ tag:0  format:frmt, ##__VA_ARGS__]

#define ZAALogI(filterName,frmt,...) \
[[AIAgentLogUtil sharedInstance] logTraceInfo:filterName file:[NSString stringWithUTF8String:__FILE__] func:__FUNCTION__ line:__LINE__ tag:1215 format:frmt, ##__VA_ARGS__]

#define ZAALogW(filterName,frmt,...) \
[[AIAgentLogUtil sharedInstance] logTraceWarning:filterName file:[NSString stringWithUTF8String:__FILE__] func:__FUNCTION__ line:__LINE__ tag:1215  format:frmt, ##__VA_ARGS__]

#define ZAALogE(filterName,frmt,...) \
[[AIAgentLogUtil sharedInstance] logTraceError:filterName file:[NSString stringWithUTF8String:__FILE__] func:__FUNCTION__ line:__LINE__ tag:1215  format:frmt, ##__VA_ARGS__]

#define ZAALogLocal(filterName,frmt,...) \
[[AIAgentLogUtil sharedInstance] logTraceCacheInfo:filterName file:[NSString stringWithUTF8String:__FILE__] func:__FUNCTION__ line:__LINE__ tag:1215  format:frmt, ##__VA_ARGS__]

#else
#define ZAALogD(filterName,frmt,...)
#define ZAALogI(filterName,frmt,...)
#define ZAALogW(filterName,frmt,...)
#define ZAALogE(filterName,frmt,...)
#define ZAALogLocal(filterName,frmt,...)
#endif
NS_ASSUME_NONNULL_END
