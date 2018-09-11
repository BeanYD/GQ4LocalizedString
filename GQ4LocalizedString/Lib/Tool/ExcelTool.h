//
//  ExcelTool.h
//

#import <Foundation/Foundation.h>


@interface ExcelTool : NSObject

-(NSString *)readExcel_Xls_WithPath:(NSString *)filePath;

-(NSString *)readExcel_XlsX_WithPath:(NSString *)filePath;

@end
