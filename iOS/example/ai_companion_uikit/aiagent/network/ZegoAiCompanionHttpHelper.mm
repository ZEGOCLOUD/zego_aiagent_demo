//
//  ZegoAiCompanionHttpHelper.m
//
//  Created by zego on 2024/5/13.
//  Copyright © 2024 Zego. All rights reserved.
//
#import "ZegoAiCompanionHttpHelper.h"
#import <CommonCrypto/CommonDigest.h>
#import "AppDataManager.h"
#import "ZegoAiCompanionUtil.h"
#import <Security/Security.h>
#import "AIAgentLogUtil.h"
#import "ZegoAiCompanionUtil.h"
#import <CoreServices/CoreServices.h>

static NSString* BASE_URL = @"https://aigc-chat-api.zegotech.cn";

//会话相关
static NSString* ACTION_DescribeConversationList = @"DescribeConversationList";
static NSString* ACTION_CreateConversation = @"CreateConversation";
static NSString* ACTION_UpdateConversation = @"UpdateConversation";
static NSString* ACTION_DeleteConversation = @"DeleteConversation";
static NSString* ACTION_ResetConversationMsg = @"ResetConversationMsg";
static NSString* ACTION_StartRtcChat = @"StartRtcChat";
static NSString* ACTION_StopRtcChat = @"StopRtcChat";
//模版相关
static NSString* ACTION_DescribeCustomAgentTemplate = @"DescribeCustomAgentTemplate";
static NSString* ACTION_CreateCustomAgentTemplate = @"CreateCustomAgentTemplate";
static NSString* ACTION_DeleteCustomAgentTemplate = @"DeleteCustomAgentTemplate";
static NSString* ACTION_UpdateCustomAgentTemplate = @"UpdateCustomAgentTemplate";

//demo相关
static NSString* ACTION_UploadAgentAvatar = @"UploadAgentAvatar";

@interface MySignatureTuple : NSObject

@property (nonatomic, strong) NSString *signature_nonce;
@property (nonatomic, strong) NSString *signature;

- (instancetype)initWithMessage:(NSString *)signature_nonce 
                      signature:(NSString *)signature;

@end

@implementation MySignatureTuple

- (instancetype)initWithMessage:(NSString *)signature_nonce 
                      signature:(NSString *)signature {
    self = [super init];
    if (self) {
        _signature_nonce = signature_nonce;
        _signature = signature;
    }
    return self;
}
@end


@interface ZegoAiCompanionHttpHelper ()
{
    dispatch_source_t _heartBeatTimer;
}
@property (nonatomic, assign)BOOL hasRetryCheckLicense;
@end


static ZegoAiCompanionHttpHelper *_sharedInstance;

@implementation ZegoAiCompanionHttpHelper
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)POSTImage:(NSString *)URLString
                       path:(NSString*)path
                       data:(NSData *)imageData
                       name:(NSString*)name
              withOtherData:(NSDictionary*)keyValues
               withCallback:(AICompanionOtherCommonCallBack)complete{
    NSString *boundary = [self generateBoundaryString];
    // configure the request
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URLString]];
    [request setHTTPMethod:@"POST"];
    // set content type
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    // create body
    NSData *httpBody = [self createBodyWithBoundary:boundary parameters:keyValues paths:@[path] fieldName:@"file"];
    
    NSURLSession *session = [NSURLSession sharedSession];  // use sharedSession or create your own

    NSURLSessionTask *task = [session uploadTaskWithRequest:request fromData:httpBody completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"result = %@", result);
            if (complete) {
                complete(error.code, error.userInfo.description);
            }
        });
    }];
    [task resume];
}

- (NSData *)createBodyWithBoundary:(NSString *)boundary
                        parameters:(NSDictionary *)parameters
                             paths:(NSArray *)paths
                         fieldName:(NSString *)fieldName {
    NSMutableData *httpBody = [NSMutableData data];

    // add params (all params are strings)

    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];

    // add image data

    for (NSString *path in paths) {
        NSString *filename  = [path lastPathComponent];
        NSData   *data      = [NSData dataWithContentsOfFile:path];
        NSString *mimetype  = [self mimeTypeForPath:path];

        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:data];
        [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }

    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    return httpBody;
}

