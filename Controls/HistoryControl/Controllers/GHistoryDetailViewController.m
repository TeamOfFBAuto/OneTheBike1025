//
//  GHistoryDetailViewController.m
//  OneTheBike
//
//  Created by gaomeng on 14/10/28.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "GHistoryDetailViewController.h"

@interface GHistoryDetailViewController ()
@property (nonatomic, strong) NSMutableArray *overlays;
@end

@implementation GHistoryDetailViewController

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
    
    UILabel *titielLabel = [[UILabel alloc]initWithFrame:CGRectMake(140, 5, 35, 35)];
    titielLabel.textColor = [UIColor whiteColor];
    titielLabel.textAlignment = NSTextAlignmentCenter;
    titielLabel.text = @"历史";
    [shangGrayView addSubview:titielLabel];
    
    //返回按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"backButton.png"] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(5, 0, 35, 35)];
    [btn addTarget:self action:@selector(gGoBackVc) forControlEvents:UIControlEventTouchUpInside];
    [shangGrayView addSubview:btn];
    [self.view addSubview:shangGrayView];
    
    
    
    [self initMap];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




///初始化地图
-(void)initMap{
    //地图相关初始化
    self.mapView = [[MAMapView alloc]initWithFrame:CGRectMake(0, 55, 320, iPhone5?568:480)];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    self.mapView.showsUserLocation = NO;//关闭定位
    
    self.mapView.customizeUserLocationAccuracyCircleRepresentation = YES;//自定义定位样式
    self.mapView.userTrackingMode = MAUserTrackingModeNone;//定位模式
    
    self.mapView.showsCompass= NO;//开启指南针
    self.mapView.compassOrigin= CGPointMake(280, 10); //设置指南针位置
    
    self.mapView.showsScale= NO; //关闭比例尺
    self.mapView.scaleOrigin = CGPointMake(10, 70);
    
    
    [self.mapView addOverlays:self.overlays];//把线条添加到地图上
    
}



-(void)gGoBackVc{
    [self.navigationController popViewControllerAnimated:YES];
}



@end
