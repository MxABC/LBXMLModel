//
//  XMLReader.h
//
//  Created by Troy Brant on 9/18/10.
//  Updated by Antoine Marcadet on 9/23/11.
//  Updated by Divan Visagie on 2012-08-26
//

#import <Foundation/Foundation.h>

enum {
    XMLReaderOptionsProcessNamespaces           = 1 << 0, // Specifies whether the receiver reports the namespace and the qualified name of an element.
    XMLReaderOptionsReportNamespacePrefixes     = 1 << 1, // Specifies whether the receiver reports the scope of namespace declarations.
    XMLReaderOptionsResolveExternalEntities     = 1 << 2, // Specifies whether the receiver reports declarations of external entities.
};
typedef NSUInteger XMLReaderOptions;

@interface XMLReader : NSObject <NSXMLParserDelegate>



/// xml数据转换jsondata
/// @param data xmldata
/// @param error 解析错误
+ (NSData *)jsonDataWithXMLData:(NSData *)data error:(NSError **)error;


/// 使用当前方法下面的3个方法得到的NSDictionary 需要再次调用下面方法进行转换过滤
/// @param dictionary 待转换和过滤NSDictionary
/// @param error error
+ (NSData *)jsonDataWithXMLDictionary:(NSDictionary *)dictionary error:(NSError **)error;


+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)errorPointer;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)errorPointer;
+ (NSDictionary *)dictionaryForXMLData:(NSData *)data options:(XMLReaderOptions)options error:(NSError **)errorPointer;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string options:(XMLReaderOptions)options error:(NSError **)errorPointer;



@end
