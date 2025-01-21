//
//  ZegoAICompanionSettingsView.m
//
//  Created by zego on 2024/9/9.
//

#import "ZegoAICompanionSettingsView.h"
#import <Masonry/Masonry.h>
#import "ZegoTimbreCollectionViewCell.h"
#import "AppDataManager.h"
#import <YYKit/UIImageView+YYWebImage.h>
#import "ZegoAiCompanionHttpHelper.h"
#import "UIView+Toast.h"
#import "ZegoAiCompanionUtil.h"

@interface ZegoAICompanionSettingsView ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UIImageView* settingIcon;
@property (nonatomic, strong) UILabel* settingLabel;
@property (nonatomic, strong) UILabel* voiceSynManufacturerTitle;
@property (nonatomic, strong) UIImageView* voicefacturerIcon;
@property (nonatomic, strong) UILabel* voiceSynManufacturer;
@property (nonatomic, strong) UIView* horizontalLine;

@property (nonatomic, strong) UIImageView* ttsArrowIcon;
@property (nonatomic, strong) UILabel* languageLabel;
@property (nonatomic, strong) UILabel* timbreLabel;
@property (nonatomic, strong) UICollectionView *langCollectionView;
@property (nonatomic, strong) UICollectionView *timbreCollectionView;
@property (nonatomic, strong) NSMutableArray<VoiceConfig*> *voiceCollectionViewData;
@property (nonatomic, strong) NSMutableArray<LanguageConfig*> *langCollectionViewData;
@property (nonatomic, strong) NSIndexPath *voiceSelectedIndexPath;
@property (nonatomic, strong) NSIndexPath *langSelectedIndexPath;
@property (nonatomic, strong) NSString* voiceId;
@property (nonatomic, strong) NSString* langId;

@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *cancelButton;

@end

@implementation ZegoAICompanionSettingsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 设置颜色
    [color setFill];
    
    // 绘制矩形
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//-(void)setCustomAgentConfig:(CharacterConfig*)characterConfig{
//    TTSConfig* ttsConfig = [[AppDataManager sharedInstance].appExtraConfig getTTSConfigByProperties:characterConfig.curAgentConfig.tts];
//    if (ttsConfig == nil) {
//        return;
//    }
//    
//    self.ttsId = ttsConfig.Id;
//    self.voiceId =characterConfig.curAgentConfig.tts.Voice;
//    VoiceConfig* config = [ttsConfig getVoiceConfigById:self.voiceId];
//    self.langId = config.language.firstObject.langId;
//    [self setupUI];
//    [self updateData];
//}

-(void)setConfigInfo:(NSString*)ttsId 
         withVoiceId:(NSString*)voiceId
          withLangId:(NSString*)langId{
    self.ttsId = ttsId;
    if (voiceId == nil) {
        TTSConfig* ttsConfig = [[AppDataManager sharedInstance].appExtraConfig getTTSConfigById:self.ttsId];
        self.voiceId = ttsConfig.voiceList.firstObject.voiceId;
    }else{
        self.voiceId = voiceId;
    }
    if(langId == nil){
        TTSConfig* ttsConfig = [[AppDataManager sharedInstance].appExtraConfig getTTSConfigById:self.ttsId];
        VoiceConfig* config = [ttsConfig getVoiceConfigById:self.voiceId];
        self.langId = config.language.firstObject.langId;
    }else{
        self.langId = langId;
    }
    
    [self setupUI];
    [self updateData];
}

-(void)updateData{
    TTSConfig* ttsConfig = [[AppDataManager sharedInstance].appExtraConfig getTTSConfigById:self.ttsId];
    self.voiceCollectionViewData = [[NSMutableArray alloc]initWithCapacity:ttsConfig.voiceList.count];
    for (VoiceConfig* item in ttsConfig.voiceList) {
        [self.voiceCollectionViewData addObject:item];
    }
    [self.timbreCollectionView reloadData];
    
    VoiceConfig* voiceConfig = [ttsConfig getVoiceConfigById:self.voiceId];
    self.langCollectionViewData = [[NSMutableArray alloc]initWithCapacity:voiceConfig.language.count];
    for (LanguageConfig* item in voiceConfig.language) {
        [self.langCollectionViewData addObject:item];
    }
    [self.langCollectionView reloadData];
}

