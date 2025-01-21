//
//  ZegoAIComponionMainView.m
//  ai_companion_oc
//
//  Created by zegomjf on 2024/5/23.
//

#import "ZegoAIComponionMainView.h"
#import "AppDataManager.h"
#import <Masonry/Masonry.h>
#import <YYKit/YYReachability.h>
#import "ZegoAiCompanionUtil.h"
#import <ZIM/ZIMDefines.h>
#import "ZegoAiCompanionHttpHelper.h"
#import "ai_companion_uikit-Swift.h"
#import "UIView+Toast.h"
#import "ZGMWAsyncPCM.h"
#import "AIAgentLogUtil.h"

typedef void (^AICompanionCommonCallBack)(NSInteger errorCode, NSString* errMsg, NSString* requestId);

@import ZIMKit;

@interface ZegoAIComponionMainView ()
@property (nonatomic, copy) NSString * userID;
@property (nonatomic, copy) NSString * userName;
@property (nonatomic, copy) NSString * appSign;
@property (nonatomic, copy) NSString * roomID;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) BOOL inited;
@property (nonatomic, assign) unsigned int appID;
@property (nonatomic, strong)UIImageView* chatButtonImageView;
@property (nonatomic, strong)id<IAsyncPCM> roleCreatePCM;
@property (nonatomic, copy)pfnProduceCallback roleCreateCallback;

@end

@implementation ZegoAIComponionMainView
-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self setupView];
        __weak typeof(self) weak_self = self;
        self.roleCreatePCM = [[ZGMWAsyncPCM alloc] initWith:^(pfnProduceCallback callback) {
            
            [ZIMKit connectUserWithUserID:[AppDataManager sharedInstance].userID
                                 userName:[AppDataManager sharedInstance].userName
                                avatarUrl:[AppDataManager sharedInstance].userAvatar callback:^(ZIMError* error) {
                
                if (error.code == ZIMErrorCodeSuccess) {
                    ZAALogI(@"ZIMKit", @"connectUserWithUserID Success");
                    [self ensureDefaultConversation:^(NSInteger errorCode, NSString *errMsg, NSString* requestId) {
                        if (errorCode != 0) {
                            NSString* errorMsg =[NSString stringWithFormat:@"创建缺省的智能体会话失败:%@", errMsg];
                            [weak_self makeToast:errorMsg];
                            callback(@(0));
                        }else{
                            callback(@(1));
                        }
                    }];
                }else{
                    ZAALogI(@"ZIMKit", @"connectUserWithUserID faild, ec=%d, errMsg=%@", error.code, error.message);
                    NSString* errorMsg =[NSString stringWithFormat:@"登陆IM失败:%@", error.message];
                    [weak_self makeToast:errorMsg];
                    callback(@(0));
                }
            }];
        }];
        
        YYReachability* reach = [YYReachability reachability];
        if (reach.status != YYReachabilityStatusNone) {
            [self.roleCreatePCM doComsume:^(id product) {
                NSLog(@"preload result=%@", product);
            }];
        }
    }
    return  self;
}

- (void)showLoading {
    // 创建并配置 activityIndicator
    if(self.activityIndicator == nil){
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.activityIndicator];
        [self.activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    }
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void)hideLoading {
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
}

-(void)extractCustomAgentConfigList:(NSDictionary*)configDict callback:(AICompanionCommonCallBack)complete{
    NSArray* AgentConfigList = configDict[@"CustomAgentConfigList"];
    AppExtraConfig* appExtraConfig = [[AppExtraConfig alloc]init];
    appExtraConfig.customAgentList = [[NSMutableArray alloc]initWithCapacity:AgentConfigList.count];
    for (int i=0; i<AgentConfigList.count; i++) {
        NSDictionary* item = [AgentConfigList objectAtIndex:i];
        
        CustomAgentConfig* agentConfig = [[CustomAgentConfig alloc]init];
        agentConfig.AgentTemplateId = item[@"AgentTemplateId"];
        agentConfig.Name = item[@"Name"];
        agentConfig.Avatar = item[@"Avatar"];
        agentConfig.Intro = item[@"Intro"];
        agentConfig.System = item[@"System"];
        agentConfig.Source = item[@"Source"];
        agentConfig.Sex = item[@"Sex"];
        agentConfig.WelcomeMessage = item[@"WelcomeMessage"];
        
        NSDictionary* LLM = item[@"LLM"];
        agentConfig.llm = [[RawProperties alloc]init];
        agentConfig.llm.Model = LLM[@"Model"];
        agentConfig.llm.Type = LLM[@"Type"];
//        agentConfig.llm.AccountSource = LLM[@"AccountSource"];
        
        NSDictionary* TTS = item[@"TTS"];
        agentConfig.tts = [[RawProperties alloc]init];
        agentConfig.tts.Voice = TTS[@"Voice"];
        agentConfig.tts.Type = TTS[@"Type"];
//        agentConfig.tts.AccountSource = TTS[@"AccountSource"];
        [appExtraConfig.customAgentList addObject:agentConfig];
    }
    
    [AppDataManager sharedInstance].appExtraConfig = appExtraConfig;
    [[AppDataManager sharedInstance] loadLocalAppExtraConfig];
    [[ZegoAiCompanionHttpHelper sharedInstance] createAllDefaultConversation:^(NSInteger errorCode, NSString *errMsg, NSString* requestId) {
        if(errorCode !=0){
            NSString* errorMsg =[NSString stringWithFormat:@"创建缺省的智能体会话失败:%@", errMsg];
            [self makeToast:errorMsg];
        }else{
            self.inited = YES;
        }
        
        complete(errorCode,errMsg, requestId);
    }];
}

