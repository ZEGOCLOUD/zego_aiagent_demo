//
//  ZegoAudioChatTableView.m
//
//  Created by zego on 2024/5/13.
//  Copyright © 2024 Zego. All rights reserved.
//

#import "ZegoAudioChatTableView.h"
#import <Masonry/Masonry.h>
#import "ZegoAudioChatTableViewCell.h"
#import "ZegoAudioChatMsgModel.h"
#import "AIAgentLogUtil.h"

@interface ZegoAudioChatTableView ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) long msgTotalCount;
@property (nonatomic, strong) NSMutableDictionary<NSNumber*,ZegoAudioChatMsgModel*>* chatMsgList;
@property (nonatomic, strong) NSMutableDictionary<NSString*,ZegoAudioChatMsgModel*>* tempAsrMsgList;
@property (nonatomic, strong) NSMutableDictionary<NSString*,NSMutableDictionary<NSNumber*, ZegoAudioChatMsgModel*>*>* tempLLMMsgList;

@end

@implementation ZegoAudioChatTableView
-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    if (self = [super initWithFrame:frame style:style]) {
        self.chatMsgList = [[NSMutableDictionary alloc] initWithCapacity:100];
        self.msgTotalCount = 0;
        self.tempAsrMsgList = [[NSMutableDictionary alloc] initWithCapacity:5];
        self.tempLLMMsgList = [[NSMutableDictionary alloc] initWithCapacity:5];

        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableFooterView = [[UIView alloc] init];
        self.estimatedRowHeight = 0.0;
        self.estimatedSectionFooterHeight = 0.0;
        self.estimatedSectionHeaderHeight = 0.0;
        self.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
        self.backgroundColor = [UIColor clearColor];
        self.dataSource = self;
        self.delegate = self;

        [self registerClass:[ZegoAudioChatTableViewCell class] forCellReuseIdentifier:@"ZegoAudioChatTableViewCell"];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tap];
    }
    
    return self;
}

- (void)tap:(UIGestureRecognizer *) recognizer {
}

// 收到 asr 文本，更新聊天信息
-(void)handleRecvAsrChatMsg:(NSDictionary*)msgDict{
    int cmd = [msgDict[@"cmd"] intValue];
    long long seqId = [msgDict[@"seq_id"] longLongValue];
    long long round = [msgDict[@"round"] longLongValue];
    long timeStamp = [msgDict[@"timestamp"] longValue];
    NSDictionary* dataMap = msgDict[@"data"];
    NSString* content = dataMap[@"text"];
    NSString* message_id = dataMap[@"message_id"];
    BOOL end_flag =[dataMap[@"end_flag"] boolValue];
    
    if (content && content.length > 0) {
        NSNumber* objSeq = [NSNumber numberWithLongLong:seqId];
        ZegoAudioChatMsgModel* existAsrMsgModel = [self.tempAsrMsgList objectForKey:message_id];
        if (existAsrMsgModel == nil) {
            existAsrMsgModel =  [[ZegoAudioChatMsgModel alloc]init];
            existAsrMsgModel.seqId = seqId;
            existAsrMsgModel.isMine = YES;
            existAsrMsgModel.content = content;
            existAsrMsgModel.round = round;
            existAsrMsgModel.end_flag = end_flag;
            existAsrMsgModel.message_id = message_id;
            existAsrMsgModel.messageTimeStamp = timeStamp;
            [self.tempAsrMsgList setObject:existAsrMsgModel forKey:message_id];
            [self insertCurMsgModel:cmd withMsgModel:existAsrMsgModel];
        }else if(existAsrMsgModel.message_id && [existAsrMsgModel.message_id isEqualToString: message_id]){
            if (seqId < existAsrMsgModel.seqId) {
                //如果当前显示的item的seqId已经是最新的了，就不需要再更新文本内容
                ZAALogI(@"onInRoomMessageReceived", @"recvasr curSeqId=%lld < existAsrMsgModel.seqId=%lld", seqId, existAsrMsgModel.seqId);
            }else{
                existAsrMsgModel.content = content;
                [self reloadTableViewInternal];
            }
        }
    }
}

