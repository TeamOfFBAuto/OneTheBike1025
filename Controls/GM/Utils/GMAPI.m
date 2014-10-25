//
//  GMAPI.m
//  OneTheBike
//
//  Created by gaomeng on 14-10-10.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "GMAPI.h"
#import "LRoadClass.h"

@implementation GMAPI


+(NSString *)switchMagneticHeadingWithDoubel:(double)theHeading{
    NSString *str = @"";
    if (theHeading<22.5 || theHeading>=337.5) {
        str = @"北";
    }else if (theHeading>=22.5 && theHeading<67.5){
        str = @"东北";
    }else if (theHeading>=67.5 && theHeading<112.5){
        str = @"东";
    }else if (theHeading>=112.5 && theHeading<157.5){
        str = @"东南";
    }else if (theHeading>=157.5 && theHeading<202.5){
        str = @"南";
    }else if (theHeading>=202.5 && theHeading<247.5){
        str = @"西南";
    }else if (theHeading>=247.5 && theHeading<292.5){
        str = @"西";
    }else if (theHeading>=292.5 && theHeading<337.5){
        str = @"西北";
    }
    
    return str;
    
}




+(void)addCllocationToDataBase:(CLLocationCoordinate2D)theLocation{
    
    NSString *gLat = [NSString stringWithFormat:@"%f",theLocation.latitude];
    NSString *gLon = [NSString stringWithFormat:@"%f",theLocation.longitude];
    
    sqlite3 *db = [DataBase openDB];
    sqlite3_stmt *stmt = nil;
    
    int result = sqlite3_prepare(db, "insert into area(name,id) values(?,?)", -1, &stmt, nil);//?相当于%@格式
    
    sqlite3_bind_text(stmt, 2, [gLat UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 3, [gLon UTF8String], -1, NULL);
    
    result = sqlite3_step(stmt);
    
    sqlite3_finalize(stmt);
}



+(void)findNowAllLocation{
    sqlite3 * db = [DataBase openDB];
    sqlite3_stmt * stmt = nil;
    int result = sqlite3_prepare_v2(db,"select * from Gzuji order by fb_deteline desc", -1,&stmt,nil);
    NSLog(@"result ------   %d",result);
    
    if (result == SQLITE_OK) {
        
    }
    
}


+ (void)addRoadLinesJsonString:(NSString *)jsonstr
                     startName:(NSString *)startName
                       endName:(NSString *)endName
                      distance:(NSString *)distance
                          type:(HistoryType)type
                  startCoorStr:(NSString *)startCoorString
                    endCoorStr:(NSString *)endCoorString
{
    sqlite3 *db = [DataBase openDB];
    sqlite3_stmt *stmt = nil;
    
    int result = sqlite3_prepare(db, "insert into RoadLines(startName,endName,distance,lineString,date,type,startCoordinate,endCoordinate) values(?,?,?,?,?,?,?,?)", -1, &stmt, nil);//?相当于%@格式
    
    sqlite3_bind_text(stmt, 1, [startName UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 2, [endName UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 3, [distance UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 4, [jsonstr UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 5, [[LTools timechangeToDateline] UTF8String], -1, NULL);
    sqlite3_bind_int(stmt, 6, type);
    
    sqlite3_bind_text(stmt, 7, [startCoorString UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 8, [endCoorString UTF8String], -1, NULL);
    
    result = sqlite3_step(stmt);
    
    NSLog(@"save brand %@ brandResult:%d",startName,result);
    
    sqlite3_finalize(stmt);
}

+ (NSString *)getRoadLinesJSonStringForRoadId:(int)roadId
{
    //打开数据库
    sqlite3 *db = [DataBase openDB];
    //创建操作指针
    sqlite3_stmt *stmt = nil;
    //执行SQL语句
    int result = sqlite3_prepare_v2(db, "select * from RoadLines where roadId = ?", -1, &stmt, nil);
    
    NSLog(@"RoadLinesJSonString %d %d",result,roadId);
    
    if (result == SQLITE_OK) {
        
        sqlite3_bind_int(stmt, 1, roadId);
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            const unsigned char *cityName = sqlite3_column_text(stmt, 4);
            
            return [NSString stringWithUTF8String:(const char *)cityName];
        }
    }
    sqlite3_finalize(stmt);
    return @"";
}

+ (NSDictionary *)getRoadLinesForRoadId:(int)roadId
{
    //打开数据库
    sqlite3 *db = [DataBase openDB];
    //创建操作指针
    sqlite3_stmt *stmt = nil;
    //执行SQL语句
    int result = sqlite3_prepare_v2(db, "select * from RoadLines where roadId = ?", -1, &stmt, nil);
    
    if (result == SQLITE_OK) {
        
        sqlite3_bind_int(stmt, 1, roadId);
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            const unsigned char *lineString = sqlite3_column_text(stmt, 4);
            const unsigned char *startString = sqlite3_column_text(stmt, 7);
            const unsigned char *endString = sqlite3_column_text(stmt, 8);
            
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:[NSString stringWithUTF8String:(const char *)lineString] forKey:LINE_JSONSTRING];
            [dic setObject:[NSString stringWithUTF8String:(const char *)startString] forKey:START_COOR_STRING];
            [dic setObject:[NSString stringWithUTF8String:(const char *)endString] forKey:END_COOR_STRING];
            
            return dic;
        }
    }
    sqlite3_finalize(stmt);
    return nil;
}

+ (NSArray *)getRoadLinesForType:(HistoryType)type
{
    //打开数据库
    sqlite3 *db = [DataBase openDB];
    //创建操作指针
    sqlite3_stmt *stmt = nil;
    //执行SQL语句
    int result = sqlite3_prepare_v2(db, "select * from RoadLines where type = ?", -1, &stmt, nil);
    
    NSMutableArray *arr = [NSMutableArray array];
    
    if (result == SQLITE_OK) {
        
        sqlite3_bind_int(stmt, 1, type);
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            int roadid = sqlite3_column_int(stmt, 0);
            NSString *startName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)];
            NSString *endName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
            NSString *distance = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)];
            NSString *lineString = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)];
            NSString *date = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)];
            NSString *startStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 7)];
            NSString *endStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 8)];
            
            int isOpen = sqlite3_column_int(stmt, 9);
            int isUpload = sqlite3_column_int(stmt, 10);
            
            NSArray *start_arr = [startStr componentsSeparatedByString:@","];
            
            CLLocationCoordinate2D start;
            if (start_arr.count == 2) {
                start = CLLocationCoordinate2DMake([[start_arr objectAtIndex:0]floatValue], [[start_arr objectAtIndex:1]floatValue]);
            }
            
            NSArray *end_arr = [endStr componentsSeparatedByString:@","];
            CLLocationCoordinate2D end;
            if (end_arr.count == 2) {
                end = CLLocationCoordinate2DMake([[end_arr objectAtIndex:0]floatValue], [[end_arr objectAtIndex:1]floatValue]);
            }
            
            LRoadClass *road = [[LRoadClass alloc]initWithRoadId:roadid startName:startName endName:endName distance:distance lineString:lineString dateline:date startCoor:start endCoor:end];
            road.isOpen = isOpen;
            road.isUpload = isUpload;
            [arr addObject:road];
        }
    }
    sqlite3_finalize(stmt);
    return arr;
}