- (NSString *)generateBoundaryString {
    return [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
}

- (NSString *)mimeTypeForPath:(NSString *)path {
    // get a mime type for an extension using MobileCoreServices.framework

    CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
    assert(UTI != NULL);

    NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
    assert(mimetype != NULL);

    CFRelease(UTI);

    return mimetype;
}

-(void)requestSvrInternal:(NSURL*)url
               withParams:(NSDictionary*)params
             withCallback:(AICompanionQueryConversationCallBack)complete{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    request.HTTPBody =postData;
    ZAALogI(@"ZegoAiCompanionHttpHelper", @"req url=%@, params=%@",url, params);
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                 completionHandler:^(NSData *_Nullable data, 
                                                                                     NSURLResponse *_Nullable response,
                                                                                     NSError *_Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error != nil){
                NSInteger ec = error.code;
                ZAALogI(@"ZegoAiCompanionHttpHelper", @"rsp url=%@, code=%d, message=%@", url, ec, error.userInfo.description);
                complete(ec, error.description, nil, nil);
                return;
            }
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSString *message = dict[@"Message"] ?:@"";
            NSNumber *code = dict[@"Code"];
            NSDictionary* internalData = dict[@"Data"];
            NSString* requestId = dict[@"RequestId"];
            ZAALogI(@"ZegoAiCompanionHttpHelper", @"rsp url=%@, code=%@, message=%@,requestId=%@", url, code, message?:@"", requestId);
            complete([code intValue], message, requestId, internalData);
        });
    }];
    
    [task resume];
}

-(void)uploadAvatarHeaderImage:(NSString*)userId 
                withLoacalPath:(NSString*)localPath
                  withCallback:(AICompanionUploadImageCallBack)complete{
    NSURL *url = [self buildCommonUrl:BASE_URL withAction:ACTION_UploadAgentAvatar];
    NSString* fileName = [localPath lastPathComponent];
    NSDictionary *params = @{@"UserId":userId, @"FileName": fileName};
    [self requestSvrInternal:url withParams:params withCallback:^(NSInteger errorCode, 
                                                                  NSString *errMsg,
                                                                  NSString* requestId,
                                                                  NSDictionary *configDict) {
        complete(errorCode, errMsg, requestId, configDict);
    }];
}

-(void)describeConversationList:(NSString*)userId
                   withCallback:(AICompanionQueryConversationCallBack)complete{
    NSURL *url = [self buildCommonUrl:BASE_URL withAction:ACTION_DescribeConversationList];
    NSDictionary *params = @{@"UserId":userId};
    [self requestSvrInternal:url withParams:params withCallback:^(NSInteger errorCode, 
                                                                  NSString *errMsg,
                                                                  NSString* requestId,
                                                                  NSDictionary *configDict) {
        complete(errorCode, errMsg, requestId, configDict);
    }];
}

-(void)resetConversationMsg:(NSString*)conversationId
                 withUserId:(NSString*)userId
               withCallback:(AICompanionCommonCallBack)complete{
    NSURL *url = [self buildCommonUrl:BASE_URL withAction:ACTION_ResetConversationMsg];
    NSDictionary *params = @{@"ConversationId":conversationId,
                             @"UserId":userId};
    [self requestSvrInternal:url withParams:params withCallback:^(NSInteger errorCode,
                                                                  NSString *errMsg,
                                                                  NSString* requestId,
                                                                  NSDictionary *configDict) {
        complete(errorCode, errMsg, requestId);
    }];
}

