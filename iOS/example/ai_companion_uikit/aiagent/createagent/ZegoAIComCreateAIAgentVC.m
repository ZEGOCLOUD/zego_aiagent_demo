//
//  ZegoAIComCreateAIAgentVC.m
//
//  Created by zego on 2024/5/13.
//  Copyright © 2024 Zego. All rights reserved.
//

#import "ZegoAIComCreateAIAgentVC.h"
#import <Masonry/Masonry.h>
#import <YYKit/UIImageView+YYWebImage.h>
#import "AppDataManager.h"
#import "ZegoAiCompanionHttpHelper.h"
#import "UIView+Toast.h"
#import "ZegoAiCompanionUtil.h"
#import "ZegoPopUpContainerView.h"
#import "ZegoGenderSelectView.h"
#import "ZegoPhotoSelectView.h"
#import "AppDataManager.h"
#import "ZegoAiCompanionUtil.h"
#import "UIView+Toast.h"
#import "AIAgentLogUtil.h"

@interface ZegoAIComCreateAIAgentVC ()<UITextViewDelegate,
UITextFieldDelegate,
ZegoPopUpContainerViewDelegate, 
ZegoGenderSelectViewDelegate,
ZegoSettingsContainerViewDelegate,
ZegoPhotoSelectViewDelegate>

@property (nonatomic, strong)ZegoPopUpContainerView* popUpContainerView;
@property(nonatomic, strong)ZegoGenderSelectView* genderSelectView;
@property(nonatomic, strong)ZegoPhotoSelectView* photoSelectView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) ZegoInsetsLabelView *copyrightLabel;

- (void)setupUI;
@end

@implementation ZegoAIComCreateAIAgentVC
-(instancetype)init{
    if(self = [super init]){
        self.curGender = @"男生";
        self.fillItemFlag = AIAgentFillItems_None;
        if(self.ttsConfigInfo == nil){
            TTSConfig* ttsConfig = [AppDataManager sharedInstance].appExtraConfig.ttsList.firstObject;
            self.ttsConfigInfo = [[TTSConfigInfo alloc]init];
            self.ttsConfigInfo.ttsConfig = ttsConfig;
            self.ttsConfigInfo.voiceId = ttsConfig.voiceList.firstObject.voiceId;
        }
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self setupUI];
    
}

-(void)didMoveToParentViewController:(UIViewController *)parent{
    // 创建一个 UILabel
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 119, 25)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"创建AI智能体";
    
    // 将 UILabel 设置为导航项的 titleView
    self.navigationItem.titleView = titleLabel;
}

-(CGRect)calculateStringLenght:(NSString *)content withFont:(UIFont*)font{
    NSDictionary *attributes = @{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName: [UIColor blackColor]
    };
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:content attributes:attributes];
    
    // 计算文本的大小
    CGSize maxSize = CGSizeMake(SCREEN_WIDTH - 2*16, CGFLOAT_MAX);
    CGRect boundingBox = [attributedString boundingRectWithSize:maxSize
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                        context:nil];
    return boundingBox;
}

- (void)viewTapped:(UITapGestureRecognizer*)tap{
    [self.view endEditing:YES];
}


-(UIColor*)getFieldTextColor{
    return [UIColor colorWithRed:42/255.0 green:42/255.0 blue:42/255.0 alpha:1];
}

-(UIColor*)geFieldNameColor{
    return [UIColor colorWithRed:42/255.0 green:42/255.0 blue:42/255.0 alpha:1];
}


-(void)addNavBackIcon{
    //donothing
    self.navBackIcon = [[UIImageView alloc] init];
    self.navBackIcon.contentMode = UIViewContentModeScaleToFill;
    self.navBackIcon.image = [UIImage imageNamed:@"nav-back"];
    [self.view addSubview:self.navBackIcon];
    UITapGestureRecognizer *tapGesture0 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickNavBack:)];
    [self.navBackIcon addGestureRecognizer:tapGesture0];
    [self.navBackIcon setUserInteractionEnabled:YES];
    
    CGFloat barH = [[UIApplication sharedApplication] statusBarFrame].size.height;
    [self.navBackIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
        make.left.equalTo(self.view).offset(4);
        make.top.equalTo(self.view).offset(barH+4);
    }];
}