+ (NSArray *)getRoadLinesForType:(HistoryType)type
                          isOpen:(BOOL)open
{
    //打开数据库
    sqlite3 *db = [DataBase openDB];
    //创建操作指针
    sqlite3_stmt *stmt = nil;
    //执行SQL语句
    int result = sqlite3_prepare_v2(db, "select * from RoadLines where type = ? and isOpen = ?", -1, &stmt, nil);
    
    NSMutableArray *arr = [NSMutableArray array];
    
    if (result == SQLITE_OK) {
        
        sqlite3_bind_int(stmt, 1, type);
        sqlite3_bind_int(stmt, 2, open ? 1 : 0);
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            int roadid = sqlite3_column_int(stmt, 0);
            NSString *startName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)];
            NSString *endName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
            NSString *distance = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)];
            NSString *lineString = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)];
            NSString *date = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)];
            NSString *startStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 7)];
            NSString *endStr = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 8)];
            
            NSArray *start_arr = [startStr componentsSeparatedByString:@","];
            
            CLLocationCoordinate2D start;
            if (start_arr.count == 2) {
                start = CLLocationCoordinate2DMake([[start_arr objectAtIndex:0]floatValue], [[start_arr objectAtIndex:1]floatValue]);
            }
            
            NSArray *end_arr = [endStr componentsSeparatedByString:@","];
            CLLocationCoordinate2D end;
            if (end_arr.count == 2) {
                end = CLLocationCoordinate2DMake([[end_arr objectAtIndex:0]floatValue], [[end_arr objectAtIndex:1]floatValue]);
            }
            
            LRoadClass *road = [[LRoadClass alloc]initWithRoadId:roadid startName:startName endName:endName distance:distance lineString:lineString dateline:date startCoor:start endCoor:end];
            [arr addObject:road];
        }
    }
    sqlite3_finalize(stmt);
    return arr;

}

