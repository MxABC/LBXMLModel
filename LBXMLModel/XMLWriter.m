//
//  XMLWriter.m
//
#import "XMLWriter.h"
#define PREFIX_STRING_FOR_ELEMENT @"@" //From XMLReader

static NSString *const kXMLReaderTextNodeKey        = @"tag_content_text";


@implementation XMLWriter

-(void)serialize:(id)root
{    
    if([root isKindOfClass:[NSArray class]])
    {  
        for(id objects in root)
        {
            if ([objects isKindOfClass:[NSDictionary class]]) {
                
                [self serialize:objects];
                continue;
            }
            else if ([objects isKindOfClass:[NSArray class]]) {
                
                [self serialize:objects];
                continue;
            }
        }
    }
    else if ([root isKindOfClass:[NSDictionary class]])
    {
        for (NSString* key in root)
        {
            //text默认是标签的内容，不需要额外添加text标签
            if ([key isEqualToString:kXMLReaderTextNodeKey]) {
                
                [self serialize:[root objectForKey:key]];
                continue;
            }
            if(!isRoot)
            {
                [treeNodes addObject:key];
                
                id subObj = [root objectForKey:key];
                NSArray* xmlAttributes = nil;
                if ([subObj isKindOfClass:[NSDictionary class]]) {
                    //判断当前字段是否有标签属性
                    xmlAttributes = subObj[@"xml_attribute_set"];
                }
                
                if (xmlAttributes && xmlAttributes.count > 0) {
                    
                    NSString *tag = [NSString stringWithFormat:@"<%@",key];
                    
                    NSMutableDictionary *mudic = (NSMutableDictionary*)subObj;
                    for (int i = 0; i < xmlAttributes.count; i++) {
                        
                        NSString *attri = xmlAttributes[i];
                        NSString *val = mudic[attri];
                        
                        //属性有值才写
                        if (val) {
                            tag = [NSString stringWithFormat:@"%@ %@=\"%@\"",tag,xmlAttributes[i],val];
                        }
                        
                    }
                    tag = [NSString stringWithFormat:@"%@>",tag];
                    
                    //带属性标签
                    [xml appendData:[tag dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    for (int i = 0; i < xmlAttributes.count; i++) {
                        
                        NSString *attri = xmlAttributes[i];
                        [mudic removeObjectForKey:attri];
                    }
                    
                    subObj = mudic;
                    [mudic removeObjectForKey:@"xml_attribute_set"];
                }
                else
                {
                    if ([subObj isKindOfClass:[NSArray class]]) {
                        
                        NSArray* array = (NSArray*)subObj;
                        for (int i = 0; i < array.count; i++) {
                            NSDictionary *dic = array[i];
//                            NSLog(@"class:%@",dic);
                            dic = @{key:dic};
                            
                            [self serialize:dic];
                        }
                        continue;
                    }
                    else
                    {
                        //                    不带属性标签
                        [xml appendData:
                         [[NSString stringWithFormat:@"<%@>",key]
                          dataUsingEncoding:NSUTF8StringEncoding]];
                    }
                }
                
                [self serialize:[root objectForKey:key]];
                //xml =[xml stringByAppendingFormat:@"</%@>",key];
                
                
                [xml appendData:
                 [[NSString stringWithFormat:@"</%@>",key]
                  dataUsingEncoding:NSUTF8StringEncoding]];
              
                [treeNodes removeLastObject];
                
            } else {
                
//                NSLog(@"key:%@",key);
                
                id subObj = [root objectForKey:key];
                NSArray* xmlAttributes = nil;
                if ([subObj isKindOfClass:[NSDictionary class]]) {
                    //判断当前字段是否有标签属性
                    xmlAttributes = subObj[@"xml_attribute_set"];
                }
                
                if (xmlAttributes && xmlAttributes.count > 0) {
                    
                    NSString *tag = [NSString stringWithFormat:@"<%@",key];
                    
                    NSMutableDictionary *mudic = [NSMutableDictionary dictionaryWithDictionary:subObj];
                    for (int i = 0; i < xmlAttributes.count; i++) {
                        
                        NSString *attri = xmlAttributes[i];
                        NSString *val = mudic[attri];
                        if (val) {
                            tag = [NSString stringWithFormat:@"%@ %@=\"%@\"",tag,xmlAttributes[i],val];

                        }
                    }
                    tag = [NSString stringWithFormat:@"%@>",tag];
                    
                    //带属性标签
                    [xml appendData:[tag dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    for (int i = 0; i < xmlAttributes.count; i++) {
                        
                        NSString *attri = xmlAttributes[i];
                        [mudic removeObjectForKey:attri];
                    }
                    
                    [mudic removeObjectForKey:@"xml_attribute_set"];
                    subObj = mudic;
                }
                else
                {
                    [xml appendData:
                     [[NSString stringWithFormat:@"<%@>",key]
                      dataUsingEncoding:NSUTF8StringEncoding]];
                }
                
                isRoot = FALSE;
                [self serialize:subObj];
                if (!hasRoot) {
                    [xml appendData:
                     [[NSString stringWithFormat:@"</%@>",key]
                      dataUsingEncoding:NSUTF8StringEncoding]];
                }
            }
        }
    }
    else if ([root isKindOfClass:[NSString class]] || [root isKindOfClass:[NSNumber class]] || [root isKindOfClass:[NSURL class]])
    {
        //            if ([root hasPrefix:"PREFIX_STRING_FOR_ELEMENT"])
        //            is element
        //            else
        //xml = [xml stringByAppendingFormat:@"%@",root];
        [xml appendData:
         [[NSString stringWithFormat:@"%@",root]
          dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        // Initialization code here.
        //xml = @"";
        xml = [[NSMutableData alloc] init];
        if (withHeader)
            //xml = @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
            [xml appendData:
             [@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
              dataUsingEncoding:NSUTF8StringEncoding]];
        nodes = [[NSMutableArray alloc] init];
        treeNodes = [[NSMutableArray alloc] init];
        isRoot = YES;
        hasRoot = YES;
        if ([dictionary allKeys].count > 1) {
            
            //没有跟目录，添加一个方便写，最终获取时，再删除根目录
            hasRoot = NO;
            passDict = nil;
        }
        else
        passDict = [[dictionary allKeys] lastObject];

        
        //xml = [xml stringByAppendingFormat:@"<%@>\n",passDict];
//        [xml appendData:
//         [[NSString stringWithFormat:@"<%@>\n",passDict]
//          dataUsingEncoding:NSUTF8StringEncoding]];
        [self serialize:dictionary];
    }
    
    return self;
}
- (id)initWithDictionary:(NSDictionary *)dictionary withHeader:(BOOL)header {
    withHeader = header;
    self = [self initWithDictionary:dictionary];
    return self;
}

-(void)dealloc
{
    //    [xml release],nodes =nil;
    /*[nodes release],*/ nodes = nil ;
    /*[treeNodes release],*/ treeNodes = nil;
    //[super dealloc];
}

-(NSData *)getXML
{
    //xml = [xml stringByReplacingOccurrencesOfString:@"</(null)><(null)>" withString:@"\n"]; //Can not do it with NSData
    //xml = [xml stringByAppendingFormat:@"\n</%@>",passDict];
    
    if (passDict) {
        [xml appendData:
         [[NSString stringWithFormat:@"\n</%@>",passDict]
          dataUsingEncoding:NSUTF8StringEncoding]];
    }
  
    return xml;
}

+(NSData *)XMLDataFromDictionary:(NSDictionary *)dictionary
{
    if (![[dictionary allKeys] count])
        return NULL;
    XMLWriter* fromDictionary = [[XMLWriter alloc]initWithDictionary:dictionary];
    return [fromDictionary getXML];
}

+ (NSData *) XMLDataFromDictionary:(NSDictionary *)dictionary withHeader:(BOOL)header {
    if (![[dictionary allKeys] count])
        return NULL;
    XMLWriter* fromDictionary = [[XMLWriter alloc]initWithDictionary:dictionary withHeader:header];
    return [fromDictionary getXML];
}

+(NSString *)XMLStringFromDictionary:(NSDictionary *)dictionary
{
    return [[NSString alloc]
            initWithData:[XMLWriter XMLDataFromDictionary:dictionary]
            encoding:NSUTF8StringEncoding];
}

+(NSString *)XMLStringFromDictionary:(NSDictionary *)dictionary withHeader:(BOOL)header
{
    return [[NSString alloc]
            initWithData:[XMLWriter XMLDataFromDictionary:dictionary withHeader:header]
            encoding:NSUTF8StringEncoding];
}

+(BOOL)XMLDataFromDictionary:(NSDictionary *)dictionary toStringPath:(NSString *) path  Error:(NSError **)error
{
    
    XMLWriter* fromDictionary = [[XMLWriter alloc]initWithDictionary:dictionary];
    [[fromDictionary getXML] writeToFile:path atomically:YES];
    if (error)
        return FALSE;
    else
        return TRUE;
    
}
@end
