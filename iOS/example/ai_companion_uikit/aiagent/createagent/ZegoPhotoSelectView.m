//
//  ZegoPhotoSelectView.m
//
//  Created by zego on 2024/9/9.
//

#import "ZegoPhotoSelectView.h"
#import <Masonry/Masonry.h>
#import <YYKit/UIImageView+YYWebImage.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIView+Toast.h"

@interface ZegoPhotoSelectView ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UILabel* selectFromPhotoLabel;
@property (nonatomic, strong) UIButton* cancelButton;

@end

@implementation ZegoPhotoSelectView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI{
    //简单一点搞
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    self.selectFromPhotoLabel = [[UILabel alloc]init];
    self.selectFromPhotoLabel.text = @"从相册选择";
    self.selectFromPhotoLabel.textAlignment = NSTextAlignmentCenter;
    self.selectFromPhotoLabel.font = [UIFont fontWithName:@"PingFang SC" size:18];
    self.selectFromPhotoLabel.textColor = [UIColor blackColor];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickSelectPhoto:)];
    [self.selectFromPhotoLabel addGestureRecognizer:tapGesture];
    [self.selectFromPhotoLabel setUserInteractionEnabled:YES];
    
    [self addSubview:self.selectFromPhotoLabel];
    
    [self.selectFromPhotoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(22);
        make.width.mas_equalTo(self);
        make.top.equalTo(self).offset(24);
        make.centerX.equalTo(self);
    }];
    
    self.cancelButton = [[UIButton alloc]init];
    [self.cancelButton setTitle: @"取消" forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:15];
    [self.cancelButton setTitleColor:[UIColor colorWithRed:42/255.0 green:42/255.0 blue:42/255.0 alpha:1/1.0] forState:UIControlStateNormal];
    
    self.cancelButton.layer.cornerRadius = 16;
    self.cancelButton.layer.borderColor = [UIColor colorWithRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:1.0].CGColor;
    self.cancelButton.layer.borderWidth = 1;
    self.cancelButton.backgroundColor = [UIColor whiteColor];
    [self.cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cancelButton];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(48);
        make.width.mas_equalTo(327);
        make.top.equalTo(self.selectFromPhotoLabel.mas_bottom).offset(26);
        make.centerX.equalTo(self);
    }];
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //获取图片
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    NSString* imageUrl = info[@"UIImagePickerControllerImageURL"];
    NSString* fileExtension = [imageUrl pathExtension];
    NSString* lowCaseFileExtension = [fileExtension lowercaseString];
    if ([lowCaseFileExtension isEqualToString:@"png"] || 
        [lowCaseFileExtension isEqualToString:@"jpg"] ||
        [lowCaseFileExtension isEqualToString:@"jpeg"]) {
        NSData* imageData = [NSData dataWithContentsOfFile:imageUrl];
        NSInteger len = imageData.length;
        
        if (len > 1024*1024*10) {
            [[self superview] makeToast:@"头像过大无法显示，请更换图片" duration:3.0 position:CSToastPositionTop];
            [picker dismissViewControllerAnimated:YES completion:^{
            }];
        }else{
            [picker dismissViewControllerAnimated:YES completion:^{
                [self.delegate onRequestDismissPhotoSelector:image imageLocalUrl:imageUrl];
            }];
        }
    }else{
        [[self superview] makeToast:@"不支持的图片格式，目前只支持png/jpg/jpeg" duration:3.0 position:CSToastPositionTop];
        [picker dismissViewControllerAnimated:YES completion:^{
        }];
    }
    NSLog(@"didFinishPickingMediaWithInfo imageUrl=%@", imageUrl);

}


- (UIViewController *)getPresentedViewController{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    if (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
      
    return topVC;
}

- (void)onClickSelectPhoto:(UIGestureRecognizer *) recognizer {
    UIImagePickerController* picker = [[UIImagePickerController alloc]init];
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.delegate = self;
    
//    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
//    UIViewController *topViewController = keyWindow.rootViewController;
    
    UIViewController *topViewController = [self getPresentedViewController];
    [topViewController presentViewController:picker animated:YES completion:nil];
}

- (void)cancelButtonClicked:(UIGestureRecognizer *) recognizer {
    [self.delegate onRequestDismissPhotoSelector:nil imageLocalUrl:nil];
}

@end
