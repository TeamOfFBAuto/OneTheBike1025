//
//  RoadProduceController.m
//  OneTheBike
//
//  Created by lichaowei on 14-10-18.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "RoadProduceController.h"
#import "CommonUtility.h"
#import "LineDashPolyline.h"
#import "ReGeocodeAnnotation.h"

#import "GeocodeAnnotation.h"

#import "NSObject+MJKeyValue.h"

#import "MAPolyline+UN.h"

#import "MapCacheDashClass.h"

#import "AppDelegate.h"

#import "Gmap.h"

#define PLACEGOLD @"搜索地址"

enum{
    OverlayViewControllerOverlayTypeCircle = 0,
    OverlayViewControllerOverlayTypeCommonPolyline,
    OverlayViewControllerOverlayTypePolygon,
    OverlayViewControllerOverlayTypeTexturePolyline,
    OverlayViewControllerOverlayTypeArrowPolyline
    
};


enum{
    Point_Start = 1,//起点
    Point_Middle,//途
    Point_End //终点
};

@interface RoadProduceController ()<UITextFieldDelegate>
{
    int point_state;
    
    NSMutableArray *middle_points_arr;
    
    NSMutableArray *polines_arr;//存储线
    
    UILongPressGestureRecognizer *longPress;
    
    int point_index;
    
    MAPointAnnotation *startAnnotation;//起点
    MAPointAnnotation *detinationAnnotation;//终点
    NSMutableArray *middleAnntations;//途经点
    
    BOOL save_finish;//是否保存成功
    BOOL nav_walk_finish;//生成是否成功
    
    NSString *startName;//起点名字
    NSString *endName;//终点名字
    UITextField *first;
    UITextField *second;
    
    UIImageView *centerImage;//中间点
    
    UITextField *_searchField;//搜索
    
    UITableView *tips_table;//搜索提示tableView
    
    MBProgressHUD *loading;
    
    NSInteger totalDistance;//总距离
}

@property (nonatomic, strong) AMapRoute *route;

/* 起始点经纬度. */
@property (nonatomic) CLLocationCoordinate2D startCoordinate;
/* 终点经纬度. */
@property (nonatomic) CLLocationCoordinate2D destinationCoordinate;

@property (nonatomic, strong) MAAnnotationView *userLocationAnnotationView;

@property (nonatomic, strong) NSMutableArray *tips;//搜索提示


@end

@implementation RoadProduceController

@synthesize mapView = _mapView;
@synthesize search  = _search;

- (void)dealloc
{
    [self clearMapView];
    [self clearSearch];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *spaceButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButton1.width = IOS7_OR_LATER ? - 7 : 7;
    
    UIButton *settings=[[UIButton alloc]initWithFrame:CGRectMake(20,8,40,20)];
    [settings addTarget:self action:@selector(clickToSave:) forControlEvents:UIControlEventTouchUpInside];
    [settings setTitle:@"保存" forState:UIControlStateNormal];
    [settings.titleLabel setFont:[UIFont systemFontOfSize:12]];
    settings.layer.cornerRadius = 3.f;
    [settings setBackgroundColor:[UIColor colorWithHexString:@"bebebe"]];
    UIBarButtonItem *right =[[UIBarButtonItem alloc]initWithCustomView:settings];
    self.navigationItem.rightBarButtonItems = @[spaceButton1,right];
    
    self.titleLabel.text = @"路书制作";
    
    [self initMap];
    
    [self createTools];

    middle_points_arr = [NSMutableArray array];//途经点 AMapGeoPoint
    polines_arr = [NSMutableArray array];//所有的规划线
    middleAnntations = [NSMutableArray array];//途经点 Annotation
    point_index = 0;
    save_finish = NO;
    nav_walk_finish = NO;
    
    self.tips = [NSMutableArray array];
    
    [self initHistoryMap];
    
    CGSize aSize = [UIScreen mainScreen].bounds.size;
    centerImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"road_select"]];
    centerImage.center = CGPointMake(aSize.width / 2.f, aSize.height / 2.f - 64 + 10 + 10 + 10);
    [self.view addSubview:centerImage];
    
    
    loading = [LTools MBProgressWithText:@"路书制作中..." addToView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickToBack:(id)sender
{
    if (save_finish || polines_arr.count == 0) {
        
        [self returnAction];
        
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"路书未保存" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
        
        alert.tag = 1000;
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1000) {
        if (buttonIndex == 0) {
            
            [self returnAction];
            
        }else if(buttonIndex == 1){
            
            [self clickToSave:nil];
        }
    }else
    {
        if (buttonIndex == 0) {
            
            
            
        }else if(buttonIndex == 1){
            
            [self saveRoadLines];
        }
    }
}

#pragma mark - 历史轨迹

- (void)initHistoryMap
{
//    NSString *key = [NSString stringWithFormat:@"road_%d",self.road_index];
    
//    NSArray *arr = [LTools cacheForKey:key];
    
    NSDictionary *dic = [GMAPI getRoadLinesForRoadId:self.road_index];
    NSString *jsonString = [dic objectForKey:LINE_JSONSTRING];
    NSArray *arr = [jsonString objectFromJSONString];
    
    NSArray *start_arr = [[dic objectForKey:START_COOR_STRING] componentsSeparatedByString:@","];
    
    CLLocationCoordinate2D start;
    if (start_arr.count == 2) {
        start = CLLocationCoordinate2DMake([[start_arr objectAtIndex:0]floatValue], [[start_arr objectAtIndex:1]floatValue]);
    }
    
    NSArray *end_arr = [[dic objectForKey:END_COOR_STRING] componentsSeparatedByString:@","];
    CLLocationCoordinate2D end;
    if (end_arr.count == 2) {
        end = CLLocationCoordinate2DMake([[end_arr objectAtIndex:0]floatValue], [[end_arr objectAtIndex:1]floatValue]);
    }
    
    if (arr.count == 0) {
        return;
    }
    
    NSDictionary *history_dic = [LMapTools parseMapHistoryMap:arr];
    
    NSArray *lines = [history_dic objectForKey:L_POLINES];
    
    self.startCoordinate = start;
    [self addStartAnnotation];
    
    self.destinationCoordinate = end;
    [self addDestinationAnnotation];
    
    [self.mapView addOverlays:lines];
    
    [self.mapView setCenterCoordinate:self.startCoordinate animated:YES];

}

#pragma mark - Initialization

//地图

- (void)initMap
{
    [self initMapView];
    
    [self initSearch];
    
}

- (void)initMapView
{
//    self.mapView = [[MAMapView alloc]initWithFrame:self.view.bounds];
    
    self.mapView = [Gmap sharedMap];
    self.mapView.frame = self.view.bounds;
    
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
    
    
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    self.mapView.showsUserLocation = YES;//开启定位
    self.mapView.customizeUserLocationAccuracyCircleRepresentation = YES;//自定义定位样式
    self.mapView.userTrackingMode = MAUserTrackingModeNone;//定位模式
    
    self.mapView.visibleMapRect = MAMapRectMake(220880104, 101476980, 272496, 466656);
}

- (void)initSearch
{
    self.search = [[AMapSearchAPI alloc] initWithSearchKey:@"0b92a81f23cc5905c30dcb4c39da609d" Delegate:nil];
    self.search.delegate = self;
}

#pragma mark - 数据解析

#pragma mark - 网络请求

#pragma mark - 视图创建

- (void)createTools
{
    
    //===============键盘消失手势
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenKeyword)];
    [self.mapView addGestureRecognizer:tap];
   
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    //===============搜索框
    
    UIView *search_back = [[UIView alloc]initWithFrame:CGRectMake(10, 5+2, screenSize.width - 20, 35)];
    search_back.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.2];
    [self.view addSubview:search_back];
    
    UIImageView *logoImageV =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"map_search"]];
    logoImageV.frame = CGRectMake(20, (search_back.height - 19)/2.0 , 20, 19);
    [search_back addSubview:logoImageV];
    
    
    _searchField = [[UITextField alloc]initWithFrame:CGRectMake(logoImageV.right + 5, 0, 240, search_back.height)];
    _searchField.delegate = self;
    _searchField.returnKeyType = UIReturnKeySearch;
    _searchField.font=[UIFont systemFontOfSize:14];
    _searchField.textColor = [UIColor whiteColor];
    
    _searchField.attributedPlaceholder = [LTools attributedString:PLACEGOLD keyword:PLACEGOLD color:[UIColor whiteColor]];
    
    [search_back addSubview:_searchField];
    
    //===============选点按钮
   
    UIView *tools = [[UIView alloc]initWithFrame:CGRectMake(0, screenSize.height - 50 - 20 - 64 - 10, screenSize.width, 50)];
    tools.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tools];
