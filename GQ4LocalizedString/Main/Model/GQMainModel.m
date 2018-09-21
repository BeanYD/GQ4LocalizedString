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
#import "GQXlsxSiModel.h"

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
    NSLog(@"Unzip xml data path:%@", shareStr);
    NSData *data = [[NSData alloc] initWithContentsOfFile:shareStr];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:data options:kNilOptions error:nil];
    
    if (!doc) return;
    
    // strEles所有网格的字符
    NSArray *strEles = [doc.rootElement elementsForName:@"si"];
    
    NSLog(@"uri:%@\nprefix:%@\nname:%@\nlocalName:%@", doc.rootElement.URI, doc.rootElement.prefix, doc.rootElement.name, doc.rootElement.localName);
    
    // 新的字符数组
    NSMutableArray *newSiEles = [NSMutableArray array];
    
    for (GDataXMLElement *member in strEles) {
        
        NSString *textString;
        
        // text
        NSArray *texts = [member elementsForName:@"t"];
        
        if (texts.count) {
            GDataXMLElement *textElem = (GDataXMLElement *)[texts objectAtIndex:0];
//            textString = [textElem.stringValue stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            textString = textElem.stringValue;
            
        }
        
        NSLog(@"texts:%@, text:%@", texts, textString);
        
        // 处理前后空格的问题
        textString = [textString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        [newSiEles addObject:textString];
    }

    // 创建新的xml文档——使用原表名
    GDataXMLElement *newSiElem = [GDataXMLNode elementWithName:doc.rootElement.name];

    for (NSString *text in newSiEles) {
        
        GDataXMLElement *excelElem = [GDataXMLNode elementWithName:@"si"];
        GDataXMLElement *textElem = [GDataXMLNode elementWithName:@"t" stringValue:text];
        
        [excelElem addChild:textElem];
        [newSiElem addChild:excelElem];
    }
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:newSiElem];
    
    NSData *xmlData = document.XMLData;
    
    NSString *filePath = [self dataFilePath:YES];
    
    NSLog(@"Saving xml data to %@", filePath);

    [xmlData writeToFile:filePath atomically:YES];

    
}

- (NSString *)dataFilePath:(BOOL)forSave {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentsPath = [documentsDirectory
                               stringByAppendingPathComponent:@"sharedStrings.xml"];
    if (forSave || 
        [[NSFileManager defaultManager] fileExistsAtPath:documentsPath]) {
        return documentsPath;
    } else {
        return [[NSBundle mainBundle] pathForResource:@"sharedStrings" ofType:@"xml"];
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