+ (void)updateRoadId:(int)roadId
           startName:(NSString *)startName
             endName:(NSString *)endName
                Open:(BOOL)isOpen
{
    sqlite3 *db = [DataBase openDB];
    sqlite3_stmt *stmt = nil;
    
    int result = sqlite3_prepare(db, "update RoadLines set startName = ?,endName = ?,isOpen = ? where roadId = ?", -1, &stmt, nil);
    
    sqlite3_bind_text(stmt, 1, [startName UTF8String], -1, nil);
    sqlite3_bind_text(stmt, 2, [endName UTF8String], -1, nil);
    sqlite3_bind_int(stmt, 3, isOpen ? 1 : 0);
    sqlite3_bind_int(stmt, 4, roadId);
    
    
    if (result == SQLITE_OK) {
        sqlite3_step(stmt);
    }
    
    sqlite3_finalize(stmt);
    
}

+ (void)updateRoadId:(int)roadId isUpload:(BOOL)finish
{
    sqlite3 *db = [DataBase openDB];
    sqlite3_stmt *stmt = nil;
    
    int result = sqlite3_prepare(db, "update RoadLines set isUpload = ? where roadId = ?", -1, &stmt, nil);
    sqlite3_bind_int(stmt, 1, finish ? 1 : 0);
    sqlite3_bind_int(stmt, 2, roadId);
    
    if (result == SQLITE_OK) {
        sqlite3_step(stmt);
    }
    sqlite3_finalize(stmt);
}

+ (BOOL)deleteRoadId:(int)roadId type:(HistoryType)type
{
    sqlite3 *db = [DataBase openDB];
    sqlite3_stmt *stmt = nil;
    
    int result = sqlite3_prepare(db, "delete from RoadLines where roadId = ? and type = ?", -1, &stmt, nil);
    
    sqlite3_bind_int(stmt, 1, roadId);
    sqlite3_bind_int(stmt, 2, type);
    
    
    BOOL isOk = NO;
    
    if (result == SQLITE_OK) {
        sqlite3_step(stmt);
        
        isOk = YES;
    }
    
    sqlite3_finalize(stmt);
    
    return isOk;
}





+ (NSArray *)GgetGuiji{
    //打开数据库
    sqlite3 *db = [DataBase openDB];
    //创建操作指针
    sqlite3_stmt *stmt = nil;
    //执行SQL语句
    int result = sqlite3_prepare_v2(db, "select * from RoadLines where type = ?", -1, &stmt, NULL);
    
    
    NSMutableArray * array = [NSMutableArray array];
    
    if (result == SQLITE_OK) {
        
        sqlite3_bind_int(stmt, 1, 2);
        
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            int roadid = sqlite3_column_int(stmt, 0);
            
            const unsigned char * pstartName = sqlite3_column_text(stmt, 1);
            const unsigned char * pendName = sqlite3_column_text(stmt, 2);
            const unsigned char * pdistance = sqlite3_column_text(stmt, 3);
            const unsigned char * pLineString = sqlite3_column_text(stmt, 4);
            const unsigned char * pDate = sqlite3_column_text(stmt, 5);
            const unsigned char * pStartStr = sqlite3_column_text(stmt, 6);
            const unsigned char * pEndStr = sqlite3_column_text(stmt, 7);
            
            NSString *startName = pstartName ? [NSString stringWithUTF8String:(const char *)pstartName] : nil;
            NSString *endName = pendName ? [NSString stringWithUTF8String:(const char *)pendName]:nil;
            NSString *distance = pdistance ? [NSString stringWithUTF8String:(const char *)pdistance]:nil;
            NSString *lineString = pLineString ?[NSString stringWithUTF8String:(const char *)pLineString]:nil;
            NSString *date = pDate ? [NSString stringWithUTF8String:(const char *)pDate]:nil;
            NSString *startStr = pStartStr ? [NSString stringWithUTF8String:(const char *)pStartStr]:nil;
            NSString *endStr = pEndStr ? [NSString stringWithUTF8String:(const char *)pEndStr]:nil;
            
            int isOpen = sqlite3_column_int(stmt, 9);
            int isUpload = sqlite3_column_int(stmt, 10);
            
            NSArray *start_arr = [startStr componentsSeparatedByString:@","];
            
            CLLocationCoordinate2D start;
            if (start_arr.count == 2) {
                start = CLLocationCoordinate2DMake([[start_arr objectAtIndex:0]floatValue], [[start_arr objectAtIndex:1]floatValue]);
            }
            
            NSArray *end_arr = [endStr componentsSeparatedByString:@","];
            CLLocationCoordinate2D end;
            if (end_arr.count == 2) {
                end = CLLocationCoordinate2DMake([[end_arr objectAtIndex:0]floatValue], [[end_arr objectAtIndex:1]floatValue]);
            }
            
            LRoadClass *road = [[LRoadClass alloc]initWithRoadId:roadid startName:startName endName:endName distance:distance lineString:lineString dateline:date startCoor:start endCoor:end];
            road.isOpen = isOpen;
            road.isUpload = isUpload;
            [array addObject:road];
        }
    }
    
    sqlite3_finalize(stmt);
    return array;
    
    
}












@end
