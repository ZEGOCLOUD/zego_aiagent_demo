//
//  ZegoAIComponionExpressMainView.m
//  ai_companion_express
//
//  Created by zegomjf on 2024/5/23.
//

#import "ZegoAIComponionExpressMainView.h"
#import "AppDataManager.h"
#import <Masonry/Masonry.h>
#import <YYKit/YYReachability.h>
#import "ZegoAiCompanionUtil.h"
#import "ZegoAiCompanionHttpHelper.h"
#import "UIView+Toast.h"
#import "AIAgentLogUtil.h"
#import "ZegoAIAgentExpressHelper.h"
#import "ZegoAICompanionCallVCWithExpress.h"

typedef void (^AICompanionCommonCallBack)(NSInteger errorCode, NSString* errMsg, NSString* requestId);


@interface ZegoAIComponionExpressMainView ()
@property (nonatomic, copy) NSString * userID;
@property (nonatomic, copy) NSString * userName;
@property (nonatomic, copy) NSString * appSign;
@property (nonatomic, copy) NSString * roomID;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) BOOL inited;
@property (nonatomic, assign) unsigned int appID;
@property (nonatomic, strong)UIImageView* chatButtonImageView;
@end

@implementation ZegoAIComponionExpressMainView
-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self setupView];
        __weak typeof(self) weak_self = self;
        [self ensureDefaultCustomAgentConfig:^(NSInteger errorCode, NSString *errMsg, NSString* requestId) {
            if (errorCode != 0) {
                NSString* errorMsg =[NSString stringWithFormat:@"初始化会话数据失败，请退出重试:%@", errMsg];
                [weak_self makeToast:errorMsg];
            }else{
            }
        }];
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

- (void)ensureDefaultCustomAgentConfig:(AIAgentCommonCallBack)complete{
    [[ZegoAIAgentExpressHelper sharedInstance] queryCustomAgentTemplate:complete];
}

- (void)layoutSubviews{
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


    NSArray<CustomAgentConfig *> *customAgentList = [AppDataManager sharedInstance].appExtraConfig.customAgentList;
    if (customAgentList.count == 0) {
        NSString* errorMsg =[NSString stringWithFormat:@"初始化会话数据失败，请退出重试"];
        [self makeToast:errorMsg];
        return;
    }
    
    [self showLoading];

    NSString* userId = [AppDataManager sharedInstance].userID;
    NSString* sessionPrefix = [NSString stringWithFormat:@"%@",userId];
    NSString* newConversationId = [ZegoAiCompanionUtil generateConversationID:sessionPrefix];
    NSString* agentId = [ZegoAiCompanionUtil generateAgentId:userId withAgentTempId:customAgentList.firstObject.AgentTemplateId];
    __weak typeof(self) weakSelf = self;
    [[ZegoAIAgentExpressHelper sharedInstance] createConversationWithoutIM:newConversationId withUserId:userId withAgentId:agentId withAgentTempId:customAgentList.firstObject.AgentTemplateId withCustomConfig:nil withCallback:^(NSInteger errorCode, NSString *errMsg, NSString *requestId) {
        [weakSelf hideLoading];
        //410001007,会话已经存在
        if (errorCode !=0 && errorCode != 410001007) {
            NSString* errorMsg =[NSString stringWithFormat:@"创建会话失败，请重试 ec=%ld", (long)errorCode];
            [weakSelf makeToast:errorMsg];
            return;
        }
        
        if (errorCode == 410001007) {
            //对存在的会话，直接查询保持会话数据
            [[ZegoAIAgentExpressHelper sharedInstance] describeConversationList:^(NSInteger errorCode, NSString *errMsg, NSString *requestId) {
                [weakSelf openAICompanionCallVC:agentId];
            }];
            return;
        }
        
        [weakSelf openAICompanionCallVC:agentId];
    }];
}

-(void)openAICompanionCallVC:(NSString*)agentId{
    [[AppDataManager sharedInstance] switchCurrentCharacter:agentId];
    ZegoAICompanionCallVCWithExpress* vc = [[ZegoAICompanionCallVCWithExpress alloc] init];
    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
    UINavigationController* navCtrl;
    UIViewController *topViewController = keyWindow.rootViewController;
    if ([topViewController isKindOfClass:[UINavigationController class]]) {
        navCtrl = (UINavigationController*)topViewController;
    }else{
        navCtrl = topViewController.navigationController;
    }
    [navCtrl pushViewController:vc animated:YES];
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

