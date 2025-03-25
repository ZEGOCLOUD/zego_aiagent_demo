//
//  ZegoSettingsViewController.m
//  ai_companion_uikit
//
//  Created by Trae AI on 2024/01/01.
//

#import "ZegoSettingsViewControllerNew.h"
#import <Masonry/Masonry.h>
#import <SSZipArchive/SSZipArchive.h>
#import "UIView+Toast.h"
#import "AppDataManager.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZegoSettingsViewControllerNew () <UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIDocumentInteractionController *documentController;

@end

@implementation ZegoSettingsViewControllerNew

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
    [self setupData];
}

- (void)setupUI {
    // 设置标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"设置";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:24];
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.centerX.equalTo(self.view);
        make.height.equalTo(@48);
    }];
    
    // 添加关闭按钮
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(22);
        make.centerY.equalTo(titleLabel);
    }];
    
    // 创建滚动视图
    self.scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    // 内容视图
    self.contentView = [[UIView alloc] init];
    [self.scrollView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    
    NSString* appID = [NSString stringWithFormat:@"%ld",[AppDataManager sharedInstance].appID];
    NSString* userID = [AppDataManager sharedInstance].userID;
    NSString* userName = [AppDataManager sharedInstance].userName;
    NSString* rtcVer = [ZegoExpressEngine getVersion];
    NSString* appVer = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSDictionary *labels = [NSDictionary dictionaryWithObjectsAndKeys:appID, @"appID", userID, @"userID", rtcVer, @"rtcVer", appVer, @"appVer", nil];
    UIView *lastView = nil;
    
    for(NSString *key in labels){
        UIView *container = [[UIView alloc] init];
        [self.contentView addSubview:container];
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = key;
        titleLabel.textColor = [UIColor blackColor];
        [container addSubview:titleLabel];
         
        UILabel *valueLabel = [[UILabel alloc] init];
        [container addSubview:valueLabel];
        valueLabel.textColor = [UIColor blueColor];
        valueLabel.text =  labels[key];
         
        [container mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView);
            make.height.equalTo(@30);
            if (lastView) {
                make.top.equalTo(lastView.mas_bottom);
            } else {
                make.top.equalTo(self.contentView);
            }
        }];
         
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(container).offset(20);
            make.centerY.equalTo(container);
            make.width.equalTo(@96);
        }];
         
        [valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleLabel.mas_right).offset(10);
            make.right.equalTo(container).offset(-20);
            make.centerY.equalTo(container);
        }];
         
        lastView = container;
     }
    
    
    // 添加开关控件
    NSArray *switches = @[
        @{@"title": @"运行环境切换", @"property": @"envSwitch"},
        @{@"title": @"回声消除(AEC)", @"property": @"aecSwitch"},
        @{@"title": @"自动增益控制(AGC)", @"property": @"agcSwitch"},
        @{@"title": @"自动降噪(ANS)", @"property": @"ansSwitch"},
        @{@"title": @"发送欢迎语", @"property": @"welcomeSwitch"},
        
        @{@"title": @"音量闪避", @"property": @"audioVolumeDuckSwitch"},
        @{@"title": @"音量播放自适用", @"property": @"echoEneryAdaptiveSwitch"},
//        @{@"title": @"本地vad和打断", @"property": @"localVadSwitch"},
//        @{@"title": @"延迟优化", @"property": @"latencyModeSwitch"}
    ];
    
    for (NSDictionary *switchInfo in switches) {
        UIView *container = [[UIView alloc] init];
        [self.contentView addSubview:container];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = switchInfo[@"title"];
        titleLabel.textColor = [UIColor blackColor];
        [container addSubview:titleLabel];
        
        if([switchInfo[@"property"] isEqualToString:@"envSwitch"]){
            self.envSwitchButton = [UIButton buttonWithType:UIButtonTypeSystem];
            
            NSNumber* env_type =  [[NSUserDefaults standardUserDefaults] objectForKey:@"env_type"];
            NSString* envText =@"alpha";
            if (env_type.integerValue == 1) {
                envText = @"alpha";
            }else if(env_type.integerValue == 2){
                envText = @"beta";
            }else if(env_type.integerValue == 3){
                envText = @"publish";
            }else if(env_type.integerValue == 4){
                envText = @"delta";
            }else if(env_type.integerValue == 5){
                envText = @"gamma";
            }else if(
                     ///    旧huiW
                     env_type.integerValue == 9
                     || env_type.integerValue == 10){
                envText = @"zeta";///trail
            }
            
            [self.envSwitchButton setTitle:envText forState:UIControlStateNormal];
            [self.envSwitchButton addTarget:self action:@selector(envSwitchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [container addSubview:self.envSwitchButton];
            
            
            [container mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self.contentView);
                make.height.equalTo(@30);
                make.top.equalTo(lastView.mas_bottom);
            }];
            
            [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(container).offset(20);
                make.centerY.equalTo(container);
            }];
            
            [self.envSwitchButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(container).offset(-20);
                make.centerY.equalTo(container);
            }];
        }else{
            UISwitch *switchControl = [[UISwitch alloc] init];
            [container addSubview:switchControl];
            if ([switchInfo[@"property"] isEqualToString:@"aecSwitch"]) {
                switchControl.on = [AppDataManager sharedInstance].aecEnable;
            }else if([switchInfo[@"property"] isEqualToString:@"agcSwitch"]){
                switchControl.on = [AppDataManager sharedInstance].agcEnable;
            }else if([switchInfo[@"property"] isEqualToString:@"ansSwitch"]){
                switchControl.on = [AppDataManager sharedInstance].ansEnable;
            }else if([switchInfo[@"property"] isEqualToString:@"welcomeSwitch"]){
                switchControl.on = [AppDataManager sharedInstance].welcomeEnable;
            }else if([switchInfo[@"property"] isEqualToString:@"audioVolumeDuckSwitch"]){
                switchControl.on = [AppDataManager sharedInstance].audioVolumeDucking;
            }else if([switchInfo[@"property"] isEqualToString:@"echoEneryAdaptiveSwitch"]){
                switchControl.on = [AppDataManager sharedInstance].echoEnergyAdaptive;
            }
            
            [self setValue:switchControl forKey:switchInfo[@"property"]];
            [switchControl addTarget:self
                              action:@selector(switchAction:)
                    forControlEvents:UIControlEventValueChanged];
            
            [container mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self.contentView);
                make.height.equalTo(@48);
                make.top.equalTo(lastView.mas_bottom);
            }];
            
            [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(container).offset(20);
                make.centerY.equalTo(container);
            }];
            
            [switchControl mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(container).offset(-20);
                make.centerY.equalTo(container);
            }];
        }
        
        
        lastView = container;
        
       if ([switchInfo[@"property"] isEqualToString:@"aecSwitch"]) {
            // 在AEC和ANS开关下方添加对应的模式选择
            UIView *aecModeContainer = [[UIView alloc] init];
            [self.contentView addSubview:aecModeContainer];
            
            self.aecModeLabel = [[UILabel alloc] init];
            self.aecModeLabel.text = @"AEC_MODE";
            self.aecModeLabel.textColor = [UIColor blackColor];
            [aecModeContainer addSubview:self.aecModeLabel];
            
            self.aecModeButton = [UIButton buttonWithType:UIButtonTypeSystem];
           NSString* aecModeText =@"SOFT";
           if ([AppDataManager sharedInstance].aecMode == 0) {
               aecModeText = @"AGGRESSIVE";
           }else if([AppDataManager sharedInstance].aecMode == 1){
               aecModeText = @"MEDIUM";
           }else if([AppDataManager sharedInstance].aecMode == 2){
               aecModeText = @"SOFT";
           }else if([AppDataManager sharedInstance].aecMode == 3){
               aecModeText = @"AI";
           }
           
           
            [self.aecModeButton setTitle:aecModeText forState:UIControlStateNormal];
            [self.aecModeButton addTarget:self action:@selector(aecModeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [aecModeContainer addSubview:self.aecModeButton];
            
            
            [aecModeContainer mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self.contentView);
                make.height.equalTo(@48);
                make.top.equalTo(lastView.mas_bottom);
            }];
            
            [self.aecModeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(aecModeContainer).offset(20);
                make.centerY.equalTo(aecModeContainer);
            }];
            
            [self.aecModeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(aecModeContainer).offset(-20);
                make.centerY.equalTo(aecModeContainer);
            }];
            
            lastView = aecModeContainer;
        } else if ([switchInfo[@"property"] isEqualToString:@"ansSwitch"]) {
            UIView *ansModeContainer = [[UIView alloc] init];
            [self.contentView addSubview:ansModeContainer];
            
            self.ansModeLabel = [[UILabel alloc] init];
            self.ansModeLabel.text = @"ANS_MODE";
            self.ansModeLabel.textColor = [UIColor blackColor];
            
            
            [ansModeContainer addSubview:self.ansModeLabel];
            
            
            self.ansModeButton = [UIButton buttonWithType:UIButtonTypeSystem];
            NSString* ansModeText =@"SOFT";
            
            if ([AppDataManager sharedInstance].ansMode == 0) {
                ansModeText = @"SOFT";
            }else if([AppDataManager sharedInstance].ansMode == 1){
                ansModeText = @"MEDIUM";
            }else if([AppDataManager sharedInstance].ansMode == 2){
                ansModeText = @"AGGRESSIVE";
            }else if([AppDataManager sharedInstance].ansMode == 3){
                ansModeText = @"AI";
            }else if([AppDataManager sharedInstance].ansMode == 4){
                ansModeText = @"AIBalanced";
            }else if([AppDataManager sharedInstance].ansMode == 5){
                ansModeText = @"AILowLatency";
            }else if([AppDataManager sharedInstance].ansMode == 6){
                ansModeText = @"AIAggressive";
            }
            
            
            [self.ansModeButton setTitle:ansModeText forState:UIControlStateNormal];
            [self.ansModeButton addTarget:self action:@selector(ansModeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [ansModeContainer addSubview:self.ansModeButton];
            
            [ansModeContainer mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self.contentView);
                make.height.equalTo(@48);
                make.top.equalTo(lastView.mas_bottom);
            }];
            
            [self.ansModeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(ansModeContainer).offset(20);
                make.centerY.equalTo(ansModeContainer);
            }];
            
            [self.ansModeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(ansModeContainer).offset(-20);
                make.centerY.equalTo(ansModeContainer);
            }];
            
            lastView = ansModeContainer;
        }
    }
    
    // 添加按钮
    self.shareLogButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.shareLogButton setTitle:@"分享日志" forState:UIControlStateNormal];
    [self.shareLogButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.shareLogButton.backgroundColor = [UIColor systemBlueColor];
    [self.shareLogButton addTarget:self action:@selector(shareLogButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.shareLogButton];
    
    self.clearLogButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.clearLogButton setTitle:@"清除日志" forState:UIControlStateNormal];
    [self.clearLogButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.clearLogButton.backgroundColor = [UIColor systemBlueColor];
    [self.clearLogButton addTarget:self action:@selector(clearLogButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.clearLogButton];
    
    self.saveRestartButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.saveRestartButton setTitle:@"保存重启" forState:UIControlStateNormal];
    [self.saveRestartButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.saveRestartButton.backgroundColor = [UIColor systemBlueColor];
    [self.saveRestartButton addTarget:self action:@selector(saveRestartButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.saveRestartButton];
    
    [self.shareLogButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lastView.mas_bottom).offset(20);
        make.left.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView).offset(-20);
        make.height.equalTo(@50);
    }];
    
    [self.clearLogButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.shareLogButton.mas_bottom).offset(20);
        make.left.right.height.equalTo(self.shareLogButton);
        make.bottom.equalTo(self.contentView).offset(-20);
    }];
}