-(void)deleteConversation:(NSString*)conversationId
               withUserId:(NSString*)userId
             withCallback:(AICompanionCommonCallBack)complete;{
    NSURL *url = [self buildCommonUrl:BASE_URL withAction:ACTION_DeleteConversation];
    NSDictionary *params = @{@"ConversationId":conversationId,
                             @"UserId":userId};
    [self requestSvrInternal:url withParams:params withCallback:^(NSInteger errorCode,
                                                                  NSString *errMsg,
                                                                  NSString* requestId,
                                                                  NSDictionary *configDict) {
        complete(errorCode, errMsg, requestId);
    }];
}

-(void)createConversation:(NSString*)conversationId
               withUserId:(NSString*)userId
              withAgentId:(NSString*)agentId
          withAgentTempId:(NSString*)agentTemplateId
         withCustomConfig:(CustomAgentConfig*)config
             withCallback:(AICompanionCommonCallBack)complete{
    NSURL *url = [self buildCommonUrl:BASE_URL withAction:ACTION_CreateConversation];
    NSDictionary* dictCustomAgentConfig = [config toDict];
    NSDictionary *params = @{@"ConversationId":conversationId, @"UserId":userId, @"AgentId":agentId, @"AgentTemplateId":agentTemplateId ?:@"", @"CustomAgentConfig": dictCustomAgentConfig?:@{}};
    [self requestSvrInternal:url withParams:params withCallback:^(NSInteger errorCode, 
                                                                  NSString *errMsg,
                                                                  NSString* requestId,
                                                                  NSDictionary *configDict) {
        complete(errorCode, errMsg, requestId);
    }];
}

-(void)createConversationWithoutIM:(NSString*)conversationId
                        withUserId:(NSString*)userId
                       withAgentId:(NSString*)agentId
                   withAgentTempId:(NSString*)agentTemplateId
                  withCustomConfig:(CustomAgentConfig*)config
                      withCallback:(AICompanionCommonCallBack)complete{
    NSURL *url = [self buildCommonUrl:BASE_URL withAction:ACTION_CreateConversation];
    NSDictionary* dictCustomAgentConfig = [config toDict];
    NSDictionary *params = @{@"ConversationId":conversationId, @"UserId":userId, @"AgentId":agentId, @"AgentTemplateId":agentTemplateId ?:@"", @"ChatHistoryMode":[NSNumber numberWithInt:2], @"CustomAgentConfig": dictCustomAgentConfig?:@{}};
    [self requestSvrInternal:url withParams:params withCallback:^(NSInteger errorCode, 
                                                                  NSString *errMsg,
                                                                  NSString* requestId,
                                                                  NSDictionary *configDict) {
        complete(errorCode, errMsg, requestId);
    }];
}

-(void)updateConversation:(NSString*)conversationId
               withUserId:(NSString*)userId
          withAgentTempId:(NSString*)agentTemplateId
         withCustomConfig:(CustomAgentConfig*)config
             withCallback:(AICompanionCommonCallBack)complete{
    
    NSURL *url = [self buildCommonUrl:BASE_URL withAction:ACTION_UpdateConversation];
    NSDictionary* dictCustomAgentConfig = [config toDict];
    NSDictionary *params = @{@"ConversationId":conversationId,
                             @"UserId":userId,
                             @"AgentTemplateId":config.AgentTemplateId ?:@"",
                             @"CustomAgentConfig":dictCustomAgentConfig?:@{}
    };
    
    [self requestSvrInternal:url withParams:params withCallback:^(NSInteger errorCode, 
                                                                  NSString *errMsg,
                                                                  NSString* requestId,
                                                                  NSDictionary *configDict) {
        complete(errorCode, errMsg, requestId);
    }];
}


