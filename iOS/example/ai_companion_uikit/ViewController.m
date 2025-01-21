//
//  ViewController.m
//  ai_companion_oc
//
//  Created by applechang on 2024/5/23.
//

#import "ViewController.h"
#import "ZegoAIAgentHelper.h"
#import "AiCompanionConfig.h"
#import "ZegoTestSettingViewController.h"


@interface ViewController ()
@property (nonatomic, copy) NSString * userID;
@property (nonatomic, copy) NSString * userName;
@property (nonatomic, copy) NSString * appSign;
@property (nonatomic, copy) NSString * roomID;
@property (nonatomic, assign) unsigned int appID;

@end

@implementation ViewController
-(instancetype)init{
    if(self = [super init]){
        
    }
    return  self;
}

-(instancetype)initWithCoder:(NSCoder *)coder{
    if(self = [super initWithCoder:coder]){
        
    }
    return self;
}

- (NSString *)generateID:(NSString *)prefix isIDMaintain:(BOOL)isIDMaintain {
    NSString *randomID = [NSString stringWithFormat:@"%@%ld%u", prefix, (long)CFAbsoluteTimeGetCurrent() % 1000000, arc4random_uniform(100)];
    if (isIDMaintain) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *cacheID = [defaults objectForKey:prefix];
        if(cacheID == nil){
            [defaults setObject:randomID forKey:prefix];
            [defaults synchronize];
            cacheID = randomID;
        }
        return cacheID;
    } else {
        return randomID;
    }
}

// 显示性能监控窗口
- (void)handlelongGesture:(UILongPressGestureRecognizer*)longPress {
    ZegoTestSettingViewController * testViewController = [[ZegoTestSettingViewController alloc] initWithNibName:@"ZegoTestSettingViewController" bundle:nil];
    [self presentViewController:testViewController animated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlelongGesture:)];
    longPress.minimumPressDuration = 2.0;
    [self.view addGestureRecognizer:longPress];
    
    NSNumber *env_type =  [[NSUserDefaults standardUserDefaults] objectForKey:@"env_type"];
    NSString* prefix = @"iu";
    if (env_type.integerValue == 0) {
        env_type = @(ZegoEnvType_Test_Beta);
        prefix = @"uib";
#ifdef FINAL_RELEASE
        env_type = @(ZegoEnvType_Publish);
        prefix = @"uip";
#endif

#ifdef DEBUG
        env_type = @(ZegoEnvType_Dev_Alpha);
        prefix = @"uia";
#endif
    }else{
        if (env_type.integerValue == ZegoEnvType_Dev_Alpha) {
            prefix = @"uia";
        }else if(env_type.integerValue == ZegoEnvType_Test_Beta){
            prefix = @"uib";
        }else if(env_type.integerValue == ZegoEnvType_Publish){
            prefix = @"uip";
        }
    }
    
    
    [[NSUserDefaults standardUserDefaults] setInteger:[env_type integerValue]  forKey:@"env_type"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    ZegoConnectionConfig* connCfg = [AiCompanionConfig getAppConnectConfig:(ZegoEnvType)env_type.integerValue];

    NSString* userId = [self generateID:prefix isIDMaintain:YES];
//    NSString* userId = @"iu_94387656";
    NSString* userName = @"user_ios";
    NSString* userAvatar = @"https://zego-aigc-test.oss-accelerate.aliyuncs.com/airobotdemo/robot_ravatar.png";
    [[ZegoAIAgentHelper sharedInstance] initAIComanion: self 
                                             withAppId:connCfg.appid
                                           withAppSign:connCfg.appsign
                                      withServerSecret:connCfg.seversecret
                                            withUserId:userId
                                          withUserName:userName
                                        withUserAvatar:userAvatar];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}
@end