-(void)onClickNavBack:(UITapGestureRecognizer*)tapGensture{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

-(void)addPageTitle{
    self.pageTitle = [[UILabel alloc]init];
    self.pageTitle.text = @"创建 AI 智能体";
    self.pageTitle.font = [UIFont fontWithName:@"Pingfang-SC-Medium" size:18];
    self.pageTitle.textColor = [UIColor colorWithRed:42/255.0 green:42/255.0 blue:42/255.0 alpha:1/1.0];
    self.pageTitle.backgroundColor = [UIColor clearColor];
    self.pageTitle.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.pageTitle];
    CGFloat barH = [[UIApplication sharedApplication] statusBarFrame].size.height;
    [self.pageTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.navBackIcon);
    }];
}

-(void)addBackgroundColor{
    // 设置背景颜色
    self.view.backgroundColor = [UIColor colorWithRed:239/255.0 green:240/255.0 blue:242/255.0 alpha:1/1.0];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tap1.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap1];
}

-(void)addHeadAvatar{
    self.headAvatar = [[UIImageView alloc] init];
    self.headAvatar.contentMode = UIViewContentModeScaleAspectFill;
    self.headAvatar.layer.masksToBounds = YES;
    self.headAvatar.layer.cornerRadius = 40;
    self.headAvatar.image = [UIImage imageNamed:@"icon_touxiang"];
    
    UITapGestureRecognizer *tapGesture0 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickSelectPhoto:)];
    [self.headAvatar addGestureRecognizer:tapGesture0];
    [self.headAvatar setUserInteractionEnabled:YES];
    
    [self.view addSubview:self.headAvatar];
    [self.headAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(80);
        make.top.equalTo(self.view).offset(109);
        make.centerX.equalTo(self.view);
    }];
    
    self.PlusIcon = [[UIImageView alloc] init];
    self.PlusIcon.contentMode = UIViewContentModeScaleToFill;
    self.PlusIcon.image = [UIImage imageNamed:@"icon_add"];
    [self.view addSubview:self.PlusIcon];
    [self.PlusIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(24);
        make.height.mas_equalTo(24);
        make.right.equalTo(self.headAvatar);
        make.bottom.equalTo(self.headAvatar);
    }];
}

-(void)addTipsLabel{
    CGFloat itemWidth = SCREEN_WIDTH - 2*16;
    self.tipsLabel = [[ZegoInsetsLabelView alloc] initWithInsets:UIEdgeInsetsMake(8, 16, 8, 16)];
    NSString* tipContent = @"若生成的智能体效果不符合您的预期，请联系 ZEGO 为您提供 AI 智能体的深度运营";
    self.tipsLabel.text = tipContent;
    self.tipsLabel.numberOfLines = 0;
    self.tipsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.tipsLabel.font = [UIFont fontWithName:@"PingFang SC" size:12];
    self.tipsLabel.textColor = [UIColor colorWithRed:142/255.0 green:144/255.0 blue:147/255.0 alpha:1/1.0];
    self.tipsLabel.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6];
    self.tipsLabel.layer.cornerRadius = 12;
    self.tipsLabel.clipsToBounds = YES;
    self.tipsLabel.textAlignment = NSTextAlignmentLeft;
    CGRect boundingBox = [self calculateStringLenght:tipContent withFont:self.tipsLabel.font];
    [self.view addSubview:self.tipsLabel];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(itemWidth);
        make.height.mas_equalTo(50);
        make.top.equalTo(self.headAvatar.mas_bottom).offset(16);
        make.centerX.equalTo(self.view);
    }];
}