-(void)creatDefaultIMConversation:(NSString*)conversationId
                           userId:(NSString*)userId
                          AgentId:(NSString*)agentId
                  AgentTemplateId:(NSString*)agentTemplateId
                     withCallback:(AICompanionCommonCallBack)complete{
    
    [[ZegoAiCompanionHttpHelper sharedInstance] createConversation:conversationId 
                                                        withUserId:userId
                                                       withAgentId:agentId
                                                   withAgentTempId:agentTemplateId
                                                  withCustomConfig:nil
                                                      withCallback:^(NSInteger errorCode,NSString *errMsg,NSString* requestId) {
        if (errorCode != 0) {
            complete(errorCode, errMsg, requestId);
            return;
        }
        //新创建的会话加入到会话列表
        ConversionConfigInfo* conversationInfo = [[ConversionConfigInfo alloc] init];
        conversationInfo.conversationId = conversationId;
        conversationInfo.agentId = agentId;
        conversationInfo.agentTemplatedId = agentTemplateId;
        conversationInfo.userId =userId;
        conversationInfo.isChatting = YES;
        CustomAgentConfig* defaultAgentConfig = [[AppDataManager sharedInstance].appExtraConfig getCustomAgentConfigById:agentTemplateId];
        conversationInfo.isDefAgenttemplated = YES;
        conversationInfo.customAgentConfig = defaultAgentConfig;
        [[AppDataManager sharedInstance].conversationList addObject:conversationInfo];
        complete(errorCode, errMsg, requestId);
    }];
}

-(void)creatDefaultConversationWithoutIM:(NSString*)conversationId
                                  userId:(NSString*)userId
                                 AgentId:(NSString*)agentId
                         AgentTemplateId:(NSString*)agentTemplateId
                            withCallback:(AICompanionCommonCallBack)complete{
    [[ZegoAiCompanionHttpHelper sharedInstance] createConversationWithoutIM:conversationId
                                                        withUserId:userId
                                                       withAgentId:agentId
                                                   withAgentTempId:agentTemplateId
                                                  withCustomConfig:nil
                                                      withCallback:^(NSInteger errorCode,NSString *errMsg,NSString* requestId) {
        if (errorCode != 0) {
            complete(errorCode, errMsg, requestId);
            return;
        }
        //新创建的会话加入到会话列表
        ConversionConfigInfo* conversationInfo = [[ConversionConfigInfo alloc] init];
        conversationInfo.conversationId = conversationId;
        conversationInfo.agentId = agentId;
        conversationInfo.agentTemplatedId = agentTemplateId;
        conversationInfo.userId =userId;
        conversationInfo.isChatting = YES;
        CustomAgentConfig* defaultAgentConfig = [[AppDataManager sharedInstance].appExtraConfig getCustomAgentConfigById:agentTemplateId];
        conversationInfo.isDefAgenttemplated = YES;
        conversationInfo.customAgentConfig = defaultAgentConfig;
        [[AppDataManager sharedInstance].conversationList addObject:conversationInfo];
        complete(errorCode, errMsg, requestId);
    }];
}