//    NSArray *titls_arr = @[@"取消",@"起",@"途",@"终",@"生成"];
    
//    NSArray *images_arr = @[@"road_cancel",@"road_start",@"road_middle",@"road_end",@"road_produce"];

    NSArray *images_arr = @[@"road_cancel",@"road_start",@"road_middle",@"road_end",@"road_produce"];
    for (int i = 0; i < 5; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake((screenSize.width - 50 * 5)/2.f + 50 * i, 0, 50, 50);
        [btn setImage:[UIImage imageNamed:[images_arr objectAtIndex:i]] forState:UIControlStateNormal];
        
        btn.tag = 100 + i;
        [tools addSubview:btn];
        [btn addTarget:self action:@selector(clickToActionMap:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - 事件处理

- (void)searchKeyword
{
    [self clearAndSearchGeocodeWithKey:_searchField.text];
}

- (void)hiddenKeyword
{
    [_searchField resignFirstResponder];
}

- (void)clearMapView
{
    self.mapView.showsUserLocation = NO;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView removeOverlays:self.mapView.overlays];
    
    self.mapView.delegate = nil;
    
    self.mapView = nil;
}

- (void)clearSearch
{
    self.search.delegate = nil;
}

- (void)clickToSave:(UIButton *)sender
{
    NSLog(@"polines_arr %@",polines_arr);
    
//    LineDashPolyline
//    MAPolyline
    
    if (nav_walk_finish == NO) {
        
        [LTools showMBProgressWithText:@"请先制作路书" addToView:self.view];
        return;
    }
    
    if (save_finish == YES) {
        
        [LTools showMBProgressWithText:@"路书保存成功" addToView:self.view];
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"起点和终点" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
    
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    
    [alert show];
    
    first = [alert textFieldAtIndex:0];
    first.text = startName;
    
    second = [alert textFieldAtIndex:1];
    second.text = endName;
    second.secureTextEntry = NO;
    
}

- (void)saveRoadLines
{
    NSArray *dic_arr = [LMapTools saveMaplines:polines_arr];
    
    NSString *jsonStr = [dic_arr JSONString];
    
    NSLog(@"jsonStr %@",jsonStr);
    
    save_finish = YES;
    
    NSString *startString = [NSString stringWithFormat:@"%@,%@",[NSString stringWithFormat:@"%f",self.startCoordinate.latitude],[NSString stringWithFormat:@"%f",self.startCoordinate.longitude]];
    NSString *endString = [NSString stringWithFormat:@"%@,%@",[NSString stringWithFormat:@"%f",self.destinationCoordinate.latitude],[NSString stringWithFormat:@"%f",self.destinationCoordinate.longitude]];
    
    startName = first.text.length ? first.text : @"未知";
    endName = second.text.length ? second.text : @"未知";
    
    NSString *distance = [LTools stringForDistance:totalDistance];
    
    [GMAPI addRoadLinesJsonString:jsonStr startName:startName endName:endName distance:distance type:Type_Road startCoorStr:startString endCoorStr:endString];
    
    [LTools showMBProgressWithText:@"路书本地保存成功" addToView:self.view];
    
    [self performSelector:@selector(clickToBack:) withObject:nil afterDelay:0.5];
}

//添加点
- (void)addCoordinate
{
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:centerImage.center
                                              toCoordinateFromView:self.mapView];
    
    
    if (point_state == Point_Start) {
        
        self.startCoordinate = coordinate;
        
        [self addStartAnnotation];
        
        [self searchReGeocodeWithCoordinate:coordinate];
        
    }else if (point_state == Point_End){
        
        self.destinationCoordinate = coordinate;
        
        [self addDestinationAnnotation];
        
        [self searchReGeocodeWithCoordinate:coordinate];
        
    }else if (point_state == Point_Middle){
        
        NSLog(@"途经点");
        
        [middle_points_arr addObject:[AMapGeoPoint locationWithLatitude:coordinate.latitude
                                                              longitude:coordinate.longitude]];
        
        [self addMiddleAnnotation:coordinate];
        
    }

}

- (void)clickToActionMap:(UIButton *)sender
{
    switch (sender.tag - 100) {
        case 0:
        {
            NSLog(@"取消");
            
            nav_walk_finish = NO;
            
            longPress.enabled = NO;
            
            
            if (self.destinationCoordinate.latitude != 0) {
                [self removeDestinationAnnotation];
            }else if (middleAnntations.count > 0)
            {
                [self removeLastMiddleAnnotation];
            }else if(self.startCoordinate.latitude != 0){
                [self removeStartAnnotation];
                point_state = Point_Start;
            }
        }
            break;
        case 1:
        {
            NSLog(@"起");
            point_state = Point_Start;
            
            [self addCoordinate];
        }
            break;
        case 2:
        {
            NSLog(@"途");
            point_state = Point_Middle;
            
            [self addCoordinate];
        }
            break;
        case 3:
        {
            NSLog(@"终");
            point_state = Point_End;

            [self addCoordinate];
        }
            break;
        case 4:
        {
            NSLog(@"生成");
            
            totalDistance = 0;
            
            [self searchNaviWalk];
            
            longPress.enabled = NO;
            
            [self clear];
        }
            break;
            
        default:
            break;
    }
    
    for (int i = 0; i < 5; i ++) {
        
        UIButton *btn = (UIButton *)[self.view viewWithTag:100 + i];
        
        if (btn == sender) {
            sender.selected = YES;
        }else
        {
            sender.selected = NO;
        }
    }
}

- (void)returnAction
{
    [self.navigationController popViewControllerAnimated:YES];
    
    [self clearMapView];
    
    [self clearSearch];
}


//手势处理

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPresss//长按弹出大头针=========
{
    
    if (longPresss.state == UIGestureRecognizerStateBegan)
    {
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:[longPress locationInView:self.view]
                                                  toCoordinateFromView:self.mapView];
        
        [self searchReGeocodeWithCoordinate:coordinate];
        
        if (point_state == Point_Start) {
            
            self.startCoordinate = coordinate;
            
            [self addStartAnnotation];
            
            [self searchReGeocodeWithCoordinate:coordinate];
            
        }else if (point_state == Point_End){
            
            self.destinationCoordinate = coordinate;
            
            [self addDestinationAnnotation];
            
            [self searchReGeocodeWithCoordinate:coordinate];
            
        }else if (point_state == Point_Middle){
            
            NSLog(@"途经点");
            
            [middle_points_arr addObject:[AMapGeoPoint locationWithLatitude:coordinate.latitude
                                     longitude:coordinate.longitude]];
            
            [self addMiddleAnnotation:coordinate];
            
        }
    }
}

- (void)searchReGeocodeWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeo.requireExtension = YES;
    
    [self.search AMapReGoecodeSearch:regeo];
}

