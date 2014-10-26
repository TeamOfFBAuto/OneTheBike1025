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
    
    UIButton *settings=[[UIButton alloc]initWithFrame:CGRectMake(20,7.5,40,40)];
    [settings addTarget:self action:@selector(clickToSave:) forControlEvents:UIControlEventTouchUpInside];
    [settings setTitle:@"保存" forState:UIControlStateNormal];
//    [settings setImage:[UIImage imageNamed:@"road_save"] forState:UIControlStateNormal];
    [settings.titleLabel setFont:[UIFont systemFontOfSize:12]];
    settings.layer.cornerRadius = 3.f;
//    [settings setBackgroundColor:[UIColor colorWithHexString:@"bebebe"]];
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
    centerImage.center = CGPointMake(aSize.width / 2.f, aSize.height / 2.f - 64);
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
   
    UIView *tools = [[UIView alloc]initWithFrame:CGRectMake(0, screenSize.height - 50 - 20 - 64, screenSize.width, 50)];
    tools.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tools];
//    NSArray *titls_arr = @[@"取消",@"起",@"途",@"终",@"生成"];
    
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


@end