-(void)ensureDefaultConversation:(AICompanionCommonCallBack)complete{
    [[ZegoAiCompanionHttpHelper sharedInstance] queryCustomAgentTemplate:^(NSInteger errorCode, NSString *errMsg, NSDictionary *configDict) {
        //防止App首次启动需要网络权限
        if(errorCode !=0){
            NSString* errorMsg =[NSString stringWithFormat:@"查询智能体配置模版失败:ec=%ld, %@",(long)errorCode, errMsg];
            [self makeToast:errorMsg];
            return;
        }
        
        [self extractCustomAgentConfigList:configDict callback:complete];
    }];
}

-(void)layoutSubviews{
    // 设置背景图像
    UIImage* bgImage = [UIImage imageNamed:@"main_bg.png"];
    
    UIGraphicsBeginImageContext(self.frame.size);
    [bgImage drawInRect:self.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.backgroundColor = [UIColor colorWithPatternImage:image];
}

- (void)setupView {
    // 添加main_title.png
    UIImageView *mainTitleImageView = [[UIImageView alloc] init];
    mainTitleImageView.contentMode = UIViewContentModeScaleToFill;
    mainTitleImageView.image = [UIImage imageNamed:@"main_title"];
    [self addSubview:mainTitleImageView];
    [mainTitleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(222);
        make.height.mas_equalTo(97);
        make.left.equalTo(self).offset(21);
        make.top.equalTo(self).offset(76);
    }];
    
    // 添加peiban.png
    self.chatButtonImageView =  [[UIImageView alloc] init];
    self.chatButtonImageView.contentMode = UIViewContentModeScaleToFill;
    self.chatButtonImageView.image = [UIImage imageNamed:@"peiban"];
    [self addSubview:self.chatButtonImageView];
    [self.chatButtonImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(150);
        make.left.equalTo(self).offset(21);
        make.right.equalTo(self).offset(-21);
        make.top.equalTo(mainTitleImageView.mas_bottom).offset(26);
    }];
    
    self.chatButtonImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickAICompanioArea:)];
    [self.chatButtonImageView addGestureRecognizer:tapGestureRecognizer];

    
    UIImageView *button1ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 164, 180)];
     button1ImageView.contentMode = UIViewContentModeScaleToFill; // 拉伸填充，可能导致变形
     button1ImageView.image = [UIImage imageNamed:@"kefu"];
     [self addSubview:button1ImageView];
     

     [button1ImageView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.width.mas_equalTo(164);
         make.height.mas_equalTo(180);
         make.left.equalTo(self).offset(21);
         make.top.equalTo(self.chatButtonImageView.mas_bottom).offset(11);
     }];

    
    UIImageView *button2ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 164, 180)];
    button2ImageView.contentMode = UIViewContentModeScaleToFill; // 保持宽高比，可能有空白区域
    button2ImageView.image = [UIImage imageNamed:@"zhibo"];
    [self addSubview:button2ImageView];
    [button2ImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(164);
        make.height.mas_equalTo(180);
        make.right.equalTo(self).offset(-21);
        make.top.equalTo(self.chatButtonImageView.mas_bottom).offset(11);
    }];
    
    UIImageView *button3ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 164, 180)];
    button3ImageView.contentMode = UIViewContentModeScaleToFill; // 保持宽高比，可能裁剪
    button3ImageView.image = [UIImage imageNamed:@"main_more"];
    [self addSubview:button3ImageView];
    [button3ImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(164);
        make.height.mas_equalTo(180);
        make.left.equalTo(self).offset(21);
        make.top.equalTo(button1ImageView.mas_bottom).offset(11);
    }];
}

- (void)onClickAICompanioArea:(UIGestureRecognizer *) recognizer {
    if (self.activityIndicator && !self.activityIndicator.hidden) {
        NSLog(@"onClickAICompanioArea is requesting, return");
        return;
    }
    [self showLoading];
    __weak typeof(self) weakSelf = self;
    [weakSelf.roleCreatePCM doComsume:^(id product) {
        if ([(NSNumber*)product intValue] == 0) {
            [weakSelf.roleCreatePCM reset];
            NSString* errorMsg =[NSString stringWithFormat:@"初始化数据失败，请重新尝试"];
            [weakSelf makeToast:errorMsg];
        }else{
            [ZIMKit connectUserWithUserID:[AppDataManager sharedInstance].userID
                                 userName:[AppDataManager sharedInstance].userName
                                avatarUrl:[AppDataManager sharedInstance].userAvatar callback:^(ZIMError* error) {
                if (error.code == ZIMErrorCodeSuccess) {
                    ZegoAIComConversationListVC* conversationListVC = [[ZegoAIComConversationListVC alloc] init];
                    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
                    UINavigationController* navCtrl;
                    UIViewController *topViewController = keyWindow.rootViewController;
                    if ([topViewController isKindOfClass:[UINavigationController class]]) {
                        navCtrl = (UINavigationController*)topViewController;
                    }else{
                        navCtrl = topViewController.navigationController;
                    }
                    [navCtrl pushViewController:conversationListVC animated:YES];
                }else{
                    NSString* errorMsg =[NSString stringWithFormat:@"登陆IM失败:%@", error.message];
                    [weakSelf makeToast:errorMsg];
                }
                dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, 0.5*NSEC_PER_SEC);
                dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                    [weakSelf hideLoading];
                });
            }];
        }
    }];
}

- (void)showAnimatedView:(UIView *)view {
    // 设置动画的持续时间和曲线
    [UIView animateWithDuration:0.5
                      delay:0.0
                    options:UIViewAnimationOptionCurveEaseInOut
                 animations:^{
                     // 动画结束时的目标位置
                     view.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
                 }
                 completion:^(BOOL finished) {
                     // 动画完成后的回调
                     NSLog(@"Animation completed.");
                 }];
}
@end

