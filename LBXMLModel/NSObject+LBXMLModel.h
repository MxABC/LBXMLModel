//
//  NSObject+XMLModel.h
//  XMLModel <https://github.com/ibireme/YYModel>
//
//  Created by ibireme on 15/5/10.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface NSObject (LBXMLModel)




/// xml -> jsonmodel
/// @param xml xml数据，类型 NSString,NSData,NSDictionary
+ (instancetype)jsonModelWithXML:(id)xml;


/// model -> xmldata
/// @param header  是否写 xml头： <?xml version="1.0" encoding="UTF-8" ?>
- (NSData*)jsonModelToXMLData:(BOOL)header;


/**
 Creates and returns a new instance of the receiver from a json.
 This method is thread-safe.
 
 @param json  A json object in `NSDictionary`, `NSString` or `NSData`.
 
 @return A new instance created from the json, or nil if an error occurs.
 */
+ (nullable instancetype)xml_modelWithJSON:(id)json;

/**
 Creates and returns a new instance of the receiver from a key-value dictionary.
 This method is thread-safe.
 
 @param dictionary  A key-value dictionary mapped to the instance's properties.
 Any invalid key-value pair in dictionary will be ignored.
 
 @return A new instance created from the dictionary, or nil if an error occurs.
 
 @discussion The key in `dictionary` will mapped to the reciever's property name,
 and the value will set to the property. If the value's type does not match the
 property, this method will try to convert the value based on these rules:
 
     `NSString` or `NSNumber` -> c number, such as BOOL, int, long, float, NSUInteger...
     `NSString` -> NSDate, parsed with format "yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd HH:mm:ss" or "yyyy-MM-dd".
     `NSString` -> NSURL.
     `NSValue` -> struct or union, such as CGRect, CGSize, ...
     `NSString` -> SEL, Class.
 */
+ (nullable instancetype)xml_modelWithDictionary:(NSDictionary *)dictionary;

/**
 Set the receiver's properties with a json object.
 
 @discussion Any invalid data in json will be ignored.
 
 @param json  A json object of `NSDictionary`, `NSString` or `NSData`, mapped to the
 receiver's properties.
 
 @return Whether succeed.
 */
- (BOOL)xml_modelSetWithJSON:(id)json;

/**
 Set the receiver's properties with a key-value dictionary.
 
 @param dic  A key-value dictionary mapped to the receiver's properties.
 Any invalid key-value pair in dictionary will be ignored.
 
 @discussion The key in `dictionary` will mapped to the reciever's property name,
 and the value will set to the property. If the value's type doesn't match the
 property, this method will try to convert the value based on these rules:
 
     `NSString`, `NSNumber` -> c number, such as BOOL, int, long, float, NSUInteger...
     `NSString` -> NSDate, parsed with format "yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd HH:mm:ss" or "yyyy-MM-dd".
     `NSString` -> NSURL.
     `NSValue` -> struct or union, such as CGRect, CGSize, ...
     `NSString` -> SEL, Class.
 
 @return Whether succeed.
 */
- (BOOL)xml_modelSetWithDictionary:(NSDictionary *)dic;

/**
 Generate a json object from the receiver's properties.
 
 @return A json object in `NSDictionary` or `NSArray`, or nil if an error occurs.
 See [NSJSONSerialization isValidJSONObject] for more information.
 
 @discussion Any of the invalid property is ignored.
 If the reciver is `NSArray`, `NSDictionary` or `NSSet`, it just convert
 the inner object to json object.
 */
- (nullable id)xml_modelToJSONObject;

/**
 Generate a json string's data from the receiver's properties.
 
 @return A json string's data, or nil if an error occurs.
 
 @discussion Any of the invalid property is ignored.
 If the reciver is `NSArray`, `NSDictionary` or `NSSet`, it will also convert the 
 inner object to json string.
 */
- (nullable NSData *)xml_modelToJSONData;

/**
 Generate a json string from the receiver's properties.
 
 @return A json string, or nil if an error occurs.
 
 @discussion Any of the invalid property is ignored.
 If the reciver is `NSArray`, `NSDictionary` or `NSSet`, it will also convert the 
 inner object to json string.
 */
- (nullable NSString *)xml_modelToJSONString;

/**
 Copy a instance with the receiver's properties.
 
 @return A copied instance, or nil if an error occurs.
 */
