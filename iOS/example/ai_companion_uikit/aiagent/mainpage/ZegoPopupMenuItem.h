#import <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

@interface ZegoPopupMenuItem : NSObject

@property (readwrite, nonatomic, strong) UIImageView *image;
@property (readwrite, nonatomic, strong) NSString *title;
@property (readwrite, nonatomic, strong) NSString *tag;
@property (readwrite, nonatomic, weak) id target;
@property (readwrite, nonatomic) SEL action;
@property (readwrite, nonatomic, assign) BOOL initSelected;
@property (readwrite, nonatomic, assign) BOOL canUse;
@property (readwrite, nonatomic, strong) UIColor *foreColor;
@property (readwrite, nonatomic) NSTextAlignment alignment;

- (instancetype)initWith:(NSString *)title
                  canUse:(BOOL)canUse
                     tag:(NSString*)tag
                   image:(UIImageView *)image
                  target:(id)target
                  action:(SEL) action;

- (BOOL) enabled;
- (void) performAction;
- (NSString*) description;
@end