-(void) switchAction:(id)sender
{
    if (sender == self.ansSwitch) {
        [AppDataManager sharedInstance].ansEnable = self.ansSwitch.on;
    }else if(sender == self.aecSwitch){
        [AppDataManager sharedInstance].aecEnable = self.aecSwitch.on;
    }else if(sender == self.agcSwitch){
        [AppDataManager sharedInstance].agcEnable = self.agcSwitch.on;
    }else if(sender == self.agcSwitch){
        [AppDataManager sharedInstance].agcEnable = self.agcSwitch.on;
    }else if(sender == self.welcomeSwitch){
        [AppDataManager sharedInstance].welcomeEnable = self.welcomeSwitch.on;
    }
    else if(sender == self.audioVolumeDuckSwitch){
        [AppDataManager sharedInstance].audioVolumeDucking = self.audioVolumeDuckSwitch.on;
    }else if(sender == self.echoEneryAdaptiveSwitch){
        [AppDataManager sharedInstance].echoEnergyAdaptive = self.echoEneryAdaptiveSwitch.on;
    }
}

- (void)setupData {
    // 设置基本信息
    long appID = [AppDataManager sharedInstance].appID;
    NSString *userId = [AppDataManager sharedInstance].userID;
    
    self.appIdLabel.text = [NSString stringWithFormat:@"%ld", appID];
    self.userIdLabel.text = userId;
    self.userNameLabel.text = @"";
    self.expressVersionLabel.text = @"";
    self.appVersionLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

#pragma mark - Button Actions

- (void)closeButtonClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)shareLogButtonClicked {
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *zipFilePath = [cachePath stringByAppendingPathComponent:@"ZegoLogFile.zip"];
    
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:zipFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:zipFilePath error:&error];
    }
    
    if ([SSZipArchive createZipFileAtPath:zipFilePath withContentsOfDirectory:cachePath]) {
        if (!self.documentController) {
            self.documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:zipFilePath]];
            self.documentController.delegate = self;
        }
        [self.documentController presentOpenInMenuFromRect:self.view.bounds inView:self.view animated:YES];
    } else {
        [self.view makeToast:@"压缩日志文件失败，请重试"];
    }
}

