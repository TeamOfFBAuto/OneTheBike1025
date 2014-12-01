//
//  LMapTools.h
//  OneTheBike
//
//  Created by lichaowei on 14/10/21.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NavigationViewControllerStartTitle     @"起点"
#define NavigationViewControllerDestinationTitle @"终点"
#define NavigationViewControllerMiddleTitle      @"途经点"
#define guijistart @"轨迹起点"


#define L_START_POINT_COORDINATE @"start_point_coor"//起点坐标
#define L_END_POINT_COORDINATE @"end_point_coor"//终点坐标
#define L_POLINES @"lines"//线路数据

#define ROAD_INDEX @"road_index"//路书id
#define NOTIFICATION_ROAD_LINES @"road_lines"//选择路书通知

#define ROAD_PARAMES @"road_params"//路线参数
#define ROAD_START_LAT @"start_latitude"//起点latitude
#define ROAD_START_LON @"start_longitude"//起点longitude
#define ROAD_START_LAT @"start_latitude"//起点latitude
#define ROAD_START_LON @"start_longitude"//起点longitude

@interface LMapTools : NSObject

+ (NSArray *)saveMaplines:(NSArray *)polines_arr;//保存line对象

+ (NSDictionary *)parseMapHistoryMap:(NSArray *)historyMaplines;//解析成line对象

@end
