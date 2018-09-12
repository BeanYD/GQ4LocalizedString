//
//  GQMainModel.m
//  GQ4LocalizedString
//
//  Created by dingbinbin on 2018/9/5.
//  Copyright © 2018年 dingbinbin. All rights reserved.
//

#import "GQMainModel.h"
#import "DHxlsReaderIOS.h"
#import "DHxlsReaderIOS.h"

#import "ZipArchive.h"

#import "GDataXMLNode.h"

@interface GQMainModel ()

@end

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

- (void)dealWithSpaceWithPath:(NSString *)path {
    NSString *unZipPath = [self unzipXlsxFileFromPath:path];
    if (!unZipPath) {
        // 解压失败
        return;
    }
    
    // 加载XML文档
    //字符池
    NSString *xlStr = [unZipPath stringByAppendingPathComponent:@"xl"];
    NSString *shareStr = [xlStr stringByAppendingPathComponent:@"sharedStrings.xml"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:shareStr];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:data options:kNilOptions error:nil];
        
    // strEles所有网格的字符
    NSArray *strEles = [doc.rootElement elementsForName:@"si"];

    for (GDataXMLNode *xmlNode in strEles) {
        
//        NSLog(@"xmlNode Xml String:%@", xmlNode.XMLString);
        
        NSArray *xmlChildren = xmlNode.children;
        
        for (GDataXMLElement *elem in xmlChildren) {
            

            if (!elem.XMLNode->children) {
                continue;
            }
            
            xmlChar *pcText = elem.XMLNode->children->content;
            // 去除头尾空格操作.ASCII码值，0-255之间，unsigned char *和char *可直接强转
            pcText = (unsigned char *)delete_space((char *)pcText);
            
            NSLog(@"content str:%s", pcText);

        }
            
    }
    
    
//    NSLog(@"网格所有字符%@\n", strEles);
    
    

    NSString *workStr= [xlStr stringByAppendingPathComponent:@"worksheets"];
    NSString *sheetStr = [workStr stringByAppendingPathComponent:@"sheet1.xml"];
    NSData *sheetData = [[NSData alloc] initWithContentsOfFile:sheetStr];
    GDataXMLDocument *xmldoc = [[GDataXMLDocument alloc]initWithData:sheetData options:kNilOptions error:nil];
    
    // sheetEles文件内的sheet数组（表格数组）
    NSArray *sheetEles  = [xmldoc.rootElement elementsForName:@"sheetData"];
    
    
    // 行数据关键字"row"
    GDataXMLDocument *sheet1Doc = [[GDataXMLDocument alloc] initWithRootElement:sheetEles.firstObject];
    NSArray *rowS = [sheet1Doc.rootElement elementsForName:@"row"];
    
    
    
//    NSLog(@"行数据Row:%@\n", rowS);
    

    // 获取节点属性
    for (GDataXMLElement *contact in rowS) {
        
        NSString *str = [contact attributeForName:@"r"].stringValue;
        
//        NSLog(@"str:%@", str);
        
        GDataXMLDocument *cDoc = [[GDataXMLDocument alloc] initWithRootElement:contact];
        NSArray *cArrays = [cDoc.rootElement elementsForName:@"c"];
        
//        NSLog(@"cArrays:%@", cArrays);
    }
    
}

#pragma mark - private method
- (NSString *)unzipXlsxFileFromPath:(NSString *)fromPath {
    // 解压zip文件
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *unZipPath = [docDir stringByAppendingPathComponent:@"Cont"];
    
    BOOL succeed = [SSZipArchive unzipFileAtPath:fromPath toDestination:unZipPath];
    
    if (!succeed) {
        // 解压失败
        NSLog(@"解压xlsx的zip文件失败，直接返回");
        
        return nil;
    }
    
    return unZipPath;
}

#pragma mark - public method

- (NSString *)dataStringFromXlsxExcel:(NSString *)path {
    
    [self dealWithSpaceWithPath:path];

    return nil;
}


- (NSString *)dataStringFromXlsExcel:(NSString *)path {
    
    return nil;
}

#pragma mark - text method
- (void)textCFunction {
    char *str = "   wo shi ";
    
    char *cStr = delete_space(str);
    
    printf("%s", cStr);
}

#pragma mark - c function
// 删除首尾空格 
char * delete_space(char *src)
{
    char *end,*sp,*ep;
    long len;
    
    sp = (char *)malloc(sizeof(char) * strlen(src));
    strcpy(sp, src);
    
    end = sp + strlen(sp) - 1;
    ep = end;
    
    // 去除头部空格
    while(sp<=end && isspace(*sp))
        sp++;
    
    // 找到最后一个非空格字符
    while(ep>=sp && isspace(*ep))
        ep--;
    
    // (ep < sp)判断是否整行都是空格
    len = (ep < sp) ? 0:(ep-sp)+1;
    sp[len] = '\0';
    return sp;
    
} 


@end