-(void)addNameComponent{
    CGFloat itemWidth = SCREEN_WIDTH - 2*16;
    self.nameBg = [[UIView alloc] init];
    self.nameBg.backgroundColor = [UIColor whiteColor];
    self.nameBg.layer.cornerRadius = 12;
    [self.view addSubview:self.nameBg];
    if (self.tipsLabel) {
        [self.nameBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(itemWidth);
            make.height.mas_equalTo(50);
            make.top.equalTo(self.tipsLabel.mas_bottom).offset(30);
            make.centerX.equalTo(self.view);
        }];
    }else{
        [self.nameBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(itemWidth);
            make.height.mas_equalTo(50);
            make.top.equalTo(self.headAvatar.mas_bottom).offset(30);
            make.centerX.equalTo(self.view);
        }];
    }

    
    self.nameTitle = [[UILabel alloc]init];
    self.nameTitle.text = @"名称";
    self.nameTitle.font = [UIFont fontWithName:@"PingFang SC" size:16];
    self.nameTitle.textColor = [self geFieldNameColor];
    self.nameTitle.backgroundColor = [UIColor clearColor];
    self.nameTitle.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.nameTitle];
    [self.nameTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(32);
        make.height.mas_equalTo(22);
        make.left.mas_equalTo(self.nameBg).offset(16);
        make.centerY.equalTo(self.nameBg);
    }];
    
    
    self.nameTextField = [[UITextField alloc] init];
    self.nameTextField.font =  [UIFont fontWithName:@"PingFang SC" size:16];
    self.nameTextField.textColor = [self getFieldTextColor];
    self.nameTextField.returnKeyType = UIReturnKeyDone;
    self.nameTextField.textAlignment = NSTextAlignmentRight;
    [self.nameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    NSString *placeholderText = @"输入智能体名称";
    // 创建一个可变的 NSMutableAttributedString
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:placeholderText];
    
    // 设置占位符文本的属性
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"PingFang SC" size:16] range:NSMakeRange(0, placeholderText.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1.0] range:NSMakeRange(0, placeholderText.length)];
    self.nameTextField.attributedPlaceholder =  attributedString;
    self.nameTextField.delegate = self;
    [self.view addSubview:self.nameTextField];
    [self.nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(130);
        make.height.mas_equalTo(22);
        make.right.mas_equalTo(self.nameBg).offset(-18);
        make.centerY.equalTo(self.nameBg);
    }];
}

-(void)addGenderComponent{
    CGFloat itemWidth = SCREEN_WIDTH - 2*16;
    self.genderBg = [[UIView alloc] init];
    self.genderBg.backgroundColor = [UIColor whiteColor];
    self.genderBg.layer.cornerRadius = 12;
    [self.view addSubview:self.genderBg];
    [self.genderBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(itemWidth);
        make.height.mas_equalTo(50);
        make.top.equalTo(self.nameBg.mas_bottom).offset(16);
        make.centerX.equalTo(self.view);
    }];
    
    self.genderTitle = [[UILabel alloc]init];
    self.genderTitle.text = @"性别";
    self.genderTitle.font = [UIFont fontWithName:@"PingFang SC" size:16];
    self.genderTitle.textColor = [self geFieldNameColor];
    self.genderTitle.backgroundColor = [UIColor clearColor];
    self.genderTitle.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.genderTitle];
    [self.genderTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(32);
        make.height.mas_equalTo(22);
        make.left.mas_equalTo(self.genderBg).offset(16);
        make.centerY.equalTo(self.genderBg);
    }];
    
    self.genderArrow = [[UIImageView alloc] init];
    self.genderArrow.contentMode = UIViewContentModeScaleToFill;
    self.genderArrow.image = [UIImage imageNamed:@"gender-arrow"];
    [self.view addSubview:self.genderArrow];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickSelectGender:)];
    [self.genderArrow addGestureRecognizer:tapGesture];
    [self.genderArrow setUserInteractionEnabled:YES];
    
    [self.genderArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(24);
        make.height.mas_equalTo(24);
        make.right.equalTo(self.genderBg).offset(-10);
        make.centerY.equalTo(self.genderBg);
    }];
    
    self.genderContent = [[UILabel alloc] init];
    self.genderContent.font =  [UIFont fontWithName:@"PingFang SC" size:16];
    self.genderContent.textColor = [UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1/1.0];
    self.genderContent.text = @"请选择";
    self.genderContent.textAlignment = NSTextAlignmentRight;
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickSelectGender:)];
    [self.genderContent addGestureRecognizer:tapGesture1];
    [self.genderContent setUserInteractionEnabled:YES];
    [self.view addSubview:self.genderContent];
    [self.genderContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(48);
        make.height.mas_equalTo(22);
        make.right.mas_equalTo(self.genderArrow.mas_left);
        make.centerY.equalTo(self.genderBg);
    }];
}

