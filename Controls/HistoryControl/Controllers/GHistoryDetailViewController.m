//
//  GHistoryDetailViewController.m
//  OneTheBike
//
//  Created by gaomeng on 14/10/28.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "GHistoryDetailViewController.h"
#import "ShareView.h"

@interface GHistoryDetailViewController ()<UITableViewDataSource,UITableViewDelegate,ShareViewDelegate>
@property (nonatomic, strong) NSMutableArray *overlays;
@end

@implementation GHistoryDetailViewController






-(void)dealloc{
    [self returnAction];
}


#pragma mark - 地图相关内存管理 点击返回按钮vc释放的时候走
- (void)returnAction
{
    [self clearMapView];
    
    
    
    self.mapView.userTrackingMode  = MAUserTrackingModeNone;
    
//    [self.mapView removeObserver:self forKeyPath:@"showsUserLocation"];
    
}
- (void)clearMapView
{
    self.mapView.showsUserLocation = NO;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView removeOverlays:self.mapView.overlays];
    
    self.mapView.delegate = nil;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    
    
    
    
    if ([[[UIDevice currentDevice]systemVersion]doubleValue] >=7.0) {
        self.navigationController.navigationBar.translucent = NO;
    }
    
    
    //自定义导航栏
    UIView *shangGrayView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, 320, 35)];
    shangGrayView.backgroundColor = RGBCOLOR(105, 105, 105);
    
    UILabel *titielLabel = [[UILabel alloc]initWithFrame:CGRectMake(130, 3, 60, 30)];
    titielLabel.font = [UIFont systemFontOfSize:16];
    titielLabel.textColor = [UIColor whiteColor];
    titielLabel.textAlignment = NSTextAlignmentCenter;
    titielLabel.text = @"详细";
    [shangGrayView addSubview:titielLabel];
    
    
    //分享
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn setImage:[UIImage imageNamed:@"ghistoryShare.png"] forState:UIControlStateNormal];
    
    [shareBtn addTarget:self action:@selector(gshare) forControlEvents:UIControlEventTouchUpInside];
    
    shareBtn.frame = CGRectMake(270, 3, 30, 30);
    [shangGrayView addSubview:shareBtn];
    
    
    //返回按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"backButton.png"] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(5, 0, 35, 35)];
    [btn addTarget:self action:@selector(gGoBackVc) forControlEvents:UIControlEventTouchUpInside];
    [shangGrayView addSubview:btn];
    [self.view addSubview:shangGrayView];
    
    
    
    [self initMap];
    
    [self showRoadLineInMapViewWith:self.passModel];
    
    
    [self customTabelView];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)gshare
{
    ShareView * share_view = [[ShareView alloc] initWithFrame:self.view.bounds];
    share_view.userInteractionEnabled = YES;
    share_view.delegate = self;
    share_view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [share_view showInView:[UIApplication sharedApplication].keyWindow WithAnimation:YES];
}



-(void)customTabelView{
    
    
    _imageArray = @[[UIImage imageNamed:@"gtime.png"],[UIImage imageNamed:@"gpodu.png"],[UIImage imageNamed:@"gpeisu.png"],[UIImage imageNamed:@"gpashenglv"],[UIImage imageNamed:@"ghaibashang.png"],[UIImage imageNamed:@"ghaibaxia.png"],[UIImage imageNamed:@"gpingjunsudu.png"],[UIImage imageNamed:@"gzuigaosudu.png"],[UIImage imageNamed:@"gongli.png"],[UIImage imageNamed:@"ghaiba.png"],[UIImage imageNamed:@"gbpm.png"]];
    _titleArray = @[@"时间",@"坡度",@"配速",@"爬升率",@"海拔上升",@"海拔下降",@"平均速度",@"最高速度",@"距离",@"当前海拔",@"卡路里"];
    
    
    
    
    UIView *tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.mapView.frame), 320, 30)];
    tableHeaderView.backgroundColor = RGBCOLOR(105, 105, 105);
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 80, 20)];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.text = @"运动信息";
    titleLabel.textColor = [UIColor whiteColor];
    [tableHeaderView addSubview:titleLabel];
    [self.view addSubview:tableHeaderView];
    
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(tableHeaderView.frame), 320, iPhone5?568-35-64-30:480-35-64-30) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    
    
    //图标
    UIImageView *titleImv = [[UIImageView alloc]initWithFrame:CGRectMake(20, 15, 25, 25)];
    [titleImv setImage:_imageArray[indexPath.row]];
    [cell.contentView addSubview:titleImv];
    
    //标题
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(titleImv.frame)+5, titleImv.frame.origin.y, 60, 25)];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textColor = RGBCOLOR(190, 190, 190);
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text = _titleArray[indexPath.row];
    [cell.contentView addSubview:titleLabel];
    
    //内容
    UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame)+60, titleImv.frame.origin.y, 130, 25)];
    contentLabel.font = [UIFont systemFontOfSize:15];
    contentLabel.textColor = RGBCOLOR(190, 190, 190);
    contentLabel.textAlignment = NSTextAlignmentRight;
    [cell.contentView addSubview:contentLabel];
    
    
    
    //调试颜色
    //    titleLabel.backgroundColor = [UIColor grayColor];
    //    contentLabel.backgroundColor = [UIColor orangeColor];
    
    
    
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 11;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