- (void)searchNaviWalk {

    if (self.startCoordinate.latitude == 0) {

        [LTools showMBProgressWithText:@"请选择起点" addToView:self.view];
        return;
    }

    if (self.destinationCoordinate.latitude == 0) {

        [LTools showMBProgressWithText:@"请选择终点" addToView:self.view];
        return;
    }
    
    NSLog(@"--->searchNaviWalk");
    
    [loading show:YES];
    
    int middleCount = middle_points_arr.count;
    
    //没有途经点,直接导航
    if (middleCount == 0) {
        
        AMapGeoPoint *origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                                        longitude:self.startCoordinate.longitude];
        
        AMapGeoPoint *destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude
                                                             longitude:self.destinationCoordinate.longitude];
        
        
        [self searchWithOrigin:origin destination:destination];
        
    }else
    {
        
        AMapGeoPoint *origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                                        longitude:self.startCoordinate.longitude];
        [middle_points_arr insertObject:origin atIndex:0];
        
        AMapGeoPoint *destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude
                                                        longitude:self.destinationCoordinate.longitude];
        
        [middle_points_arr addObject:destination];
        
        
        point_index = 0;
        
        AMapGeoPoint *des = [middle_points_arr objectAtIndex:1];
        
        
        [self searchWithOrigin:origin destination:des];
    }
}

- (void)searchWithOrigin:(AMapGeoPoint *)origin destination:(AMapGeoPoint *)destination
{
    AMapNavigationSearchRequest *navi = [[AMapNavigationSearchRequest alloc] init];
    navi.searchType       = AMapSearchType_NaviDrive;
    navi.requireExtension = YES;
    /* 出发点. */
    navi.origin = origin;
    /* 目的地. */
    navi.destination = destination;
    
    [self.search AMapNavigationSearch:navi];
}

#pragma mark 添加\取消 标志

//起点
- (void)addStartAnnotation
{
    if (startAnnotation) {
        
        [self.mapView removeAnnotation:startAnnotation];
    }
    
    startAnnotation = [[MAPointAnnotation alloc] init];
    startAnnotation.coordinate = self.startCoordinate;
    startAnnotation.title      = (NSString*)NavigationViewControllerStartTitle;
    startAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", self.startCoordinate.latitude, self.startCoordinate.longitude];
    [self.mapView addAnnotation:startAnnotation];
}
- (void)removeStartAnnotation
{
    [self.mapView removeAnnotation:startAnnotation];
    
    self.startCoordinate = CLLocationCoordinate2DMake(0, 0);
    
    [self removeAllPolines];
}

//终点
- (void)addDestinationAnnotation
{
    if (detinationAnnotation) {
        [self.mapView removeAnnotation:detinationAnnotation];
    }
    
    detinationAnnotation = [[MAPointAnnotation alloc] init];
    detinationAnnotation.coordinate = self.destinationCoordinate;
    detinationAnnotation.title      = (NSString*)NavigationViewControllerDestinationTitle;
    detinationAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", self.destinationCoordinate.latitude, self.destinationCoordinate.longitude];
    
    [self.mapView addAnnotation:detinationAnnotation];
}

- (void)removeDestinationAnnotation
{
    [self.mapView removeAnnotation:detinationAnnotation];
    
    self.destinationCoordinate = CLLocationCoordinate2DMake(0, 0);
    
    [self removeAllPolines];
}

//中间点
- (void)addMiddleAnnotation:(CLLocationCoordinate2D)midCoordinate
{
    MAPointAnnotation *midAnnotation = [[MAPointAnnotation alloc] init];
    midAnnotation.coordinate = midCoordinate;
    midAnnotation.title      = (NSString*)NavigationViewControllerMiddleTitle;
    midAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", midCoordinate.latitude, midCoordinate.longitude];
    [self.mapView addAnnotation:midAnnotation];
    
    [middleAnntations addObject:midAnnotation];
}

- (void)removeLastMiddleAnnotation
{
    if (middleAnntations.count == 0) {
        [LTools showMBProgressWithText:@"没有添加途经点" addToView:self.view];
        return;
    }
    MAPointAnnotation *last = [middleAnntations lastObject];
    [self.mapView removeAnnotation:last];
    [middleAnntations removeLastObject];

    [middle_points_arr removeLastObject];
    
    [self removeAllPolines];
}

- (void)removeAllPolines
{
    if (middleAnntations.count == 0 && self.startCoordinate.latitude == 0 && self.destinationCoordinate.latitude == 0){
        
        [self.mapView removeAnnotations:self.mapView.annotations];
        
        [self.mapView removeOverlays:self.mapView.overlays];
    }
}

#pragma mark - delegate

