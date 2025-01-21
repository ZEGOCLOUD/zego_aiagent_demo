//
//  UIView+Toast.h
//  Toast
//
#import <UIKit/UIKit.h>
//Toast定义的三个基本位置常量
extern const NSString * CSToastPositionTop;
extern const NSString * CSToastPositionCenter;
extern const NSString * CSToastPositionBottom;

@class CSToastStyle;

/**
 Toast是一个Objective-C类别，它将Toast通知添加到uiview
对象类。它的目的是简单，轻便，易于使用。大多数
Toast通知可以用一行代码触发。

'maketoast:'方法创建一个新视图，然后将其显示为toast。

'showtoast:'方法将任何视图显示为toast。
 
 */
@interface UIView (Toast)

/**
 创建并显示带有消息的新Toast视图，并用
默认持续时间和位置。使用共享样式设置样式。

@参数message：要显示的消息
 */
- (void)makeToast:(NSString *)message;

/**
 创建并显示带有消息的新Toast视图。持续时间和位置
可以显式设置。使用共享样式设置样式。

@参数message：要显示的消息
@参数duration ：Toast持续时间
@参数position：定位吐司的中心点。可以是预定义的CSTOastPosition之一
常量或包装在“nsvalue”对象中的“cgpoint”。
 */
- (void)makeToast:(NSString *)message
         duration:(NSTimeInterval)duration
         position:(id)position;

/**
 创建并显示带有消息的新Toast视图。持续时间、位置和
可以显式设置样式。

@参数message：要显示的消息
@参数duration ：Toast持续时间
@参数position：定位吐司的中心点。可以是预定义的CSTOastPosition之一
常量或包装在“nsvalue”对象中的“cgpoint”。
@参数style：nil时将使用共享样式
 */
- (void)makeToast:(NSString *)message
         duration:(NSTimeInterval)duration
         position:(id)position
            style:(CSToastStyle *)style;

/**
创建并显示带有消息、标题和图像的新Toast视图。持续时间，
位置和样式可以显式设置。当
Toast视图完成。`如果toast视图从tap中取消，则didtap“将是”yes“。
 
@参数message：要显示的消息
@参数duration ：Toast持续时间
@参数position：定位Toast的中心点。可以是预定义的CSTOastPosition之一
常量或包装在“nsvalue”对象中的“cgpoint”。
@参数title：标题
@参数image：图像
@参数style：样式。nil时将使用共享样式
@param completion ：toast视图消失后执行的完成块。
如果toast视图从tap中取消，则didtap将为“是”。
 */
- (void)makeToast:(NSString *)message
         duration:(NSTimeInterval)duration
         position:(id)position
            title:(NSString *)title
            image:(UIImage *)image
            style:(CSToastStyle *)style
       completion:(void(^)(BOOL didTap))completion;

/**
创建一个新的toast视图，其中包含消息、标题和图像的任何组合。
外观和感觉是通过样式配置的。与“makeToast:”方法不同，
此方法不会自动呈现toast视图。其中一个toast是:
方法必须用于显示结果视图。

@ 警告：如果消息、标题和图像都是nil，这个方法将返回nil。
@参数message：要显示的消息
@参数title：标题
@参数image：图像
@参数style：样式。nil时将使用共享样式
@返回新创建的Toast视图
 */
- (UIView *)toastViewForMessage:(NSString *)message
                          title:(NSString *)title
                          image:(UIImage *)image
                          style:(CSToastStyle *)style;

/**
 隐藏活跃的Toast。如果一个视图中有多个激活的toast，则此方法
 隐藏最古老的toast（第一个被展示的toast）。
 */
- (void)hideToast;

/**
 隐藏一个活跃的toast。

@param toast：活跃的toast视图将被取消。任何正在展示的吐司
在屏幕上被认为是活跃的。

@警告：这没有清除当前正在队列中等待的toast视图。
 */
- (void)hideToast:(UIView *)toast;

/**
隐藏所有活动的Toast视图并清除队列。
 */
- (void)hideAllToasts;

/**
隐藏所有活动的Toast视图，并提供隐藏活动和清除队列的选项。

@参数includeActivity：如果为“true”，toast活动也将被隐藏。默认值为“false”。
@param clearqueue：如果为“true”，则从队列中删除所有toast视图。默认值为“true”。
 */
- (void)hideAllToasts:(BOOL)includeActivity clearQueue:(BOOL)clearQueue;

