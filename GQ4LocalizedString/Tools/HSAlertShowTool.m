//
//  HSAlertShowTool.m
//  HiStor4MAC
//
//  Created by dingbinbin on 2018/1/24.
//  Copyright © 2018年 dingbinbin. All rights reserved.
//

#import "HSAlertShowTool.h"
#import <Cocoa/Cocoa.h>

@implementation HSAlertShowTool

+ (void)showWarningAlertViewWithMessage:(NSString *)message
                            informative:(NSString *)informative
                        sureButtonTitle:(NSString *)sureTitle
                      cancelButtonTitle:(NSString *)cancelTitle
                             sureButton:(void (^)(void))sureButtonBlock
                           cancelButton:(void (^)(void))cancelButtonBlock {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = message;
    alert.informativeText = informative;
    alert.alertStyle = NSAlertStyleWarning;
    [alert addButtonWithTitle:sureTitle];
    [alert addButtonWithTitle:cancelTitle];
    
    NSUInteger action = [alert runModal];
    
    if (action == NSAlertFirstButtonReturn) {
        
        sureButtonBlock();
        
    } else if (action == NSAlertSecondButtonReturn) {
        
        cancelButtonBlock();
    }
}

+ (void)showRemindAlertWithMessage:(NSString *)message
                       informative:(NSString *)informative
                   sureButtonTitle:(NSString *)sureTitle
                        sureButton:(void (^)(void))sureButtonBlock {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = message;
    alert.informativeText = informative;
    alert.alertStyle = NSAlertStyleWarning;
    [alert addButtonWithTitle:sureTitle];
    
    NSUInteger action = [alert runModal];
    
    if (action == NSAlertFirstButtonReturn) {
        
        sureButtonBlock();
        
    }
}

+ (void)showInfoAlertWithMessage:(NSString *)message
                     informative:(NSString *)informative
                 sureButtonTitle:(NSString *)sureTitle {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = message;
    alert.informativeText = informative;
    alert.alertStyle = NSAlertStyleInformational;
    [alert addButtonWithTitle:sureTitle];
    
    [alert runModal];
}

+ (void)showImageAlertWithMessage:(NSString *)message
                      informative:(NSString *)informative
                        imageName:(NSString *)imageName
                  sureButtonTitle:(NSString *)sureButtonTitle {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = message;
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    imageView.image = [NSImage imageNamed:imageName];
    alert.accessoryView = imageView;
    alert.informativeText = informative;
    alert.alertStyle = NSAlertStyleInformational;
    [alert addButtonWithTitle:sureButtonTitle];
    
    [alert runModal];
}

@end