- (nullable id)xml_modelCopy;

/**
 Encode the receiver's properties to a coder.
 
 @param aCoder  An archiver object.
 */
- (void)xml_modelEncodeWithCoder:(NSCoder *)aCoder;

/**
 Decode the receiver's properties from a decoder.
 
 @param aDecoder  An archiver object.
 
 @return self
 */
- (id)xml_modelInitWithCoder:(NSCoder *)aDecoder;

/**
 Get a hash code with the receiver's properties.
 
 @return Hash code.
 */
- (NSUInteger)xml_modelHash;

/**
 Compares the receiver with another object for equality, based on properties.
 
 @param model  Another object.
 
 @return `YES` if the reciever is equal to the object, otherwise `NO`.
 */
- (BOOL)xml_modelIsEqual:(id)model;

/**
 Description method for debugging purposes based on properties.
 
 @return A string that describes the contents of the receiver.
 */
- (NSString *)xml_modelDescription;

@end



/**
 Provide some data-model method for NSArray.
 */
@interface NSArray (LBXMLModel)

/**
 Creates and returns an array from a json-array.
 This method is thread-safe.
 
 @param cls  The instance's class in array.
 @param json  A json array of `NSArray`, `NSString` or `NSData`.
              Example: [{"name","Mary"},{name:"Joe"}]
 
 @return A array, or nil if an error occurs.
 */
+ (nullable NSArray *)xml_modelArrayWithClass:(Class)cls json:(id)json;

@end



/**
 Provide some data-model method for NSDictionary.
 */
@interface NSDictionary (LBXMLModel)

/**
 Creates and returns a dictionary from a json.
 This method is thread-safe.
 
 @param cls  The value instance's class in dictionary.
 @param json  A json dictionary of `NSDictionary`, `NSString` or `NSData`.
              Example: {"user1":{"name","Mary"}, "user2": {name:"Joe"}}
 
 @return A dictionary, or nil if an error occurs.
 */
+ (nullable NSDictionary *)xml_modelDictionaryWithClass:(Class)cls json:(id)json;
@end



/**
 If the default model transform does not fit to your model class, implement one or
 more method in this protocol to change the default key-value transform process.
 There's no need to add '<XMLModel>' to your class header.
 */
@protocol XMLModel <NSObject>
@optional


+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper;


+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass;


+ (nullable NSArray*)modelContainerAttributePropertys;


+ (nullable Class)modelCustomClassForDictionary:(NSDictionary *)dictionary;

/**
 All the properties in blacklist will be ignored in model transform process.
 Returns nil to ignore this feature.
 
 @return An array of property's name.
 */
+ (nullable NSArray<NSString *> *)modelPropertyBlacklist;

/**
 If a property is not in the whitelist, it will be ignored in model transform process.
 Returns nil to ignore this feature.
 
 @return An array of property's name.
 */
+ (nullable NSArray<NSString *> *)modelPropertyWhitelist;

/**
 This method's behavior is similar to `- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic;`, 
 but be called before the model transform.
 
 @discussion If the model implements this method, it will be called before
 `+modelWithJSON:`, `+modelWithDictionary:`, `-modelSetWithJSON:` and `-modelSetWithDictionary:`.
 If this method returns nil, the transform process will ignore this model.
 
 @param dic  The json/kv dictionary.
 
 @return Returns the modified dictionary, or nil to ignore this model.
 */
- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic;

/**
 If the default json-to-model transform does not fit to your model object, implement
 this method to do additional process. You can also use this method to validate the 
 model's properties.
 
 @discussion If the model implements this method, it will be called at the end of
 `+modelWithJSON:`, `+modelWithDictionary:`, `-modelSetWithJSON:` and `-modelSetWithDictionary:`.
 If this method returns NO, the transform process will ignore this model.
 
 @param dic  The json/kv dictionary.
 
 @return Returns YES if the model is valid, or NO to ignore this model.
 */
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic;

/**
 If the default model-to-json transform does not fit to your model class, implement
 this method to do additional process. You can also use this method to validate the
 json dictionary.
 
 @discussion If the model implements this method, it will be called at the end of
 `-modelToJSONObject` and `-modelToJSONString`.
 If this method returns NO, the transform process will ignore this json dictionary.
 
 @param dic  The json dictionary.
 
 @return Returns YES if the model is valid, or NO to ignore this model.
 */
- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
