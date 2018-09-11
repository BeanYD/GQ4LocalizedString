//
//  ExcelTool.m
//

#import "ExcelTool.h"
#import "DHxlsReaderIOS.h"

#import "ZipArchive.h"

#import "GDataXMLNode.h"

@interface ExcelTool ()

@end



@implementation ExcelTool

-(NSString *)readExcel_Xls_WithPath:(NSString *)filePath{
    DHxlsReader *reader = [DHxlsReader xlsReaderFromFile:filePath];
    assert(reader);
    
#if 0
    [reader startIterator:0];
    
    while(YES) {
        DHcell *cell = [reader nextCell];
        if(cell.type == cellBlank) break;
        
        text = [text stringByAppendingFormat:@"\n%@\n", [cell dump]];
        NSLog(@"%@", text);
    }
    
#else
    
    int col = 1;
  
    while (YES) {
        DHcell *cell = [reader cellInWorkSheetIndex:0 row:1 col:col];
        if(col > 10) break;
        NSString *name = [cell dump];

        col++;
    }
    if (self.nameCol == 0 || self.phoneCol == 0) {
        NSLog(@"读取xls完成");
        return nil;
    }
    int row = 2;
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    while(YES) {
        DHcell *cell = [reader cellInWorkSheetIndex:0 row:row col:self.nameCol];
        if(cell.type == cellBlank) break;
        DHcell *cell1 = [reader cellInWorkSheetIndex:0 row:row col:self.phoneCol];
        //        NSLog(@"\nCell:%@\nCell1:%@\n", [cell dump], [cell1 dump]);
        NSLog(@"%@%@", [cell dump], [cell1 dump]);
        row++;
        if ([cell1 dump].length == 0) {
            continue;
        }
        NSDictionary *contact = @{@"AgentNo":[[NSUserDefaults standardUserDefaults] objectForKey:@"用户"],@"Name":[cell dump],@"Phone":[cell1 dump]};
        [tempArray addObject:contact];
       
    }
   
#endif
    NSData* jsonData =[NSJSONSerialization dataWithJSONObject:tempArray
                                                      options:NSJSONWritingPrettyPrinted error:nil];
    NSString *strs=[[NSString alloc] initWithData:jsonData
                                         encoding:NSUTF8StringEncoding];
    
    return strs;
}


-(NSString *)readExcel_XlsX_WithPath:(NSString *)filePath
{
    
    // 解压zip文件
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *unZipPath = [docDir stringByAppendingPathComponent:@"Cont"];
    
    BOOL succeed = [SSZipArchive unzipFileAtPath:filePath toDestination:unZipPath];
    
    if (!succeed) {
        // 解压失败
        NSLog(@"解压xlsx的zip文件失败，直接返回");
        
        return nil;
    }
    
    //4.1 加载XML文档
    //字符池
    NSString *xlStr = [unZipPath stringByAppendingPathComponent:@"xl"];
    NSString *shareStr = [xlStr stringByAppendingPathComponent:@"sharedStrings.xml"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:shareStr];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc]initWithData:data options:kNilOptions error:nil];
    NSArray *strEles = [doc.rootElement elementsForName:@"si"];
    //字符串中介数组
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (GDataXMLElement *student in strEles) {
        //获取节点属性
        GDataXMLElement *pidElement = [[student elementsForName:@"t"] objectAtIndex:0];
        NSString *pid = [pidElement stringValue];
        
        if (!pid) {
            break;
        }
        [tempArray addObject:pid];
    }
   
    
    //表格
    NSString *workStr= [xlStr stringByAppendingPathComponent:@"worksheets"];
    NSString *sheetStr = [workStr stringByAppendingPathComponent:@"sheet1.xml"];
    NSData *sheetData = [[NSData alloc] initWithContentsOfFile:sheetStr];
    GDataXMLDocument *xmldoc = [[GDataXMLDocument alloc]initWithData:sheetData options:kNilOptions error:nil];
    NSArray *sheetEles  = [xmldoc.rootElement elementsForName:@"sheetData"];
    GDataXMLDocument *rowDoc = [[GDataXMLDocument alloc] initWithRootElement:sheetEles.firstObject];
    NSArray *rowS = [rowDoc.rootElement elementsForName:@"row"];
  
    //表格字典中介数组
    NSMutableArray *dictTemp = [[NSMutableArray alloc] init];
    NSString *name;
    NSString *number;
    for (GDataXMLElement *contact in rowS) {
        //获取节点属性
        NSString *str = [contact attributeForName:@"r"].stringValue;
        if ([str isEqualToString:@"1"]) {
            GDataXMLDocument *cDoc = [[GDataXMLDocument alloc] initWithRootElement:contact];
            NSArray *cArrays = [cDoc.rootElement elementsForName:@"c" ];
          
            for (GDataXMLElement *clo in cArrays) {
                NSString *str = [clo attributeForName:@"r"].stringValue;
                NSString *typeStr = [clo attributeForName:@"t"].stringValue;
                GDataXMLElement *pidElement = [[clo elementsForName:@"v"] objectAtIndex:0];
                NSInteger index = pidElement.stringValue.intValue;
                
            }
            continue;
        }
        
        
        GDataXMLDocument *cDoc = [[GDataXMLDocument alloc] initWithRootElement:contact];
        NSArray *cArrays = [cDoc.rootElement elementsForName:@"c" ];
        NSLog(@"%@",cArrays);
        for (GDataXMLElement *clo in cArrays) {
            NSString *str = [clo attributeForName:@"r"].stringValue;
            NSString *typeStr = [clo attributeForName:@"t"].stringValue;
            
            if ([str containsString:self.nameNum]) {
                GDataXMLElement *pidElement = [[clo elementsForName:@"v"] objectAtIndex:0];
                NSInteger index = pidElement.stringValue.intValue;
                if ([typeStr isEqualToString:@"s"]) {
                    name = tempArray[index];
                }else{
                    name = pidElement.stringValue;
                }
            }
            
            if ([str containsString:self.phoneNum]) {
                GDataXMLElement *pidElement = [[clo elementsForName:@"v"] objectAtIndex:0];
                NSInteger index = pidElement.stringValue.intValue;
                if ([typeStr isEqualToString:@"s"]) {
                    number = tempArray[index];
                }else{
                    number = pidElement.stringValue;
                }
            }
        }
        if (number == nil) {
            continue;
        }
        NSDictionary *contact = @{@"AgentNo":[[NSUserDefaults standardUserDefaults] objectForKey:@"用户"],@"Name":name,@"Phone":number};
                [dictTemp addObject:contact];
    }
    
    NSLog(@"%@",dictTemp);
  
    
    NSData* jsonData =[NSJSONSerialization dataWithJSONObject:dictTemp
                                                      options:NSJSONWritingPrettyPrinted error:nil];
    NSString *strs=[[NSString alloc] initWithData:jsonData
                                             encoding:NSUTF8StringEncoding];
// [[NSFileManager defaultManager] removeItemAtPath:unZipPath error:nil];
    return strs;

}



@end
