//
//  ZegoTestSettingViewController.m
//  ZegoEducation
//
//  Created by MrLQ  on 2019/11/21.
//  Copyright © 2019 Shenzhen Zego Technology Company Limited. All rights reserved.
//

#import "ZegoTestSettingViewController.h"
#import "ZegoRadioButton.h"
#import <SSZipArchive/SSZipArchive.h>
#import "UIView+Toast.h"
#import "AppDataManager.h"

#define kenv_type @"env_type"
@interface ZegoTestSettingViewController ()<UIDocumentInteractionControllerDelegate>

@property (weak, nonatomic) IBOutlet ZegoRadioButton *testButton;
@property (weak, nonatomic) IBOutlet ZegoRadioButton *alphaButton;
@property (weak, nonatomic) IBOutlet ZegoRadioButton *customButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *shareLogButton;
@property (weak, nonatomic) IBOutlet UIButton *clearLogButton;
@property (weak, nonatomic) IBOutlet UILabel *versionInfo;
@property (weak, nonatomic) IBOutlet UILabel *appId;
@property (weak, nonatomic) IBOutlet UILabel *userId;
@property (nonatomic, assign) NSInteger env_type;

@property (nonatomic, assign) NSTimeInterval lastUpLoadTime;  // 上次上传日志的时间
@property (nonatomic, strong) UIDocumentInteractionController *documentController;  // 日志分享控制器
@end

@implementation ZegoTestSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSNumber *env_type =  [[NSUserDefaults standardUserDefaults] objectForKey:kenv_type];
    if (env_type.integerValue == 0) {
        env_type = @(1);
    }
    
    self.versionInfo.text = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    long appID = [AppDataManager sharedInstance].appID;
    NSString* userId = [AppDataManager sharedInstance].userID;
    self.appId.text = [NSString stringWithFormat:@"appID:%ld", appID];
    self.userId.text = [NSString stringWithFormat:@"userID:%@", userId];
    
    [self buttonTouchUpInside:[self.view viewWithTag:env_type.integerValue]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (IBAction)buttonTouchUpInside:(id)sender {
    if (sender == self.testButton) {
        self.env_type = ((UIButton *)sender).tag;
        self.testButton.selected = YES;
        self.alphaButton.selected = self.customButton.selected = NO;
        
    }else if (sender == self.alphaButton){
        self.env_type = ((UIButton *)sender).tag;
        self.alphaButton.selected = YES;
        self.testButton.selected = self.customButton.selected = NO;

    }else if (sender == self.customButton){
        self.env_type = ((UIButton *)sender).tag;
        self.customButton.selected = YES;
        self.testButton.selected = self.alphaButton.selected = NO;
    }
    else if (sender == self.saveButton){
        [[NSUserDefaults standardUserDefaults] setInteger:self.env_type forKey:kenv_type];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        NSString * messgae = @"重启后生效。立即重启";
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:messgae preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                  NSLog(@"确定");
            exit(0);
        }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else if(sender == self.clearLogButton){
        NSString* cachedPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
        
        NSError *error;
        NSString* PlayStreamRecords = [cachedPath stringByAppendingPathComponent:@"PlayStreamRecords"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:PlayStreamRecords]) {
            [[NSFileManager defaultManager] removeItemAtPath:PlayStreamRecords error:&error];
        }
        
        if (error != nil) {
            NSString* msg=[NSString stringWithFormat:@"删除日志目录PlayStreamRecords失败,ec=%ld", (long)error.code];
            [self.view makeToast:msg];
        }
        
        NSString* AICompanionLogs = [cachedPath stringByAppendingPathComponent:@"AICompanionLogs"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:AICompanionLogs]) {
            [[NSFileManager defaultManager] removeItemAtPath:AICompanionLogs error:&error];
        }
        
        if (error != nil) {
            NSString* msg=[NSString stringWithFormat:@"删除日志目录AICompanionLogs失败,ec=%ld", (long)error.code];
            [self.view makeToast:msg];
        }
        
        NSString* ZegoLogs = [cachedPath stringByAppendingPathComponent:@"ZegoLogs"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:ZegoLogs]) {
            [[NSFileManager defaultManager] removeItemAtPath:ZegoLogs error:&error];
        }
        
        if (error != nil) {
            NSString* msg=[NSString stringWithFormat:@"删除日志目录ZegoLogs失败,ec=%ld", (long)error.code];
            [self.view makeToast:msg];
        }
        
//        NSString* ZIMCaches = [cachedPath stringByAppendingPathComponent:@"ZIMCaches"];
//        if ([[NSFileManager defaultManager] fileExistsAtPath:ZIMCaches]) {
//            [[NSFileManager defaultManager] removeItemAtPath:ZIMCaches error:&error];
//        }
//        
//        if (error != nil) {
//            NSString* msg=[NSString stringWithFormat:@"删除日志目录ZIMCaches失败,ec=%ld", (long)error.code];
//            [self.view makeToast:msg];
//        }
        
        NSString* ZIMLogs = [cachedPath stringByAppendingPathComponent:@"ZIMLogs"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:ZIMLogs]) {
            [[NSFileManager defaultManager] removeItemAtPath:ZIMLogs error:&error];
        }
        
        if (error != nil) {
            NSString* msg=[NSString stringWithFormat:@"删除日志目录ZIMLogs失败,ec=%ld", (long)error.code];
            [self.view makeToast:msg];
        }
    }
    else if(sender == self.shareLogButton){
        NSMutableArray<NSString*>* logFilePaths = [[NSMutableArray alloc]init];
        NSString* cachedPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
        NSString* zipFilePath = [cachedPath stringByAppendingPathComponent:@"ZegoLogFile.zip"];
        NSError *error;
        if ([[NSFileManager defaultManager] fileExistsAtPath:zipFilePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:zipFilePath error:&error];
        }
        
        if ([SSZipArchive createZipFileAtPath:zipFilePath withContentsOfDirectory:cachedPath]) {
            if (self.documentController == nil) {
                self.documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:zipFilePath]];
                self.documentController.delegate = self;
            }
            CGRect rect = self.view.bounds;
            [self.documentController presentOpenInMenuFromRect:rect inView:self.view animated:YES];
        } else {
            [self.view makeToast:@"压缩日志文件失败，请重试"];
    
        }
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
                    
        }];
    }
}

#pragma mark - UIDocumentInteractionControllerDelegate
- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
}
@end
