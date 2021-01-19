# LBXMLModel
xml 与model相互转换，达到类似YYModel使用效果，
基于xml库[XMLReader](https://github.com/amarcadet/XMLReader)和[XMLWriter](https://github.com/ahmyi/XMLWriter)修改,最后与[YYModel](https://github.com/ibireme/YYModel)搭配使用



## 安装
- cocoapods安装

```
pod 'LBXMLModel'
```

- 手动安装

将`LBXMLModel`文件夹copy到工程，另外需要YYModel库

## 调用

包含头文件 `NSObject+LBXMLModel.h`

xml->model

```
NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"xml"];
NSData *dataXML = [NSData dataWithContentsOfFile:path];
//xml ->model
RootModel *model = [RootModel jsonModelWithXML:dataXML];
```

model->xml

```
RootModel *rootModel = [[RootModel alloc]init];
    //TODO:   初始化model值
NSData *xmlData  = [rootModel jsonModelToXMLData:YES];
NSString* strXML = [[NSString alloc]initWithData:xmlData encoding:NSUTF8StringEncoding];
NSLog(@"%@",strXML);
```


# model定义注意事项

## 常用xml报文格式
xml数据只是标签内容，没有标签属性，那么直接按照YYModel使用注意事项即可

如类似如下xml报文，各个标签没有属性(大部分情况都是如此)，model定义只要按照YYModel要求即可

```
<?xml version="1.0" encoding="UTF-8" ?>
<root>
    <RESPONSE_CODE>200</RESPONSE_CODE>
    <RESPONSE_MSG>上传成功</RESPONSE_MSG>
    <NODE>
        <PAGEID>page1<PAGEID/>
        <FILE_NAME>FILE_NAME_123.jpg<FILE_NAME/>
    </NODE>
    <TITLE>titl1</TITLE>
    <TITLE>titl2</TITLE>
</root>
```

对应model定义

```
@interface NODEModel : NSObject
@property (nonatomic, copy) NSString *PAGEID;
@property (nonatomic, copy) NSString *FILE_NAME;
@end

@interface ResModel : NSObject
@property (nonatomic, assign) NSInteger RESPONSE_CODE;
@property (nonatomic, copy) NSString *RESPONSE_MSG;

//有可能是数组的，均写成数组形式
@property (nonatomic, strong) NSArray<NODEModel*> *NODE;
@property (nonatomic, strong) NSArray<NSString*> *TITLE;
@end

@interface RootModel : NSObject
@property (nonatomic, strong) ResModel *root;
@end
```

```
@implementation NODEModel
@end

@implementation ResModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"NODE":[NODEModel class]
            };
}
@end

@implementation RootModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"root" : [ResModel class]
            };
}
@end
```


## 如果标签包含属性

```
<?xml version="1.0" encoding="UTF-8" ?>
<root>
    <NODE>
        <SUBNODE>subnode</SUBNODE>
        <PAGE PAGEID="11-22-33-44-66" FILE_NAME="filename3.jpg"/>
        <PAGE PAGEID="11-22-33-44-77" FILE_NAME="filename.xml"></PAGE>
    </NODE>
    <RESPONSE_MSG>上传成功</RESPONSE_MSG>
    <RESPONSE_CODE>200</RESPONSE_CODE>
    <PAGE PAGEID="11-22-33-44" FILE_NAME="filename1.doc"/>
    <PAGE PAGEID="11-22-33-44-55" FILE_NAME="filename2.pdf"></PAGE>
    <TITLE>titl1</TITLE>
    <TITLE>titl2</TITLE>
    <TagARRAY>
        <TagSubARRAY subTitle="st1">subArray1</TagSubARRAY>
    </TagARRAY>
    <TagARRAY>
        <TagSubARRAY>subArray3</TagSubARRAY>
        <TagSubARRAY>subArray4</TagSubARRAY>
    </TagARRAY>
</root>


1、如果xml报文只是从服务器接收到用来解析

1)、有标签属性，且没有标签内容(大部分情况都是如此)，如上面的xml报文中的PAGE标签，那么定义Model和json报文定义model没有区别

2)、如果有标签属性且有标签内容，如上图的TagSubARRAY,包含属性 subTitle，且有内容 subArray1，那么model需要定义字段为`NSString *tag_content_text`，也可以通过YYModel提供的mapper方法，修改为名称text

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"text" : @"tag_content_text",
             };
}

2、如果jsonmodel需要打包成xml
1)、有标签属性，且没有标签内容(大部分情况都是如此)，如上面的xml报文中的PAGE标签，定义Model安装普通model定义外，需要额外增加`NSArray *xml_attribute_set`，并返回对应属性的名字数组

2)、有标签属性，且包含标签内容  如上面xml的TagSubARRAY,包含属性 subTitle，且有内容 subArray1
需要额外增加`NSArray *xml_attribute_set`，并返回对应属性的名字数组 ，可参考下面的model定义
标签内容参数名称定义为`NSString *tag_content_text`，且不可修改
```



如上面报文对应的model(用来model->xml，如果只是xml->model xml_attribute_set不需要定义)


```
//头文件
@interface PAGEModel : NSObject
@property (nonatomic, copy) NSString *PAGEID;
@property (nonatomic, copy) NSString *FILE_NAME;

//当前对象 哪些字段是xml标签的属性,如果没有属性字段则不需要改字段
//在model->xml时用来判断当前model哪些字段是标签的属性
@property (nonatomic, strong) NSArray *xml_attribute_set;
@end

@interface NODEModel : NSObject
@property (nonatomic, copy) NSString *SUBNODE;
@property (nonatomic, strong) NSArray<PAGEModel*> *PAGE;
@end

//既包含属性，还有标签内容
@interface TagSubARRAYModel : NSObject
@property (nonatomic, copy) NSString *subTitle;
@property (nonatomic, copy) NSString *tag_content_text;//标签值，名字固定tag_content_text
@property (nonatomic, strong) NSArray *xml_attribute_set;//标签属性名称

@end
@interface TagARRAYModel : NSObject
@property (nonatomic, strong) NSArray<TagSubARRAYModel*> *TagSubARRAY;
@end

@interface ResModel : NSObject
@property (nonatomic, assign) NSInteger RESPONSE_CODE;
@property (nonatomic, copy) NSString *RESPONSE_MSG;

//有可能是数组的，均写成数组形式
@property (nonatomic, strong) NSArray<PAGEModel*> *PAGE;
@property (nonatomic, strong) NSArray<NODEModel*> *NODE;
@property (nonatomic, strong) NSArray<NSString*> *TITLE;

@property (nonatomic, strong) NSArray<TagARRAYModel*> *TagARRAY;

@end

@interface RootModel : NSObject
@property (nonatomic, strong) ResModel *root;
@end
```

```
@implementation PAGEModel

- (NSArray*)xml_attribute_set
{
    return @[@"PAGEID",@"FILE_NAME"];
}
@end

@implementation NODEModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"PAGE" : [PAGEModel class]
            };
}
@end

@implementation TagSubARRAYModel
- (NSArray*)xml_attribute_set
{
    return @[@"subTitle"];
}
@end

@implementation TagARRAYModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"TagSubARRAY" : [TagSubARRAYModel class]
            };
}
@end

@implementation ResModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"PAGE" : [PAGEModel class],@"NODE":[NODEModel class],@"TagARRAY":[TagARRAYModel class]
            };
}
@end

@implementation RootModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"root" : [ResModel class]
            };
}
@end
```


