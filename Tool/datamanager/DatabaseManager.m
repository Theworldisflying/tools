//
//  DatabaseManager.m
//

#import "DatabaseManager.h"

@interface DatabaseManager ()
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;
@end

@implementation DatabaseManager

+ (instancetype)sharedInstance {
    static DatabaseManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)createOrOpenDatabaseAtPath:(nullable NSString *)path {
    if (!path) {
        NSString *defaultPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
                                 stringByAppendingPathComponent:@"car_data.sqlite"];
        path = defaultPath;
    }

    self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:path];

    // 可选：开启缓存提高性能
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db setShouldCacheStatements:YES];
    }];
}

#pragma mark - 表操作

- (BOOL)createTableWithName:(NSString *)tableName
                  columnsInfo:(NSDictionary<NSString *, NSString *> *)columnsInfo
                        error:(NSError **)error {
    __block BOOL success = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        if (![db open]) {
            if (error) {
                *error = [NSError errorWithDomain:@"DatabaseError" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"数据库未打开"}];
            }
            return;
        }

        NSMutableString *sql = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS \"%@\" (", tableName];
        [columnsInfo enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
            [sql appendFormat:@"\"%@\" %@,", key, obj];
        }];

        NSRange lastCommaRange = [sql rangeOfString:@"," options:NSBackwardsSearch];
        if (lastCommaRange.location != NSNotFound) {
            [sql replaceCharactersInRange:lastCommaRange withString:@")"];
        } else {
            [sql appendString:@")"];
        }

        success = [db executeUpdate:sql];
        if (!success && error) {
            *error = [NSError errorWithDomain:@"DatabaseError" code:-2 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"创建表失败: %@", sql]}];
        }
    }];
    return success;
}

#pragma mark - 插入数据

- (NSInteger)insertIntoTable:(NSString *)tableName values:(NSDictionary<NSString *, id> *)values error:(NSError **)error {
    __block NSInteger rowsInserted = 0;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        if (!db || ![db open]) {
            if (error) {
                *error = [NSError errorWithDomain:@"DatabaseError"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: @"数据库未打开"}];
            }
            return;
        }

        if (values.count == 0) {
            if (error) {
                *error = [NSError errorWithDomain:@"DatabaseError"
                                             code:-2
                                         userInfo:@{NSLocalizedDescriptionKey: @"没有提供要插入的数据"}];
            }
            return;
        }

        // 强制排序字段名，保证字段顺序一致
        NSArray<NSString *> *sortedKeys = [[values allKeys] sortedArrayUsingSelector:@selector(compare:)];
        NSMutableArray *placeholders = [NSMutableArray arrayWithCapacity:values.count];

        for (__unused id key in sortedKeys) {
            [placeholders addObject:@"?"];
        }

        NSString *columns = [sortedKeys componentsJoinedByString:@", "];
        NSString *valuesPlaceholders = [placeholders componentsJoinedByString:@", "];

        NSString *sql = [NSString stringWithFormat:@"INSERT INTO \"%@\" (%@) VALUES (%@)",
                         tableName, columns, valuesPlaceholders];

        // 确保按照字段顺序传值
        NSMutableArray *orderedValues = [NSMutableArray arrayWithCapacity:values.count];
        for (NSString *key in sortedKeys) {
            [orderedValues addObject:values[key]];
        }

        if ([db executeUpdate:sql withArgumentsInArray:orderedValues]) {
            rowsInserted = (NSInteger)[db changes];
        } else {
            if (error) {
                *error = [NSError errorWithDomain:@"DatabaseError"
                                             code:-3
                                         userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"插入失败: %@", [db lastErrorMessage]]}];
            }
        }
    }];
    return rowsInserted;
}

#pragma mark - 删除数据

- (int)deleteFromTable:(NSString *)tableName
           whereCondition:(nullable NSString *)whereCondition
                 arguments:(nullable NSArray *)arguments
                   error:(NSError **)error {
    __block int affectedRows = 0;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        if (![db open]) {
            if (error) {
                *error = [NSError errorWithDomain:@"DatabaseError" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"数据库未打开"}];
            }
            return;
        }

        NSString *sql;
        if (whereCondition) {
            sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@", tableName, whereCondition];
        } else {
            sql = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
        }

        if ([db executeUpdate:sql withArgumentsInArray:arguments]) {
            affectedRows = (int)[db changes];
        } else {
            if (error) {
                *error = [NSError errorWithDomain:@"DatabaseError" code:-4 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"删除失败: %@", [db lastErrorMessage]]}];
            }
        }
    }];
    return affectedRows;
}

