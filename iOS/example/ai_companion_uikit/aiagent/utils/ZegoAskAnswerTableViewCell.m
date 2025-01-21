//
//  ZegoAskAnswerTableViewCell.m
//
//  Created by zego on 2024/5/13.
//  Copyright © 2024 Zego. All rights reserved.
//

#import "ZegoAskAnswerTableViewCell.h"
#import <Masonry/Masonry.h>
#import "PerfStaticsHelper.h"

@interface ZegoAskAnswerTableViewCell ()
@property(nonatomic, strong)UILabel* seqLabel;
@property(nonatomic, strong)UILabel* curOverhead;
@property(nonatomic, strong)UILabel* minOverhead;
@property(nonatomic, strong)UILabel* maxOverhead;
@property(nonatomic, strong)UILabel* meanOverhead;
@property(nonatomic, strong)UILabel* seiTimeStamp;
@property(nonatomic, strong)UILabel* curTimeStamp;
@end

@implementation ZegoAskAnswerTableViewCell

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

-(void)setCellModel:(NSInteger)rowIndex{
    // 清除所有子视图
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    AskAnswerStatics* item = [[PerfStaticsHelper sharedInstance].askAnswerStaticsList objectAtIndex:rowIndex];
    
    
    self.seqLabel = [[UILabel alloc]init];
    self.seqLabel.text = [NSString stringWithFormat:@"%lld", item.seq_id];
    self.seqLabel.textAlignment = NSTextAlignmentLeft;
    
    self.seqLabel.font = [UIFont fontWithName:@"PingFang SC" size:12];
    self.seqLabel.textColor = [UIColor greenColor];
    [self addSubview:self.seqLabel];
    
    [self.seqLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(30);
        make.left.equalTo(self).offset(5);
        make.centerY.equalTo(self);
    }];
    
    
    self.curOverhead = [[UILabel alloc]init];
    self.curOverhead.text = [NSString stringWithFormat:@"%lld", item.overhead];
    self.curOverhead.textAlignment = NSTextAlignmentLeft;
    
    self.curOverhead.font = [UIFont fontWithName:@"PingFang SC" size:12];
    self.curOverhead.textColor = [UIColor greenColor];
    [self addSubview:self.curOverhead];
    
    [self.curOverhead mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(50);
        make.left.equalTo(self.seqLabel.mas_right);
        make.centerY.equalTo(self);
    }];
    
    self.seiTimeStamp = [[UILabel alloc]init];
    
    NSTimeInterval time=item.answerTimestamp/1000.0;
    NSDate *detailDate=[NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //实例化一个NSDateFormatter对象
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
    NSString *currentDateStr = [dateFormatter stringFromDate: detailDate];
    
    self.seiTimeStamp.text = currentDateStr;
    self.seiTimeStamp.textAlignment = NSTextAlignmentLeft;
    self.seiTimeStamp.font = [UIFont fontWithName:@"PingFang SC" size:12];
    self.seiTimeStamp.textColor = [UIColor greenColor];
    [self addSubview:self.seiTimeStamp];
    
    [self.seiTimeStamp mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(80);
        make.left.equalTo(self.curOverhead.mas_right);
        make.centerY.equalTo(self);
    }];
    
    
    self.curTimeStamp = [[UILabel alloc]init];
    time=item.curTimestamp/1000.0;
    detailDate=[NSDate dateWithTimeIntervalSince1970:time];
    dateFormatter = [[NSDateFormatter alloc] init]; //实例化一个NSDateFormatter对象
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
    NSString *currentTs = [dateFormatter stringFromDate: detailDate];
    self.curTimeStamp.text = currentTs;
    self.curTimeStamp.textAlignment = NSTextAlignmentLeft;
    self.curTimeStamp.font = [UIFont fontWithName:@"PingFang SC" size:12];
    self.curTimeStamp.textColor = [UIColor greenColor];
    [self addSubview:self.curTimeStamp];
    
    [self.curTimeStamp mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(80);
        make.left.equalTo(self.seiTimeStamp.mas_right);
        make.centerY.equalTo(self);
    }];
    
    
    
    //    self.minOverhead = [[UILabel alloc]init];
    //    self.minOverhead.text = [NSString stringWithFormat:@"%lld", [PerfStaticsHelper sharedInstance].minAskAnswerOverHead];
    //    self.minOverhead.textAlignment = NSTextAlignmentLeft;
    //    self.minOverhead.font = [UIFont fontWithName:@"PingFang SC" size:12];
    //    self.minOverhead.textColor =  [UIColor greenColor];
    //    [self addSubview:self.minOverhead];
    //
    //    [self.minOverhead mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.height.mas_equalTo(20);
    //        make.width.mas_equalTo(50);
    //        make.left.equalTo(self.curOverhead.mas_right);
    //        make.centerY.equalTo(self);
    //    }];
    
//    self.minOverhead = [[UILabel alloc]init];
//    self.minOverhead.text = [NSString stringWithFormat:@"%lld", [PerfStaticsHelper sharedInstance].minAskAnswerOverHead];
//    self.minOverhead.textAlignment = NSTextAlignmentLeft;
//    self.minOverhead.font = [UIFont fontWithName:@"PingFang SC" size:12];
//    self.minOverhead.textColor =  [UIColor greenColor];
//    [self addSubview:self.minOverhead];
//    
//    [self.minOverhead mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(20);
//        make.width.mas_equalTo(50);
//        make.left.equalTo(self.curOverhead.mas_right);
//        make.centerY.equalTo(self);
//    }];
//    
//    self.maxOverhead = [[UILabel alloc]init];
//    self.maxOverhead.text = [NSString stringWithFormat:@"%lld", [PerfStaticsHelper sharedInstance].maxAskAnswerOverHead];
//    self.maxOverhead.textAlignment = NSTextAlignmentLeft;
//    self.maxOverhead.font = [UIFont fontWithName:@"PingFang SC" size:12];
//    self.maxOverhead.textColor =  [UIColor greenColor];
//    [self addSubview:self.maxOverhead];
//    
//    [self.maxOverhead mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(20);
//        make.width.mas_equalTo(50);
//        make.left.equalTo(self.minOverhead.mas_right);
//        make.centerY.equalTo(self);
//    }];
    
    self.meanOverhead = [[UILabel alloc]init];
    self.meanOverhead.text = [NSString stringWithFormat:@"%lld", [PerfStaticsHelper sharedInstance].meanAskAnswerOverHead];
    self.meanOverhead.textAlignment = NSTextAlignmentLeft;
    self.meanOverhead.font = [UIFont fontWithName:@"PingFang SC" size:12];
    self.meanOverhead.textColor = [UIColor greenColor];
    [self addSubview:self.meanOverhead];
    
    [self.meanOverhead mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(50);
        make.left.equalTo(self.curTimeStamp.mas_right);
        make.centerY.equalTo(self);
    }];
    

}
@end
