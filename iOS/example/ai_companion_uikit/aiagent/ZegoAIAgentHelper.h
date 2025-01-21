//
//  ZegoAIAgentHelper.h
//
//  Created by zego on 2024/3/13.
//  Copyright © 2024 Zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface ZegoAIAgentHelper: NSObject

+ (instancetype)sharedInstance;
/**
 * 初始化 AI 陪伴服务
 * 初始化时需要填入用户账号信息，用户需要确保 userID 唯一
 * @param containerVC 容器VC
 * @param appID       app id
 * @param appSign     app sign
 * @param serverSecret  服务key
 * @param userId    用户id
 * @param userName    用户名称
 * @param avatarUrl  用户头像url
**/
-(void)initAIComanion:(UIViewController*)containerVC
            withAppId:(long)appID
          withAppSign:(NSString*)appSign
     withServerSecret:(NSString*)serverSecret
           withUserId:(NSString*)userId
         withUserName:(NSString*)userName
       withUserAvatar:(NSString*)avatarUrl;

-(void)unInitAIComanion;

-(long)getCurrentAppID;
-(NSString*)getCurrentUserID;
@end