#pragma mark - 更新数据

- (int)updateTable:(NSString *)tableName
          setValues:(NSDictionary<NSString *, id> *)setValues
    whereCondition:(nullable NSString *)whereCondition
          arguments:(nullable NSArray *)arguments
              error:(NSError **)error {
    
    __block BOOL success = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        if (!db || ![db open]) {
            if (error) {
                *error = [NSError errorWithDomain:@"DatabaseError"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: @"数据库未打开"}];
            }
            return;
        }

        // 检查 setValues 是否为空
        if (setValues.count == 0) {
            if (error) {
                *error = [NSError errorWithDomain:@"DatabaseError"
                                             code:-2
                                         userInfo:@{NSLocalizedDescriptionKey: @"没有提供要更新的值"}];
            }
            return;
        }

        NSMutableArray *setClauses = [NSMutableArray array];
        NSMutableArray *finalArguments = [NSMutableArray array];

        // 添加 SET 部分的值到 finalArguments 中
        for (NSString *key in setValues.allKeys) {
            [setClauses addObject:[NSString stringWithFormat:@"%@ = ?", key]];
            [finalArguments addObject:setValues[key]];
        }

        // 如果有 WHERE 条件，则添加其参数到 finalArguments 中
        if (whereCondition && arguments) {
            [finalArguments addObjectsFromArray:arguments];
        }

        NSString *setString = [setClauses componentsJoinedByString:@", "];
        NSString *sql = [NSString stringWithFormat:@"UPDATE \"%@\" SET %@ %@", tableName, setString, whereCondition ? [NSString stringWithFormat:@"WHERE %@", whereCondition] : @""];

        success = [db executeUpdate:sql withArgumentsInArray:finalArguments];
        
        if (!success && error) {
            *error = [NSError errorWithDomain:@"DatabaseError"
                                         code:-3
                                     userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"更新失败: %@", [db lastErrorMessage]]}];
        }
    }];
    
    return success;
}

- (int)updateOrInsertTable:(NSString *)tableName
          setValues:(NSDictionary<NSString *, id> *)setValues
    whereCondition:(nullable NSString *)whereCondition
          arguments:(nullable NSArray *)arguments error:(NSError **)error{
    NSMutableDictionary * values = [[NSMutableDictionary alloc] initWithDictionary:setValues];
    if(![values containsObjectForKey:@"ymd"]){
        values[@"ymd"] = [CalendarUtils getCurrentDate];
    }
    
    __block int status = 0;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        if (!db || ![db open]) {
            if (error) {
                *error = [NSError errorWithDomain:@"DatabaseError"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: @"数据库未打开"}];
            }
            return;
        }
        
        FMResultSet *resultSet  = [self query:db table:tableName whereCondition:whereCondition arguments:arguments error:error];
        // 判断 resultSet 是否为空
        BOOL isEmpty = ![resultSet next];
        if(isEmpty){
            NSInteger rowsInserted = [self insert:db tableName:tableName values:values error:error];
            if (rowsInserted == 1) {
                status = 200;
            }else{
                status = 304;
            }
        }else{
            BOOL sucess = [self update:db table:tableName setValues:values whereCondition:whereCondition arguments:arguments error:error];
            if (sucess) {
                status = 200;
            }else{
                status = 304;
            }
        }
        
        [resultSet close]; // 关闭结果集
    }];
    
    

    
    return status;
}
-(FMResultSet *)query:(FMDatabase*)db table:(NSString *)tableName whereCondition:(nullable NSString *)whereCondition
      arguments:(nullable NSArray *)arguments error:(NSError **)error{
    // 构建 SQL 查询语句
    NSString *sql;
    if (whereCondition) {
        sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@", tableName, whereCondition];
    } else {
        sql = [NSString stringWithFormat:@"SELECT * FROM %@", tableName];
    }
   
  

    FMResultSet *resultSet = [db executeQuery:sql withArgumentsInArray:arguments];

    if (!resultSet) {
        if (error) {
            *error = [NSError errorWithDomain:@"DatabaseError"
                                         code:-6
                                     userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"查询失败: %@", [db lastErrorMessage]]}];
        }
        return nil;
    }
    
    return resultSet;
}