-(void)createAllDefaultConversation:(AICompanionCommonCallBack)complete{
    NSString* userId = [AppDataManager sharedInstance].userID;
    [[ZegoAiCompanionHttpHelper sharedInstance] describeConversationList:userId withCallback:^(NSInteger errorCode,
                                                                                               NSString *errMsg,
                                                                                               NSString* requestID,
                                                                                               NSDictionary *configDict) {
        NSArray<CustomAgentConfig *> *customAgentList = [AppDataManager sharedInstance].appExtraConfig.customAgentList;
        NSMutableArray<CustomAgentConfig*>* needCreateDefaultAgentList = [[NSMutableArray alloc]initWithCapacity:customAgentList.count];
        
        for (int i=0; i<customAgentList.count; i++) {
            [needCreateDefaultAgentList addObject:customAgentList[i]];
        }
        

        if (errorCode != 0) {
            NSLog(@"describeConversationList fail, need create new Conversation");
        }else{
            NSNumber* totalCount = configDict[@"Total"];
            int nTotalCount = [totalCount intValue];
            if (nTotalCount ==0) {
                //创建所有会话
            }else{
                NSArray* curConversionList = configDict[@"ConversationList"];
                for (int i=0; i<curConversionList.count; i++) {
                    ConversionConfigInfo* conversationInfo = [[ConversionConfigInfo alloc] init];
                    NSDictionary* item = [curConversionList objectAtIndex:i];
                    
                    NSString* conversionId =item[@"ConversationId"];
                    conversationInfo.conversationId = conversionId;
                    
                    NSString* agentId =item[@"AgentId"];
                    conversationInfo.agentId = agentId;
                    
                    NSString* agentTemplateId =item[@"AgentTemplateId"];
                    conversationInfo.agentTemplatedId = agentTemplateId;
                    conversationInfo.userId =userId;
                    conversationInfo.isChatting = YES;
                    CustomAgentConfig* defaultAgentConfig = [[AppDataManager sharedInstance].appExtraConfig getCustomAgentConfigById:agentTemplateId];
                    if ([defaultAgentConfig.AgentTemplateId isEqualToString:agentTemplateId]) {
                        conversationInfo.isDefAgenttemplated = YES;
                        conversationInfo.customAgentConfig = defaultAgentConfig;
                    }else{
                        //对自定义智能体
                        conversationInfo.isDefAgenttemplated = NO;
                        CustomAgentConfig* agentConfig = [[CustomAgentConfig alloc] init];
                        NSDictionary* customAgentConfigDict =item[@"CustomAgentConfig"];
                        agentConfig.Name = customAgentConfigDict[@"Name"];
                        agentConfig.AgentTemplateId = nil;
                        agentConfig.Avatar = customAgentConfigDict[@"Avatar"];
                        agentConfig.Intro = customAgentConfigDict[@"Intro"];
                        agentConfig.System = customAgentConfigDict[@"System"];
                        agentConfig.Sex = customAgentConfigDict[@"Sex"];
                        
                        agentConfig.llm = [[RawProperties alloc] init];
                        NSDictionary* LLMDict = customAgentConfigDict[@"LLM"];
//                        agentConfig.llm.AccountSource = LLMDict[@"AccountSource"];
                        agentConfig.llm.Type = LLMDict[@"Type"];
                        agentConfig.llm.Model = LLMDict[@"Model"];
                        
                        NSDictionary* TTSDict = customAgentConfigDict[@"TTS"];
                        agentConfig.tts = [[RawProperties alloc] init];
//                        agentConfig.tts.AccountSource = TTSDict[@"AccountSource"];
                        agentConfig.tts.Type = TTSDict[@"Type"];
                        agentConfig.tts.Voice = TTSDict[@"Voice"];
                        conversationInfo.customAgentConfig = agentConfig;
                    }
                    
                    [[AppDataManager sharedInstance].conversationList addObject:conversationInfo];
                }
                
                //处理缺省智能体，一次性创建所有不在会话列表的缺省智能体
                for (int i=0; i< customAgentList.count; i++) {
                    CustomAgentConfig* config = customAgentList[i];
                    NSString* curRobotID = [ZegoAiCompanionUtil generateAgentId:userId withAgentTempId:config.AgentTemplateId];
                    for (int j=0; j<curConversionList.count; j++) {
                        NSDictionary* item = [curConversionList objectAtIndex:j];
                        NSString* robotId =item[@"AgentId"];
                        NSString* agentTemplateId =item[@"AgentTemplateId"];
                        NSDictionary* agentConfig =item[@"CustomAgentConfig"];
                        if ([curRobotID isEqualToString:robotId] &&
                            [agentTemplateId isEqualToString: config.AgentTemplateId]) {
                            for (int k = 0 ; k< needCreateDefaultAgentList.count; k++) {
                                CustomAgentConfig* temp = [needCreateDefaultAgentList objectAtIndex:k];
                                if (temp.AgentTemplateId == config.AgentTemplateId) {
                                    [needCreateDefaultAgentList removeObject:temp];
                                    break;
                                }
                            }
                            break;
                        }
                    }
                }
            }
        }
        
        NSInteger k = needCreateDefaultAgentList.count-1;
        for (id key in needCreateDefaultAgentList) {
            CustomAgentConfig* config = (CustomAgentConfig*)key;
            NSTimeInterval elapse = (k--)*0.02;
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, elapse*NSEC_PER_SEC);
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                NSString* sessionPrefix = [NSString stringWithFormat:@"%@",userId];
                NSString* newConversationId = [ZegoAiCompanionUtil generateConversationID:sessionPrefix];
                NSString* agentId = [ZegoAiCompanionUtil generateAgentId:userId withAgentTempId:config.AgentTemplateId];
                [self creatDefaultIMConversation:newConversationId 
                                          userId:userId
                                         AgentId:agentId
                                 AgentTemplateId:config.AgentTemplateId
                                    withCallback:^(NSInteger errorCode, NSString *errMsg, NSString *requestId) {
                    NSLog(@"creatDefaultIMConversation result, ec=%ld, msg=%@, requestId=%@", (long)errorCode, errMsg?:@"", requestId?:@"");
                }];
            });
        }
        
        complete(0, @"", @"");
    }];
}

