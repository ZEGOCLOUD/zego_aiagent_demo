//
//  ZegoTTSComponySelectView.m
//
//  Created by zego on 2024/9/9.
//

#import "ZegoTTSComponySelectView.h"
#import <Masonry/Masonry.h>
#import "ZegoTimbreCollectionViewCell.h"
#import "AppDataManager.h"
#import <YYKit/UIImageView+YYWebImage.h>
#import "ZegoAiCompanionHttpHelper.h"

@interface ZegoTTSSelectTableViewCell : UITableViewCell
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) UIImageView* llmIconView;
@property (nonatomic, strong) UILabel* llmName;
@property (nonatomic, strong) UIImageView* selectIcon;
-(void)setModel:(TTSConfig*)config;
@end

@implementation ZegoTTSSelectTableViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.backgroundColor = [UIColor clearColor];
}

-(void)setModel:(TTSConfig*)config{
    // 清除所有子视图
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    self.llmIconView = [[UIImageView alloc]init];
    NSURL* url = [NSURL URLWithString:config.icon];
    [self.llmIconView setImageWithURL:url placeholder:nil];
    self.llmIconView.contentMode =UIViewContentModeScaleToFill;
    [self addSubview:self.llmIconView];
    
    [self.llmIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(24);
        make.height.mas_equalTo(24);
        make.left.equalTo(self).offset(24);
        make.centerY.equalTo(self);
    }];
    
    self.llmName = [[UILabel alloc]init];
    self.llmName.text = config.name.uppercaseString;
    self.llmName.font = [UIFont fontWithName:@"PingFang SC" size:14];
    self.llmName.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1/1.0];
    [self addSubview:self.llmName];
    
    [self.llmName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.left.equalTo(self.llmIconView.mas_right).offset(8);
        make.centerY.equalTo(self);
    }];
    
    self.selectIcon = [[UIImageView alloc]init];
    self.selectIcon.contentMode = UIViewContentModeScaleToFill;
    self.selectIcon.image = [UIImage imageNamed:@"icon_chose"];
    [self addSubview:self.selectIcon];
    
    [self.selectIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(24);
        make.width.mas_equalTo(24);
        make.right.equalTo(self).offset(-16);
        make.centerY.equalTo(self);
    }];
}

-(void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    if (_isSelected) {
        self.selectIcon.hidden = NO;
    }else{
        self.selectIcon.hidden = YES;
    }
}
@end


@interface ZegoTTSComponySelectView ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *TTSTableView;
@property (nonatomic, strong) UIImageView* backIconView;
@property (nonatomic, strong) UILabel* selectTTSTitle;
@property (nonatomic, strong) UILabel* moreComponyTips;
@property (nonatomic, strong)NSIndexPath* selectedIndexPath;
@end

@implementation ZegoTTSComponySelectView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

-(void)setTtsList:(NSMutableArray<TTSConfig *> *)ttsList{
    _ttsList = ttsList;
    //简单一点搞
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    self.backIconView = [[UIImageView alloc]init];
    self.backIconView.contentMode = UIViewContentModeScaleToFill;
    self.backIconView.image = [UIImage imageNamed:@"icon_back"];
    [self addSubview:self.backIconView];
    [self.backIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(28);
        make.height.mas_equalTo(28);
        make.left.equalTo(self).offset(20);
        make.top.equalTo(self).offset(23);
    }];
    
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickSelectTTS:)];
    [self.backIconView addGestureRecognizer:tapGesture1];
    [self.backIconView setUserInteractionEnabled:YES];
    
    
    self.selectTTSTitle = [[UILabel alloc]init];
    self.selectTTSTitle.text = @"选择语音合成厂商";
    self.selectTTSTitle.font = [UIFont fontWithName:@"PingFang SC" size:18];
    self.selectTTSTitle.textColor = [UIColor colorWithRed:42/255.0 green:42/255.0 blue:42/255.0 alpha:1/1.0];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickSelectTTS:)];
    [self.selectTTSTitle addGestureRecognizer:tapGesture];
    [self.selectTTSTitle setUserInteractionEnabled:YES];
    
    [self addSubview:self.selectTTSTitle];
    [self.selectTTSTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backIconView);
        make.height.mas_equalTo(22);
        make.left.equalTo(self.backIconView.mas_right).offset(2);
    }];
    
    [self setupTTSTableView];
    [self.TTSTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self);
        make.top.equalTo(self).offset(63);
        make.height.equalTo(self).offset(63);
    }];
    [self.TTSTableView reloadData];
    
    self.moreComponyTips = [[UILabel alloc]init];
    self.moreComponyTips.text = @"更多厂商，敬请期待...";
    self.moreComponyTips.textAlignment = NSTextAlignmentCenter;
    self.moreComponyTips.font = [UIFont fontWithName:@"PingFang SC" size:12];
    self.moreComponyTips.textColor = [UIColor colorWithRed:137/255.0 green:138/255.0 blue:141/255.0 alpha:1/1.0];
    [self addSubview:self.moreComponyTips];
    [self.moreComponyTips mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.TTSTableView);
        make.height.mas_equalTo(17);
        make.width.mas_equalTo(118);
        make.top.equalTo(self).offset(246);
    }];
}

- (void)onClickSelectTTS:(UIGestureRecognizer *) recognizer {
    [self.delegate onRequestSwitchSettingsView];
}

-(void)setupTTSTableView{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.TTSTableView = tableView;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.estimatedRowHeight = 0.0;
    tableView.estimatedSectionFooterHeight = 0.0;
    tableView.estimatedSectionHeaderHeight = 0.0;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundView = nil;
    
    [tableView registerClass:[ZegoTTSSelectTableViewCell class] forCellReuseIdentifier:@"ZegoTTSSelectTableViewCell"];
    [self addSubview:self.TTSTableView];
}

#pragma delegate UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.ttsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ZegoTTSSelectTableViewCell";
    ZegoTTSSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ZegoTTSSelectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    TTSConfig* config = [self.ttsList objectAtIndex:indexPath.row];
    [cell setModel:config];
    if ([config.Id isEqualToString: self.selectTTSId]) {
        cell.isSelected = YES;
        self.selectedIndexPath = indexPath;
    }else{
        cell.isSelected = NO;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath != self.selectedIndexPath) {
        if (self.selectedIndexPath) {
            [tableView deselectRowAtIndexPath:self.selectedIndexPath animated:YES];
            ZegoTTSSelectTableViewCell *cell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
            cell.isSelected = NO;
        }
        self.selectedIndexPath = indexPath;
        TTSConfig* config = [self.ttsList objectAtIndex:self.selectedIndexPath.row];
        self.selectTTSId = config.Id;
        ZegoTTSSelectTableViewCell *cell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
        cell.isSelected = YES;
        [self.delegate onRequestSwitchSettingsView];
    }
}
@end
