#import "AiCompanionConfig.h"

@implementation ZegoConnectionConfig
@end

@implementation AiCompanionConfig
+ (ZegoConnectionConfig*)getAppConnectConfig:(ZegoEnvType)envType{
    if (envType == ZegoEnvType_Dev_Alpha) {
        return [AiCompanionConfig DevAlphaEnv];
    }else if(envType == ZegoEnvType_Test_Beta){
        return [AiCompanionConfig TestBetaEnv];
    }else if(envType == ZegoEnvType_Publish){
        return [AiCompanionConfig PublishEnv];
    }
    return nil;
}

+(ZegoConnectionConfig*)DevAlphaEnv{
    static NSUInteger APPID =;
    static NSString *APPSIGN =;
    static NSString* SERVERSECRET =;
    ZegoConnectionConfig* connCfg = [[ZegoConnectionConfig alloc] init];
    connCfg.appid = APPID;
    connCfg.appsign = APPSIGN;
    connCfg.seversecret = SERVERSECRET;
    return connCfg;
}

+(ZegoConnectionConfig*)TestBetaEnv{
    static NSUInteger APPID = ;
    static NSString *APPSIGN =;
    static NSString* SERVERSECRET =;
    ZegoConnectionConfig* connCfg = [[ZegoConnectionConfig alloc] init];
    connCfg.appid = APPID;
    connCfg.appsign = APPSIGN;
    connCfg.seversecret = SERVERSECRET;
    return connCfg;
}

+(ZegoConnectionConfig*)PublishEnv{
    static NSUInteger APPID = ;
    static NSString *APPSIGN = ;
    static NSString* SERVERSECRET = ;
    ZegoConnectionConfig* connCfg = [[ZegoConnectionConfig alloc] init];
    connCfg.appid = APPID;
    connCfg.appsign = APPSIGN;
    connCfg.seversecret = SERVERSECRET;
    return connCfg;
}
@end