-(void)addSettingDescComponent{
    CGFloat itemWidth = SCREEN_WIDTH - 2*16;
    self.setupBg = [[UIView alloc] init];
    self.setupBg.backgroundColor = [UIColor whiteColor];
    self.setupBg.layer.cornerRadius = 12;
    [self.view addSubview:self.setupBg];
    [self.setupBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(itemWidth);
        make.height.mas_equalTo(132);
        make.top.equalTo(self.genderBg.mas_bottom).offset(16);
        make.centerX.equalTo(self.view);
    }];
    
    
    self.setupTitle = [[UILabel alloc]init];
    self.setupTitle.text = @"设定描述";
    self.setupTitle.font = [UIFont fontWithName:@"PingFang SC" size:16];
    self.setupTitle.textColor = [self geFieldNameColor];
    self.setupTitle.backgroundColor = [UIColor clearColor];
    self.setupTitle.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.setupTitle];
    [self.setupTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(64);
        make.height.mas_equalTo(22);
        make.left.mas_equalTo(self.setupBg).offset(16);
        make.top.mas_equalTo(self.setupBg).offset(14);
    }];
    
    self.setupContent = [[ZegoAutoAdjustTextView alloc] init];
    self.setupContent.backgroundColor = [UIColor whiteColor];
    self.setupContent.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.setupContent.font = [UIFont fontWithName:@"PingFang SC" size:16];
    self.setupContent.textColor = [self getFieldTextColor];
    self.setupContent.delegate = self; // 设置代理以便处理占位符逻辑
    [self.view addSubview:self.setupContent];
    
    
    self.placeHolderLabel = [[UILabel alloc]init];
    self.placeHolderLabel.text = @"示例：你是一位经验丰富的英语老师，拥有激发学生学习热情的教学方法。你善于运用幽默和实际应用案例，使对话充满趣味。";
    self.placeHolderLabel.numberOfLines = 0;
    self.placeHolderLabel.font = [UIFont fontWithName:@"PingFang SC" size:15];
    self.placeHolderLabel.textColor = [UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1/1.0];
    self.placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.setupContent addSubview:self.placeHolderLabel];
    
    
    [self.setupContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(SCREEN_WIDTH - 32*2);
        make.height.mas_equalTo(72);
        make.left.mas_equalTo(self.setupBg).offset(16);
        make.top.mas_equalTo(self.setupTitle.mas_bottom).offset(10);
    }];
    
    [self.placeHolderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.setupContent);
        make.height.mas_equalTo(self.setupContent);
    }];
}

-(void)addVoiceComponent{
    CGFloat itemWidth = SCREEN_WIDTH - 2*16;
    self.voiceBg = [[UIView alloc] init];
    self.voiceBg.backgroundColor = [UIColor whiteColor];
    self.voiceBg.layer.cornerRadius = 12;
    [self.view addSubview:self.voiceBg];
    [self.voiceBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(itemWidth);
        make.height.mas_equalTo(50);
        make.top.equalTo(self.setupBg.mas_bottom).offset(16);
        make.centerX.equalTo(self.view);
    }];
    
    self.voiceTitle = [[UILabel alloc]init];
    self.voiceTitle.text = @"声音设置";
    self.voiceTitle.font = [UIFont fontWithName:@"PingFang SC" size:16];
    self.voiceTitle.textColor = [UIColor blackColor];
    self.voiceTitle.backgroundColor = [UIColor clearColor];
    self.voiceTitle.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.voiceTitle];
    [self.voiceTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(64);
        make.height.mas_equalTo(22);
        make.left.mas_equalTo(self.voiceBg).offset(16);
        make.centerY.equalTo(self.voiceBg);
    }];
    //
    self.voiceArrow = [[UIImageView alloc] init];
    self.voiceArrow.contentMode = UIViewContentModeScaleToFill;
    self.voiceArrow.image = [UIImage imageNamed:@"gender-arrow"];
    [self.view addSubview:self.voiceArrow];
    
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickSelectVoice:)];
    [self.voiceArrow addGestureRecognizer:tapGesture1];
    [self.voiceArrow setUserInteractionEnabled:YES];
    
    [self.voiceArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(24);
        make.height.mas_equalTo(24);
        make.right.equalTo(self.voiceBg).offset(-10);
        make.centerY.equalTo(self.voiceBg);
    }];
    
    self.voiceContent = [[UILabel alloc] init];
    self.voiceContent.font =  [UIFont fontWithName:@"PingFang SC" size:16];
    self.voiceContent.textColor = [UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1.0];
    self.voiceContent.text = @"请选择";
    self.voiceContent.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:self.voiceContent];
    [self.voiceContent addGestureRecognizer:tapGesture1];
    [self.voiceContent setUserInteractionEnabled:YES];;
    
    [self.voiceContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(22);
        make.left.mas_equalTo(self.voiceTitle.mas_right);
        make.right.mas_equalTo(self.voiceArrow.mas_left);
        make.centerY.equalTo(self.voiceBg);
    }];
}

