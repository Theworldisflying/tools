// DicModelUtils.h

#import <Foundation/Foundation.h>

@interface DicModelUtils : NSObject

+ (id)modelOfClass:(Class)modelClass fromDictionary:(NSDictionary *)dictionary;
+ (NSDictionary *)dictionaryFromModel:(NSObject *)model;

@end