-(NSInteger)insert:(FMDatabase*)db tableName:(NSString*)tableName values:(NSDictionary<NSString *, id> *)setValues error:(NSError **)error{
//    __block NSError * error;
    __block NSInteger rowsInserted = 0;
    if (setValues.count == 0) {
        if (error) {
            *error = [NSError errorWithDomain:@"DatabaseError"
                                         code:-2
                                     userInfo:@{NSLocalizedDescriptionKey: @"没有提供要插入的数据"}];
        }
        return 0;
    }

    // 强制排序字段名，保证字段顺序一致
    NSArray<NSString *> *sortedKeys = [[setValues allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *placeholders = [NSMutableArray arrayWithCapacity:setValues.count];

    for (__unused id key in sortedKeys) {
        [placeholders addObject:@"?"];
    }

    NSString *columns = [sortedKeys componentsJoinedByString:@", "];
    NSString *valuesPlaceholders = [placeholders componentsJoinedByString:@", "];

    NSString *sql = [NSString stringWithFormat:@"INSERT INTO \"%@\" (%@) VALUES (%@)", tableName, columns, valuesPlaceholders];

    // 确保按照字段顺序传值
    NSMutableArray *orderedValues = [NSMutableArray arrayWithCapacity:setValues.count];
    for (NSString *key in sortedKeys) {
        [orderedValues addObject:setValues[key]];
    }

    if ([db executeUpdate:sql withArgumentsInArray:orderedValues]) {
        rowsInserted = (NSInteger)[db changes];
    } else {
        if (error) {
            *error = [NSError errorWithDomain:@"DatabaseError"
                                         code:-3
                                     userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"插入失败: %@", [db lastErrorMessage]]}];
        }
    }
    return rowsInserted;
    
}
-(BOOL)update:(FMDatabase*)db table:(NSString *)tableName setValues:(NSDictionary<NSString *, id> *)setValues
whereCondition:(nullable NSString *)whereCondition
      arguments:(nullable NSArray *)arguments error:(NSError **)error{
    __block BOOL success = NO;
    // 检查 setValues 是否为空
    if (setValues.count == 0) {
        if (error) {
            *error = [NSError errorWithDomain:@"DatabaseError"
                                         code:-2
                                     userInfo:@{NSLocalizedDescriptionKey: @"没有提供要更新的值"}];
        }
        return success;
    }

    NSMutableArray *setClauses = [NSMutableArray array];
    NSMutableArray *finalArguments = [NSMutableArray array];

    // 添加 SET 部分的值到 finalArguments 中
    for (NSString *key in setValues.allKeys) {
        [setClauses addObject:[NSString stringWithFormat:@"%@ = ?", key]];
        [finalArguments addObject:setValues[key]];
    }

    // 如果有 WHERE 条件，则添加其参数到 finalArguments 中
    if (whereCondition && arguments) {
        [finalArguments addObjectsFromArray:arguments];
    }

    NSString *setString = [setClauses componentsJoinedByString:@", "];
    NSString *sql = [NSString stringWithFormat:@"UPDATE \"%@\" SET %@ %@", tableName, setString, whereCondition ? [NSString stringWithFormat:@"WHERE %@", whereCondition] : @""];

    success = [db executeUpdate:sql withArgumentsInArray:finalArguments];
    
    if (!success && error) {
        *error = [NSError errorWithDomain:@"DatabaseError"
                                     code:-3
                                 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"更新失败: %@", [db lastErrorMessage]]}];
    }
    return success;
}
#pragma mark - 查询数据

- (nullable FMResultSet *)queryFromTable:(NSString *)tableName
                       whereCondition:(nullable NSString *)whereCondition
                             arguments:(nullable NSArray *)arguments
                                 error:(NSError **)error {
    __block FMResultSet *resultSet = nil;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        if (![db open]) {
            if (error) {
                *error = [NSError errorWithDomain:@"DatabaseError" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"数据库未打开"}];
            }
            return;
        }

        NSString *sql;
        if (whereCondition) {
            sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@", tableName, whereCondition];
        } else {
            sql = [NSString stringWithFormat:@"SELECT * FROM %@", tableName];
        }

        resultSet = [db executeQuery:sql withArgumentsInArray:arguments];
        if (!resultSet && error) {
            *error = [NSError errorWithDomain:@"DatabaseError" code:-6 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"查询失败: %@", [db lastErrorMessage]]}];
        }
    }];
    return resultSet;
}

- (void)querySql:(NSString*)sql resultBlock:(void (^)(NSArray<NSDictionary *> * arr))resultBlock error:(NSError **)error {
    __block FMResultSet *resultSet = nil;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        if (![db open]) {
            if (error) {
                *error = [NSError errorWithDomain:@"DatabaseError" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"数据库未打开"}];
            }
            return;
        }
        resultSet = [db executeQuery:sql];
        
        
        if (!resultSet && error) {
            *error = [NSError errorWithDomain:@"DatabaseError" code:-6 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"查询失败: %@", [db lastErrorMessage]]}];
        }else{
            NSArray<NSDictionary *> * dicArr = [self dictionariesFromResultSet:resultSet];
            for (NSDictionary * dic in dicArr) {
                NSLog(@"%@", dic);
            }
            resultBlock(dicArr);
        }
        
       
    }];
}