/**
 从队列中删除所有toast视图。这对活跃的toast视图没有影响。
 */
- (void)clearToastQueue;

/**
在指定位置创建并显示新的toast活动指示器视图。
@警告：每个父视图只能显示一个toast活动指示器视图。后续
对“makeToastActivity:”的调用将被忽略，直到调用hideToastActivity。
@警告` maketoastactivity:`独立于showtoas:方法工作。
在显示Toast视图时，可以显示和取消活跃的Toast视图。“makeToastActivity:”
对showToast:方法的排队行为没有影响。

@参数position：定位toast的中心点。可以是预定义的CSTOastPosition之一
常量或包装在“nsvalue”对象中的“cgpoint”。
 */
- (void)makeToastActivity:(id)position;

/**
关闭活动的Toast活动指示器视图。
 */
- (void)hideToastActivity;

/**
 使用默认的持续时间和位置将任何视图显示为toast。

@参数toast：将显示为toast的视图
 */
- (void)showToast:(UIView *)toast;

/**
 在指定的位置和持续时间内将任何视图显示为toast。当toast视图完成时，完成块执行。
如果toast视图从tap中被取消，则“didTap”将变为“YES”。

@参数Toast：要显示为Toast的视图
@参数duration：Toast持续时间
@参数Toast：定位Toast的中心点。可以是预定义的CSTOastPosition之一
常量或包装在“nsvalue”对象中的“cgpoint”。
@参数completion：toast视图消失后执行的完成块。
如果toast视图从tap中取消，则didtap将为“是”。
 */
- (void)showToast:(UIView *)toast
         duration:(NSTimeInterval)duration
         position:(id)position
       completion:(void(^)(BOOL didTap))completion;

@end

/**
 “CSToastStyle”实例定义通过“makeToast:”方法创建的toast视图的外观，
以及直接使用toastViewForMessage:title:image:style:”创建的toast视图的外观。

@警告：' CSToastStyle '为默认toast视图提供了相对简单的样式选项。
如果需要一个具有更复杂UI的toast视图，
创建自定义UIView子类并使用' showToast: '方法来呈现它可能更有意义。
 */
@interface CSToastStyle : NSObject

/**
背景颜色。默认为' [UIColor blackColor] '，不透明度为80%。 */
@property (strong, nonatomic) UIColor *backgroundColor;

/**
标题的颜色。默认值是' [UIColor whiteColor] '。
 */
@property (strong, nonatomic) UIColor *titleColor;

/**
消息的颜色。默认值是' [UIColor whiteColor] '。
 */
@property (strong, nonatomic) UIColor *messageColor;

/**
 从0.0到1.0的百分比值，表示Toast视图相对于其SuperView的最大宽度。
默认值为0.8（SuperView宽度的80%）。
 */
@property (assign, nonatomic) CGFloat maxWidthPercentage;

/**
 从0.0到1.0的百分比值，表示Toast视图相对于其SuperView的最大高度。
默认值为0.8（SuperView高度的80%）。
 */
@property (assign, nonatomic) CGFloat maxHeightPercentage;

/**
 从toast视图的水平边缘到内容的间距。
当图像出现时，这也用作图像和文本之间的填充。
默认是10.0。
 */
@property (assign, nonatomic) CGFloat horizontalPadding;

/**
从Toast视图的垂直边缘到内容的间距。
当出现标题时，它也用作标题和消息之间的填充。
默认值为10.0。
 */
@property (assign, nonatomic) CGFloat verticalPadding;

/**
 圆角半径。默认是10.0。
 */
@property (assign, nonatomic) CGFloat cornerRadius;

/**
标题字体。默认值为`[uifont-boldSystemFontOfSize:16.0]`。
 */
@property (strong, nonatomic) UIFont *titleFont;

/**
消息的字体。默认值是' [UIFont systemFontOfSize:16.0] '。
 */
@property (strong, nonatomic) UIFont *messageFont;

/**
标题文本对齐。默认设置是“NSTextAlignmentLeft”。
 */
@property (assign, nonatomic) NSTextAlignment titleAlignment;

/**
消息文本对齐。默认设置是“NSTextAlignmentLeft”。
 */
@property (assign, nonatomic) NSTextAlignment messageAlignment;

/**
标题的最大行数。默认值为0（无限制）。
 */
