//
//  LMaplineClass.h
//  OneTheBike
//
//  Created by lichaowei on 14/10/21.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LMaplineClass : NSObject
#define TYPE_MAPolyline @"MAPolyline"
#define TYPE_LineDashPolyline @"LineDashPolyline"

//    LineDashPolyline

@property(nonatomic,retain)NSString *classType;//判断对象类型

@property(nonatomic,assign)CGFloat latitude;
@property(nonatomic,assign)CGFloat longitude;

@property(nonatomic,assign)double rect_x;
@property(nonatomic,assign)double rect_y;
@property(nonatomic,assign)double rect_width;
@property(nonatomic,assign)double rect_height;
@property (nonatomic, retain)  NSDictionary *polyline;

- (instancetype)initLineDashPolylineWithCoordinate:(CLLocationCoordinate2D)coordinate
                                              rect:(MAMapRect)rect
                                          polyline:(MAPolyline*)line
                                              type:(NSString *)type
                                 coordinatesString:(NSString *)coordinatesStr;

//    MAPolyline

@property(nonatomic,assign)double pointX;
@property(nonatomic,assign)double pointY;

@property(nonatomic,retain)NSString *coordinatesString;
/*!
 @brief 坐标点的个数
 */
@property (nonatomic, assign) NSUInteger pointCount;

- (instancetype)initMAPolylineWithMapPointX:(double)x
                                     pointY:(double)y
                                 pointCount:(NSInteger)count
                                       type:(NSString *)type
                          coordinatesString:(NSString *)coordinatesStr;
@end
