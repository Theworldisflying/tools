//
//  SqliteManager.h
//  vpecker
//
//  Created by TD on 2017/11/26.
//  Copyright © 2017年 . All rights reserved.
//

#import <Foundation/Foundation.h>

//#import <sqlite3.h>

typedef void(^returnRes)(BOOL isSuccess);
typedef void(^returnArr)(NSArray *array);

@interface SqliteManager : NSObject
/**
 * 获取单例对象
 */
+(instancetype)shareManager;

/**
 * 打开数据库
 *
 * @param isSuccess 执行结果的回调
 */
- (void)openDb:(NSString*)path returnBlock:(returnRes)isSuccess;

/**
 * 数据库更新
 *
 * @param sql 执行的更新语句
 * @param isSuccess 执行结果的回调
 */
-(void)excuteUpdate:(NSString *)sql returnBlock:(returnRes)isSuccess;

/**
 * 数据库查询
 *
 * @param sql 执行的更新语句
 * @param arrayReturn 执行结果的回调
 */
-(void)excuteQuery:(NSString *)sql returnBlock:(returnArr)arrayReturn;

-(void)excuteQuery1:(NSString *)sql returnBlock:(returnArr)arrayReturn;

//关闭数据库
- (void)Canceldb;

@end
