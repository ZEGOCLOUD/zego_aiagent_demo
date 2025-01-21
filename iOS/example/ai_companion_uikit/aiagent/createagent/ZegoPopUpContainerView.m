//
//  ZegoPopUpContainerView.m
//
//  Created by zego on 2024/9/4.
//

#import "ZegoPopUpContainerView.h"
#import <Masonry/Masonry.h>
#import "ZegoAiCompanionUtil.h"

@interface ZegoPopUpContainerView ()
@property (nonatomic, strong) UIView *curPopupView;
@end

@implementation ZegoPopUpContainerView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupBackground];
    }
    return self;
}

- (void)setupBackground {
    // 创建一个 UIView
    UIView *transparentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    transparentView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4]; // 半透明背景色
    [self addSubview:transparentView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [transparentView addGestureRecognizer:tapGesture];
    transparentView.userInteractionEnabled = YES;
}
-(void)dismiss{
    [self closeWithAnimate:^(BOOL finished) {
        [self.delegate onRequestDismiss:self.curPopupView];
    }];
}

-(void)display:(UIView*)parentContainer popUpView:(UIView*)popUp topOffset:(CGFloat)offset{
    [parentContainer addSubview:self];
    [self addSubview:popUp];
    self.curPopupView = popUp;
    [self showAnimatedView:popUp topOffset:offset];
}

- (void)showAnimatedView:(UIView *)view topOffset:(CGFloat)offset{
    // 设置动画的持续时间和曲线
    [UIView animateWithDuration:0.3
                      delay:0.0
                    options:UIViewAnimationOptionCurveEaseInOut
                 animations:^{
                     // 动画结束时的目标位置
                     view.frame = CGRectMake(0, offset, self.bounds.size.width, self.bounds.size.height - offset);
                 }
                 completion:^(BOOL finished) {
                     // 动画完成后的回调
                     NSLog(@"Animation completed.");
                 }];
}

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
    [self closeWithAnimate:^(BOOL finished) {
        [self.delegate onRequestDismiss:self.curPopupView];
    }];
}

-(void)closeWithAnimate:(void(^ __nullable)(BOOL finished))complete{
    [UIView animateWithDuration:0.2
                      delay:0.0
                    options:UIViewAnimationOptionTransitionFlipFromBottom
                     animations:^{
        self.alpha = 0.0; // 淡出效果
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
        complete(finished);
        NSLog(@"Animation completed.");
    }];
}
@end