#pragma mark - UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //    maskView.hidden = YES;
    //   searchBlock (Search_Cancel,nil);
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self searchKeyword];
    
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - AMapSearchDelegate<NSObject>

/*!
 当请求发生错误时，会调用代理的此方法.
 @param request 发生错误的请求.
 @param error   返回的错误.
 */

- (void)searchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"%s: searchRequest = %@, errInfo= %@", __func__, [request class], error);
    
    [loading hide:YES];
    if (error.code == 1001) {
        
        [LTools showMBProgressWithText:@"请求超时" addToView:self.view];
    }
}

- (void)search:(id)searchRequest error:(NSString *)errInfo __attribute__ ((deprecated("use -search:didFailWithError instead.")))
{
    
}

#pragma mark - AMapSearchDelegate

/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode != nil)
    {
        
        NSLog(@"response0 %@",response.regeocode.formattedAddress);
        
        AMapGeoPoint *start = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude longitude:self.startCoordinate.longitude];
        AMapGeoPoint *end = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude longitude:self.destinationCoordinate.longitude];
        
        if (request.location.latitude == start.latitude) {
            startName = response.regeocode.formattedAddress;
        }else if (request.location.latitude == end.latitude){
            endName = response.regeocode.formattedAddress;
        }
        
//        if (fabsf(request.location.latitude - self.startCoordinate.latitude) < 0.00001) {
//            
//            startName = response.regeocode.formattedAddress;
//        }else if (fabsf(request.location.latitude - self.destinationCoordinate.latitude) < 0.00001){
//            endName = response.regeocode.formattedAddress;
//        }

        
//        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(request.location.latitude, request.location.longitude);
//        ReGeocodeAnnotation *reGeocodeAnnotation = [[ReGeocodeAnnotation alloc] initWithCoordinate:coordinate
//                                                                                         reGeocode:response.regeocode];
//        
//        [self.mapView addAnnotation:reGeocodeAnnotation];
//        [self.mapView selectAnnotation:reGeocodeAnnotation animated:YES];
        
    }
}

/*!
 @brief 路径规划查询回调函数
 @param request 发起查询的查询选项(具体字段参考AMapNavigationSearchRequest类中的定义)
 @param response 查询结果(具体字段参考AMapNavigationSearchResponse类中的定义)
 */
- (void)onNavigationSearchDone:(AMapNavigationSearchRequest *)request response:(AMapNavigationSearchResponse *)response
{
    NSLog(@"--->onNavigationSearchDone");
    self.route = response.route;
    
    AMapPath *path = self.route.paths[0];
    
    NSLog(@"distance -->%d",path.distance);
    
    totalDistance += path.distance;//计算总距离
    
    NSArray *polylines = [CommonUtility polylinesForPath:path];

    if (middle_points_arr.count == 0) {
        
        [self.mapView addOverlays:polylines];
        
        [polines_arr addObjectsFromArray:polylines];
        
        /* 缩放地图使其适应polylines的展示. */
        self.mapView.visibleMapRect = [CommonUtility mapRectForOverlays:polylines];
        
        nav_walk_finish = YES;
        
        [loading hide:YES];
        
        [LTools showMBProgressWithText:@"路书制作成功" addToView:self.view];
        
    }else
    {
        
        [self.mapView addOverlays:polylines];
        
        [polines_arr addObjectsFromArray:polylines];
        
        self.mapView.visibleMapRect = [CommonUtility mapRectForOverlays:polines_arr];
        
        point_index ++;
        
        if (point_index < middle_points_arr.count - 1) {
            
            AMapGeoPoint *origin = [middle_points_arr objectAtIndex:point_index];
            AMapGeoPoint *detin = [middle_points_arr objectAtIndex:point_index + 1];
            
            [self searchWithOrigin:origin destination:detin];
            
        }else if(point_index == middle_points_arr.count - 1)
        {
            nav_walk_finish = YES;
            
            [loading hide:YES];
            
            [LTools showMBProgressWithText:@"路书制作成功" addToView:self.view];
        }
        
    }
}

#pragma mark - MAMapViewDelegate

- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[LineDashPolyline class]])
    {
        MAPolylineView *overlayView = [[MAPolylineView alloc] initWithPolyline:((LineDashPolyline *)overlay).polyline];
        
        overlayView.lineWidth    = 5.f;
        overlayView.strokeColor  = [UIColor redColor];
        overlayView.lineDash     = YES;
        
        return overlayView;
    }
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineView *overlayView = [[MAPolylineView alloc] initWithPolyline:(MAPolyline *)overlay];
        
        overlayView.lineWidth    = 5.f;
        overlayView.strokeColor  = [UIColor blueColor];
        
        return overlayView;
    }
    
    return nil;
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *navigationCellIdentifier = @"navigationCellIdentifier";
        
        MAAnnotationView *poiAnnotationView = (MAAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:navigationCellIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:navigationCellIdentifier];
        }
        
        poiAnnotationView.canShowCallout = YES;
        
        /* 起点. */
        if ([[annotation title] isEqualToString:(NSString*)NavigationViewControllerStartTitle])
        {
            poiAnnotationView.image = [UIImage imageNamed:@"road_start"];
        }
        /* 终点. */
        else if([[annotation title] isEqualToString:(NSString*)NavigationViewControllerDestinationTitle])
        {
            poiAnnotationView.image = [UIImage imageNamed:@"road_end"];
        }
        /* 途经点. */
        else if([[annotation title] isEqualToString:(NSString*)NavigationViewControllerMiddleTitle])
        {
            poiAnnotationView.image = [UIImage imageNamed:@"road_middle"];
        }
        
        return poiAnnotationView;
    }else if ([annotation isKindOfClass:[MAUserLocation class]])/* 自定义userLocation对应的annotationView. */
    {
        static NSString *userLocationStyleReuseIndetifier = @"userLocationStyleReuseIndetifier";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:userLocationStyleReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:userLocationStyleReuseIndetifier];
        }
        
        annotationView.image = [UIImage imageNamed:@"userPosition"];
        
        self.userLocationAnnotationView = annotationView;
        
        return annotationView;
        
        
    }else if ([annotation isKindOfClass:[ReGeocodeAnnotation class]]){//长按弹出大头针上面的详细信息页面
        
        
        static NSString *invertGeoIdentifier = @"invertGeoIdentifier";
        MAPinAnnotationView *poiAnnotationView = (MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:invertGeoIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                                reuseIdentifier:invertGeoIdentifier];
        }
        
        poiAnnotationView.animatesDrop              = YES;
        poiAnnotationView.canShowCallout            = YES;
        poiAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return poiAnnotationView;
        
    }else if ([annotation isKindOfClass:[GeocodeAnnotation class]])
    {
        static NSString *geoCellIdentifier = @"geoCellIdentifier";
        
        MAPinAnnotationView *poiAnnotationView = (MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:geoCellIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                                reuseIdentifier:geoCellIdentifier];
        }
        
        poiAnnotationView.canShowCallout            = YES;
        poiAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return poiAnnotationView;
    }


    
    
    return nil;
}

