//
//  GHistoryDetailViewController.h
//  OneTheBike
//
//  Created by gaomeng on 14/10/28.
//  Copyright (c) 2014年 szk. All rights reserved.
//




//历史界面点击某个历史跳转到的详细历史界面

#import <UIKit/UIKit.h>

@interface GHistoryDetailViewController : UIViewController<MAMapViewDelegate>



@property (nonatomic, strong) MAMapView *mapView;

@end
