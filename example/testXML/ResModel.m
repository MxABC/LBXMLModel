//
//  ResModel.m
//  testXML
//
//  Created by lbxia on 2021/1/15.
//

#import "ResModel.h"

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