//定位=============================
#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated{
    
}


-(void)mapView:(MAMapView*)mapView didFailToLocateUserWithError:(NSError*)error{
    NSLog(@"定位失败");
}

//定位的回调方法
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    //方向
    NSString *headingStr = @"";
    if (userLocation) {
//        NSLog(@"userLocation ---- %@",userLocation);
//        NSLog(@"userLocation.heading----%@",userLocation.heading);
        //地磁场方向
        double heading = userLocation.heading.magneticHeading;
        if (heading > 0) {
            headingStr = [GMAPI switchMagneticHeadingWithDoubel:heading];
        }
//        NSLog(@"%@",headingStr);
    }
    
    //海拔
    CLLocation *currentLocation = userLocation.location;
    if (currentLocation) {
//        NSLog(@"海拔---%f",currentLocation.altitude);
    }
    
    //自定义定位箭头方向
    if (!updatingLocation && self.userLocationAnnotationView != nil)
    {
        
        [UIView animateWithDuration:0.1 animations:^{
            
            double degree = userLocation.heading.trueHeading - self.mapView.rotationDegree;
            self.userLocationAnnotationView.transform = CGAffineTransformMakeRotation(degree * M_PI / 180.f );
            
        }];
    }
    
}


#pragma mark - --------------- ---------搜索

/* 地理编码 搜索. */
- (void)searchGeocodeWithKey:(NSString *)key
{
    if (key.length == 0)
    {
        return;
    }
    
    AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
    geo.address = key;
    
    [self.search AMapGeocodeSearch:geo];
}

/* 输入提示 搜索.*/
- (void)searchTipsWithKey:(NSString *)key
{
    if (key.length == 0)
    {
        return;
    }
    
    AMapInputTipsSearchRequest *tips = [[AMapInputTipsSearchRequest alloc] init];
    tips.keywords = key;
    [self.search AMapInputTipsSearch:tips];
}

/* 清除annotation. */
- (void)clear
{
    NSMutableArray *need_remove = [NSMutableArray array];
    for (id a in self.mapView.annotations) {
        
        if ([a isKindOfClass:[GeocodeAnnotation class]]) {
            
            [need_remove addObject:a];
        }
    }
    
    [self.mapView removeAnnotations:need_remove];
}

- (void)clearAndSearchGeocodeWithKey:(NSString *)key
{
    /* 清除annotation. */
    [self clear];
    
    [self searchGeocodeWithKey:key];
}


#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:[GeocodeAnnotation class]])
    {
//        [self gotoDetailForGeocode:[(GeocodeAnnotation*)view.annotation geocode]];
    }
}


#pragma mark - AMapSearchDelegate

/* 地理编码回调.*/
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    if (response.geocodes.count == 0)
    {
        return;
    }
    
    NSMutableArray *annotations = [NSMutableArray array];
    
    [response.geocodes enumerateObjectsUsingBlock:^(AMapGeocode *obj, NSUInteger idx, BOOL *stop) {
        GeocodeAnnotation *geocodeAnnotation = [[GeocodeAnnotation alloc] initWithGeocode:obj];
        
        [annotations addObject:geocodeAnnotation];
    }];
    
    if (annotations.count == 1)
    {
        [self.mapView setCenterCoordinate:[annotations[0] coordinate] animated:YES];
    }
    else
    {
        [self.mapView setVisibleMapRect:[CommonUtility minMapRectForAnnotations:annotations]
                               animated:YES];
    }
    
    [self.mapView addAnnotations:annotations];
}

/* 输入提示回调. */
- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response
{
    [self.tips setArray:response.tips];
    
//    [self.displayController.searchResultsTableView reloadData];
}

