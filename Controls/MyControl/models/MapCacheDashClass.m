//
//  MapCacheDashClass.m
//  OneTheBike
//
//  Created by lichaowei on 14/10/20.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "MapCacheDashClass.h"

@implementation MapCacheDashClass

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                              rect:(MAMapRect)rect
                          polyline:(MAPolyline*)line
                              type:(NSString *)type
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
        
        MapCacheDashClass *cache = [[MapCacheDashClass alloc]initWithMapPointX:line.points->x pointY:line.points->y pointCount:line.pointCount type:TYPE_MAPolyline];
        
        cache.
        
        self.polyline = [cache keyValues];
    }
    return self;
}

- (instancetype)initWithMapPointX:(double)x
                           pointY:(double)y
                       pointCount:(NSInteger)count
                             type:(NSString *)type
{
    self = [super init];
    if (self) {
        self.pointCount = count;
        self.pointX = x;
        self.pointY = y;
        self.classType = type;
    }
    return self;
}

@end