-(void)addCompleteComponent{
    self.createAIAgentBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.createAIAgentBtn.layer.cornerRadius = 16;
    self.createAIAgentBtn.layer.masksToBounds = YES;
    self.createAIAgentBtn.enabled = NO;
    [self.createAIAgentBtn setTitle:@"  创建智能体\n(仅自己可对话)" forState:UIControlStateNormal];
    [self.createAIAgentBtn setTitle:@"  创建智能体\n(仅自己可对话)" forState:UIControlStateDisabled];
    self.createAIAgentBtn.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.createAIAgentBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:16];
    
    
    UIColor* normalColor = [UIColor colorWithRed:0.0 green:85/255.0 blue:255/255.0 alpha:1.0];
    UIColor* disableColor = [UIColor colorWithRed:0.0 green:85/255.0 blue:255/255.0 alpha:0.4];
    
    UIImage* normalBgImage = [ZegoAiCompanionUtil generateImageWithColor:normalColor];
    UIImage* disableBgImage = [ZegoAiCompanionUtil generateImageWithColor:disableColor];
    
    
    [self.createAIAgentBtn setBackgroundImage:normalBgImage forState:UIControlStateNormal];
    [self.createAIAgentBtn setBackgroundImage:disableBgImage forState:UIControlStateDisabled];
    
    
    
    [self.createAIAgentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.createAIAgentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [self.createAIAgentBtn addTarget:self action:@selector(createAIAgentBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.createAIAgentBtn];
    [self.createAIAgentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(SCREEN_WIDTH - 24*2);
        make.height.mas_equalTo(52);
        make.bottom.equalTo(self.view).offset(-74);
        make.centerX.equalTo(self.view);
    }];
}
-(void)addCopyrightLabel{
    self.copyrightLabel = [[ZegoInsetsLabelView alloc] initWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    NSString* copyrightContent = @"版权声明：请确认此智能体是您的原创智能体，请勿侵犯他人图像、IP或其他权利";
    self.copyrightLabel.text = copyrightContent;
    self.copyrightLabel.numberOfLines = 0;
    self.copyrightLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.copyrightLabel.font = [UIFont fontWithName:@"PingFang SC" size:12];
    self.copyrightLabel.textColor = [UIColor colorWithRed:142/255.0 green:144/255.0 blue:147/255.0 alpha:1/1.0];
    self.copyrightLabel.backgroundColor = [UIColor clearColor];
    self.copyrightLabel.clipsToBounds = YES;
    self.copyrightLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.copyrightLabel];
    
    [self.copyrightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.createAIAgentBtn.mas_width);
        make.height.mas_equalTo(34);
        make.top.equalTo(self.createAIAgentBtn.mas_bottom).offset(8);
        make.centerX.equalTo(self.createAIAgentBtn);
    }];
}


- (void)setupUI {
    [self addBackgroundColor];
    if (self.needAddNavBackIcon) {
        [self addNavBackIcon];
    }
    
    [self addPageTitle];
    
    [self addHeadAvatar];
    [self addTipsLabel];
    [self addNameComponent];
    [self addGenderComponent];
    [self addSettingDescComponent];
    [self addVoiceComponent];
    [self addCompleteComponent];
    [self addCopyrightLabel];
}

