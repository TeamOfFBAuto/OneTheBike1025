//
//  GMapStarViewController.h
//  OneTheBike
//
//  Created by gaomeng on 14/10/18.
//  Copyright (c) 2014年 szk. All rights reserved.
//

//系统自带地图画线
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GMapStarViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate>
{
    // the map view
    MKMapView* _mapView;
    
    // routes points
    NSMutableArray* _points;
    
    // the data representing the route points.
    MKPolyline* _routeLine;
    
    // the view we create for the line on the map
    MKPolylineView* _routeLineView;
    
    // the rect that bounds the loaded points
    MKMapRect _routeRect;
    
    // location manager
    CLLocationManager* _locationManager;
    
    // current location
    CLLocation* _currentLocation;
    
    //IOS8 定位
    UINavigationController *_navController;
    CLLocationManager      *_locationmanager;
    
}

@property (nonatomic, retain) MKMapView* mapView;
@property (nonatomic, retain) NSMutableArray* points;
@property (nonatomic, retain) MKPolyline* routeLine;
@property (nonatomic, retain) MKPolylineView* routeLineView;
@property (nonatomic, retain) CLLocationManager* locationManager;

-(void) configureRoutes;



@end
