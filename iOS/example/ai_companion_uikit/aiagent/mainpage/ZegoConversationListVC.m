//
//  ZegoConversationListVC.m
//  ai_companion_oc
//
//  Created by applechang on 2024/5/23.
//

#import "ZegoConversationListVC.h"


@interface ZegoConversationListVC ()
@end

@implementation ZegoConversationListVC
-(instancetype)init{
    if(self = [super init]){
        
    }
    return  self;
}

-(instancetype)initWithCoder:(NSCoder *)coder{
    if(self = [super initWithCoder:coder]){
        
    }
    return self;
}

- (NSString *)generateID:(NSString *)prefix isIDMaintain:(BOOL)isIDMaintain {
    NSString *randomID = [NSString stringWithFormat:@"%@%ld%u", prefix, (long)CFAbsoluteTimeGetCurrent() % 1000000, arc4random_uniform(100)];
    if (isIDMaintain) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *cacheID = [defaults objectForKey:prefix];
        if(cacheID == nil){
            [defaults setObject:randomID forKey:prefix];
            [defaults synchronize];
            cacheID = randomID;
        }
        return cacheID;
    } else {
        return randomID;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}
@end