- (void)clearLogButtonClicked {
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSArray *logDirs = @[@"PlayStreamRecords", @"AICompanionLogs", @"ZegoLogs", @"ZIMLogs"];
    
    for (NSString *dirName in logDirs) {
        NSString *dirPath = [cachePath stringByAppendingPathComponent:dirName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
            NSError *error;
            [[NSFileManager defaultManager] removeItemAtPath:dirPath error:&error];
            
            if (error) {
                NSString *msg = [NSString stringWithFormat:@"删除日志目录%@失败,ec=%ld", dirName, (long)error.code];
                [self.view makeToast:msg];
            }
        }
    }
    
    NSString *msg = @"删除日志目录成功";
    [self.view makeToast:msg];
}

- (void)saveRestartButtonClicked {
    
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
    // 处理分享菜单关闭事件
}

#pragma mark - Mode Selection Actions


- (void)envSwitchButtonClicked:(UIButton *)sender{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择运行环境"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *modes = @[@"alpha", @"beta", @"publish",@"delta", @"gamma", @"zeta"];
    for (NSString *mode in modes) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:mode
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {


            
            NSNumber* env_type =  [[NSUserDefaults standardUserDefaults] objectForKey:@"env_type"];
            if (env_type.integerValue < 1 ||env_type.integerValue > 10) {
                env_type = @(1);
            }
            
            if ([mode isEqualToString:@"alpha"]) {
                env_type = @(1);
            }else if([mode isEqualToString:@"beta"]){
                env_type = @(2);
            }else if([mode isEqualToString:@"publish"]){
                env_type = @(3);
            }else if([mode isEqualToString:@"delta"]){
                env_type = @(4);
            }else if([mode isEqualToString:@"gamma"]){
                env_type = @(5);
            }else if([mode isEqualToString:@"zeta"]){///    trail
                env_type = @(10);
            }


            [[NSUserDefaults standardUserDefaults] setInteger:env_type.integerValue forKey:@"env_type"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self.envSwitchButton setTitle:mode forState:UIControlStateNormal];
            
            NSString * messgae = @"重启后生效。立即重启";
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:messgae preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                      NSLog(@"确定");
                exit(0);
            }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            
            
        }];
        [alertController addAction:action];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)aecModeButtonClicked:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择AEC模式"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *modes = @[@"AGGRESSIVE",@"MEDIUM", @"SOFT", @"AI"];
    for (NSString *mode in modes) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:mode
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
            [self.aecModeButton setTitle:mode forState:UIControlStateNormal];
            if ([mode isEqualToString:@"AGGRESSIVE"]) {
                [AppDataManager sharedInstance].aecMode = 0;
            }else if([mode isEqualToString:@"MEDIUM"]){
                [AppDataManager sharedInstance].aecMode = 1;
            }else if([mode isEqualToString:@"SOFT"]){
                [AppDataManager sharedInstance].aecMode = 2;
            }else if([mode isEqualToString:@"AI"]){
                [AppDataManager sharedInstance].aecMode = 3;
            }
        }];
        [alertController addAction:action];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)ansModeButtonClicked:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择ANS模式"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *modes = @[@"SOFT",@"MEDIUM", @"AGGRESSIVE", @"AI", @"AIBalanced", @"AILowLatency", @"AIAggressive"];
    for (NSString *mode in modes) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:mode
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
            [self.ansModeButton setTitle:mode forState:UIControlStateNormal];
            
            if ([mode isEqualToString:@"SOFT"]) {
                [AppDataManager sharedInstance].ansMode = 0;
            }else if([mode isEqualToString:@"MEDIUM"]){
                [AppDataManager sharedInstance].ansMode = 1;
            }else if([mode isEqualToString:@"AGGRESSIVE"]){
                [AppDataManager sharedInstance].ansMode = 2;
            }else if([mode isEqualToString:@"AI"]){
                [AppDataManager sharedInstance].ansMode = 3;
            }else if([mode isEqualToString:@"AIBalanced"]){
                [AppDataManager sharedInstance].ansMode = 4;
            }else if([mode isEqualToString:@"AILowLatency"]){
                [AppDataManager sharedInstance].ansMode = 5;
            }else if([mode isEqualToString:@"AIAggressive"]){
                [AppDataManager sharedInstance].ansMode = 6;
            }
        }];
        [alertController addAction:action];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
