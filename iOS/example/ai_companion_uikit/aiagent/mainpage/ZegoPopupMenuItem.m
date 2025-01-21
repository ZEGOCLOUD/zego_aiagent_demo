#import "ZegoPopupMenuItem.h"

@implementation ZegoPopupMenuItem

- (instancetype)initWith:(NSString *)title
                  canUse:(BOOL)canUse
                     tag:(NSString*)tag
                   image:(UIImageView *)image
                  target:(id)target
                  action:(SEL) action{
    self = [super init];
    if (self) {
        self.title = title;
        self.image = image;
        self.target = target;
        self.action = action;
        self.tag = tag;
        self.canUse = canUse;
    }
    return self;
}

- (BOOL) enabled{
    return _target != nil && _action != NULL;
}

- (void) performAction{
    __strong id target = self.target;
    if (target && [target respondsToSelector:_action]) {
        [target performSelectorOnMainThread:_action withObject:self waitUntilDone:YES];
    }
}

- (NSString *) description{
    return [NSString stringWithFormat:@"<%@ #%p %@>", [self class], self, _title];
}
@end