//[{"classType":"MAPolyline","rect_x":221018864,"rect_y":101670608,"rect_width":16,"pointX":221018864,"pointY":101670608,"latitude":39.951824188232422,"longitude":116.40940856933594,"coordinatesString":"116.409395,39.952170,116.409416,39.952014,116.409416,39.951479","pointCount":3,"rect_height":672},{"classType":"MAPolyline","rect_x":221018816,"rect_y":101671288,"rect_width":64,"pointX":221018880,"pointY":101671288,"latitude":39.951408386230469,"longitude":116.40937042236328,"coordinatesString":"116.409416,39.951471,116.409330,39.951348","pointCount":2,"rect_height":120},{"classType":"LineDashPolyline","rect_x":221018880,"rect_y":101671280,"rect_width":0,"pointX":0,"pointY":0,"latitude":39.951469421386719,"longitude":116.40941619873047,"polyline":{"classType":"MAPolyline","rect_x":0,"rect_y":0,"rect_width":0,"pointX":221018880,"pointY":101671280,"latitude":0,"longitude":0,"coordinatesString":"116.409416,39.951479,116.409416,39.951463","pointCount":2,"rect_height":0},"pointCount":0,"rect_height":16},{"classType":"MAPolyline","rect_x":221018784,"rect_y":101671408,"rect_width":16,"pointX":221018800,"pointY":101671408,"latitude":39.950855255126953,"longitude":116.4093017578125,"coordinatesString":"116.409309,39.951348,116.409309,39.950755,116.409287,39.950361","pointCount":3,"rect_height":960},{"classType":"LineDashPolyline","rect_x":221018800,"rect_y":101671416,"rect_width":16,"pointX":0,"pointY":0,"latitude":39.951339721679688,"longitude":116.40931701660156,"polyline":{"classType":"MAPolyline","rect_x":0,"rect_y":0,"rect_width":0,"pointX":221018816,"pointY":101671416,"latitude":0,"longitude":0,"coordinatesString":"116.409330,39.951339,116.409309,39.951339","pointCount":2,"rect_height":0},"pointCount":0,"rect_height":0},{"classType":"MAPolyline","rect_x":221018784,"rect_y":101672376,"rect_width":4032,"pointX":221018784,"pointY":101672376,"latitude":39.950187683105469,"longitude":116.4119873046875,"coordinatesString":"116.409287,39.950352,116.410167,39.950295,116.411648,39.950213,116.413150,39.950122,116.414266,39.950048,116.414695,39.950023","pointCount":6,"rect_height":320},{"classType":"LineDashPolyline","rect_x":221018784,"rect_y":101672368,"rect_width":0,"pointX":0,"pointY":0,"latitude":39.950355529785156,"longitude":116.40928649902344,"polyline":{"classType":"MAPolyline","rect_x":0,"rect_y":0,"rect_width":0,"pointX":221018784,"pointY":101672368,"latitude":0,"longitude":0,"coordinatesString":"116.409287,39.950361,116.409287,39.950352","pointCount":2,"rect_height":0},"pointCount":0,"rect_height":8},{"classType":"MAPolyline","rect_x":221022816,"rect_y":101672432,"rect_width":7152,"pointX":221022816,"pointY":101672704,"latitude":39.950115203857422,"longitude":116.41948699951172,"coordinatesString":"116.414695,39.950015,116.414952,39.949949,116.415210,39.949933,116.416647,39.949958,116.417656,39.950007,116.417956,39.950065,116.418278,39.950073,116.418965,39.950097,116.421368,39.950180,116.422248,39.950204,116.422956,39.950229,116.424286,39.950295","pointCount":12,"rect_height":352},{"classType":"LineDashPolyline","rect_x":221022816,"rect_y":101672704,"rect_width":0,"pointX":0,"pointY":0,"latitude":39.950016021728516,"longitude":116.41469573974609,"polyline":{"classType":"MAPolyline","rect_x":0,"rect_y":0,"rect_width":0,"pointX":221022816,"pointY":101672704,"latitude":0,"longitude":0,"coordinatesString":"116.414695,39.950015,116.414695,39.950015","pointCount":2,"rect_height":0},"pointCount":0,"rect_height":0},{"classType":"MAPolyline","rect_x":221029968,"rect_y":101672352,"rect_width":736,"pointX":221029968,"pointY":101672432,"latitude":39.950336456298828,"longitude":116.42478179931641,"coordinatesString":"116.424286,39.950295,116.425273,39.950377","pointCount":2,"rect_height":80},{"classType":"MAPolyline","rect_x":221030704,"rect_y":101672352,"rect_width":64,"pointX":221030704,"pointY":101672352,"latitude":39.950088500976562,"longitude":116.42531585693359,"coordinatesString":"116.425273,39.950377,116.425359,39.949801","pointCount":2,"rect_height":560},{"classType":"MAPolyline","rect_x":221030880,"rect_y":101673176,"rect_width":1984,"pointX":221030880,"pointY":101673256,"latitude":39.949489593505859,"longitude":116.42684173583984,"coordinatesString":"116.425509,39.949448,116.425724,39.949448,116.426840,39.949489,116.428170,39.949530","pointCount":4,"rect_height":80},{"classType":"LineDashPolyline","rect_x":221030768,"rect_y":101672912,"rect_width":112,"pointX":0,"pointY":0,"latitude":39.949623107910156,"longitude":116.42543792724609,"polyline":{"classType":"MAPolyline","rect_x":0,"rect_y":0,"rect_width":0,"pointX":221030768,"pointY":101672912,"latitude":0,"longitude":0,"coordinatesString":"116.425359,39.949801,116.425509,39.949448","pointCount":2,"rect_height":0},"pointCount":0,"rect_height":344},{"classType":"MAPolyline","rect_x":221032864,"rect_y":101673176,"rect_width":3104,"pointX":221032864,"pointY":101673176,"latitude":39.949306488037109,"longitude":116.43025207519531,"coordinatesString":"116.428170,39.949530,116.428406,39.949513,116.429136,39.949472,116.429307,39.949472,116.430445,39.949489,116.430745,39.949489,116.431046,39.949448,116.431324,39.949398,116.431818,39.949275,116.432118,39.949176,116.432333,39.949086","pointCount":11,"rect_height":432},{"classType":"MAPolyline","rect_x":221023376,"rect_y":101673616,"rect_width":22912,"pointX":221035968,"pointY":101673616,"latitude":39.909858703613281,"longitude":116.43080902099609,"coordinatesString":"116.432333,39.949078,116.432762,39.949004,116.433170,39.948609,116.433299,39.948452,116.433427,39.948239,116.433556,39.947918,116.433642,39.947646,116.433685,39.947268,116.433685,39.946446,116.433642,39.944644,116.433642,39.942662,116.433835,39.938253,116.433899,39.936303,116.433964,39.935629,116.434050,39.934090,116.434093,39.932321,116.434178,39.930339,116.434243,39.928841,116.434586,39.921083,116.434715,39.918063,116.434715,39.917766,116.434865,39.914467,116.434929,39.913907,116.435015,39.913430,116.435509,39.911257,116.435552,39.910969,116.435595,39.910681,116.435637,39.910080,116.435659,39.909718,116.435766,39.907414,116.435852,39.906114,116.435916,39.905546,116.436067,39.904682,116.436324,39.903225,116.436324,39.902970,116.436281,39.902698,116.436131,39.901752,116.436131,39.901538,116.436152,39.901217,116.436238,39.900945,116.436410,39.900665,116.436539,39.900525,116.436667,39.900385,116.436968,39.900138,116.437118,39.900040,116.437440,39.899908,116.437891,39.899760,116.442311,39.898813,116.442547,39.898739,116.442676,39.898706,116.442761,39.898665,116.443083,39.898492,116.443405,39.898245,116.443512,39.898147,116.443684,39.897924,116.443748,39.897817,116.443834,39.897570,116.443877,39.897439,116.443920,39.897307,116.443942,39.897052,116.443985,39.894722,116.444006,39.893982,116.444070,39.893331,116.444156,39.892821,116.444242,39.892253,116.444542,39.890063,116.444693,39.889042,116.445014,39.886334,116.445100,39.885717,116.445358,39.883749,116.445465,39.882959,116.445658,39.881765,116.446109,39.879525,116.446173,39.879188,116.446173,39.878752,116.446152,39.878579,116.446002,39.878019,116.445508,39.877088,116.445165,39.876421,116.444821,39.875623,116.444521,39.874676,116.444414,39.874239,116.444092,39.872823,116.444006,39.872444,116.443920,39.872165,116.443684,39.871745,116.443448,39.871481,116.443105,39.871193,116.442826,39.871020,116.442461,39.870847,116.442246,39.870781,116.441967,39.870707,116.441839,39.870682,116.441517,39.870641,116.441238,39.870616,116.441023,39.870616,116.438577,39.870748,116.436989,39.870847,116.434822,39.870946,116.425939,39.871423,116.424522,39.871456,116.423922,39.871456,116.423106,39.871423,116.422377,39.871391,116.421840,39.871349,116.419845,39.871251,116.419523,39.871218,116.418600,39.871160,116.418149,39.871160,116.417806,39.871201,116.417420,39.871292,116.417270,39.871349,116.416969,39.871481,116.416583,39.871654,116.415575,39.872123,116.415446,39.872181","pointCount":116,"rect_height":76272},{"classType":"LineDashPolyline","rect_x":221035968,"rect_y":101673608,"rect_width":0,"pointX":0,"pointY":0,"latitude":39.949081420898438,"longitude":116.43233489990234,"polyline":{"classType":"MAPolyline","rect_x":0,"rect_y":0,"rect_width":0,"pointX":221035968,"pointY":101673608,"latitude":0,"longitude":0,"coordinatesString":"116.432333,39.949086,116.432333,39.949078","pointCount":2,"rect_height":0},"pointCount":0,"rect_height":8},{"classType":"MAPolyline","rect_x":221022960,"rect_y":101748128,"rect_width":400,"pointX":221023360,"pointY":101748368,"latitude":39.872303009033203,"longitude":116.41515350341797,"coordinatesString":"116.415424,39.872181,116.415188,39.872280,116.414888,39.872428","pointCount":3,"rect_height":240},{"classType":"LineDashPolyline","rect_x":221023360,"rect_y":101748368,"rect_width":16,"pointX":0,"pointY":0,"latitude":39.872180938720703,"longitude":116.41543579101562,"polyline":{"classType":"MAPolyline","rect_x":0,"rect_y":0,"rect_width":0,"pointX":221023376,"pointY":101748368,"latitude":0,"longitude":0,"coordinatesString":"116.415446,39.872181,116.415424,39.872181","pointCount":2,"rect_height":0},"pointCount":0,"rect_height":0},{"classType":"MAPolyline","rect_x":221022848,"rect_y":101747456,"rect_width":112,"pointX":221022960,"pointY":101748128,"latitude":39.872772216796875,"longitude":116.41481018066406,"coordinatesString":"116.414888,39.872428,116.414781,39.872510,116.414738,39.872609,116.414738,39.873120","pointCount":4,"rect_height":672},{"classType":"MAPolyline","rect_x":221021824,"rect_y":101747432,"rect_width":976,"pointX":221022800,"pointY":101747456,"latitude":39.873130798339844,"longitude":116.41401672363281,"coordinatesString":"116.414673,39.873120,116.413364,39.873144","pointCount":2,"rect_height":24},{"classType":"LineDashPolyline","rect_x":221022800,"rect_y":101747456,"rect_width":48,"pointX":0,"pointY":0,"latitude":39.873119354248047,"longitude":116.41470336914062,"polyline":{"classType":"MAPolyline","rect_x":0,"rect_y":0,"rect_width":0,"pointX":221022848,"pointY":101747456,"latitude":0,"longitude":0,"coordinatesString":"116.414738,39.873120,116.414673,39.873120","pointCount":2,"rect_height":0},"pointCount":0,"rect_height":0},{"classType":"MAPolyline","rect_x":221021760,"rect_y":101745576,"rect_width":64,"pointX":221021824,"pointY":101747432,"latitude":39.874099731445312,"longitude":116.41332244873047,"coordinatesString":"116.413364,39.873144,116.413343,39.873573,116.413343,39.874091,116.413321,39.874519,116.413279,39.875055","pointCount":5,"rect_height":1856},{"classType":"MAPolyline","rect_x":221018864,"rect_y":101745576,"rect_width":2896,"pointX":221021760,"pointY":101745576,"latitude":39.874992370605469,"longitude":116.41133880615234,"coordinatesString":"116.413279,39.875055,116.411991,39.875022,116.409395,39.874931","pointCount":3,"rect_height":120},{"classType":"MAPolyline","rect_x":221018864,"rect_y":101745608,"rect_width":0,"pointX":221018864,"pointY":101745696,"latitude":39.874977111816406,"longitude":116.40939331054688,"coordinatesString":"116.409395,39.874931,116.409395,39.875022","pointCount":2,"rect_height":88}]