///初始化地图
-(void)initMap{
    //地图相关初始化
    self.mapView = [[MAMapView alloc]initWithFrame:CGRectMake(0, 55, 320, iPhone5?250:200)];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    self.mapView.showsUserLocation = NO;//关闭定位

    
    self.mapView.showsCompass= NO;//开启指南针
    self.mapView.compassOrigin= CGPointMake(280, 10); //设置指南针位置
    
    self.mapView.showsScale= NO; //关闭比例尺
    self.mapView.scaleOrigin = CGPointMake(10, 70);
    

    
    
    
    
    //把轨迹加到地图上
    [self showRoadLineInMapViewWith:self.passModel];
}




- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id <MAOverlay>)overlay
{
    
    
    
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    
    MAOverlayPathView* overlayView = nil;
    
    
#pragma 路书================
    if ([overlay isKindOfClass:[LineDashPolyline class]])
    {
        MAPolylineView *overlayView = [[MAPolylineView alloc] initWithPolyline:((LineDashPolyline *)overlay).polyline];
        
        overlayView.lineWidth    = 5.f;
        overlayView.strokeColor  = [UIColor greenColor];
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
    
    
    
    return overlayView;
    
    
    
    
    return nil;
}




- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    
#pragma - mark - 路书===============
    
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
        if ([[annotation title] isEqualToString:NavigationViewControllerStartTitle])
        {
            poiAnnotationView.image = [UIImage imageNamed:@"road_start"];
        }
        /* 终点. */
        else if([[annotation title] isEqualToString:NavigationViewControllerDestinationTitle])
        {
            poiAnnotationView.image = [UIImage imageNamed:@"road_end"];
        }
        /* 途经点. */
        else if([[annotation title] isEqualToString:NavigationViewControllerMiddleTitle])
        {
            poiAnnotationView.image = [UIImage imageNamed:@"road_middle"];
        }
        
        return poiAnnotationView;
    }
    
    
    
    
    return nil;
}






#pragma mark - 把路书添加到地图上



-(void)showRoadLineInMapViewWith:(GyundongCanshuModel*)model{
    
    NSLog(@"jsonStr %@",model.jsonStr);
    NSLog(@"起点 %@",model.startCoorStr);
    NSLog(@"终点 %@",model.coorStr);
    
    NSArray *arr = [model.jsonStr objectFromJSONString];
    
    CLLocationCoordinate2D start;
    NSArray *a = [model.startCoorStr componentsSeparatedByString:@","];
    NSString *lat = a[0];
    NSString *lon = a[1];
    start = CLLocationCoordinate2DMake([lat doubleValue], [lon doubleValue]);
    
    CLLocationCoordinate2D end;
    NSArray *b = [model.coorStr componentsSeparatedByString:@","];
    NSString *blat = b[0];
    NSString *blon = b[1];
    end = CLLocationCoordinate2DMake([blat doubleValue], [blon doubleValue]);
    
    if (0) {
        return;
    }
    
    NSDictionary *history_dic = [LMapTools parseMapHistoryMap:arr];
    
    self.lines = [history_dic objectForKey:L_POLINES];
    
    self.startCoordinate = start;
    [self addStartAnnotation];
    
    self.destinationCoordinate = end;
    [self addDestinationAnnotation];
    
    [self.mapView addOverlays:self.lines];
    
    [self.mapView setCenterCoordinate:self.startCoordinate animated:YES];
    
    
    
}




//起点
- (void)addStartAnnotation
{
    if (startAnnotation) {
        
        [self.mapView removeAnnotation:startAnnotation];
    }
    
    startAnnotation = [[MAPointAnnotation alloc] init];
    startAnnotation.coordinate = self.startCoordinate;
    startAnnotation.title      = NavigationViewControllerStartTitle;
    startAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", self.startCoordinate.latitude, self.startCoordinate.longitude];
    [self.mapView addAnnotation:startAnnotation];
}
- (void)removeStartAnnotation
{
    [self.mapView removeAnnotation:startAnnotation];
    
    self.startCoordinate = CLLocationCoordinate2DMake(0, 0);
    
    [self removeAllPolines];
}

- (void)removeAllPolines
{
    if (middleAnntations.count == 0 && self.startCoordinate.latitude == 0 && self.destinationCoordinate.latitude == 0){
        
        [self.mapView removeAnnotations:self.mapView.annotations];
        
        [self.mapView removeOverlays:self.mapView.overlays];
    }
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





-(void)gGoBackVc{
    [self.navigationController popViewControllerAnimated:YES];
}



@end
