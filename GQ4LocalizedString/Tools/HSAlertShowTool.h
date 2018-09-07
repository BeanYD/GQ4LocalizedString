//
//  HSAlertShowTool.h
//  HiStor4MAC
//
//  Created by dingbinbin on 2018/1/24.
//  Copyright © 2018年 dingbinbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HSAlertShowTool : NSObject

// 警告弹窗——删除等重要操作
+ (void)showWarningAlertViewWithMessage:(NSString *)message
                            informative:(NSString *)informative
                        sureButtonTitle:(NSString *)sureTitle
                      cancelButtonTitle:(NSString *)cancelTitle
                             sureButton:(void (^)(void))sureButtonBlock
                           cancelButton:(void (^)(void))cancelButtonBlock;

// 信息弹窗——提示信息
+ (void)showInfoAlertWithMessage:(NSString *)message
                     informative:(NSString *)informative
                 sureButtonTitle:(NSString *)sureTitle;

// 提醒弹窗
+ (void)showRemindAlertWithMessage:(NSString *)message
                       informative:(NSString *)informative
                   sureButtonTitle:(NSString *)sureTitle
                        sureButton:(void (^)(void))sureButtonBlock;

// 带图片的提醒框
+ (void)showImageAlertWithMessage:(NSString *)message
                      informative:(NSString *)informative
                        imageName:(NSString *)imageName
                  sureButtonTitle:(NSString *)sureButtonTitle;

@end
