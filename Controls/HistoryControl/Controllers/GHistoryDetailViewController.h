//
//  GHistoryDetailViewController.h
//  OneTheBike
//
//  Created by gaomeng on 14/10/28.
//  Copyright (c) 2014年 szk. All rights reserved.
//




//历史界面点击某个历史跳转到的详细历史界面

#import <UIKit/UIKit.h>
#import "LRoadClass.h"
#import "LineDashPolyline.h"

@interface GHistoryDetailViewController : UIViewController<MAMapViewDelegate>
{
    //路书
    MAPointAnnotation *startAnnotation;//起点
    MAPointAnnotation *detinationAnnotation;//终点
    NSMutableArray *middleAnntations;//途经点
    
    
    
    UITableView *_tableView;
    
    NSArray *_imageArray;
    NSArray *_titleArray;
}


@property (nonatomic, strong) MAMapView *mapView;


@property(nonatomic,strong)LRoadClass *passModel;//上个界面传过来的数据

@property(nonatomic,strong)NSArray *lines;//显示的路书线数组


//路书=================
/* 起始点经纬度. */
@property (nonatomic) CLLocationCoordinate2D startCoordinate;
/* 终点经纬度. */
@property (nonatomic) CLLocationCoordinate2D destinationCoordinate;



@end
