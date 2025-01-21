//
//  ZegoStaticsLogView.m
//
//  Created by zego on 2024/9/4.
//

#import "ZegoStaticsLogView.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>
#import <Masonry/Masonry.h>
#import "ZegoAskAnswerTableViewCell.h"
#import "PerfStaticsHelper.h"
#import "AppDataManager.h"
#import "PlayAudioRecorderUtil.h"
#import "AIAgentLogUtil.h"

@interface ZegoStaticsLogView ()<UITableViewDataSource, UITableViewDelegate, ZegoCustomAudioProcessHandler>
@property(nonatomic, strong)UITableView* askAnswerPerfTable;
@property(nonatomic, strong)UILabel* roomInfo;
@property(nonatomic, strong)UILabel* header;
@property(nonatomic, strong)UILabel* close;
@property(nonatomic, strong)UIButton* switchAudioRecoder;
@property(nonatomic, strong)UIButton* swithDumpAudio;
@property(nonatomic, strong)UIButton* swithLocalMute;
@property(nonatomic, strong)NSString* roomId;

@property (nonatomic, strong) UIImageView *closeImg;
@end

@implementation ZegoStaticsLogView
-(instancetype)initWithRoomID:(NSString*)roomId{
    if (self = [super init]) {
        self.roomId = roomId;
        [self setupUI];
        [self initZegoExpressExtension];
    }
    return self;
}

-(void)dealloc{
    [[ZegoExpressEngine sharedEngine] enableCustomAudioRemoteProcessing:NO config:nil];
    [[PlayAudioRecorderUtil sharedInstance] stop];
}

-(void)reload{
    [self.askAnswerPerfTable reloadData];
    NSInteger total = [PerfStaticsHelper sharedInstance].askAnswerStaticsList.count;
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:total-1 inSection:0];
    [self.askAnswerPerfTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}


-(void)initZegoExpressExtension{
    // 开启音频拉流后处理 & 设置采样率和每片回调音频的长度
    int chunk_ms = 40;
    ZegoCustomAudioProcessConfig *config = [ZegoCustomAudioProcessConfig new];
    config.sampleRate = ZegoAudioSampleRate16K;
    config.channel = ZegoAudioChannelMono;
    config.samples = 16000 / 1000 * chunk_ms;
    [[ZegoExpressEngine sharedEngine] enableCustomAudioRemoteProcessing:YES config:config];
    /**************************************/
}


- (void)switchAudioRecoder: (NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSNumber* isOn = userInfo[@"on"];
    if([isOn boolValue]){
        [self enablePlayAudioHandler:YES];
    }else{
        [self enablePlayAudioHandler:NO];
    }
}

- (void)enablePlayAudioHandler:(BOOL)enable {
    if (enable) {
        //此处是用来做外部采集的，外部接入方请注释
        [[ZegoExpressEngine sharedEngine] setCustomAudioProcessHandler:self];
        NSString *logPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/PlayStreamRecords"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDir = NO;
        BOOL existed = [fileManager fileExistsAtPath:logPath isDirectory:&isDir];
        NSError* error = nil;
        if ( !(isDir == YES && existed == YES) ){
            [fileManager createDirectoryAtPath:logPath withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if(error != nil){
            return;
        }
        
        ZegoNetworkTimeInfo* curNetworkTime = [[ZegoExpressEngine sharedEngine] getNetworkTimeInfo];
        uint64_t curTs = curNetworkTime.timestamp;
        NSTimeInterval time = curTs / 1000;
        NSDate* detailData = [NSDate dateWithTimeIntervalSince1970:time];
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-DD-HH-mm-ss"];
        NSString* currentDateStr = [dateFormatter stringFromDate:detailData];
        NSString* saveFilePath = [NSString stringWithFormat:@"%@/%@.wav",logPath, currentDateStr];
        [[PlayAudioRecorderUtil sharedInstance] start:saveFilePath withChannels:ZegoAudioChannelMono withSampleRate:ZegoAudioSampleRate16K withBitsPerSample:16];
    }else{
        [[ZegoExpressEngine sharedEngine] setCustomAudioProcessHandler:nil];
        [[PlayAudioRecorderUtil sharedInstance] stop];
    }
}

- (void)switchDumpAudioClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    [self enableDumpData:sender.selected];
}

- (void)enableDumpData:(BOOL)enable {
    if (enable) {
        //开始音频数据转储
        ZegoDumpDataConfig* config = [[ZegoDumpDataConfig alloc]init];
        config.dataType = ZegoDumpDataTypeAudio;
        [[ZegoExpressEngine sharedEngine] startDumpData:config];
    }else{
        //停止音频数据转储
        [[ZegoExpressEngine sharedEngine] stopDumpData];
    }
}

- (void)switchAudioRecoderClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    [self enablePlayAudioHandler:sender.selected];
}

//该函数是用来做问题定位的，外部接入方请忽略
- (void)onProcessRemoteAudioData:(unsigned char *_Nonnull)data
                      dataLength:(unsigned int)dataLength
                           param:(ZegoAudioFrameParam *)param
                        streamID:(NSString *)streamID
                       timestamp:(double)timestamp{
    ZAALogI(@"onProcessRemoteAudioData", @"writeToFile, timestamp=%f, dataLength=%d", timestamp, dataLength);
    [[PlayAudioRecorderUtil sharedInstance] writeToFile:data dataLenght:dataLength];
}

- (void)switchLocalMuteClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc]init];
    userInfo[@"on"] = [NSNumber numberWithBool:sender.selected];
   [[NSNotificationCenter defaultCenter] postNotificationName:@"switch_local_mute" object:self userInfo:userInfo];
}

