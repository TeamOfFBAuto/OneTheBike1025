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

#import "RoadManagerController.h"

#import "ReGeocodeAnnotation.h"
#import "GOffLineMapViewController.h"
#import "Gmap.h"

#import "GstarCanshuViewController.h"
#import "GyundongCustomView.h"

#import "LRoadClass.h"




#define FRAME_IPHONE5_MAP_UP CGRectMake(0, 30, 320, 568-60-20)
#define FRAME_IPHONE5_MAP_DOWN CGRectMake(0, 230+20, 320, 568-230-20)
#define FRAME_IPHONE5_UPVIEW_UP CGRectMake(0, -115, 320, 230)
#define FRAME_IPHONE5_UPVIEW_DOWN CGRectMake(0, 20, 320, 230)



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
    
    
    
    
    
    
    UIView *_upview;//上面的运动信息view
    BOOL _isUpViewShow;//当前是否显示运动信息view
    UIButton *_upOrDownBtn;//上下收放btn
    UIView *_downView;//运动开始时下方的view
    
    UILabel *_fangxiangLabel;//方向
    
    GyundongCustomView *_fangxiangView;//方向
    GyundongCustomView *_dingView;//速度
    GyundongCustomView *_zuoshangView;//时间
    GyundongCustomView *_youshangView;//公里
    GyundongCustomView *_zuoxiaView;//海拔
    GyundongCustomView *_youxiaView;//bpm
    
    
    
    BOOL _isTimeOutClicked;//暂停按钮点击
    UIButton *_greenTimeOutBtn;//暂停按钮
    
    double _distance;//距离
    
    
    BOOL _isFirstStartCanshu;//是否为刚开始时候的参数 用于记录开始时候的海拔 起点
    
    
    //    NSString *_saveViewTag54ViewType;//upview上移之前的type
    //    NSString *_saveViewTag55ViewType;
    
    GyundongCustomView *_saveViewTag54View;//upview上移之前的view样式
    GyundongCustomView *_saveViewTag55View;
    
    NSTimer *_localTimer;//本地时钟
    
    UIImageView *_gpsQiangRuo;//gps强弱
    
    UIButton *_dingweiCenterBtn;//定位中心点按钮
    
    
    //保存路书时起点和终点的输入框
    UITextField *first;
    UITextField *second;
    
    NSString *startName;//起点名字
    NSString *endName;//终点名字
    
    
    //路书
    MAPointAnnotation *startAnnotation;//起点
    MAPointAnnotation *detinationAnnotation;//终点
    NSMutableArray *middleAnntations;//途经点
    
    
    
}
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) MAAnnotationView *userLocationAnnotationView;

//划线
@property (nonatomic, retain) MAPolyline* routeLine;
@property (nonatomic, retain) MAPolylineView* routeLineView;
@property(nonatomic,strong) NSMutableArray *routeLineArray;


@property(nonatomic,strong)NSArray *lines;//小胖界面 跳转过来显示的路书线数组


//路书=================
/* 起始点经纬度. */
@property (nonatomic) CLLocationCoordinate2D startCoordinate;
/* 终点经纬度. */
@property (nonatomic) CLLocationCoordinate2D destinationCoordinate;


//运动参数model
@property(nonatomic,strong)GyundongCanshuModel *gYunDongCanShuModel;

//五个自定义view
@property(nonatomic,strong)NSArray *fiveCustomView;



//@property (nonatomic,strong)NSMutableArray *cllocation2dsArray;
//@property (nonatomic, strong) NSMutableArray *overlays;


//清理 地图 搜索服务的相关代理
- (void)returnAction;

//设置参数
-(void)setImage:(UIImage*)theImage andContent:(NSString *)theStr andDanwei:(NSString *)theDanwei withTag:(NSInteger)theTag
       withType:(NSString *)theViewType;
@end
