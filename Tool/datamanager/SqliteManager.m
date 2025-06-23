//
//  SqliteManager.m
//  vpecker
//
//  Created by TD on 2017/11/26.
//  Copyright © 2017年 . All rights reserved.
//

#import "SqliteManager.h"

#import "FMDB.h"
#import "DtcQuerModel.h"

static SqliteManager *shareManager;

@interface SqliteManager (){
    
    dispatch_queue_t mySqliteQueue;
}
@property(nonatomic)FMDatabase  *database;
@property(nonatomic)FMDatabaseQueue *databaseQueue;
@end

@implementation SqliteManager

+(instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager =  [[SqliteManager alloc]init];
    });
    return shareManager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        // 创建并发队列
        mySqliteQueue = dispatch_queue_create("SqliteManager", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)openDb:(NSString*)path returnBlock:(returnRes)isSuccess{
    
    __block BOOL isOpen = NO;
    self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        isOpen = [db open];
    }];
    
    if (isSuccess) {
        isSuccess(isOpen);
    }
}

-(void)excuteUpdate:(NSString *)sql returnBlock:(returnRes)isSuccess{
    dispatch_async(mySqliteQueue, ^{
        __block BOOL isSuc = NO;
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            isSuc = [db executeUpdate:sql];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isSuccess) {
                isSuccess(isSuc);
            }
        });
    });
}
//- (NSMutableArray *)getRecordsGoodDataArrayWithSql:(NSString *)sql{
//    NSMutableArray *array = [NSMutableArray array];
//    [self.databaseQueue inDatabase:^(FMDatabase *db) {
//        if ([db open]) {
//            FMResultSet *resultSet = [db executeQuery:sql];
//            while (resultSet.next) {
//                UserInfoModel *user = [[UserInfoModel alloc] init];
//                user.currentAccount = [resultSet stringForColumn:@"currentAccount"];
//                user.currentPsw = [resultSet stringForColumn:@"currentPsw"];
//                [array addObject:user];
//            }
//            [db close];
//            [resultSet close];
//        }else {
//            NSLog(@"打开数据库失败");
//        }
//    }];
//    return array;
//}
-(void)excuteQuery:(NSString *)sql returnBlock:(returnArr)arrayReturn{
    
    NSMutableArray *array = [NSMutableArray array];

    
    dispatch_async(mySqliteQueue, ^{
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            if ([db open]) {
                [db setShouldCacheStatements:YES];
                [db beginTransaction];
                    FMResultSet *resultSet = [db executeQuery:sql];
                    while (resultSet.next) {
//                        DtcQuerModel *model = [[DtcQuerModel alloc] init];
//                        model.idStr = [resultSet stringForColumn:@"CODE"];
//                        model.vehickeStr = [resultSet stringForColumn:@"TITLE"];
//                        model.causeStr = [resultSet stringForColumn:@"CAUSE"];
//                        model.descriptionStr = [resultSet stringForColumn:@"DESCRIPTION"];
//                        model.symptomsStr = [resultSet stringForColumn:@"SYMPTOMS"];
                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                        for (int i=0; i<resultSet.columnCount; i++) {
                            if ([[resultSet stringForColumnIndex:i]  isEqualToString:@"0x00000000"]) {
                                dic[[resultSet columnNameForIndex:i]] = @"GENERAL";
                            }
                            else{
                                dic[[resultSet columnNameForIndex:i]] = [resultSet stringForColumnIndex:i];
                            }
                        }
                        DtcQuerModel *model = [DtcQuerModel modelWithJSON:dic];
                        [array addObject:model];
                    }
                    [db close];
                    [resultSet close];
            }else {
                NSLog(@"打开数据库失败");
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (arrayReturn) {
                arrayReturn(array);
            }
        });
    });
//}
//        while (result.next) {
//
//
//            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//            for (int i=0; i<result.columnCount; i++) {
//                if ([[result stringForColumnIndex:i]  isEqualToString:@"0x00000000"]) {
//                    dic[[result columnNameForIndex:i]] = @"GENERAL";
//                }
//                else{
//                    dic[[result columnNameForIndex:i]] = [result stringForColumnIndex:i];
//                }
//            }
//
////            DtcQuerModel *model = [[DtcQuerModel alloc]init];
//            DtcQuerModel *model = [DtcQuerModel modelWithJSON:dic];
////            model.idStr = [dic objectForKey:@"CODE"];
////            NSString *vehickeStr = [dic objectForKey:@"TITLE"];
////            NSArray *array1 = [vehickeStr componentsSeparatedByString:@"-"];//分隔符
////            if (array1.count == 2) {
////                model.vehickeStr = array1[1];
////            }else if (array1.count == 1){
////                model.vehickeStr = array1[0];
////            }
////
////            model.causeStr = [dic objectForKey:@"CAUSE"];
////            model.descriptionStr = [dic objectForKey:@"DESCRIPTION"];
////
////            model.symptomsStr = [dic objectForKey:@"SYMPTOMS"];
//            [array addObject:model];
//        }
    

}

-(void)excuteQuery1:(NSString *)sql returnBlock:(returnArr)arrayReturn{
    
    NSMutableArray *array = [NSMutableArray array];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:sql];
        while (result.next) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            for (int i=0; i<result.columnCount; i++) {
                if ([[result stringForColumnIndex:i]  isEqualToString:@"0x00000000"]) {
                    dic[[result columnNameForIndex:i]] = @"GENERAL";
                }
                else{
                    dic[[result columnNameForIndex:i]] = [result stringForColumnIndex:i];
                }
            }
        
            DtcQuerModel *model = [[DtcQuerModel alloc]init];
            model.vehickeStr = [dic objectForKey:@"BRAND"];
            model.descriptionStr = [dic objectForKey:@"DEFINITION"];
            [array addObject:model];
        }
    }];
    
    if (arrayReturn) {
        arrayReturn(array);
    }
}



- (void)Canceldb{
    
    [self.databaseQueue close];
}


@end