- (void)setupLangCollectionView {
    // 创建 UICollectionView
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    int cell_width = (self.bounds.size.width - 24*2 - 13)/2;
    layout.itemSize = CGSizeMake(cell_width, 44); // 单个 cell 的大小
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    
    self.langCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:layout];
    self.langCollectionView.backgroundColor = [UIColor whiteColor];
    self.langCollectionView.delegate = self;
    self.langCollectionView.dataSource = self;
    [self.langCollectionView registerClass:[ZegoTimbreCollectionViewCell class] forCellWithReuseIdentifier:@"langCollectionView"];
    [self addSubview:self.langCollectionView];
    
}

- (void)setupTimbreCollectionView {
    // 创建 UICollectionView
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    int cell_width = (self.bounds.size.width - 24*2 - 13)/2;
    layout.itemSize = CGSizeMake(cell_width, 44); // 单个 cell 的大小
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    
    self.timbreCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:layout];
    self.timbreCollectionView.backgroundColor = [UIColor whiteColor];
    self.timbreCollectionView.delegate = self;
    self.timbreCollectionView.dataSource = self;
    [self.timbreCollectionView registerClass:[ZegoTimbreCollectionViewCell class] forCellWithReuseIdentifier:@"ZegoTimbreCollectionViewCell"];
    [self addSubview:self.timbreCollectionView];
}

-(void)setupUI{
    //简单一点搞，不考虑性能
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    self.settingIcon =  [[UIImageView alloc] init];
    self.settingIcon.contentMode = UIViewContentModeScaleToFill;
    self.settingIcon.image = [UIImage imageNamed:@"icon_setting"];
    [self addSubview:self.settingIcon];
    
    self.settingLabel = [[UILabel alloc]init];
    self.settingLabel.text = @"声音设置";
    self.settingLabel.font = [UIFont fontWithName:@"PingFang SC" size:18];
    self.settingLabel.textColor = [UIColor colorWithRed:42/255.0 green:42/255.0 blue:42/255.0 alpha:1/1.0];
    [self addSubview:self.settingLabel];
    
    self.voiceSynManufacturerTitle = [[UILabel alloc]init];
    self.voiceSynManufacturerTitle.text = @"语音合成厂商";
    self.voiceSynManufacturerTitle.font = [UIFont fontWithName:@"PingFang SC" size:15];
    self.voiceSynManufacturerTitle.textColor = [UIColor colorWithRed:42/255.0 green:42/255.0 blue:42/255.0 alpha:1/1.0];
    [self addSubview:self.voiceSynManufacturerTitle];
    
    TTSConfig* ttsConfig = [[AppDataManager sharedInstance].appExtraConfig getTTSConfigById:self.ttsId];
    self.voicefacturerIcon = [[UIImageView alloc]init];
    NSURL* url = [NSURL URLWithString:ttsConfig.icon];
    [self.voicefacturerIcon setImageWithURL:url placeholder:nil];
    [self addSubview:self.voicefacturerIcon];
    
    self.voiceSynManufacturer = [[UILabel alloc]init];
    self.voiceSynManufacturer.text = ttsConfig.name.uppercaseString;
    self.voiceSynManufacturer.font = [UIFont fontWithName:@"PingFang SC" size:15];
    self.voiceSynManufacturer.textColor = [UIColor colorWithRed:42/255.0 green:42/255.0 blue:42/255.0 alpha:1/1.0];
    [self addSubview:self.voiceSynManufacturer];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickSelectTTS:)];
    [self.voiceSynManufacturer addGestureRecognizer:tapGesture];
    [self.voiceSynManufacturer setUserInteractionEnabled:YES];
    

    self.ttsArrowIcon = [[UIImageView alloc] init];
    self.ttsArrowIcon.contentMode = UIViewContentModeScaleToFill;
    self.ttsArrowIcon.image = [UIImage imageNamed:@"tts_arrow"];
    [self addSubview:self.ttsArrowIcon];
    
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickSelectTTS:)];
    [self.ttsArrowIcon addGestureRecognizer:tapGesture1];
    [self.ttsArrowIcon setUserInteractionEnabled:YES];
    
    self.horizontalLine = [[UIView alloc]init];
    self.horizontalLine.backgroundColor = [UIColor colorWithRed:239/255.0 green:240/255.0 blue:242/255.0 alpha:1];
    [self addSubview:self.horizontalLine];
    
    
    
