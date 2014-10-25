//
//  DataBase.h
//  area
//
//  Created by gaomeng on 14-7-6.
//  Copyright (c) 2014年 gaomeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@interface DataBase : NSObject
+(sqlite3 *)openDB;

+(void) closeDB;
@end
