//
//  ZegoGenderSelectView.m
//
//  Created by zego on 2024/9/9.
//

#import "ZegoGenderSelectView.h"
#import <Masonry/Masonry.h>
#import "ZegoTimbreCollectionViewCell.h"
#import "AppDataManager.h"
#import <YYKit/UIImageView+YYWebImage.h>

@interface ZegoGenderSelectTableViewCell : UITableViewCell
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) UILabel* genderName;
@property (nonatomic, strong) UIImageView* selectIcon;
-(void)setModel:(NSString*)gender;
@end

@implementation ZegoGenderSelectTableViewCell

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

-(void)setModel:(NSString*)gender{
    // 清除所有子视图
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    self.genderName = [[UILabel alloc]init];
    self.genderName.text = gender;
    self.genderName.font = [UIFont fontWithName:@"PingFang SC" size:14];
    self.genderName.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1/1.0];
    [self addSubview:self.genderName];
    
    [self.genderName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.left.equalTo(self).offset(26);
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


@interface ZegoGenderSelectView ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *TTSTableView;
@property (nonatomic, strong) UIImageView* backIconView;
@property (nonatomic, strong) UILabel* selectTTSTitle;
@property (nonatomic, strong) NSMutableArray<NSString *> *genderList;
@property (nonatomic, strong) NSIndexPath* selectedIndexPath;
@end

@implementation ZegoGenderSelectView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        self.genderList = [[NSMutableArray alloc]initWithObjects:@"男生",@"女生", nil];
    }
    return self;
}

-(void)setupUI{
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
    
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickSelectGender:)];
    [self.backIconView addGestureRecognizer:tapGesture1];
    [self.backIconView setUserInteractionEnabled:YES];
    
    
    self.selectTTSTitle = [[UILabel alloc]init];
    self.selectTTSTitle.text = @"选择性别";
    self.selectTTSTitle.font = [UIFont fontWithName:@"PingFang SC" size:18];
    self.selectTTSTitle.textColor = [UIColor colorWithRed:42/255.0 green:42/255.0 blue:42/255.0 alpha:1/1.0];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickSelectGender:)];
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
}

- (void)onClickSelectGender:(UIGestureRecognizer *) recognizer {
    [self.delegate onRequestDismissGenderSelector];
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
    
    [tableView registerClass:[ZegoGenderSelectTableViewCell class] forCellReuseIdentifier:@"ZegoGenderSelectTableViewCell"];
    [self addSubview:self.TTSTableView];
}

#pragma delegate UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.genderList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ZegoGenderSelectTableViewCell";
    ZegoGenderSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ZegoGenderSelectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString* gender = [self.genderList objectAtIndex:indexPath.row];
    [cell setModel:gender];
    if (self.selectGender == gender) {
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
            ZegoGenderSelectTableViewCell *cell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
            cell.isSelected = NO;
        }
        self.selectedIndexPath = indexPath;
        NSString* gender = [self.genderList objectAtIndex:indexPath.row];
        self.selectGender = gender;
        ZegoGenderSelectTableViewCell *cell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
        cell.isSelected = YES;
        [self.delegate onRequestDismissGenderSelector];
    }
}
@end
