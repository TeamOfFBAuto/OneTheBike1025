//
//  LRoadClass.h
//  OneTheBike
//
//  Created by lichaowei on 14/10/22.
//  Copyright (c) 2014年 szk. All rights reserved.
//

//数据库取出的路线列表类

#import <Foundation/Foundation.h>

@interface LRoadClass : NSObject
@property(nonatomic,assign)NSInteger roadId;
@property(nonatomic,retain)NSString *startName;
@property(nonatomic,retain)NSString *endName;
@property(nonatomic,retain)NSString *distance;
@property(nonatomic,retain)NSString *lineString;
@property(nonatomic,retain)NSString *dateline;
@property(nonatomic,assign)CLLocationCoordinate2D startCoor;
@property(nonatomic,assign)CLLocationCoordinate2D endCoor;
@property(nonatomic,assign)BOOL isOpen;//是否在地图打开
@property(nonatomic,assign)BOOL isUpload;//是否已经上传成功
@property(nonatomic,retain)NSString *serverRoadId;//服务器返回的id

@property(nonatomic,assign)BOOL time;//按天数排出二维数组的标志位

-(instancetype)initWithRoadId:(NSInteger)roadId
                    startName:(NSString *)startName
                      endName:(NSString *)endName
                     distance:(NSString *)diatane
                   lineString:(NSString *)linesSring
                     dateline:(NSString *)dateline
                    startCoor:(CLLocationCoordinate2D)start
                      endCoor:(CLLocationCoordinate2D)end;

@end
