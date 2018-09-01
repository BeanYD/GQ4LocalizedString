//
//  GQResultWindowController.m
//  GQ4LocalizedString
//
//  Created by dingbinbin on 2018/9/2.
//  Copyright © 2018年 dingbinbin. All rights reserved.
//

#import "GQResultWindowController.h"
#import "GQResultViewController.h"

@interface GQResultWindowController ()

@property (strong, nonatomic) GQResultViewController *vc;

@end

@implementation GQResultWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.contentViewController = self.vc;
    
    self.window.title = NSLocalizedString(@"搜索结果", nil);
    
}

- (GQResultViewController *)vc {
    if (!_vc) {
        _vc = [[GQResultViewController alloc] initWithNibName:@"GQResultViewController" bundle:nil];
    }
    
    return _vc;
}

@end
