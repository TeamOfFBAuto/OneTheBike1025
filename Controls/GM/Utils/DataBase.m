//
//  DataBase.m
//  area
//
//  Created by gaomeng on 14-7-6.
//  Copyright (c) 2014年 gaomeng. All rights reserved.
//

#import "DataBase.h"
#define kDBFileName @"GMLOCATION.sqlite"
static sqlite3 *dbPointer = nil;  //sqlite3数据库  存在沙盒的包里面 包里的东西不能修改   把数据库拷贝到document里 进行操作
@implementation DataBase

+(sqlite3 *)openDB
{
	if(dbPointer)//如果数据库已经打开，返回数据库指针
	{
		return dbPointer;
	}
	//沙盒中sql文件的路径
	NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *sqlFilePath = [docPath stringByAppendingPathComponent:kDBFileName];
	//原始sql文件路径
	NSString *originFilePath = [[NSBundle mainBundle] pathForResource:@"GMLOCATION" ofType:@"sqlite"];
	
	NSFileManager *fm = [NSFileManager defaultManager];//文件管理器
	if([fm fileExistsAtPath:sqlFilePath] == NO)//如果sql文件不在doc下，copy过来
	{
		NSError *error = nil;
		if([fm copyItemAtPath:originFilePath toPath:sqlFilePath error:&error] == NO)
		{
			NSLog(@"创建数据库的时候出现了错误：%@",[error localizedDescription]);
		}
	}
	
	NSLog(@"open db at path:%@",sqlFilePath);
	sqlite3_open([sqlFilePath UTF8String], &dbPointer);//打开数据库，并且设置其指针
	return dbPointer;
}

+(void) closeDB
{
	if(dbPointer)
	{
		sqlite3_close(dbPointer);//关闭数据库
		dbPointer = nil;
	}
}

@end
