//
//  LMaplineClass.m
//  OneTheBike
//
//  Created by lichaowei on 14/10/21.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "LMaplineClass.h"

@implementation LMaplineClass

- (instancetype)initLineDashPolylineWithCoordinate:(CLLocationCoordinate2D)coordinate
                              rect:(MAMapRect)rect
                          polyline:(MAPolyline*)line
                              type:(NSString *)type
                coordinatesString:(NSString *)coordinatesStr
{
    self = [super init];
    if (self) {
        
        self.latitude = coordinate.latitude;
        self.longitude = coordinate.longitude;
        self.rect_x = rect.origin.x;
        self.rect_y = rect.origin.y;
        self.rect_width = rect.size.width;
        self.rect_height = rect.size.height;
        self.classType = type;
        
        LMaplineClass *cache = [[LMaplineClass alloc]initMAPolylineWithMapPointX:line.points->x pointY:line.points->y pointCount:line.pointCount type:TYPE_MAPolyline coordinatesString:coordinatesStr];
        
        self.polyline = [cache keyValues];
    }
    return self;
}

- (instancetype)initMAPolylineWithMapPointX:(double)x
                           pointY:(double)y
                       pointCount:(NSInteger)count
                             type:(NSString *)type
                          coordinatesString:(NSString *)coordinatesStr
{
    self = [super init];
    if (self) {
        self.pointCount = count;
        self.pointX = x;
        self.pointY = y;
        self.classType = type;
        self.coordinatesString = coordinatesStr;
    }
    return self;
}


@end
