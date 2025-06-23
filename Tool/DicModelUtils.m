#import "DicModelUtils.h"
#import <objc/runtime.h>

@implementation DicModelUtils

+ (id)modelOfClass:(Class)modelClass fromDictionary:(NSDictionary *)dictionary {
    if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    NSObject *model = [[modelClass alloc] init];
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];

    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(modelClass, &propertyCount);

    for (unsigned int i = 0; i < propertyCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];

        id value = mutableDictionary[propertyName];

        if (value == [NSNull null] || value == nil) {
            // 如果是 NSNull 或 nil，跳过或设为基本类型的默认值
            const char *typeEncoding = property_getAttributes(property);
            NSString *typeStr = [NSString stringWithUTF8String:typeEncoding];

            if ([typeStr containsString:@"d"]) { // double
                [model setValue:@(0.0) forKey:propertyName];
            } else if ([typeStr containsString:@"i"]) { // int
                [model setValue:@0 forKey:propertyName];
            } else if ([typeStr containsString:@"f"]) { // float
                [model setValue:@(0.0f) forKey:propertyName];
            } else if ([typeStr containsString:@"B"]) { // BOOL
                [model setValue:@NO forKey:propertyName];
            } else {
                [model setValue:nil forKey:propertyName];
            }

            [mutableDictionary removeObjectForKey:propertyName];
            continue;
        }

        // 获取属性类型
        const char *typeEncoding = property_getAttributes(property);
        NSString *typeStr = [NSString stringWithUTF8String:typeEncoding];
        NSRange range = [typeStr rangeOfString:@"T@\""];
        if (range.location != NSNotFound) {
            range = NSMakeRange(range.location + 3, typeStr.length - range.location - 4);
            NSString *className = [typeStr substringWithRange:range];
            Class propertyClass = NSClassFromString(className);

            if (propertyClass && [value isKindOfClass:[NSDictionary class]] && ![propertyClass isEqual:[NSString class]]) {
                value = [self modelOfClass:propertyClass fromDictionary:value];
            } else if ([value isKindOfClass:[NSArray class]]) {
                NSMutableArray *array = [NSMutableArray array];
                for (id item in value) {
                    if ([item isKindOfClass:[NSDictionary class]] && propertyClass && ![propertyClass isEqual:[NSString class]]) {
                        [array addObject:[self modelOfClass:propertyClass fromDictionary:item]];
                    } else {
                        [array addObject:item];
                    }
                }
                value = array;
            }
        }

        [model setValue:value forKey:propertyName];
        [mutableDictionary removeObjectForKey:propertyName];
    }

    free(properties);
    return model;
}

+ (NSDictionary *)dictionaryFromModel:(NSObject *)model {
    if (!model || ![model isKindOfClass:[NSObject class]]) {
        return nil;
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList([model class], &propertyCount);

    for (unsigned int i = 0; i < propertyCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        id value = [model valueForKey:propertyName];

        // 排除值为空（nil 或 NSNull）的字段
        if (value == nil || value == [NSNull null]) {
            continue; // 跳过空值字段
        }

        if ([value isKindOfClass:[NSObject class]] && ![value isKindOfClass:[NSString class]] && ![value isKindOfClass:[NSNumber class]] && ![value isKindOfClass:[NSArray class]]) {
            // 对于复杂对象（如嵌套模型），递归转换
            value = [self dictionaryFromModel:value];
        } else if ([value isKindOfClass:[NSArray class]]) {
            // 处理数组，特别是包含复杂对象的情况
            NSMutableArray *array = [NSMutableArray array];
            for (id item in value) {
                if ([item isKindOfClass:[NSObject class]] && ![item isKindOfClass:[NSString class]] && ![item isKindOfClass:[NSNumber class]]) {
                    [array addObject:[self dictionaryFromModel:item]];
                } else {
                    [array addObject:item];
                }
            }
            value = array;
        }

        // 只有非空值才会被加入字典
        dictionary[propertyName] = value;
    }

    free(properties);
    return dictionary;
}

@end
