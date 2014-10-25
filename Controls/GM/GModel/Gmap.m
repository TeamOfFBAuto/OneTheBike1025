//
//  Gmap.m
//  OneTheBike
//
//  Created by gaomeng on 14/10/21.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "Gmap.h"

@implementation Gmap


+ (MAMapView *)sharedMap
{
    static MAMapView *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[MAMapView alloc] init];
        sharedAccountManagerInstance.zoomLevel = 19;
        sharedAccountManagerInstance.visibleMapRect = MAMapRectMake(220880104, 101476980, 272496, 466656);
    });
    sharedAccountManagerInstance.backgroundColor = [UIColor whiteColor];
    return sharedAccountManagerInstance;
}


@end
