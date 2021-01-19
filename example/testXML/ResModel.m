//
//  ResModel.m
//  testXML
//
//  Created by lbxia on 2021/1/15.
//

#import "ResModel.h"

@implementation PAGEModel

+ (NSArray*)modelContainerAttributePropertys
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


+ (NSArray*)modelContainerAttributePropertys
{
    return @[@"subTitle"];
}

//标签内容 字段为tag_content_text，如果想其他名称，这里mapper
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"text" : @"tag_content_text"};
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

