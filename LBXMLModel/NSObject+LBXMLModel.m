//
//  NSObject+LBXMLModel.m
//  XML
//
//  Created by lbxia on 2021/1/16.
//

#import "NSObject+LBXMLModel.h"
#import "XMLReader.h"
#import "XMLWriter.h"
#import "YYModel.h"
static NSString *const kXMLReaderTextNodeKey        = @"tag_content_text";


@implementation NSObject (LBXMLModel)

#pragma mark-
#pragma mark-  xmldata -> jsonmodel
#pragma mark-

+ (instancetype)jsonModelWithXML:(id)json
{
    NSDictionary *dic = [self _xml_dictionaryWithJSON:json];
    
    NSMutableDictionary *mudic = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    [self PropertiesWithDictionary:mudic];
    
    return [self yy_modelWithDictionary:mudic];
}

+ (NSDictionary *)_xml_dictionaryWithJSON:(id)json {
    if (!json || json == (id)kCFNull) return nil;
    NSDictionary *dic = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
        jsonData = [XMLReader jsonDataWithXMLDictionary:dic error:nil];
        
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding : NSUTF8StringEncoding];
        dic = [XMLReader dictionaryForXMLData:jsonData error:nil];
        jsonData = [XMLReader jsonDataWithXMLDictionary:dic error:nil];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
        
        dic = [XMLReader dictionaryForXMLData:jsonData error:nil];
        jsonData = [XMLReader jsonDataWithXMLDictionary:dic error:nil];
    }
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
    }
    return dic;
}


/// 字典中不是数组，但是原型是数组的，对字典进行修改
/// @param dictionary dictionary description
+ (void)PropertiesWithDictionary:(NSMutableDictionary *)dictionary {
    
    unsigned int count;
    
    // 获取当前对象的属性列表
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    
    // 遍历 propertyList 中所有属性，以其属性名为 key，在字典中查找 value
    for (unsigned int i = 0; i < count; i++) {
        // 获取属性
        objc_property_t property = propertyList[i];
        const char *propertyName = property_getName(property);
        
        NSString *propertyNameStr = [NSString stringWithUTF8String:propertyName];
        
        // 获取 JSON 中属性值 value
        id value = [dictionary objectForKey:propertyNameStr];
        
        NSLog(@"value:%@",value);
        
        if ([value isKindOfClass:[NSMutableDictionary class]]) {
            NSLog(@"NSMutableDictionary");
        }
        else if ([value isKindOfClass:[NSDictionary class]]) {
            NSLog(@"NSDictionary");
            
            NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:value];
            [dictionary setValue:tmp forKey:propertyNameStr];
            value = tmp;
        }
        else if ([value isKindOfClass:[NSMutableArray class]]) {
            NSLog(@"NSMutableArray");
        }
        else if ([value isKindOfClass:[NSArray class]])
        {
            NSMutableArray *tmp = [NSMutableArray arrayWithArray:value];
            [dictionary setValue:tmp forKey:propertyNameStr];

            value = tmp;
        }
        
        // 获取属性类型
        NSString *propertyType=nil;
        unsigned int attrCount;
        objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
        for (unsigned int i = 0; i < attrCount; i++) {
            switch (attrs[i].name[0]) {
                case 'T': { // Type encoding
                    if (attrs[i].value) {
                        propertyType = [NSString stringWithUTF8String:attrs[i].value];
                        // 去除转义字符：@\"NSString\" -> @"NSString"
                        propertyType = [propertyType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                        // 去除 @ 符号
                        propertyType = [propertyType stringByReplacingOccurrencesOfString:@"@" withString:@""];
//                        NSLog(@"type=%@,key=%@",propertyType,propertyNameStr);
                    }
                } break;
                default: break;
            }
        }
        
        if (propertyType && ([propertyType isEqualToString:@"NSArray"] || [propertyType isEqualToString:@"NSMutableArray"] )) {
            
            //判断字典对应字段非数组,则将字典内容转换为数组
            if ( value && !([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSMutableArray class]]) )
            {
                NSMutableArray *array = [NSMutableArray arrayWithObject:value];
                
                [dictionary setValue:array forKey:propertyNameStr];
                value = array;
            }
        }
        
        // 对特殊属性进行处理
        // 判断当前类是否实现了协议方法，获取协议方法中规定的特殊属性的处理方式
        NSDictionary *perpertyTypeDic;
        if([self respondsToSelector:@selector(modelContainerPropertyGenericClass)]){
            perpertyTypeDic = [self performSelector:@selector(modelContainerPropertyGenericClass) withObject:nil];
        }

        // 处理：模型嵌套模型的情况
        if ([value isKindOfClass:[NSDictionary class]] && ![propertyType hasPrefix:@"NS"]) {
            Class modelClass = NSClassFromString(propertyType);
            if (modelClass != nil) {
                // 将被嵌套字典数据也进行检查
                [modelClass PropertiesWithDictionary:value];
            }
        }
        else if ([value isKindOfClass:[NSDictionary class]] && perpertyTypeDic)
        {
            //可能有异常
            Class itemModelClass = perpertyTypeDic[propertyNameStr];
            if (itemModelClass) {
                
                for (NSString* key  in value) {
                    
                    id obj = value[key];
                    if ([obj isKindOfClass:[NSDictionary class]]) {
                        
                        if (![obj isKindOfClass:[NSMutableDictionary class]]) {
                            obj = [NSMutableDictionary dictionaryWithDictionary:obj];
                            value[key]=obj;
                        }
                        
                        [itemModelClass PropertiesWithDictionary:obj];
                    }
                    else if ([obj isKindOfClass:[NSArray class]])
                    {
                        if (![obj isKindOfClass:[NSMutableArray class]]) {
                            
                            obj = [NSMutableArray arrayWithArray:obj];
                            value[key]=obj;
                        }
                        
                        NSDictionary *tmpPerpertyTypeDic = nil;
                        if([itemModelClass respondsToSelector:@selector(modelContainerPropertyGenericClass)]){
                            tmpPerpertyTypeDic = [itemModelClass performSelector:@selector(modelContainerPropertyGenericClass) withObject:nil];
                        }
                        
                        if (tmpPerpertyTypeDic) {
                            
                            Class cls = tmpPerpertyTypeDic[key];
                            if (cls) {
                                [self propertyWithArray:obj cls:cls];
                            }
                        }
                        
                    }
                }
            }
            
        }

        // 处理：模型嵌套模型数组的情况
        // 判断当前 value 是一个数组，而且存在协议方法返回了 perpertyTypeDic
        if ([value isKindOfClass:[NSArray class]] && perpertyTypeDic) {
            Class itemModelClass = perpertyTypeDic[propertyNameStr];
            NSMutableArray *array = (NSMutableArray*)value;
            for (int i = 0; i < array.count; i++) {
                
                id obj = array[i];
                
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    NSMutableDictionary *tmpDic = nil;
                    if ([obj isKindOfClass:[NSMutableDictionary class]]) {
                        tmpDic = (NSMutableDictionary*)obj;
                    }
                    else
                    {
                        tmpDic = [NSMutableDictionary dictionaryWithDictionary:obj];
                        array[i] = tmpDic;
                    }
                    [itemModelClass PropertiesWithDictionary:tmpDic];
                }
                else if([obj isKindOfClass:[NSString class]])
                {
                    NSLog(@"");
                    unsigned int count;

                    // 获取当前对象的属性列表
                    objc_property_t *propertyList = class_copyPropertyList(itemModelClass, &count);

                    // 遍历 propertyList 中所有属性，以其属性名为 key，在字典中查找 value
                    BOOL tagExist = NO;
                    for (unsigned int i = 0; i < count; i++) {
                        // 获取属性
                        objc_property_t property = propertyList[i];
                        const char *propertyName = property_getName(property);
                        
                        NSString *propertyNameStr = [NSString stringWithUTF8String:propertyName];

                        if ([propertyNameStr isEqualToString:kXMLReaderTextNodeKey]) {
                            tagExist = YES;
                            break;
                        }
                    }
                    free(propertyList);

                    if (tagExist) {
                        
                        NSDictionary *dic = @{kXMLReaderTextNodeKey:obj};
                        array[i]= [NSMutableDictionary dictionaryWithDictionary:dic] ;
                    }
                }
            }
        }
    }
    free(propertyList);
}