//    self.languageLabel = [[UILabel alloc]init];
//    self.languageLabel.text = @"语言";
//    self.languageLabel.font = [UIFont fontWithName:@"PingFang SC" size:14];
//    self.languageLabel.textColor = [UIColor colorWithRed:137/255.0 green:138/255.0 blue:141/255.0 alpha:1/1.0];
//    [self addSubview:self.languageLabel];
//    
//    [self setupLangCollectionView];
    
    self.timbreLabel = [[UILabel alloc]init];
    self.timbreLabel.text = @"音色";
    self.timbreLabel.font = [UIFont fontWithName:@"PingFang SC" size:14];
    self.timbreLabel.textColor = [UIColor colorWithRed:137/255.0 green:138/255.0 blue:141/255.0 alpha:1/1.0];
    [self addSubview:self.timbreLabel];
    
    [self setupTimbreCollectionView];
    
    self.saveButton = [[UIButton alloc]init];
    [self.saveButton setTitle: @"保存" forState:UIControlStateNormal];
    self.saveButton.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:15];
    //    self.saveButton.titleLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1/1.0];
    self.saveButton.layer.cornerRadius = 16;
    self.saveButton.backgroundColor = [UIColor colorWithRed:0 green:85/255.0 blue:255/255.0 alpha:1.0];
    [self.saveButton addTarget:self action:@selector(saveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.saveButton];
    
    self.cancelButton = [[UIButton alloc]init];
    [self.cancelButton setTitle: @"取消" forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:15];
    [self.cancelButton setTitleColor:[UIColor colorWithRed:22/255.0 green:22/255.0 blue:22/255.0 alpha:1/1.0] forState:UIControlStateNormal];
    self.cancelButton.layer.cornerRadius = 16;
    self.cancelButton.layer.borderColor = [UIColor colorWithRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:1.0].CGColor;
    self.cancelButton.layer.borderWidth = 1;
    self.cancelButton.backgroundColor = [UIColor whiteColor];
    [self.cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cancelButton];
}

- (void)onClickSelectTTS:(UIGestureRecognizer *) recognizer {
    [self.delegate onRequestSwitchTTSSelectView];
}

- (void)saveButtonClicked:(UIButton *)sender {
    [self dismissModalView:YES];
}

- (void)dismissModalView:(BOOL)saved {
    if (self.delegate) {
        TTSConfigInfo* ttsConfigInfo = nil;
        if (saved) {
            ttsConfigInfo = [[TTSConfigInfo alloc]init];
            ttsConfigInfo.ttsConfig = [[AppDataManager sharedInstance].appExtraConfig getTTSConfigById:self.ttsId];
            ttsConfigInfo.voiceId = self.voiceId;
        }
        [self.delegate onRequestDismiss: saved withTTSConfig:ttsConfigInfo];
    }
}

// 取消退出
- (void)cancelButtonClicked:(UIButton *)sender {
    [self dismissModalView: NO];
}

-(void)layoutSubviews{
    [self.settingIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(20);
        make.top.equalTo(self).offset(25.31);
        make.left.equalTo(self).offset(24);
    }];
    
    [self.settingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(22);
        make.left.equalTo(self.settingIcon.mas_right).offset(7);
        make.centerY.equalTo(self.settingIcon);
    }];
    
    [self.voiceSynManufacturerTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(76);
        make.left.equalTo(self).offset(24);
    }];
    
    [self.ttsArrowIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-24);
        make.centerY.equalTo(self.voiceSynManufacturerTitle);
        make.width.mas_equalTo(24);
        make.height.mas_equalTo(24);
    }];
    
    [self.voiceSynManufacturer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.ttsArrowIcon.mas_left).offset(-6);
        make.centerY.equalTo(self.voiceSynManufacturerTitle);
    }];
    
    [self.voicefacturerIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.voiceSynManufacturer.mas_left).offset(-6);
        make.centerY.equalTo(self.voiceSynManufacturerTitle);
        make.width.mas_equalTo(24);
        make.height.mas_equalTo(24);
    }];
    
    [self.horizontalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self);
        make.height.mas_equalTo(0.5);
        make.top.mas_equalTo(self.voiceSynManufacturer.mas_bottom).offset(30);
    }];
    
    int tableWidth = SCREEN_WIDTH - 24*2;
    