//[{classType:MAPolyline,rect_x:220950640,rect_y:101684480,rect_width:16,pointX:220950640,pointY:101684480,latitude:39.936759948730469,longitude:116.31790924072266,coordinatesString:116.317899,39.937907,116.317899,39.937652,116.317921,39.937109,116.317899,39.936640,116.317899,39.935735,116.317899,39.935612,pointCount:6,rect_height:2232},{classType:MAPolyline,rect_x:220950640,rect_y:101686720,rect_width:1408,pointX:220950640,pointY:101686720,latitude:39.935596466064453,longitude:116.31884002685547,coordinatesString:116.317899,39.935604,116.318779,39.935587,116.319788,39.935596,pointCount:3,rect_height:16},{classType:LineDashPolyline,rect_x:220950640,rect_y:101686712,rect_width:0,pointX:0,pointY:0,latitude:39.935604095458984,longitude:116.31790161132812,polyline:{classType:MAPolyline,rect_x:0,rect_y:0,rect_width:0,pointX:220950640,pointY:101686712,latitude:0,longitude:0,coordinatesString:116.317899,39.935612,116.317899,39.935596,pointCount:2,rect_height:0},pointCount:0,rect_height:16},{classType:MAPolyline,rect_x:220952032,rect_y:101686728,rect_width:16,pointX:220952048,pointY:101686728,latitude:39.934009552001953,longitude:116.31977844238281,coordinatesString:116.319788,39.935596,116.319766,39.934765,116.319766,39.933687,116.319766,39.933309,116.319766,39.932766,116.319788,39.932420,pointCount:6,rect_height:3088},{classType:MAPolyline,rect_x:220948016,rect_y:101689816,rect_width:4032,pointX:220952048,pointY:101689816,latitude:39.932407379150391,longitude:116.31708526611328,coordinatesString:116.319788,39.932420,116.316783,39.932412,116.314745,39.932412,116.314380,39.932395,pointCount:4,rect_height:24},{classType:MAPolyline,rect_x:220945536,rect_y:101689800,rect_width:2480,pointX:220948016,pointY:101689840,latitude:39.932415008544922,longitude:116.31271362304688,coordinatesString:116.314380,39.932395,116.314230,39.932428,116.312621,39.932420,116.311054,39.932437,pointCount:4,rect_height:40},{classType:MAPolyline,rect_x:220945072,rect_y:101689800,rect_width:464,pointX:220945536,pointY:101689800,latitude:39.932422637939453,longitude:116.31074523925781,coordinatesString:116.311054,39.932437,116.310711,39.932412,116.310432,39.932412,pointCount:3,rect_height:24},{classType:MAPolyline,rect_x:220944688,rect_y:101689960,rect_width:16,pointX:220944704,pointY:101689960,latitude:39.930961608886719,longitude:116.30992889404297,coordinatesString:116.309938,39.932272,116.309938,39.931260,116.309938,39.930273,116.309917,39.929648,pointCount:4,rect_height:2552},{classType:LineDashPolyline,rect_x:220944704,rect_y:101689824,rect_width:368,pointX:0,pointY:0,latitude:39.932342529296875,longitude:116.31018829345703,polyline:{classType:MAPolyline,rect_x:0,rect_y:0,rect_width:0,pointX:220945072,pointY:101689824,latitude:0,longitude:0,coordinatesString:116.310432,39.932412,116.309938,39.932272,pointCount:2,rect_height:0},pointCount:0,rect_height:136},{classType:MAPolyline,rect_x:220944688,rect_y:101692528,rect_width:224,pointX:220944688,pointY:101692528,latitude:39.914474487304688,longitude:116.31006622314453,coordinatesString:116.309917,39.929631,116.310110,39.928677,116.310110,39.927393,116.310153,39.923386,116.310153,39.918170,116.310174,39.912549,116.310196,39.909249,116.310196,39.907891,116.310196,39.906945,116.310196,39.905612,116.310217,39.903192,116.310217,39.900484,116.310217,39.899315,pointCount:13,rect_height:29472},{classType:LineDashPolyline,rect_x:220944688,rect_y:101692512,rect_width:0,pointX:0,pointY:0,latitude:39.929634094238281,longitude:116.30991363525391,polyline:{classType:MAPolyline,rect_x:0,rect_y:0,rect_width:0,pointX:220944688,pointY:101692512,latitude:0,longitude:0,coordinatesString:116.309917,39.929648,116.309917,39.929623,pointCount:2,rect_height:0},pointCount:0,rect_height:24},{classType:MAPolyline,rect_x:220944832,rect_y:101722008,rect_width:80,pointX:220944912,pointY:101722008,latitude:39.899166107177734,longitude:116.31016540527344,coordinatesString:116.310217,39.899307,116.310110,39.899027,pointCount:2,rect_height:272},{classType:LineDashPolyline,rect_x:220944912,rect_y:101722008,rect_width:0,pointX:0,pointY:0,latitude:39.899303436279297,longitude:116.31021881103516,polyline:{classType:MAPolyline,rect_x:0,rect_y:0,rect_width:0,pointX:220944912,pointY:101722008,latitude:0,longitude:0,coordinatesString:116.310217,39.899307,116.310217,39.899299,pointCount:2,rect_height:0},pointCount:0,rect_height:8},{classType:MAPolyline,rect_x:220944816,rect_y:101722288,rect_width:16,pointX:220944832,pointY:101722288,latitude:39.8978271484375,longitude:116.31009674072266,coordinatesString:116.310110,39.899019,116.310089,39.898575,116.310089,39.898048,116.310110,39.897323,116.310089,39.896632,pointCount:5,rect_height:2320},{classType:LineDashPolyline,rect_x:220944832,rect_y:101722280,rect_width:0,pointX:0,pointY:0,latitude:39.899017333984375,longitude:116.31011199951172,polyline:{classType:MAPolyline,rect_x:0,rect_y:0,rect_width:0,pointX:220944832,pointY:101722280,latitude:0,longitude:0,coordinatesString:116.310110,39.899027,116.310110,39.899011,pointCount:2,rect_height:0},pointCount:0,rect_height:16},{classType:MAPolyline,rect_x:220943136,rect_y:101724272,rect_width:4704,pointX:220944816,pointY:101724608,latitude:39.896686553955078,longitude:116.31098937988281,coordinatesString:116.310089,39.896632,116.309981,39.896492,116.309874,39.896426,116.309810,39.896418,116.308222,39.896393,116.308115,39.896410,116.307986,39.896451,116.307857,39.896541,116.307836,39.896607,116.307836,39.896714,116.307921,39.896830,116.308050,39.896912,116.308243,39.896961,116.312127,39.896969,116.313393,39.896969,116.314144,39.896978,pointCount:16,rect_height:568},{classType:MAPolyline,rect_x:220947840,rect_y:101724272,rect_width:9264,pointX:220947840,pointY:101724272,latitude:39.896903991699219,longitude:116.32035827636719,coordinatesString:116.314144,39.896978,116.314509,39.896838,116.315389,39.896830,116.316032,39.896838,116.316376,39.896846,116.318007,39.896854,116.319015,39.896854,116.319852,39.896854,116.322792,39.896871,116.323221,39.896871,116.323349,39.896871,116.324594,39.896871,116.324959,39.896871,116.325388,39.896879,116.325817,39.896879,116.325946,39.896879,116.326568,39.896887,pointCount:17,rect_height:144},{classType:MAPolyline,rect_x:220957104,rect_y:101724360,rect_width:1888,pointX:220957104,pointY:101724360,latitude:39.896858215332031,longitude:116.32783508300781,coordinatesString:116.326568,39.896887,116.326783,39.896846,116.327126,39.896830,116.328564,39.896838,116.329100,39.896846,pointCount:5,rect_height:56},{classType:MAPolyline,rect_x:220958992,rect_y:101724400,rect_width:64,pointX:220958992,pointY:101724400,latitude:39.895393371582031,longitude:116.32913970947266,coordinatesString:116.329100,39.896846,116.329186,39.893940,pointCount:2,rect_height:2824},{classType:MAPolyline,rect_x:220956624,rect_y:101727232,rect_width:2432,pointX:220959056,pointY:101727232,latitude:39.893653869628906,longitude:116.32755279541016,coordinatesString:116.329186,39.893932,116.329165,39.893842,116.329122,39.893735,116.329079,39.893636,116.329057,39.893586,116.328950,39.893512,116.328886,39.893479,116.328757,39.893422,116.328585,39.893397,116.328263,39.893397,116.327190,39.893381,116.327040,39.893372,116.326139,39.893372,116.326096,39.893372,116.325924,39.893372,pointCount:15,rect_height:544},{classType:LineDashPolyline,rect_x:220959056,rect_y:101727224,rect_width:0,pointX:0,pointY:0,latitude:39.893932342529297,longitude:116.32918548583984,polyline:{classType:MAPolyline,rect_x:0,rect_y:0,rect_width:0,pointX:220959056,pointY:101727224,latitude:0,longitude:0,coordinatesString:116.329186,39.893940,116.329186,39.893924,pointCount:2,rect_height:0},pointCount:0,rect_height:16},{classType:MAPolyline,rect_x:220956384,rect_y:101727512,rect_width:240,pointX:220956624,pointY:101727776,latitude:39.893508911132812,longitude:116.32575988769531,coordinatesString:116.325924,39.893372,116.325839,39.893430,116.325774,39.893521,116.325603,39.893644,pointCount:4,rect_height:264},{classType:MAPolyline,rect_x:220956320,rect_y:101727024,rect_width:144,pointX:220956384,pointY:101727512,latitude:39.893894195556641,longitude:116.32561492919922,coordinatesString:116.325603,39.893644,116.325538,39.893751,116.325517,39.893874,116.325560,39.893990,116.325710,39.894146,pointCount:5,rect_height:488}]


@end
