//
//  ZegoAutoAdjustTextView.m
//
//  Created by zego on 2024/9/9.
//

#import "ZegoAutoAdjustTextView.h"
#import <Masonry/Masonry.h>
#import <YYKit/UIImageView+YYWebImage.h>

@interface ZegoAutoAdjustTextView ()
//上移后，textField需要额外高于键盘顶部的距离，默认为0
@property (nonatomic, assign) CGFloat offset;
//需要向上移动的view，默认为keyWindow
@property (nonatomic, weak) UIView *movingView;
@property (nonatomic, assign) CGRect originalFrame;
@end

@implementation ZegoAutoAdjustTextView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self onInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self onInit];
    }
    return self;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)onInit {
    [self addKeyboardNotifications];
    self.movingView = [UIApplication sharedApplication].keyWindow;
    self.originalFrame = CGRectZero;
}

- (void)addKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow: (NSNotification *)notification {
    if (self.isFirstResponder) {
        CGPoint relativePoint = [self convertPoint: CGPointZero toView: [UIApplication sharedApplication].keyWindow];
        
        CGFloat keyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        CGFloat overstep = CGRectGetHeight(self.frame) + relativePoint.y + keyboardHeight - CGRectGetHeight([UIScreen mainScreen].bounds);
        overstep += self.offset;
        
        if (CGRectEqualToRect(self.originalFrame, CGRectZero)) {
            self.originalFrame = self.movingView.frame;
        }
        
        if (overstep > 0) {
            CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
            CGRect frame = self.originalFrame;
            frame.origin.y -= (overstep + 15);
            [UIView animateWithDuration: duration delay: 0 options: UIViewAnimationOptionCurveLinear animations: ^{
                self.movingView.frame = frame;
            } completion: nil];
        }
    }
}


- (void)keyboardWillHide: (NSNotification *)notification {
    if (self.isFirstResponder || !CGRectEqualToRect(self.originalFrame, CGRectZero)) {
        CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration: duration delay: 0 options: UIViewAnimationOptionCurveLinear animations: ^{
            self.movingView.frame = self.originalFrame;
        } completion: nil];
        self.originalFrame = CGRectZero;
    }
}
@end
