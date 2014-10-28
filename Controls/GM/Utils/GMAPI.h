//
//  GMAPI.h
//  OneTheBike
//
//  Created by gaomeng on 14-10-10.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "DataBase.h"

#define START_COOR_STRING @"startCoorString" //起点坐标
#define END_COOR_STRING @"endCoorString"
#define LINE_JSONSTRING @"lineJsonString"//线的jsonString

typedef enum{
    Type_Road = 1,//路书
    Type_GUIJI //轨迹
}HistoryType;

/* 使用高德地图API，请注册Key，注册地址：http://lbs.amap.com/console/key
 */
const static NSString *APIKey_MAP = @"0b92a81f23cc5905c30dcb4c39da609d";


@interface GMAPI : NSObject

///根据时间获取星期
+ (NSUInteger)getWeekdayFromDate:(NSDate*)date;


///根据定位返回的地磁场doule值 返回方位 东 西 南 北 东北 东南 西南 西北
+(NSString *)switchMagneticHeadingWithDoubel:(double)theHeading;



///把经纬度添加到本地数据库里
+(void)addCllocationToDataBase:(CLLocationCoordinate2D)theLocation;



///从数据库里查找数据
+(void)findNowAllLocation;


///存储路线数据 type 1为路书 2为轨迹   当type = 1时 startCoorString为起点的坐标 endCoorString为终点的坐标 经度和纬度用逗号分隔的字符串      当type = 2时   startName:开始时间 结束时间 用时   endName:平均速度 distance:距离 startCoorString:开始的经纬度 endCoorString:结束时的经纬度
+ (void)addRoadLinesJsonString:(NSString *)jsonstr
                     startName:(NSString *)startName
                       endName:(NSString *)endName
                      distance:(NSString *)distance
                          type:(HistoryType)type
                  startCoorStr:(NSString *)startCoorString
                    endCoorStr:(NSString *)endCoorString;


//网络请求的才调用此方法（添加了 serverRoadId\isUpload 参数）

+ (void)addRoadLinesJsonString:(NSString *)jsonstr
                     startName:(NSString *)startName
                       endName:(NSString *)endName
                      distance:(NSString *)distance
                          type:(HistoryType)type
                  startCoorStr:(NSString *)startCoorString
                    endCoorStr:(NSString *)endCoorString
                  serverRoadId:(NSString *)serverRoadId
                      isUpload:(BOOL)isUpload;

+ (BOOL)existForServerRoadId:(NSString *)serverRoadId;//判断是否存在该serverRoadId对应路书

+ (NSString *)getRoadLinesJSonStringForRoadId:(int)roadId;//根据id获取roadline的json数据

+ (NSDictionary *)getRoadLinesForRoadId:(int)roadId;//根据id获取json 以及起点终点


+ (NSArray *)getRoadLinesForType:(HistoryType)type;//根据类型获取LRoadClass对象列表

+ (void)updateRoadId:(int)roadId
           startName:(NSString *)startName
             endName:(NSString *)endName
                Open:(BOOL)isOpen;// yes 1 地图显示  NO 0 不显示





+ (void)updateRoadId:(int)roadId isUpload:(BOOL)finish;//是否上传成功

+ (void)updateRoadId:(int)roadId serverRoadId:(NSString *)serverRoadID isUpload:(BOOL)finish;//更改上传状态以及serverRoadID



+ (void)updateRoadOpenForId:(int)roadId;//打开某个路书,其他路书关闭





+ (BOOL)deleteRoadId:(int)roadId type:(HistoryType)type;//删除路书或者轨迹

+ (BOOL)deleteAllData;//切换用户清空数据(路书和轨迹)





///根据type获取轨迹
+ (NSArray *)GgetGuiji;


//路书在地图显示相关method
+ (void)updateRoadCloseForId:(int)roadId;//关闭某个路书

+ (NSArray *)getRoadLinesForType:(HistoryType)type
                          isOpen:(BOOL)open;//获取所有是否打开的路书或者轨迹



@end