//    [self.languageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self).offset(138);
//        make.left.equalTo(self).offset(24);
//    }];
//
//    [self.langCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.languageLabel.mas_bottom).offset(6);
//        make.left.equalTo(self).offset(24);
//        make.width.mas_equalTo(tableWidth);
//        make.height.mas_equalTo(44);
//    }];
    
    [self.timbreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(138);
        make.left.equalTo(self).offset(24);
    }];
    

    [self.timbreCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timbreLabel.mas_bottom).offset(6);
        make.left.equalTo(self).offset(24);
        make.width.mas_equalTo(tableWidth);
        make.height.mas_equalTo(101);
    }];
    
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self).offset(-88);
        make.left.equalTo(self).offset(24);
        make.width.mas_equalTo(tableWidth);
        make.height.mas_equalTo(48);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self).offset(-32);
        make.left.equalTo(self).offset(24);
        make.width.mas_equalTo(tableWidth);
        make.height.mas_equalTo(48);
    }];
    
}

#pragma delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    NSInteger count = 0;
    if (collectionView == self.timbreCollectionView) {
        count = self.voiceCollectionViewData.count;
    }else if(collectionView == self.langCollectionView){
        count = self.langCollectionViewData.count;
    }
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView 
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZegoTimbreCollectionViewCell *cell = nil;
    if (collectionView == self.timbreCollectionView) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZegoTimbreCollectionViewCell" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[ZegoTimbreCollectionViewCell alloc]init];
        }
        VoiceConfig* config = [self.voiceCollectionViewData objectAtIndex:indexPath.row];
        cell.itemTitle = config.name;
        
        if ([self.voiceId isEqualToString:config.voiceId ]) {
            cell.isSelected = YES;
            self.voiceSelectedIndexPath = indexPath;
        }else{
            cell.isSelected = NO;
        }
    }else if(collectionView == self.langCollectionView){
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"langCollectionView" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[ZegoTimbreCollectionViewCell alloc]init];
        }
        
        LanguageConfig* langConfig = [self.langCollectionViewData objectAtIndex:indexPath.row];
        cell.itemTitle = langConfig.name;
        
        if ([self.langId isEqualToString: langConfig.langId]) {
            cell.isSelected = YES;
            self.langSelectedIndexPath = indexPath;
        }else{
            cell.isSelected = NO;
        }
    }
    return cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.timbreCollectionView) {
        if (indexPath != self.voiceSelectedIndexPath) {
            // 如果不是同一个 item，取消之前选中的 item 的选中状态
            if (self.voiceSelectedIndexPath) {
                [collectionView deselectItemAtIndexPath:self.voiceSelectedIndexPath animated:YES];
                ZegoTimbreCollectionViewCell *cell = [collectionView cellForItemAtIndexPath:self.voiceSelectedIndexPath];
                cell.isSelected = NO;
            }
            self.voiceSelectedIndexPath = indexPath;
            ZegoTimbreCollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            cell.isSelected = YES;
            
            VoiceConfig* config = [self.voiceCollectionViewData objectAtIndex:indexPath.row];
            self.voiceId = config.voiceId;
            [self.langCollectionViewData removeAllObjects];
            for (LanguageConfig* item in config.language) {
                [self.langCollectionViewData addObject:item];
            }
            [self.langCollectionView reloadData];
        }
    }else if(collectionView == self.langCollectionView){
        if (indexPath != self.langSelectedIndexPath) {
            // 如果不是同一个 item，取消之前选中的 item 的选中状态
            if (self.langSelectedIndexPath) {
                [collectionView deselectItemAtIndexPath:self.langSelectedIndexPath animated:YES];
                ZegoTimbreCollectionViewCell *cell = [collectionView cellForItemAtIndexPath:self.langSelectedIndexPath];
                cell.isSelected = NO;
            }
            self.langSelectedIndexPath = indexPath;
            LanguageConfig* langConfig = [self.langCollectionViewData objectAtIndex:indexPath.row];
            self.langId = langConfig.langId;
            ZegoTimbreCollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            cell.isSelected = YES;
        }
    }

}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int cell_width = (self.bounds.size.width - 24*2 - 13)/2;
    return CGSizeMake(cell_width, 44);
}

@end