- (NSString *)generateRandomStringWithLength:(NSInteger)length {
    NSString *characters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    
    for (NSInteger i = 0; i < length; i++) {
        NSRange range = NSMakeRange(0, characters.length);
        NSInteger randomIndex = arc4random_uniform((uint32_t)range.length);
        unichar randomChar = [characters characterAtIndex:randomIndex];
        [randomString appendFormat:@"%C", randomChar];
    }
    
    return randomString;
}


// 点击事件处理方法
- (void)createAIAgentBtnClicked:(UIButton *)sender {
    sender.enabled = NO;
    CustomAgentConfig* agentConfig = [[CustomAgentConfig alloc]init];
    agentConfig.AgentTemplateId = @"";
    NSString* trimWhiteText = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimWhiteText.length == 0) {
        [self.view makeToast:@"名称不能为空，请输入名称重试"];
        return;;
    }
    
    agentConfig.Name = trimWhiteText;
    agentConfig.Avatar = self.avatarOSSUrl;
    agentConfig.Intro = self.setupContent.text;
    NSString* system = [NSString stringWithFormat:@"角色：%@\n性别：%@\n角色设定：%@\n",agentConfig.Name, self.genderContent.text,agentConfig.Intro];
    agentConfig.System = system;
    agentConfig.Sex = self.genderContent.text;

    LLMConfig* doubaoPro =  [[AppDataManager sharedInstance].appExtraConfig getLLMConfigById:@"doubaopro"];
    agentConfig.llm = doubaoPro.rawProperties;
    RawProperties* ttsRawProperties = [[RawProperties alloc] init];
    ttsRawProperties.Voice = self.ttsConfigInfo.voiceId;
    ttsRawProperties.Type = self.ttsConfigInfo.ttsConfig.rawProperties.Type;
//    ttsRawProperties.AccountSource = self.ttsConfigInfo.ttsConfig.rawProperties.AccountSource;
    agentConfig.tts = ttsRawProperties;
    
    NSString* userId = [AppDataManager sharedInstance].userID;
    NSString* newConversionId = [ZegoAiCompanionUtil generateConversationID:userId];
    NSString* randomAgentTempId = [ZegoAiCompanionUtil generateAgentTemplateId:@"atid"];
    NSString* newAgentId = [ZegoAiCompanionUtil generateAgentId:userId withAgentTempId: randomAgentTempId];
    
    
    [[ZegoAiCompanionHttpHelper sharedInstance] createConversation:newConversionId
                                                        withUserId:userId
                                                       withAgentId:newAgentId
                                                   withAgentTempId:randomAgentTempId
                                                  withCustomConfig:agentConfig
                                                      withCallback:^(NSInteger errorCode, NSString *errMsg, NSString* requestId) {
        sender.enabled = YES;
        NSLog(@"createConversation result errorCode=%ld, erroMsg=%@", (long)errorCode, errMsg);
        if (errorCode == 0) {
            NSString* errorMsg =[NSString stringWithFormat:@"创建智能体会话成功"];
            //把新创建的会话加入到
            ConversionConfigInfo* newConversion = [[ConversionConfigInfo alloc]init];
            newConversion.agentId = newAgentId;
            newConversion.userId = userId;
            newConversion.agentTemplatedId = @"";
            newConversion.isChatting = YES;
            newConversion.conversationId = newConversionId;
            newConversion.customAgentConfig = agentConfig;
            [[AppDataManager sharedInstance].conversationList addObject:newConversion];
            [self.view makeToast:errorMsg];
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }else{
            NSString* errorMsg =[NSString stringWithFormat:@"网络异常，创建智能体会话失败:ec=%ld",(long)errorCode];
            [self.view makeToast:errorMsg];
        }
    }];
}

#pragma delegate UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    [self setState:AIAgentFillItems_Intro withRemove:NO];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.placeHolderLabel.hidden = YES;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        self.placeHolderLabel.hidden = NO;
    }else{
        self.placeHolderLabel.hidden = YES;
    }
    return YES;
}

