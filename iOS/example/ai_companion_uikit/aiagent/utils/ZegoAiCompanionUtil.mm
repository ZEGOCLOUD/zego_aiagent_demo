//
//  ZegoAiCompanionUtil.m
//
//  Created by zego on 2024/3/13.
//  Copyright © 2024 Zego. All rights reserved.
//
#import "ZegoAiCompanionUtil.h"
#import <Security/Security.h>
#include <functional>
#include <string>
#include "WavFileWriter.h"

@interface ZegoAiCompanionUtil ()
@end

@implementation ZegoAiCompanionUtil

+ (NSString *)generateRandomNumberString {
    NSString *randomID = [NSString stringWithFormat:@"%ld%u", (long)CFAbsoluteTimeGetCurrent() % 1000000, arc4random_uniform(100)];
    return randomID;
}

+ (NSString *)generatRandomHexString {
    // 生成 8 字节的随机数据
    uint8_t bytes[8];
    
    // 使用 SecRandomCopyBytes 获取高强度安全随机数生成器
    OSStatus status = SecRandomCopyBytes(kSecRandomDefault, sizeof(bytes), bytes);
    
    if (status == errSecSuccess) {
        // 将字节数组转换为 16 进制字符串
        NSMutableString *hexString = [NSMutableString stringWithCapacity:16];
        for (int i = 0; i < 8; i++) {
            [hexString appendFormat:@"%02x", bytes[i]];
        }
        
        return hexString;
    } else {
        NSLog(@"Failed to generate random bytes with status: %d", status);
        return nil;
    }
}

+ (NSString*)generateConversationID:(NSString*)prefix{
    NSString* result = [NSString stringWithFormat:@"%@_%@",prefix,[ZegoAiCompanionUtil generatRandomHexString]];
    return result;
}

+ (NSString*)generateAgentTemplateId:(NSString*)extraAppend{
    NSString* result = [NSString stringWithFormat:@"%@%@",extraAppend,[ZegoAiCompanionUtil generateRandomNumberString]];
    return result;
}
+ (NSString*)generateAgentId:(NSString*)userId withAgentTempId:(NSString*)agentTempId{
    NSString* result = [NSString stringWithFormat:@"@RBT#_%@_%@", userId, agentTempId];
    return result;
}

+ (UIImage*)generateImageWithColor:(UIColor*)color{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

/**
 计算输入的字符长度
 */
+ (NSUInteger)countCharacterLength:(NSString *)test
{
    __block NSUInteger total = 0;
    [test enumerateSubstringsInRange:NSMakeRange(0, test.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        total++;
    }];
    return total;
}

+ (NSString*)trimStringEllipsis:(NSString*)originStr
                     limitCount:(NSInteger)limitCount{
    NSUInteger charTotal = [ZegoAiCompanionUtil countCharacterLength:originStr];
    if (charTotal > limitCount) {
        NSMutableArray *characters = [NSMutableArray array];
        NSUInteger len = originStr.length;
        [originStr enumerateSubstringsInRange:NSMakeRange(0, len) 
                                      options:NSStringEnumerationByComposedCharacterSequences
                                   usingBlock:^(NSString * _Nullable substring,
                                                NSRange substringRange,
                                                NSRange enclosingRange, BOOL * _Nonnull stop) {
            if (characters.count < limitCount) {
                [characters addObject:substring];
            }
            else{
                *stop = true;
            }
        }];
        
        NSString *resultStr = [characters componentsJoinedByString:@""];
        resultStr = [resultStr stringByAppendingString:@"..."];
        return resultStr;
    }
    
    return originStr;
}

/** json转dict*/
+(NSDictionary *)dictFromJson:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSError *error;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) {
        return nil;
    }
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
    if(error) {
        NSLog(@"dictFromJson: Error, json解析失败：%@", error);
        return nil;
    }
    
    return dic;
}

@end
