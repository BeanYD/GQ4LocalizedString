//
//  GQMainModel.h
//  GQ4LocalizedString
//
//  Created by dingbinbin on 2018/9/5.
//  Copyright © 2018年 dingbinbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GQMainModel : NSObject

// 获取excel文件
- (NSMutableArray *)excelFileListFromSource:(NSArray *)sourceList;

// 获取.strings文件
- (NSMutableArray *)stringsFileListFromSource:(NSArray *)sourceList;

@end
