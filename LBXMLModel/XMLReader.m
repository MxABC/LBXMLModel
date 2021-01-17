//
//  XMLReader.m
//
//  Created by Troy Brant on 9/18/10.
//  Updated by Antoine Marcadet on 9/23/11.
//  Updated by Divan Visagie on 2012-08-26
//

#import "XMLReader.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "XMLReader requires ARC support."
#endif

static NSString *const kXMLReaderTextNodeKey		= @"tag_content_text";
NSString *const kXMLReaderAttributePrefix	= @"@";

@interface XMLReader ()

@property (nonatomic, strong) NSMutableArray *dictionaryStack;
@property (nonatomic, strong) NSMutableString *textInProgress;
@property (nonatomic, strong) NSError *errorPointer;

@end


@implementation XMLReader

#pragma mark - Public methods

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)error
{
    XMLReader *reader = [[XMLReader alloc] initWithError:error];
    NSDictionary *rootDictionary = [reader objectWithData:data options:0];
    return rootDictionary;
}

+ (NSMutableDictionary*)deleteTagText:(NSMutableDictionary*)dic
{
    NSArray * allkeys = [dic allKeys];

    for (int i = 0; i < allkeys.count; i++)
    {
        NSString * key = [allkeys objectAtIndex:i];
        
        if ([key isEqualToString:kXMLReaderTextNodeKey]) {

            NSString* text = dic[kXMLReaderTextNodeKey];

            if (allkeys.count >1 && text.length <= 1 ) {

                [dic removeObjectForKey:kXMLReaderTextNodeKey];
            }
            continue;
        }

        id obj  = [dic objectForKey:key];
        if ([obj isKindOfClass:[NSMutableDictionary class]]) {

            NSMutableDictionary *tmp = (NSMutableDictionary*)obj;
            NSArray* allTmpKeys = tmp.allKeys;
            if (allTmpKeys.count == 1) {
                
                NSString* text = tmp[kXMLReaderTextNodeKey];
                if ( text ) {

                    if (text.length >0) {
                        [dic setValue:tmp[kXMLReaderTextNodeKey] forKey:key];
                    }
                }
            }
            else
            {
                NSString* text = tmp[kXMLReaderTextNodeKey];
                if (text || text.length <= 0) {
                    [tmp removeObjectForKey:kXMLReaderTextNodeKey];
                }
                
                [self deleteTagText:tmp];
            }
        }
        else if([obj isKindOfClass:[NSMutableArray class]])
        {
            NSMutableArray* array = (NSMutableArray*)obj;
            
            for (int i = 0; i < array.count; i++) {
                
                id obj = array[i];
           
             
                if ( [obj isKindOfClass:[NSMutableDictionary class]] ) {
                    
                    
                    NSMutableDictionary *oneDic = (NSMutableDictionary*)obj;
                    if ([oneDic allKeys].count == 1 && [[oneDic allKeys][0] isEqualToString:kXMLReaderTextNodeKey] ) {
                        
                        //如果只有一个 tag内容如何处理？
                        [array replaceObjectAtIndex:i withObject:oneDic[kXMLReaderTextNodeKey]];
                    }
                    else
                    {
                        [self deleteTagText:obj];
                    }
                }
                else if ([obj isKindOfClass:[NSMutableArray class]])
                {
                    NSLog(@"");

                }
            }
        }
        
    }
    return dic;
}

+ (NSData *)jsonDataWithXMLData:(NSData *)data error:(NSError **)error
{
    XMLReader *reader = [[XMLReader alloc] initWithError:error];
    NSDictionary *rootDictionary = [reader objectWithData:data options:0];

    if (!rootDictionary) {
        return nil;
    }
    
    NSMutableDictionary * muDic = [[NSMutableDictionary alloc] initWithDictionary:rootDictionary];

    [self deleteTagText:muDic];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:muDic
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:error];
    
    return jsonData;
}