#pragma delegate UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [PerfStaticsHelper sharedInstance].askAnswerStaticsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ZegoAskAnswerTableViewCell";
    ZegoAskAnswerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ZegoAskAnswerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [cell setCellModel:indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
    if (self.delegate) {
        [self.delegate onCloseStaticsLogView];
    }
}

- (void)setupUI {
    self.roomInfo = [[UILabel alloc]init];
    NSString* roomID = self.roomId;
    NSString* userID = [AppDataManager sharedInstance].userID;
    
    self.roomInfo.text = [NSString stringWithFormat:@"%@", roomID];
    self.roomInfo.textAlignment = NSTextAlignmentLeft;
    
    self.roomInfo.font = [UIFont fontWithName:@"PingFang SC" size:12];
    self.roomInfo.textColor = [UIColor greenColor];
    [self addSubview:self.roomInfo];
    
    [self.roomInfo mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.width.mas_equalTo(self).offset(-30);
        make.height.mas_equalTo(20);
        make.left.equalTo(self).offset(5);
        make.top.equalTo(self);
    }];
    
    self.header = [[UILabel alloc]init];
    self.header.text = @"seq｜当次｜服务端发送｜终端端收到｜均值(单位:ms)";
    self.header.textAlignment = NSTextAlignmentLeft;
    
    self.header.font = [UIFont fontWithName:@"PingFang SC" size:12];
    self.header.textColor = [UIColor greenColor];
    [self addSubview:self.header];
    
    [self.header mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self).offset(-30);
        make.height.mas_equalTo(20);
        make.left.equalTo(self).offset(5);
        make.top.equalTo(self.roomInfo.mas_bottom).offset(3);
    }];
    
    
    self.closeImg = [[UIImageView alloc]init];
    self.closeImg.contentMode = UIViewContentModeScaleToFill;
    self.closeImg.image = [UIImage imageNamed:@"icon_close"];
    self.closeImg.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.closeImg addGestureRecognizer:tapGesture];
    [self addSubview:self.closeImg];
    
    [self.closeImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(22);
        make.height.mas_equalTo(22);
        make.right.equalTo(self.mas_right).offset(2);
        make.top.equalTo(self).offset(2);
    }];
    
    
    self.switchAudioRecoder = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.switchAudioRecoder setTitle:@"录拉流音频" forState:UIControlStateNormal];
    [self.switchAudioRecoder setTitle:@"录推流音频" forState:UIControlStateSelected];
    self.switchAudioRecoder.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.switchAudioRecoder.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:12];
    UIImage* uncheckedImag = [UIImage imageNamed:@"unchecked"];
    UIImage* checkedImag = [UIImage imageNamed:@"checked"];
    [self.switchAudioRecoder setImage:uncheckedImag forState:UIControlStateNormal];
    [self.switchAudioRecoder setImage:checkedImag forState:UIControlStateSelected];
    self.switchAudioRecoder.selected = NO;
    [self addSubview:self.switchAudioRecoder];
    [self.switchAudioRecoder addTarget:self action:@selector(switchAudioRecoderClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.switchAudioRecoder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(22);
        make.left.equalTo(self.roomInfo.mas_right).offset(2);
        make.top.equalTo(self).offset(2);
    }];
    
    
    self.swithDumpAudio = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.swithDumpAudio setTitle:@"dumpData" forState:UIControlStateNormal];
    [self.swithDumpAudio setTitle:@"dumpData" forState:UIControlStateSelected];
    self.swithDumpAudio.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.swithDumpAudio.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:12];
    [self.swithDumpAudio setImage:uncheckedImag forState:UIControlStateNormal];
    [self.swithDumpAudio setImage:checkedImag forState:UIControlStateSelected];
    self.swithDumpAudio.selected = NO;
    [self addSubview:self.swithDumpAudio];
    [self.swithDumpAudio addTarget:self action:@selector(switchDumpAudioClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.swithDumpAudio mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(22);
        make.left.equalTo(self.switchAudioRecoder.mas_right).offset(2);
        make.top.equalTo(self).offset(2);
    }];
    
    self.swithLocalMute = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.swithLocalMute setTitle:@"vad静音" forState:UIControlStateNormal];
    [self.swithLocalMute setTitle:@"vad静音" forState:UIControlStateSelected];
    self.swithLocalMute.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.swithLocalMute.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:12];
    [self.swithLocalMute setImage:uncheckedImag forState:UIControlStateNormal];
    [self.swithLocalMute setImage:checkedImag forState:UIControlStateSelected];
    self.swithLocalMute.selected = YES; //默认是打开的
    [self addSubview:self.swithLocalMute];
    [self.swithLocalMute addTarget:self action:@selector(switchLocalMuteClick:) 
                  forControlEvents:UIControlEventTouchUpInside];
    [self.swithLocalMute mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(22);
        make.left.equalTo(self.swithDumpAudio.mas_right).offset(2);
        make.top.equalTo(self).offset(2);
    }];
    
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.askAnswerPerfTable = tableView;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.estimatedRowHeight = 0.0;
    tableView.estimatedSectionFooterHeight = 0.0;
    tableView.estimatedSectionHeaderHeight = 0.0;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundView = nil;
    
    [tableView registerClass:[ZegoAskAnswerTableViewCell class] forCellReuseIdentifier:@"ZegoAskAnswerTableViewCell"];
    [self addSubview:self.askAnswerPerfTable];
    
    [self.askAnswerPerfTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.header.mas_bottom);
        make.width.mas_equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
}
@end
