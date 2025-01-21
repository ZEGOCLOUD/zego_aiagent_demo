#import "ZegoPopupMenuWindow.h"
#import <QuartzCore/QuartzCore.h>
#import <YYKit/UIImageView+YYWebImage.h>
#import <Masonry/Masonry.h>
#import "ZegoPopupMenuViewCell.h"
#import "ZegoPopupMenuItem.h"

@implementation ZegoPopupMenuConfig
@end


@interface ZegoPopupMenuFloatView()<UIGestureRecognizerDelegate>
@end

@implementation ZegoPopupMenuFloatView
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        UITapGestureRecognizer *gestureRecognizer;
        gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(singleTap:)];
        gestureRecognizer.delegate = self;
        [self addGestureRecognizer:gestureRecognizer];
    }
    return self;
}

- (void)singleTap:(UITapGestureRecognizer *)recognizer{
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[ZegoPopupMenuView class]] && 
            [v respondsToSelector:@selector(dismissMenu:)]) {
            [v performSelector:@selector(dismissMenu:) withObject:@(YES)];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // 若为ZegoPopupMenuViewCell（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"ZegoPopupMenuViewCell"] ||
        [NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"] ) {
        return NO;
    }
    return  YES;
}

@end

typedef enum {
  
    KxMenuViewArrowDirectionNone,
    KxMenuViewArrowDirectionUp,
    KxMenuViewArrowDirectionDown,
    KxMenuViewArrowDirectionLeft,
    KxMenuViewArrowDirectionRight,
    
} KxMenuViewArrowDirection;

@interface ZegoPopupMenuView()
@property (nonatomic, strong) ZegoPopupMenuConfig* popupMenuConfig;
@end

@implementation ZegoPopupMenuView {
    KxMenuViewArrowDirection     _arrowDirection;
    CGFloat                      _arrowPosition;
    UIView*                      _contentView;
    NSArray<ZegoPopupMenuItem*>* _menuItems;
}

- (id)init{
    self = [super initWithFrame:CGRectZero];    
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
        self.alpha = 0;
        self.layer.shadowOpacity = 0.08;
        self.layer.shadowOffset = CGSizeMake(0, -1);
        self.layer.shadowRadius = 15;
    }
    
    return self;
}

- (void)showMenuInView:(UIView*)parentView
              fromRect:(CGRect)anchorRect
             menuItems:(NSArray*)menuItems
                config:(ZegoPopupMenuConfig*)config{
    for (UIView *v in self.subviews) {
        [v removeFromSuperview];
    }
    self.popupMenuConfig = config;
    _menuItems = menuItems;
    
    ZegoPopupMenuFloatView *overlay = [[ZegoPopupMenuFloatView alloc] initWithFrame:parentView.bounds];
    [parentView addSubview:overlay];
    
    [overlay addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(overlay);
        make.height.equalTo(overlay);
    }];
    
    self.menuItemsTable = [[UITableView alloc]initWithFrame:CGRectZero];
    self.menuItemsTable.backgroundColor = [UIColor whiteColor];
    self.menuItemsTable.layer.cornerRadius = 10;
    [self.menuItemsTable registerClass:[ZegoPopupMenuViewCell class] forCellReuseIdentifier:@"ZegoPopupMenuViewCell"];
    self.menuItemsTable.dataSource = self;
    self.menuItemsTable.delegate = self;
    self.menuItemsTable.userInteractionEnabled = YES;
    self.menuItemsTable.separatorColor = [UIColor colorWithRed:239/255.0 green:240/255.0 blue:242/255.0 alpha:1.0];

    self.menuItemsTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.menuItemsTable.scrollEnabled = NO;

    _contentView = self.menuItemsTable;
    _contentView.hidden = YES;
    [self addSubview:_contentView];
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    
    CGPoint temp = [parentView convertPoint:CGPointMake(anchorRect.origin.x, anchorRect.origin.y) toView:overlay];
    if(temp.x + config.width > screenBounds.size.width){
        temp.x = screenBounds.size.width - config.width - 8;
    }
    temp.y = temp.y + anchorRect.size.height + config.topMargin;
    
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(config.width);
        make.height.mas_offset(44*_menuItems.count);
        make.left.mas_equalTo(temp.x);
        make.top.mas_equalTo(temp.y);
    }];
    
    const CGRect toFrame = self.frame;
    self.frame = (CGRect){self.arrowPoint, 1, 1};
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2
                     animations:^(void) {
                         self.alpha = 1.0f;
                         self.frame = toFrame;
                     } completion:^(BOOL completed) {
                         _contentView.hidden = NO;
                     }];
   
}