-(void)StopRtcChat:(NSString*)conversationId
        withUserId:(NSString*)userId
      withCallback:(AICompanionCommonCallBack)complete{
    NSURL *url = [self buildCommonUrl:BASE_URL withAction:ACTION_StopRtcChat];
    NSDictionary *params = @{@"ConversationId":conversationId,
                             @"UserId":userId};
    
    [self requestSvrInternal:url withParams:params withCallback:^(NSInteger errorCode,
                                                                  NSString *errMsg,
                                                                  NSString* requestId,
                                                                  NSDictionary *configDict) {
        complete(errorCode, errMsg, requestId);
    }];
}

-(void)StartRtcChat:(NSString*)conversationId
         withUserId:(NSString*)userId
         withRoomId:(NSString*)roomId
       withStreamId:(NSString*)streamId
  withAgentStreamId:(NSString*)agentStreamId
       withCallback:(AICompanionCommonCallBack)complete{
    NSURL *url = [self buildCommonUrl:BASE_URL withAction:ACTION_StartRtcChat];
    NSDictionary *params = @{@"ConversationId":conversationId,
                             @"UserId":userId,
                             @"RoomId":roomId,
                             @"StreamId":streamId,
                             @"AgentStreamId":agentStreamId};
    
    [self requestSvrInternal:url withParams:params withCallback:^(NSInteger errorCode, 
                                                                  NSString *errMsg,
                                                                  NSString* requestId,
                                                                  NSDictionary *configDict) {
        complete(errorCode, errMsg, requestId);
    }];
}


-(void)createCustomAgentTemplate:(CustomAgentConfig*)config
                    withCallback:(AICompanionCreateCustomTemplateCallBack)complete{
    NSURL *url = [self buildCommonUrl:BASE_URL withAction:ACTION_CreateCustomAgentTemplate];
    
    NSDictionary *params = @{@"CustomAgentConfig":@{
                             @"AgentTemplateId":config.AgentTemplateId,
                             @"Name":config.Name,
                             @"Avatar":config.Avatar,
                             @"Intro":config.Intro,
                             @"System":config.System,
                             @"LLM":@{@"Type":config.llm.Type, @"Model": config.llm.Model},
                             @"TTS":@{ @"Type":config.llm.Type}}
    };
    
    [self requestSvrInternal:url withParams:params withCallback:^(NSInteger errorCode,
                                                                  NSString *errMsg,
                                                                  NSString* requestId,
                                                                  NSDictionary *configDict) {
        complete(errorCode, errMsg, configDict);
    }];
}

-(void)queryCustomAgentTemplate:(AICompanionQueryCustomTemplateCallBack)complete{
    NSURL *url = [self buildCommonUrl:BASE_URL withAction:ACTION_DescribeCustomAgentTemplate];
    NSDictionary *params = @{};
    
    [self requestSvrInternal:url withParams:params withCallback:^(NSInteger errorCode, 
                                                                  NSString *errMsg,
                                                                  NSString* requestId,
                                                                  NSDictionary *configDict) {
        complete(errorCode, errMsg, configDict);
    }];
}


