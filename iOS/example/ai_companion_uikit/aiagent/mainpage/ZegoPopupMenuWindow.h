#import <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

@interface ZegoPopupMenuConfig : NSObject
@property (readwrite, nonatomic, assign) BOOL cellShowRearIcon;
@property (readwrite, nonatomic, assign) CGFloat width;
@property (readwrite, nonatomic, assign) CGFloat topMargin;
@end

@interface ZegoPopupMenuView : UIView<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *menuItemsTable;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath; // 保存当前选中的索引路径
- (void)dismissMenu:(BOOL) animated;
@end

@interface ZegoPopupMenuFloatView : UIView
@end

@interface ZegoPopupMenuWindow : NSObject
+ (instancetype) shareInstance;

-(void)showMenuInView:(UIView *)view
              fromRect:(CGRect)anchorRect
             menuItems:(NSArray *)menuItems
                config:(ZegoPopupMenuConfig*)config;

- (void)dismissMenu;
@end