// 收到 LLM 文本，更新聊天信息
-(void)handleRecvLLMChatMsg:(NSDictionary*)msgDict{
    int cmd = [msgDict[@"cmd"] intValue];
    long long seqId = [msgDict[@"seq_id"] longLongValue];
    long long round = [msgDict[@"round"] longLongValue];
    long timeStamp = [msgDict[@"timestamp"] longValue];
    NSDictionary* dataMap = msgDict[@"data"];
    NSString* content = dataMap[@"text"];
    NSString* message_id = dataMap[@"message_id"];
    BOOL end_flag =[dataMap[@"end_flag"] boolValue];
    
    if (content && content.length > 0) {
        NSNumber* objSeq = [NSNumber numberWithLongLong:seqId];
        ZegoAudioChatMsgModel* existAsrMsgModel =  [[ZegoAudioChatMsgModel alloc]init];
        existAsrMsgModel.seqId = seqId;
        existAsrMsgModel.isMine = NO;
        existAsrMsgModel.content = content;
        existAsrMsgModel.round = round;
        existAsrMsgModel.message_id = message_id;
        existAsrMsgModel.end_flag = end_flag;
        existAsrMsgModel.messageTimeStamp = timeStamp;
        
        NSMutableDictionary<NSNumber*,ZegoAudioChatMsgModel*>* existAsrMsgList = [self.tempLLMMsgList objectForKey:message_id];
        if (existAsrMsgList == nil) {
            //如果是该消息id的第一条内容
            existAsrMsgList = [[NSMutableDictionary alloc]initWithCapacity:5];
            [existAsrMsgList setObject:existAsrMsgModel forKey:objSeq];
            [self.tempLLMMsgList setObject:existAsrMsgList forKey:message_id];
            
            ZegoAudioChatMsgModel* chatTableCellModel =  [[ZegoAudioChatMsgModel alloc]init];
            chatTableCellModel.seqId = seqId;
            chatTableCellModel.isMine = NO;
            chatTableCellModel.content = content;
            chatTableCellModel.round = round;
            chatTableCellModel.message_id = message_id;
            chatTableCellModel.end_flag = end_flag;
            chatTableCellModel.messageTimeStamp = timeStamp;
            [self insertCurMsgModel:cmd withMsgModel:chatTableCellModel];
        }else{
            [existAsrMsgList setObject:existAsrMsgModel forKey:objSeq];
            NSArray *keysArray = [existAsrMsgList allKeys];
            NSArray * sortedArray = [keysArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                NSNumber* obj1N = (NSNumber*)obj1;
                NSNumber* obj2N = (NSNumber*)obj2;
                return [obj1N longLongValue] > [obj2N longLongValue];
            }];
            
            NSString* totalContent = @"";
//            long long lastSeq = 0;
            for (NSNumber* key in sortedArray) {
                //这部分实现等待逻辑，2,3,4,6...,只会显示2，3，4
//                long long curItemSeqId = [key longLongValue];
//                if (lastSeq == 0) {
//                    lastSeq = curItemSeqId;
//                }else if(curItemSeqId - lastSeq > 1){
//                    break;
//                }else{
//                    lastSeq = curItemSeqId;
//                }
                ZegoAudioChatMsgModel* temp = [existAsrMsgList objectForKey:key];
                totalContent = [totalContent stringByAppendingString:temp.content];
            }
            
            ZegoAudioChatMsgModel* curUserChatMsgModel = [self queryMsgModelWithMessageId:message_id];
            curUserChatMsgModel.seqId = seqId;
            curUserChatMsgModel.isMine = NO;
            curUserChatMsgModel.end_flag = end_flag;
            curUserChatMsgModel.messageTimeStamp = timeStamp;
            curUserChatMsgModel.content = totalContent;
            [self reloadTableViewInternal];
        }
    }
    
    if (end_flag) {
        //代码代码主要用来打日志
        NSMutableDictionary<NSNumber*,ZegoAudioChatMsgModel*>* tempLLMMsgList = [self.tempLLMMsgList objectForKey:message_id];
        NSArray *keysArray = [tempLLMMsgList allKeys];
        NSArray * sortedArray = [keysArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSNumber* obj1N = (NSNumber*)obj1;
            NSNumber* obj2N = (NSNumber*)obj2;
            return [obj1N longLongValue] > [obj2N longLongValue];
        }];
        
        NSString* roundSeqId=@"";
        for (int i=0; i<sortedArray.count; i++) {
            roundSeqId = [roundSeqId stringByAppendingFormat:@"%lld,", [[sortedArray objectAtIndex:i] longLongValue]];
        }
        
        ZAALogI(@"onInRoomMessageReceived", @"recvllmtts remove round=%lld, totalSeqStr=%@, message_id=%@", round, roundSeqId, message_id);
        [self.tempLLMMsgList removeObjectForKey:message_id];
    }
}

-(void)insertCurMsgModel:(int)cmd
            withMsgModel:(ZegoAudioChatMsgModel*)curMsgModel{
    if (curMsgModel == nil) {
        return;
    }
    NSLog(@"chatMsgList insert:cmd=%d, seqId=%lld, timeStamp=%lld, message=%@, isMine=%d",
          cmd,
          curMsgModel.seqId,
          curMsgModel.messageTimeStamp,
          curMsgModel.content,curMsgModel.isMine);
    
    [self.chatMsgList setObject:curMsgModel forKey:[NSNumber numberWithLong:self.msgTotalCount++]];
    [self reloadTableViewInternal];
}

-(ZegoAudioChatMsgModel*)queryMsgModelWithMessageId:(NSString*)msgId{
    NSArray* keysArray = [self.chatMsgList allKeys];
    for (int i=0; i<keysArray.count; i++) {
        NSNumber* itemKey = keysArray[i];
        ZegoAudioChatMsgModel* itemValue = [self.chatMsgList objectForKey:itemKey];
        if ([itemValue.message_id isEqualToString:msgId]) {
            return itemValue;
        }
    }
    return nil;
}

-(void)reloadTableViewInternal{
    [self reloadData];
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:self.chatMsgList.count-1 inSection:0];
    [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

#pragma delegate UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // 返回表中有多少个部分
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.chatMsgList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ZegoAudioChatTableViewCell";
    ZegoAudioChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ZegoAudioChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSNumber* index = [NSNumber numberWithLong:indexPath.row];
    ZegoAudioChatMsgModel* msgModel = [self.chatMsgList objectForKey:index];
    
    cell.msgModel = msgModel;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 设置单元格的高度
    NSNumber* index = [NSNumber numberWithLong:indexPath.row];
    ZegoAudioChatMsgModel* msgModel = [self.chatMsgList objectForKey:index];
    CGRect rect = msgModel.boundingBox;
    return rect.size.height + CELL_TOP_MARGIN;
}

- (CGFloat)tableView:(UITableView *)tableView
estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
@end
