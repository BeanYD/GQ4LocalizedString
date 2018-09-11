//
//  ViewController.m
//  GQ4LocalizedString
//
//  Created by dingbinbin on 2018/9/2.
//  Copyright © 2018年 dingbinbin. All rights reserved.
//

#import "GQMainViewController.h"
#import "GQMainModel.h"
#import "HSAlertShowTool.h"

@interface GQMainViewController()

@property (nonatomic, strong) NSMutableArray *selectFileList;

@property (nonatomic, strong) GQMainModel *model;

@end

@implementation GQMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    self.model = [[GQMainModel alloc] init];
}

// 浏览按钮
- (IBAction)browseButtonClick:(id)sender {
    
    // 弹出panel选择文件或者文件夹
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    // 是否可以创建文件夹
    panel.canCreateDirectories = NO;
    // 是否可以选择文件夹
    panel.canChooseDirectories = YES;
    // 是否可以选择文件
    panel.canChooseFiles = YES;
    
    // 是否支持多选
    panel.allowsMultipleSelection = YES;
    
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
    
        if (result == NSModalResponseOK) {
            
            // 处理选中后事件
            self.selectFileList = [panel.URLs mutableCopy];
            
            NSLog(@"urls:%@", self.selectFileList);
        }
        
    }];
    
    
}

// excel检测空格
- (IBAction)excelScanSpaceButtonClick:(id)sender {
    
    NSArray *excels = [self.model excelFileListFromSource:self.selectFileList];
    
    if (0 == excels.count) {
        // 不存在excel文件
        [HSAlertShowTool showInfoAlertWithMessage:@"" informative:@"不存在所选的文件类型" sureButtonTitle:@"确定"];
        return;
    }
    
    // 处理excel文件
    NSURL *url = self.selectFileList[0];

    NSString *excelString = [self.model dataStringFromXlsxExcel:[url path]];
    
    NSLog(@"result:%@", excelString);
}

// excel检测占位符
- (IBAction)excelScanPlaceHoderButtonClick:(id)sender {
    
    NSArray *excels = [self.model excelFileListFromSource:self.selectFileList];
    
    if (0 == excels.count) {
        // 不存在excel文件
        [HSAlertShowTool showInfoAlertWithMessage:@"" informative:@"不存在所选的文件类型" sureButtonTitle:@"确定"];
        return;
    }
    
    // 处理excel文件
}

// iOS的string文件检测空格
- (IBAction)stringScanSpaceButtonClick:(id)sender {
    
    NSArray *stringFiles = [self.model stringsFileListFromSource:self.selectFileList];
    
    if (0 == stringFiles.count) {
        // 不存在excel文件
        [HSAlertShowTool showInfoAlertWithMessage:@"" informative:@"不存在所选的文件类型" sureButtonTitle:@"确定"];
        return;
    }
    
    // 处理strings文件
    
}

// iOS的string文件检测占位符
- (IBAction)stringScanPlaceHodlerButtonClick:(id)sender {
    
    NSArray *stringFiles = [self.model stringsFileListFromSource:self.selectFileList];
    
    if (0 == stringFiles.count) {
        // 不存在excel文件
        [HSAlertShowTool showInfoAlertWithMessage:@"" informative:@"不存在所选的文件类型" sureButtonTitle:@"确定"];
        return;
    }
    
    // 处理strings文件
    
}



@end
