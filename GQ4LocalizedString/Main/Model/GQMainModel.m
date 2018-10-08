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
#import "xlsxwriter.h"

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
    
    // 解析 doc 的 xml <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    
    #pragma mark - 后续实现解析doc的xml <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    
    
    // strEles所有网格的字符 <si><t>(text)</t><phoneticPr ...></si>
    NSArray *strEles = [doc.rootElement elementsForName:@"si"];
    
    NSLog(@"uri:%@\nprefix:%@\nname:%@\nlocalName:%@\n", doc.rootElement.URI, doc.rootElement.prefix, doc.rootElement.name, doc.rootElement.localName);
    
    // 新的字符数组
    NSMutableArray *newSiEles = [NSMutableArray array];
    
    // 新的字符attr数组（二维数组）——与字符数组一一对应
    NSMutableArray *newSiAttrEles = [NSMutableArray array];
    
    for (GDataXMLElement *member in strEles) {
        
        NSString *textString;
        
        // 获取text from <t>(text)</t>
        NSArray *texts = [member elementsForName:@"t"];
        
        if (texts.count) {
            GDataXMLElement *textElem = (GDataXMLElement *)[texts objectAtIndex:0];
//            textString = [textElem.stringValue stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            textString = textElem.stringValue;
            
        }
        
        NSLog(@"texts:%@, text:%@", texts, textString);
        
        // 处理前后空格的问题
        textString = [textString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        // text添加到数组中
        [newSiEles addObject:textString];
        
        // phoneticPr <phoneticPr fontId="1" type="noConversion"/> —— GDataXMLNode
        NSArray *ticPrs = [member elementsForName:@"phoneticPr"];
        
        if (ticPrs.count) {
            GDataXMLElement *prElem = (GDataXMLElement *)[ticPrs objectAtIndex:0];
            NSLog(@"prElem name:%@, attr:%@", prElem.name, prElem.attributes);
            
            // 解析每个格子内的attr
            NSArray *prAttrNodes = prElem.attributes;
            
            [newSiAttrEles addObject:prAttrNodes];
        }
    }

    // 创建新的xml文档——使用原表名
    GDataXMLElement *newSiElem = [GDataXMLNode elementWithName:doc.rootElement.name];
    
    for (int i = 0; i < newSiEles.count; i++) {
        NSString *text = newSiEles[i];
        
        // 创建 <si>...</si>
        GDataXMLElement *excelElem = [GDataXMLNode elementWithName:@"si"];
        
        // 创建 <t>(text)</t>     
        // 暂不处理 <t xml:space="preserve"> 
        // 标志 default:无空行 preserve:有空行
        GDataXMLElement *textElem = [GDataXMLNode elementWithName:@"t" stringValue:text];
        
        // 添加 t——>si     <si><t>(text)</t></si>
        [excelElem addChild:textElem];
        
        // 创建 <phoneticPr ...>
        GDataXMLElement *docPrElem = [GDataXMLNode elementWithName:@"phoneticPr"];
        
        NSArray *ticPrs = newSiAttrEles[i];
        
        // 添加 attr 到 phoneticPr 
        for (GDataXMLNode *ticPrAttr in ticPrs) {
            [docPrElem addAttribute:ticPrAttr];
        }
        
        // 添加 phoneticPr——>si     <si><t>(text)</t><phoneticPr ...></si>   
        [excelElem addChild:docPrElem];
        
        // 将创建好的 <si>...</si> 添加到表中
        [newSiElem addChild:excelElem];

    }
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:newSiElem];
    
    // 设置编码格式 @"UTF-8"
    [document setCharacterEncoding:@"UTF-8"];
    
    // 解析doc.rootElement的attr <sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="12" uniqueCount="12"> —— GDataXMLNode
    NSArray *docRootElemAttrs = doc.rootElement.attributes;
    for (GDataXMLNode *rootAttrNode in docRootElemAttrs) {
        // 添加每条attr
        [document.rootElement addAttribute:rootAttrNode];

//        NSLog(@"rootAttrNode:%@", rootAttrNode);
    }
    
    NSData *xmlData = document.XMLData;
        
    NSString *filePath = [self createNewXmlDataFilePath:YES];
    
    NSLog(@"Saving xml data to %@", filePath);

    // 写入文件
    [xmlData writeToFile:filePath atomically:YES];
    
    // 生成新压缩包
    
    [self zipXlsxFileFromPath:unZipPath createPath:[self createNewZipFilePathWithFileName:@"newZip.xlsx"]];
}

#pragma mark - private method

// 解压 xlsx ，获取 xml 
- (NSString *)unzipXlsxFileFromPath:(NSString *)fromPath {
    // 解压zip文件
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *unZipPath = [docDir stringByAppendingPathComponent:@"Cont"];
    
    NSLog(@"unzip file Path:%@", unZipPath);
    
    BOOL succeed = [SSZipArchive unzipFileAtPath:fromPath toDestination:unZipPath];
    
    if (!succeed) {
        // 解压失败
        NSLog(@"解压xlsx的zip文件失败，直接返回");
        
        return nil;
    }
    
    return unZipPath;
}

// 将 xml 压缩生成 xlsx
- (void)zipXlsxFileFromPath:(NSString *)fromPath createPath:(NSString *)createPath {
    
    BOOL succeed = [SSZipArchive createZipFileAtPath:createPath withFilesAtPaths:[NSArray arrayWithObject:fromPath]];
    
    if (!succeed) {
        // 压缩失败
        NSLog(@"压缩失败");
        
    }
    
}

// 重新生成 xml 文件的路径
- (NSString *)createNewXmlDataFilePath:(BOOL)forSave {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                         NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *contPath = [docDir stringByAppendingPathComponent:@"cont"];
    NSString *xlPath = [contPath stringByAppendingPathComponent:@"xl"];
    NSString *xmlPath = [xlPath stringByAppendingPathComponent:@"sharedStrings.xml"];
    
    NSLog(@"new xml file path:%@", xmlPath);
    
    if (forSave || 
        [[NSFileManager defaultManager] fileExistsAtPath:xmlPath]) {
        return xmlPath;
    } else {
        return [[NSBundle mainBundle] pathForResource:@"sharedStrings" ofType:@"xml"];
    }
    
}

// 重新生成 zip 文件的路径
- (NSString *)createNewZipFilePathWithFileName:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *filePath = [docDir stringByAppendingPathComponent:fileName];
    
    NSLog(@"new zip file path:%@", filePath);
    return filePath;
}

// 重新生成 xlsx 文件
- (void)createNewXlsxFile {
    // 文件保存的路径
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filename = [documentPath stringByAppendingPathComponent:@"Localization.xlsx"];
    
    
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