- (void)onClickSelectPhoto:(UIGestureRecognizer *) recognizer {
    [self.view endEditing:YES];
    self.photoSelectView = [[ZegoPhotoSelectView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, self.view.frame.size.width, self.view.frame.size.height)];
    self.photoSelectView.backgroundColor = [UIColor whiteColor];
    UIBezierPath* maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, SCREEN_WIDTH, 1000) byRoundingCorners:UIRectCornerTopRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(24, 24)];
    CAShapeLayer* maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame=self.photoSelectView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.photoSelectView.layer.mask = maskLayer;
    self.photoSelectView.delegate = self;
    self.popUpContainerView = [[ZegoPopUpContainerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.popUpContainerView.delegate = self;
    [self.popUpContainerView display:self.view popUpView:self.photoSelectView topOffset:SCREEN_HEIGHT - 152];
}

- (void)onClickSelectVoice:(UIGestureRecognizer *) recognizer {
    [self.view endEditing:YES];
    NSLog(@"onSettingsButtonClicked");
    if (self.settingsContainerView != nil) {
        return;
    }
    self.settingsContainerView = [[ZegoSettingsContainerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.settingsContainerView.delegate = self;
    
    [self.settingsContainerView display:self.view withTTSConfig:self.ttsConfigInfo];
}

- (void)onClickSelectGender:(UIGestureRecognizer *) recognizer {
    [self.view endEditing:YES];
    self.genderSelectView = [[ZegoGenderSelectView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, self.view.frame.size.width, self.view.frame.size.height)];
    
    UIBezierPath* maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, SCREEN_WIDTH, 1000) byRoundingCorners:UIRectCornerTopRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(24, 24)];
    CAShapeLayer* maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame=self.genderSelectView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.genderSelectView.layer.mask = maskLayer;
    self.genderSelectView.backgroundColor = [UIColor whiteColor];
    self.genderSelectView.delegate = self;
    self.genderSelectView.selectGender = self.curGender;
    
    self.popUpContainerView = [[ZegoPopUpContainerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.popUpContainerView.delegate = self;
    [self.popUpContainerView display:self.view popUpView:self.genderSelectView topOffset:SCREEN_HEIGHT - 199];
}
#pragma delegate ZegoSettingsContainerViewDelegate
-(void)onCloseTTSSettingsView:(BOOL)saved withTTSConfig:(TTSConfigInfo*)ttsConfig{
    if (saved == YES) {
        self.ttsConfigInfo = ttsConfig;
        VoiceConfig* voiceConfig = [self.ttsConfigInfo.ttsConfig getVoiceConfigById:self.ttsConfigInfo.voiceId];
        self.voiceContent.text = voiceConfig.name;
        self.voiceContent.textColor = [self getFieldTextColor];
    }
    
    self.settingsContainerView = nil;
}

#pragma delegate ZegoPopUpContainerViewDelegate
-(void)onRequestDismiss:(UIView*)curPopupView{
    if (curPopupView == self.genderSelectView) {
        [self destroyGenderSelector];
    }
}
#pragma delegate ZegoGenderSelectViewDelegate
-(void)onRequestDismissGenderSelector{
    [self.popUpContainerView dismiss];
    [self destroyGenderSelector];

}
-(void)destroyGenderSelector{
    self.curGender = self.genderSelectView.selectGender;
    if (self.curGender.length > 0) {
        [self setState:AIAgentFillItems_Gender withRemove:NO];
    }else{
        [self setState:AIAgentFillItems_Gender withRemove:YES];
    }
    self.genderContent.text = self.curGender;
    self.genderContent.textColor = [self getFieldTextColor];
    self.genderSelectView = nil;
}

-(void)setState:(FillItemsState)state withRemove:(BOOL)remove{
    if (remove) {
        self.fillItemFlag &= ~state;
    }else{
        self.fillItemFlag |= state;
    }
    
    if ((self.fillItemFlag & AIAgentFillItems_CreateNecessary) == AIAgentFillItems_CreateNecessary) {
        self.createAIAgentBtn.enabled = YES;
    }else{
        self.createAIAgentBtn.enabled = NO;
    }
}

#pragma delegate ZegoPhotoSelectViewDelegate
-(void)onRequestDismissPhotoSelector:(UIImage*)image imageLocalUrl:(NSString*)localUrl{
    if (image == nil) {
        [self.popUpContainerView dismiss];
        return;
    }
    
    NSString* userId = [AppDataManager sharedInstance].userID;
    [[ZegoAiCompanionHttpHelper sharedInstance] uploadAvatarHeaderImage:userId 
                                                         withLoacalPath:localUrl
                                                           withCallback:^(NSInteger errorCode, NSString *errMsg, NSString *requestId, NSDictionary *configDict) {
        NSLog(@"uploadAvatarHeaderImage");
        if(errorCode != 0){
            ZAALogI(@"onRequestDismissPhotoSelector", @"获取头像上传地址失败 ec=%ld, msg=%@", errorCode, errMsg ?:@"");
            NSString* errorMsg =[NSString stringWithFormat:@"获取头像上传地址失败，ec=%ld, msg=%@", (long)errorCode, errMsg];
            [self.view makeToast:errorMsg];
            return;
        }
        
        NSString* postUrl = configDict[@"PostUrl"];
        NSString* fullUrl = configDict[@"FullUrl"];
        NSDictionary* formdata = configDict[@"FormData"];
        NSString* fileName = [localUrl lastPathComponent];
        NSData* data = [NSData dataWithContentsOfFile:localUrl];
        __weak typeof(self) weakSelf = self;
        [[ZegoAiCompanionHttpHelper sharedInstance] POSTImage:postUrl path:localUrl data:data name:fileName withOtherData:formdata withCallback:^(NSInteger errorCode, NSString *errMsg) {
            if (errorCode == 0) {
                weakSelf.headAvatar.image = image;
                [weakSelf setState:AIAgentFillItems_Avatar withRemove:NO];
                self.avatarOSSUrl = fullUrl;
            }else{
                //提示用户上传头像失败,接入方请注意，这里图片是上传到即构的静态服务器上，接入方应该部署自己的静态服务器，实现该处逻辑
                NSString* errorMsg =[NSString stringWithFormat:@"上传图片失败，ec=%ld, msg=%@", (long)errorCode, errMsg];
                [self.view makeToast:errorMsg];
            }
            
            ZAALogI(@"onRequestDismissPhotoSelector", @"POSTImage postUrl=%@, localUrl=%@, ec=%ld, msg=%@",postUrl, localUrl, errorCode, errMsg ?:@"");
            //上传图片结果
            NSLog(@"POSTImage, errorCode=%ld, errMsg=%@",(long)errorCode, errMsg);
        }];
    }];
    
    [self.popUpContainerView dismiss];
    self.photoSelectView = nil;
}

#pragma delegate UITextFieldDelegate
- (void)textFieldDidChange:(UITextField *)textField{
    UITextRange *selectedRange = [textField markedTextRange];
    // 获取高亮部分,
    UITextPosition *pos = [textField positionFromPosition:selectedRange.start offset:0];
    if (selectedRange && pos) {//如果存在高亮部分, 就暂时不统计字数
        return;
    }
    NSInteger realLength = textField.text.length;
    if (realLength > 20) {
        textField.text = [textField.text substringToIndex:20];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.nameTextField == textField) {
        [self.nameTextField resignFirstResponder];
    }

    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.nameTextField == textField) {
        NSLog(@"applechang-test:获取焦点");
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.nameTextField == textField) {
        if (self.nameTextField.text.length > 0) {
            [self setState:AIAgentFillItems_Name withRemove:NO];
        }else{
            [self setState:AIAgentFillItems_Name withRemove:YES];
        }
        NSLog(@"applechang-test:失去焦点");
    }
}


- (void)showAnimatedView:(UIView *)view {
    // 设置动画的持续时间和曲线
    [UIView animateWithDuration:0.5
                      delay:0.0
                    options:UIViewAnimationOptionCurveEaseInOut
                 animations:^{
                     // 动画结束时的目标位置
                     view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
                 }
                 completion:^(BOOL finished) {
                     // 动画完成后的回调
                     NSLog(@"Animation completed.");
                 }];
}

/** json转dict*/
-(NSDictionary *)dictFromJson:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSError *error;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) {
        return nil;
    }
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
    if(error) {
        NSLog(@"dictFromJson: Error, json解析失败：%@", error);
        return nil;
    }
    return dic;
}

@end
