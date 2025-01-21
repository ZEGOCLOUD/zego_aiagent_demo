
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ZegoEnvType) {
    ZegoEnvType_None = 0, //未初始化状态
    ZegoEnvType_Dev_Alpha = 1, //开发环境
    ZegoEnvType_Test_Beta = 2, //提测用
    ZegoEnvType_Publish   = 3, //发布用
};


@interface ZegoConnectionConfig: NSObject
@property (readwrite, nonatomic, assign) NSUInteger appid;
@property (readwrite, nonatomic, strong) NSString *appsign;
@property (readwrite, nonatomic, strong) NSString *seversecret;
@end


@interface AiCompanionConfig: NSObject
+ (ZegoConnectionConfig*)getAppConnectConfig:(ZegoEnvType)envType;
+ (ZegoConnectionConfig*)DevAlphaEnv;
+ (ZegoConnectionConfig*)TestBetaEnv;
+ (ZegoConnectionConfig*)PublishEnv;
@end
