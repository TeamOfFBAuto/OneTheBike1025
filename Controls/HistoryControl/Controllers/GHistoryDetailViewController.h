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
#import "GyundongCanshuModel.h"

#define TABLEHEADERVIEW_FRAME_UP CGRectMake(0,264,320,30)
#define TABLEVIEW_FRAME_UP CGRectMake(0,294,320,274)

#define TABLEHEADERVIEW_FRAME_DOWN CGRectMake(0,568,320,30)
#define TABLEVIEW_FRAME_DOWN CGRectMake(0,568,320,274)

#define MAP_FRAME_UP CGRectMake(0, 64, 320, iPhone5?200:150)
#define MAP_FRAME_DOWN CGRectMake(0, 64, 320, iPhone5?568-64:480-64)

@interface GHistoryDetailViewController : UIViewController<MAMapViewDelegate>
{
    //路书
    MAPointAnnotation *startAnnotation;//起点
    MAPointAnnotation *detinationAnnotation;//终点
    NSMutableArray *middleAnntations;//途经点
    
    UIView *_tableHeaderView;
    UITableView *_tableView;
    
    NSArray *_imageArray;
    NSArray *_titleArray;
    
    
    BOOL _isShowMap;//是否隐藏地图
}


@property (nonatomic, strong) MAMapView *mapView;


@property(nonatomic,strong)GyundongCanshuModel *passModel;//上个界面传过来的数据

@property(nonatomic,strong)NSArray *lines;//显示的路书线数组


//路书=================
/* 起始点经纬度. */
@property (nonatomic) CLLocationCoordinate2D startCoordinate;
/* 终点经纬度. */
@property (nonatomic) CLLocationCoordinate2D destinationCoordinate;



@end
