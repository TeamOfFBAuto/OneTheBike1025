//
//  LRoadClass.m
//  OneTheBike
//
//  Created by lichaowei on 14/10/22.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "LRoadClass.h"

@implementation LRoadClass

-(instancetype)initWithRoadId:(NSInteger)roadId
                    startName:(NSString *)startName
                      endName:(NSString *)endName
                     distance:(NSString *)diatane
                   lineString:(NSString *)linesSring
                     dateline:(NSString *)dateline
                    startCoor:(CLLocationCoordinate2D)start
                      endCoor:(CLLocationCoordinate2D)end
{
    self = [super init];
    if (self) {
        self.roadId = roadId;
        self.startName = startName;
        self.endName = endName;
        self.distance = diatane;
        self.lineString = linesSring;
        self.dateline = dateline;
        self.startCoor = start;
        self.endCoor = end;
    }
    return self;
}

@end