@property (assign, nonatomic) NSInteger titleNumberOfLines;

/**
消息的最大行数。默认值是0(没有限制)。
 */
@property (assign, nonatomic) NSInteger messageNumberOfLines;

/**
启用或禁用Toast视图上的阴影。默认值为“否”。
 */
@property (assign, nonatomic) BOOL displayShadow;

/**
阴影颜色。默认值为`[uicolor blackcolor]`。
 */
@property (strong, nonatomic) UIColor *shadowColor;

/**
值从0.0到1.0，表示阴影的不透明度。
默认值为0.8(80%不透明度)。
 */
@property (assign, nonatomic) CGFloat shadowOpacity;

/**
阴影半径。默认是6.0。
 */
@property (assign, nonatomic) CGFloat shadowRadius;

/**
阴影偏移量。默认值是' CGSizeMake(4.0, 4.0) '。
 */
@property (assign, nonatomic) CGSize shadowOffset;

/**
图像的大小。默认值是“CGSizeMake(80.0, 80.0)”。
 */
@property (assign, nonatomic) CGSize imageSize;

/**
调用“makeToastActivity:”时toast活动视图的大小。
默认值是“CGSizeMake(100.0, 100.0)”。
 */
@property (assign, nonatomic) CGSize activitySize;

/**
淡入/淡出动画持续时间。默认是0.2。

 */
@property (assign, nonatomic) NSTimeInterval fadeDuration;

/**
创建一个“CSToastStyle”的新实例，并设置所有默认值。
 */
- (instancetype)initWithDefaultStyle NS_DESIGNATED_INITIALIZER;

/**
 @警告：只应该使用指定的初始化器来创建“CSToastStyle”的实例。
 */
- (instancetype)init NS_UNAVAILABLE;

@end

/**
 “CSToastManager”为所有toast通知提供一般配置选项。由单例实例支持。
 */
@interface CSToastManager : NSObject

/**
 在单例上设置共享样式。使用nil样式调用“makeToast:”方法
(或“toastViewForMessage:title:image:style:”)时，将使用共享样式。
默认情况下，这被设置为' CSToastStyle '的默认样式。
@参数sharedStyle：共享样式
 */
+ (void)setSharedStyle:(CSToastStyle *)sharedStyle;

/**
 从singlton获取共享样式。默认情况下，这是“CSToastStyle”的默认样式。

@ return 共享样式
 */
+ (CSToastStyle *)sharedStyle;

/**
启用或禁用tap在toast视图上消失。默认是“是的”。

@参数 tapToDismissEnabled：是或不是
 */
+ (void)setTapToDismissEnabled:(BOOL)tapToDismissEnabled;

/**
如果启用了tap to dismiss，则返回“YES”，否则返回“NO”。
默认是“是的”。

@return BOOL是或不是
 */
+ (BOOL)isTapToDismissEnabled;

/**
 启用或禁用toast视图的排队行为。当回答“是”时，toast视图将一个接一个
地出现。当“否”时，多个Toast视图将同时出现(根据它们的位置可能重叠)。
这对toast活动视图没有影响，它独立于正常的toast视图运行。默认设置是“不”。

@参数queueEnabled：是或否
 */
+ (void)setQueueEnabled:(BOOL)queueEnabled;

/**
如果启用队列，则返回“YES”，否则返回“NO”。默认设置是“不”。

@return BOOL
 */
+ (BOOL)isQueueEnabled;

/**
 设置默认持续时间。用于不需要显式持续时间的“makeToast:”和“showToast:”方法。默认是3.0。
@参数 duration：toast 显示持续时间
 */
+ (void)setDefaultDuration:(NSTimeInterval)duration;

/**
返回默认持续时间。默认是3.0。

 @return duration The toast duration
*/
+ (NSTimeInterval)defaultDuration;

/**
 设置默认位置。用于不需要明确位置的“makeToast:”和“showToast:”方法。默认设置是“CSToastPositionBottom”。
参数position：可以是预定义的CSToastPosition常量之一，也可以是包装在“NSValue”对象中的“CGPoint”。
 */
+ (void)setDefaultPosition:(id)position;

/**
返回默认toast位置。默认设置是“CSToastPositionBottom”。
@return定位默认中心点。将是预定义的CSToastPosition常量之一，或包装在' NSValue '对象中的' CGPoint '。
 */
+ (id)defaultPosition;

@end