- (void)dismissMenu:(BOOL) animated{
    if (self.superview) {
        if (animated) {
            _contentView.hidden = YES;            
            const CGRect toFrame = (CGRect){self.arrowPoint, 1, 1};
            [UIView animateWithDuration:0.2
                             animations:^(void) {
                                 
                                 self.alpha = 0;
                                 self.frame = toFrame;
                                 
                             } completion:^(BOOL finished) {
                                 
                                 if ([self.superview isKindOfClass:[ZegoPopupMenuFloatView class]])
                                     [self.superview removeFromSuperview];
                                 [self removeFromSuperview];
                             }];
        } else {
            if ([self.superview isKindOfClass:[ZegoPopupMenuFloatView class]])
                [self.superview removeFromSuperview];
            [self removeFromSuperview];
        }
    }
}

#pragma mark - UITableViewDelegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // 返回表中有多少个部分
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ZegoPopupMenuViewCell";
    ZegoPopupMenuViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ZegoPopupMenuViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ZegoPopupMenuItem* item = _menuItems[indexPath.row];
    cell.menuItem = item;
    cell.showRearIcon = self.popupMenuConfig.cellShowRearIcon;
    if (item.initSelected) {
        cell.isSelected = item.initSelected;
        self.selectedIndexPath = indexPath;
    }
    if (indexPath.row == _menuItems.count - 1) {
        cell.separatorInset = UIEdgeInsetsMake(0, self.bounds.size.width, 0, 0);
    }else{
        cell.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 设置单元格的高度
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath != self.selectedIndexPath) {
        ZegoPopupMenuViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if(cell.canUse){
            // 如果不是同一个 item，取消之前选中的 item 的选中状态
            if (self.selectedIndexPath) {
                [tableView deselectRowAtIndexPath:self.selectedIndexPath animated:YES];
                ZegoPopupMenuViewCell *cell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
                cell.isSelected = NO;
            }
            self.selectedIndexPath = indexPath;
            
            ZegoPopupMenuViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.isSelected = YES;
        }
    }
    
    ZegoPopupMenuItem* menuItem = _menuItems[indexPath.row];
    if (menuItem) {
        [menuItem performAction];
    }
}

- (CGPoint) arrowPoint{
    CGPoint point;
    if (_arrowDirection == KxMenuViewArrowDirectionUp) {
        point = (CGPoint){ CGRectGetMinX(self.frame) + _arrowPosition, CGRectGetMinY(self.frame) };
    } else if (_arrowDirection == KxMenuViewArrowDirectionDown) {
        point = (CGPoint){ CGRectGetMinX(self.frame) + _arrowPosition, CGRectGetMaxY(self.frame) };
    } else if (_arrowDirection == KxMenuViewArrowDirectionLeft) {
        point = (CGPoint){ CGRectGetMinX(self.frame), CGRectGetMinY(self.frame) + _arrowPosition  };
    } else if (_arrowDirection == KxMenuViewArrowDirectionRight) {
        point = (CGPoint){ CGRectGetMaxX(self.frame), CGRectGetMinY(self.frame) + _arrowPosition  };
    } else {
        point = self.center;
    }
    
    return point;
}
@end


static ZegoPopupMenuWindow *gMenu;

@implementation ZegoPopupMenuWindow {
    ZegoPopupMenuView* _menuView;
    BOOL        _observing;
}

+ (instancetype) shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gMenu = [[ZegoPopupMenuWindow alloc] init];
    });
    return gMenu;
}

- (id)init{
    NSAssert(!gMenu, @"singleton object");
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc{
    if (_observing) {        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void) showMenuInView:(UIView *)parentView
               fromRect:(CGRect)rect
              menuItems:(NSArray *)menuItems
                 config:(ZegoPopupMenuConfig*)config{
    NSParameterAssert(parentView);
    NSParameterAssert(menuItems.count);
    
    if (_menuView) {
        [_menuView dismissMenu:NO];
        _menuView = nil;
    }

    if (!_observing) {
        _observing = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationWillChange:)
                                                     name:UIApplicationWillChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    _menuView = [[ZegoPopupMenuView alloc] init];
    [_menuView showMenuInView:parentView fromRect:rect menuItems:menuItems config:config];
}

- (void)dismissMenu{
    if (_menuView) {
        [_menuView dismissMenu:NO];
        _menuView = nil;
    }
    
    if (_observing) {
        _observing = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void) orientationWillChange: (NSNotification *) notification{
    [self dismissMenu];
}

@end
