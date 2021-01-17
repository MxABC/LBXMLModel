//
//  NSObject+LBXMLModel.h
//  XML
//
//  Created by lbxia on 2021/1/16.
//

#import <Foundation/Foundation.h>


/*
 xml与jsonmodel相互转换，基于XMLReader,XMLWriter对xml数据进行改造，最后使用YYModel进行打包和解析
 json model定义参考YYModel
 
 model定义额为注意事项
 1、xml标签如果有属性，需要在model添加 NSArray *xml_attribute_set 参数，并返回对应标签的属性名称,属性类型都需要定义为NSString
 2、既有属性，又有标签内容的，还需要定义 NSString *tag_content_text;参数，来表示标签值
 */
@interface NSObject (LBXMLModel)


/// xml -> jsonmodel
/// @param xml xml数据，类型 NSString,NSData,NSDictionary
+ (instancetype)jsonModelWithXML:(id)xml;


/// model -> xmldata
/// @param header  是否写 xml头： <?xml version="1.0" encoding="UTF-8" ?>
- (NSData*)jsonModelToXMLData:(BOOL)header;

@end


