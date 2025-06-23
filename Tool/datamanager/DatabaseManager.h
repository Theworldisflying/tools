//
//  DatabaseManager.h
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

NS_ASSUME_NONNULL_BEGIN

@interface DatabaseManager : NSObject

+ (instancetype)sharedInstance;

- (void)createOrOpenDatabaseAtPath:(nullable NSString *)path;

- (BOOL)createTableWithName:(NSString *)tableName
                  columnsInfo:(NSDictionary<NSString *, NSString *> *)columnsInfo
                        error:(NSError **)error;

- (int)insertIntoTable:(NSString *)tableName
                 values:(NSDictionary<NSString *, id> *)values
                  error:(NSError **)error;

- (int)deleteFromTable:(NSString *)tableName
           whereCondition:(nullable NSString *)whereCondition
                 arguments:(nullable NSArray *)arguments
                   error:(NSError **)error;

- (int)updateTable:(NSString *)tableName
         setValues:(NSDictionary<NSString *, id> *)setValues
   whereCondition:(nullable NSString *)whereCondition
         arguments:(nullable NSArray *)arguments
             error:(NSError **)error;
- (int)updateOrInsertTable:(NSString *)tableName
          setValues:(NSDictionary<NSString *, id> *)setValues
    whereCondition:(nullable NSString *)whereCondition
          arguments:(nullable NSArray *)arguments error:(NSError **)error;

- (nullable FMResultSet *)queryFromTable:(NSString *)tableName
                       whereCondition:(nullable NSString *)whereCondition
                             arguments:(nullable NSArray *)arguments
                                 error:(NSError **)error;

- (void)queryFromTable:(NSString *)tableName
          whereCondition:(nullable NSString *)whereCondition
                arguments:(nullable NSArray *)arguments
              resultBlock:(void (^)(NSArray<NSDictionary *> * arr))resultBlock
                    error:(NSError **)error;
- (void)querySql:(NSString*)sql resultBlock:(void (^)(NSArray<NSDictionary *> * arr))resultBlock error:(NSError **)error;

- (void)beginTransaction;
- (void)commit;
- (void)rollback;

- (void)query:(NSString *)ymd resultBlock:(void (^)(NSMutableArray<CarPerformanceData *> * arr))resultBlock;


/**
 *  将 FMResultSet 转换为字典数组
 *
 *  @param resultSet 包含数据的 FMResultSet 对象
 *  @return 包含数据的字典数组
 */
-(NSArray<NSDictionary *> *)dictionariesFromResultSet:(FMResultSet *)resultSet;


@end

NS_ASSUME_NONNULL_END

/**
 [[DatabaseManager sharedInstance] createOrOpenDatabaseAtPath:nil];

 NSDictionary *columns = @{
     @"id": @"INTEGER PRIMARY KEY AUTOINCREMENT",
     @"name": @"TEXT NOT NULL",
     @"age": @"INTEGER"
 };

 NSError *error;
 [[DatabaseManager sharedInstance] createTableWithName:@"users" columnsInfo:columns error:&error];

 NSDictionary *data = @{
     @"name": @"Alice",
     @"age": @25
 };
 NSInteger rowsInserted = [[DatabaseManager sharedInstance] insertIntoTable:@"users" values:data error:&error];

 [[DatabaseManager sharedInstance] queryFromTable:@"users"
                                 whereCondition:nil
                                       arguments:nil
                                     resultBlock:^(FMResultSet * _Nonnull rs) {
     NSLog(@"ID: %d, Name: %@", [rs intForColumn:@"id"], [rs stringForColumn:@"name"]);
 } error:&error];
 //更新
 NSDictionary *valuesToUpdate = @{
     @"spd": @25,
     @"ymd": @"2020-01-21"
 };
 NSString *condition = @"ymd = ?";
 NSArray *args = @[@"2020-01-21"];

 BOOL success = [[DatabaseManager sharedInstance] updateTable:@"cardatadb"
                                                    setValues:valuesToUpdate
                                              whereCondition:condition
                                                    arguments:args
                                                        error:&error];
 if (success) {
     NSLog(@"更新成功");
 } else {
     NSLog(@"更新失败: %@", error.localizedDescription);
 }
 //查询年龄大于=30
 [[DatabaseManager sharedInstance] queryFromTable:@"cardatadb"
                                   whereCondition:@"age >= ?"
                                         arguments:@[@30]
                                       resultBlock:^(FMResultSet * _Nonnull rs) {
     while ([rs next]) {
         NSInteger userId = [rs intForColumn:@"id"];
         NSString *userName = [rs stringForColumn:@"name"];
         NSInteger userAge = [rs intForColumn:@"age"];
         
         NSLog(@"ID: %ld, 名字: %@, 年龄: %ld", (long)userId, userName, (long)userAge);
     }
 } error:&error];
 //    // 不传 resultBlock，会自动打印每一条记录的字段内容
 //    [[DatabaseManager sharedInstance] queryFromTable:@"cardatadb"
 //                                      whereCondition:nil
 //                                            arguments:nil
 //                                          resultBlock:nil
 //                                                error:nil];
 */
