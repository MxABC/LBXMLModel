//
//  ResModel.h
//  testXML
//
//  Created by lbxia on 2021/1/15.
//

#import <Foundation/Foundation.h>

@interface PAGEModel : NSObject
@property (nonatomic, copy) NSString *PAGEID;
@property (nonatomic, copy) NSString *FILE_NAME;
@end


@interface NODEModel : NSObject
@property (nonatomic, copy) NSString *SUBNODE;
@property (nonatomic, strong) NSArray<PAGEModel*> *PAGE;
@end


@interface TagSubARRAYModel : NSObject
@property (nonatomic, copy) NSString *subTitle;
@property (nonatomic, copy) NSString *text;//标签值


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
