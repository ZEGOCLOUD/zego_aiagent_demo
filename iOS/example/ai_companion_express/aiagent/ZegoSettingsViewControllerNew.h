//
//  ZegoSettingsViewControllerNew.h
//  ai_companion_uikit
//
//  Created by Trae AI on 2024/01/01.
//

#import <UIKit/UIKit.h>

@interface ZegoSettingsViewControllerNew : UIViewController

@property (nonatomic, strong) UILabel *appIdLabel;
@property (nonatomic, strong) UILabel *userIdLabel;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UILabel *expressVersionLabel;
@property (nonatomic, strong) UILabel *appVersionLabel;

@property (nonatomic, strong) UISwitch *aecSwitch;
@property (nonatomic, strong) UISwitch *agcSwitch;
@property (nonatomic, strong) UISwitch *ansSwitch;
@property (nonatomic, strong) UISwitch *welcomeSwitch;
@property (nonatomic, strong) UISwitch *localVadSwitch;
@property (nonatomic, strong) UISwitch *latencyModeSwitch;

@property (nonatomic, strong) UIButton *shareLogButton;
@property (nonatomic, strong) UIButton *clearLogButton;
@property (nonatomic, strong) UIButton *saveRestartButton;

@property (nonatomic, strong) UILabel *aecModeLabel;
@property (nonatomic, strong) UIButton *envSwitchButton;
@property (nonatomic, strong) UILabel *ansModeLabel;
@property (nonatomic, strong) UIButton *aecModeButton;
@property (nonatomic, strong) UIButton *ansModeButton;
@end