- (void)queryFromTable:(NSString *)tableName
          whereCondition:(nullable NSString *)whereCondition
                arguments:(nullable NSArray *)arguments
              resultBlock:(void (^)(NSArray<NSDictionary *> * arr))resultBlock
                    error:(NSError **)error {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        if (!db || ![db open]) {
            if (error) {
                *error = [NSError errorWithDomain:@"DatabaseError"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: @"数据库未打开"}];
            }
            return;
        }

        FMResultSet *resultSet  = [self query:db table:tableName whereCondition:whereCondition arguments:arguments error:error];
        
       
        

        // 如果传入了 resultBlock，则逐条执行回调
        if (resultBlock) {
            NSArray<NSDictionary *> * dicArr = [self dictionariesFromResultSet:resultSet];
            for (NSDictionary * dic in dicArr) {
                NSLog(@"%@", dic);
            }
            resultBlock(dicArr);
           
        } else {
            // 如果没有传入 resultBlock，默认打印所有字段
            NSLog(@"---------- 自动打印查询结果开始 ----------");
            int row = 0;
            while ([resultSet next]) {
                row++;
                NSMutableString *rowDesc = [NSMutableString stringWithFormat:@"第 %d 行数据：", row];

                // 获取当前行的所有列名和值
                for (int i = 0; i < [resultSet columnCount]; i++) {
                    NSString *columnName = [resultSet columnNameForIndex:i];
                    id value = [resultSet objectForColumnIndex:i];
                    [rowDesc appendFormat:@"%@=%@ | ", columnName, value ?: @"(null)"];
                }

                NSLog(@"%@", rowDesc);
            }
            NSLog(@"---------- 自动打印查询结果结束 ----------");
        }

        [resultSet close]; // 关闭结果集
    }];
}


#pragma mark - 事务

- (void)beginTransaction {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
    }];
}

- (void)commit {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db commit];
    }];
}

- (void)rollback {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db rollback];
    }];
}

- (void)query:(NSString *)ymd resultBlock:(void (^)(NSMutableArray<CarPerformanceData *> * arr))resultBlock{
    NSString * arguments = ymd;
    if(ymd.length == 0){
        arguments = [CalendarUtils getCurrentDate];
    }
    NSError *error;
    [[DatabaseManager sharedInstance] queryFromTable:@"cardatadb" whereCondition:@"ymd = ?" arguments:@[arguments] resultBlock:^(NSArray<NSDictionary *> * _Nonnull dicArr) {
        NSMutableArray<CarPerformanceData *> * arr = [[NSMutableArray alloc] init];
        for (NSDictionary*dic in dicArr) {
            NSLog(@"%@",dic);
            CarPerformanceData * model = [DicModelUtils modelOfClass:[CarPerformanceData class] fromDictionary:dic];
            NSLog(@"%@",model.ymd);
            [arr addObject:model];
        }
        resultBlock(arr);
    } error:&error];

}



/**
 *  将 FMResultSet 转换为字典数组
 *
 *  @param resultSet 包含数据的 FMResultSet 对象
 *  @return 包含数据的字典数组
 */
-(NSArray<NSDictionary *> *)dictionariesFromResultSet:(FMResultSet *)resultSet {
    NSMutableArray<NSDictionary *> *dictionariesArray = [NSMutableArray array];
    
    // 遍历结果集中的每一行
    while ([resultSet next]) {
        NSDictionary *rowDictionary = [resultSet resultDictionary];
        [dictionariesArray addObject:rowDictionary];
    }
    
    return [dictionariesArray copy];
}

/**
 *  将 FMResultSet 的当前行转换为字典
 *
 *  @param resultSet 包含数据的 FMResultSet 对象
 *  @return 包含当前行数据的字典
 */
-(NSDictionary *)dictionaryForRow:(FMResultSet *)resultSet {
    NSMutableDictionary *rowDictionary = [NSMutableDictionary dictionary];
    
    // 获取列的数量
    int columnCount = [resultSet columnCount];
    
    // 遍历每一列
    for (int i = 0; i < columnCount; i++) {
        NSString *columnName = [resultSet columnNameForIndex:i];
        id value = [resultSet objectForColumn:columnName];
        
        // 将列名和对应的值添加到字典中
        rowDictionary[columnName] = value;
    }
    
    return [rowDictionary copy];
}



@end
