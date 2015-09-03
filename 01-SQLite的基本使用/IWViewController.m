//
//  IWViewController.m
//  01-SQLite的基本使用
//
//  Created by apple on 14-5-22.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "IWViewController.h"
#import "FMDB.h"

@interface IWViewController ()
@property (nonatomic, strong) FMDatabaseQueue *queue;
- (IBAction)insert;
- (IBAction)update;
- (IBAction)delete;
- (IBAction)query;
@end

@implementation IWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 0.获得沙盒中的数据库文件名
    NSString *filename = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"student.sqlite"];
    
    // 1.创建数据库队列
    self.queue = [FMDatabaseQueue databaseQueueWithPath:filename];
    
    // 2.创表
    [self.queue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:@"create table if not exists t_student (id integer primary key autoincrement, name text, age integer);"];
        
        if (result) {
            NSLog(@"创表成功");
        } else {
            NSLog(@"创表失败");
        }
    }];
}

- (IBAction)insert
{
    [self.queue inDatabase:^(FMDatabase *db) {
        for (int i = 0; i<40; i++) {
            NSString *name = [NSString stringWithFormat:@"rose-%d", arc4random() % 1000];
            NSNumber *age = @(arc4random() % 100 + 1);
            [db executeUpdate:@"insert into t_student (name, age) values (?, ?);", name, age];
        }
    }];
}

- (IBAction)update
{
    [self.queue inDatabase:^(FMDatabase *db) {
        // 开启事务
//        [db executeUpdate:@"begin transaction;"];
//        [db beginTransaction];
        
        [db executeUpdate:@"update t_student set age = ? where name = ?;", @20, @"jack"];
        [db executeUpdate:@"update t_student set age = ? where name = ?;", @20, @"jack"];
        
        
//        if (发现情况不对){
//            // 回滚事务
//            [db rollback];
////            [db executeUpdate:@"rollback transaction;"];
//        }
        
        
        [db executeUpdate:@"update t_student set age = ? where name = ?;", @20, @"jack"];
        
        // 提交事务
//        [db commit];
//        [db executeUpdate:@"commit transaction;"];
    }];
}

- (IBAction)delete
{
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"update t_student set age = ? where name = ?;", @20, @"jack"];
        [db executeUpdate:@"update t_student set age = ? where name = ?;", @20, @"jack"];
        
//        if (发现情况不对){
//            // 回滚事务
//            *rollback = YES;
//        }
    }];
}

- (IBAction)query
{
    [self.queue inDatabase:^(FMDatabase *db) {
        // 1.查询数据
        FMResultSet *rs = [db executeQuery:@"select * from t_student where age > ?;", @50];
        
        // 2.遍历结果集
        while (rs.next) {
            int ID = [rs intForColumn:@"id"];
            NSString *name = [rs stringForColumn:@"name"];
            int age = [rs intForColumn:@"age"];
            
            NSLog(@"%d %@ %d", ID, name, age);
        }
    }];
}
@end