+ (void)propertyWithArray:(NSMutableArray*)array cls:(Class)cls
{
    for ( int i = 0; i < array.count;i++ ) {
        id obj = array[i];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            
            if (![obj isKindOfClass:[NSMutableDictionary class]]) {
                obj = [NSMutableDictionary dictionaryWithDictionary:obj];
                array[i]=obj;
            }
            [cls PropertiesWithDictionary:obj];
        }
        else if([obj isKindOfClass:[NSString class]])
        {
            //可能定义是model，包含属性参数，实际xml给的参数没有属性内容或部分没有属性内容，这里自动判断，转换为model
            
            unsigned int count;

            // 获取当前对象的属性列表
            objc_property_t *propertyList = class_copyPropertyList(cls, &count);

            // 遍历 propertyList 中所有属性，以其属性名为 key，在字典中查找 value
            BOOL tagExist = NO;
            for (unsigned int i = 0; i < count; i++) {
                // 获取属性
                objc_property_t property = propertyList[i];
                const char *propertyName = property_getName(property);
                
                NSString *propertyNameStr = [NSString stringWithUTF8String:propertyName];

                if ([propertyNameStr isEqualToString:kXMLReaderTextNodeKey]) {
                    tagExist = YES;
                    break;
                }
            }
            free(propertyList);

            if (tagExist) {
                
                NSDictionary *dic = @{kXMLReaderTextNodeKey:obj};
                array[i]= [NSMutableDictionary dictionaryWithDictionary:dic] ;
            }
                
        }
    }
}

#pragma mark-
#pragma mark- model -> xmldata
#pragma mark-

- (NSData*)jsonModelToXMLData:(BOOL)header {
  
    id jsonObject =  [self yy_modelToJSONObject];
    if ([jsonObject isKindOfClass:[NSArray class]] || [jsonObject isKindOfClass:[NSDictionary class]])
    { 
        NSData *data = [XMLWriter XMLDataFromDictionary:jsonObject withHeader:header];
        return data;
    }

    return nil;
}

@end