+ (NSData *)jsonDataWithXMLDictionary:(NSDictionary *)dictionary error:(NSError **)error
{
    
    NSMutableDictionary * muDic = [[NSMutableDictionary alloc] initWithDictionary:dictionary];

    [self deleteTagText:muDic];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:muDic
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:error];
    
    return jsonData;
}


+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)error
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [XMLReader dictionaryForXMLData:data error:error];
}

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data options:(XMLReaderOptions)options error:(NSError **)error
{
    XMLReader *reader = [[XMLReader alloc] initWithError:error];
    NSDictionary *rootDictionary = [reader objectWithData:data options:options];
    return rootDictionary;
}

+ (NSDictionary *)dictionaryForXMLString:(NSString *)string options:(XMLReaderOptions)options error:(NSError **)error
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [XMLReader dictionaryForXMLData:data options:options error:error];
}


#pragma mark - Parsing

- (id)initWithError:(NSError **)error
{
	self = [super init];
    if (self)
    {
        if (error) {
            self.errorPointer = *error;

        }
    }
    return self;
}

- (NSDictionary *)objectWithData:(NSData *)data options:(XMLReaderOptions)options
{
    // Clear out any old data
    self.dictionaryStack = [[NSMutableArray alloc] init];
    self.textInProgress = [[NSMutableString alloc] init];
    
    // Initialize the stack with a fresh dictionary
    [self.dictionaryStack addObject:[NSMutableDictionary dictionary]];
    
    // Parse the XML
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    
    [parser setShouldProcessNamespaces:(options & XMLReaderOptionsProcessNamespaces)];
    [parser setShouldReportNamespacePrefixes:(options & XMLReaderOptionsReportNamespacePrefixes)];
    [parser setShouldResolveExternalEntities:(options & XMLReaderOptionsResolveExternalEntities)];
    
    parser.delegate = self;
    BOOL success = [parser parse];
	
    // Return the stack's root dictionary on success
    if (success)
    {
        NSDictionary *resultDict = [self.dictionaryStack objectAtIndex:0];
        return resultDict;
    }
    
    return nil;
}

- (NSDictionary*)parser:(NSDictionary*)dic
{
    //https://stackoverflow.com/questions/15498989/xml-into-json-conversion-in-ios/15499189
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    return nil;
}


#pragma mark -  NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{   
    // Get the dictionary for the current level in the stack
    NSMutableDictionary *parentDict = [self.dictionaryStack lastObject];

    // Create the child dictionary for the new element, and initilaize it with the attributes
    NSMutableDictionary *childDict = [NSMutableDictionary dictionary];
    [childDict addEntriesFromDictionary:attributeDict];
    
    // If there's already an item for this key, it means we need to create an array
    id existingValue = [parentDict objectForKey:elementName];
    if (existingValue)
    {
        NSMutableArray *array = nil;
        if ([existingValue isKindOfClass:[NSMutableArray class]])
        {
            // The array exists, so use it
            array = (NSMutableArray *) existingValue;
        }
        else
        {
            // Create an array if it doesn't exist
            array = [NSMutableArray array];
            [array addObject:existingValue];

            // Replace the child dictionary with an array of children dictionaries
            [parentDict setObject:array forKey:elementName];
        }
        
        // Add the new child dictionary to the array
        [array addObject:childDict];
    }
    else
    {
        // No existing value, so update the dictionary
        [parentDict setObject:childDict forKey:elementName];
    }
    
    // Update the stack
    [self.dictionaryStack addObject:childDict];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // Update the parent dict with text info
    NSMutableDictionary *dictInProgress = [self.dictionaryStack lastObject];
    
    // Set the text property
    if ([self.textInProgress length] > 0)
    {
        // trim after concatenating
        NSString *trimmedString = [self.textInProgress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [dictInProgress setObject:[trimmedString mutableCopy] forKey:kXMLReaderTextNodeKey];

        // Reset the text
        self.textInProgress = [[NSMutableString alloc] init];
    }
    
    // Pop the current dict
    [self.dictionaryStack removeLastObject];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    // Build the text value
    [self.textInProgress appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    // Set the error pointer to the parser's error object
    self.errorPointer = parseError;
}

@end