-(NSURL*)buildCommonUrl:(NSString*)baseUrl withAction:(NSString*)action{
    NSInteger appID = [AppDataManager sharedInstance].appID;
    NSString* nsAppID = [NSString stringWithFormat:@"%ld", appID];
    NSString* nsServerSecret = [AppDataManager sharedInstance].severSecret;
    MySignatureTuple* tuple = [self buildSignatureNew:nsAppID appSign:nsServerSecret];
    uint64_t ts = [[NSDate date] timeIntervalSince1970];
    NSString *urlString = [NSString stringWithFormat:@"%@?Action=%@&AppId=%@&SignatureNonce=%@&Timestamp=%llu&Signature=%@&SignatureVersion=2.0",
                           BASE_URL,
                           action, nsAppID, tuple.signature_nonce, ts, tuple.signature];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

-(NSMutableDictionary*)buildCommonParams{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
    NSInteger appID = [AppDataManager sharedInstance].appID;
    NSString* appSign = [AppDataManager sharedInstance].appSign;
    NSString* userId = [AppDataManager sharedInstance].userID;
    NSString* nsAppID = [NSString stringWithFormat:@"%ld", appID];
    MySignatureTuple* tuple = [self buildSignature:nsAppID appSign:appSign];
    dict[@"AppId"] = nsAppID;
    dict[@"SignatureNonce"] = tuple.signature_nonce;
    dict[@"Signature"] = tuple.signature;
    dict[@"UserId"] = userId;
    dict[@"SignatureVersion"] = @"2.0";
    uint64_t ts = [[NSDate date] timeIntervalSince1970];
    dict[@"Timestamp"] = [NSString stringWithFormat:@"%llu", ts];
    return dict;
}

-(MySignatureTuple*)buildSignature:(NSString*)appId
                           appSign:(NSString*)appSign{
    NSUInteger signature_nonce = arc4random_uniform(100000);
    // 将整数转换为字符串
    NSString *nonceString = [NSString stringWithFormat:@"%lu", (unsigned long)signature_nonce];
    if(appSign.length > 32){
        appSign = [appSign substringToIndex:32];
    }
    
    // 拼接字符串
    NSString *appendStr = [NSString stringWithFormat:@"%@%@%@", appId, nonceString, appSign];
    
    // 计算 MD5 哈希值
    NSData *data = [appendStr dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char hash[CC_MD5_DIGEST_LENGTH];
    CC_MD5([data bytes], (CC_LONG)[data length], hash);
    
    NSMutableString *md5str = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5str appendFormat:@"%02x", hash[i]];
    }
    
    NSString *signature = md5str;
    MySignatureTuple* tuple = [[MySignatureTuple alloc]initWithMessage:nonceString signature:signature];
    return tuple;
}

- (NSString *)generateSignatureNonce {
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

-(MySignatureTuple*)buildSignatureNew:(NSString*)appId
                              appSign:(NSString*)appSign{
    NSString* nonceString = [self generateSignatureNonce];
    if(appSign.length > 32){
        appSign = [appSign substringToIndex:32];
    }
    
    uint64_t ts = [[NSDate date] timeIntervalSince1970];
    
    // 拼接字符串
    NSString *appendStr = [NSString stringWithFormat:@"%@%@%@%llu", appId, nonceString, appSign, ts];
    
    // 计算 MD5 哈希值
    NSData *data = [appendStr dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char hash[CC_MD5_DIGEST_LENGTH];
    CC_MD5([data bytes], (CC_LONG)[data length], hash);
    
    NSMutableString *md5str = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5str appendFormat:@"%02x", hash[i]];
    }
    
    NSString *signature = md5str;
    MySignatureTuple* tuple = [[MySignatureTuple alloc]initWithMessage:nonceString signature:signature];
    return tuple;
}
@end
