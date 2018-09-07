//
//  GQMainModel.m
//  GQ4LocalizedString
//
//  Created by dingbinbin on 2018/9/5.
//  Copyright © 2018年 dingbinbin. All rights reserved.
//

#import "GQMainModel.h"

@implementation GQMainModel

- (instancetype)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

- (NSMutableArray *)excelFileListFromSource:(NSArray *)sourceList {
    
    NSMutableArray *excels = [NSMutableArray array];
    
    for (int i = 0; i < sourceList.count; i++) {
        NSURL *url = sourceList[i];
        
        NSString *ext = [url pathExtension];
        
        if ([ext isEqualToString:@"xlsx"] || [ext isEqualToString:@"xls"]) {
            [excels addObject:url];
        }
    }
    
    return excels;
}

- (NSMutableArray *)stringsFileListFromSource:(NSArray *)sourceList {
    
    NSMutableArray *stringsFiles = [NSMutableArray array];
    
    for (int i = 0; i < sourceList.count; i++) {
        NSURL *url = sourceList[i];
        
        NSString *ext = [url pathExtension];
        
        if ([ext isEqualToString:@"strings"]) {
            [stringsFiles addObject:url];
        }
    }
    
    return stringsFiles;
}

@end
