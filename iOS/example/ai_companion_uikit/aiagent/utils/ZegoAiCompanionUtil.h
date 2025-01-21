//
//  ZegoAiCompanionUtils.h
//
//  Created by zego on 2024/3/13.
//  Copyright © 2024 Zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

@interface ZegoAiCompanionUtil: NSObject
+ (NSString*)generateRandomNumberString;
+ (NSString*)generateConversationID:(NSString*)extraAppend;
+ (NSString*)generateAgentTemplateId:(NSString*)extraAppend;
+ (NSString*)generateAgentId:(NSString*)userId withAgentTempId:(NSString*)agentTempId;     //由于zim限制，用户ID不能超过32字节
+ (UIImage*)generateImageWithColor:(UIColor*)color;
+ (NSString*)trimStringEllipsis:(NSString*)originStr
                     limitCount:(NSInteger)limitCount;

+(NSDictionary *)dictFromJson:(NSString *)jsonString;
@end
