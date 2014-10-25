//
//  GStartViewController.h
//  OneTheBike
//
//  Created by gaomeng on 14-10-13.
//  Copyright (c) 2014年 szk. All rights reserved.
//



//记录用户行走轨迹的vc
#import <UIKit/UIKit.h>

#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>

#import "LineDashPolyline.h"

#import "GstarCanshuViewController.h"

#import "GyundongCanshuModel.h"

@interface GStartViewController : UIViewController<MAMapViewDelegate, AMapSearchDelegate>
{
    // 点的数组
    NSMutableArray* _points;
    
    // 用户当前位置
    CLLocation* _currentLocation;
    
    // 折线
    MAPolyline* _routeLine;
    
    //折线view
    MAPolylineView* _routeLineView;
    
    //时间跑起来
    Boolean started;
    NSInteger _totalTakt;
    NSInteger _lapTakt;
    Boolean splitted;
    Boolean reset;
    NSInteger splitTimes;
    NSTimer *timer;
    
    NSInteger _timerHour;
    NSInteger _splitTimerHour;
    
    
    NSInteger timerMin ;
    NSInteger timerSecond ;
    
    
    NSInteger splitTimerMin ;
    NSInteger splitTimerSecond ;
    
    
    
    
//    BOOL _kaishiyundong;//用于判断 别的类有mapview 回到这个类的时候在viewWillApear方法里是否开启定位
    
    NSString *_startTime;//开始时间
    NSString *_endTime;//结束时间
    
}
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) MAAnnotationView *userLocationAnnotationView;

//划线
@property (nonatomic, retain) MAPolyline* routeLine;
@property (nonatomic, retain) MAPolylineView* routeLineView;

@property(nonatomic,strong) NSMutableArray *routeLineArray;


//路书=================
/* 起始点经纬度. */
@property (nonatomic) CLLocationCoordinate2D startCoordinate;
/* 终点经纬度. */
@property (nonatomic) CLLocationCoordinate2D destinationCoordinate;

//运动参数model
@property(nonatomic,strong)GyundongCanshuModel *gYunDongCanShuModel;

//四个自定义view
@property(nonatomic,strong)NSArray *fourCustomView;


//清理 地图 搜索服务的相关代理
- (void)returnAction;

//设置参数
-(void)setImage:(UIImage*)theImage andContent:(NSString *)theStr andDanwei:(NSString *)theDanwei withTag:(NSInteger)theTag
       withType:(NSString *)theViewType;
@end
