//
//  AppDelegate.m
//  OneTheBike
//
//  Created by szk on 14-9-24.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "AppDelegate.h"

#import "MainViewController.h"


#import "StartViewController.h"

#import "FindViewController.h"

#import "MineViewController.h"

#import "RootViewController.h"

#import "GhistoryViewController.h"


/*
 第三方登录
 Q Q 2765869240
 邮箱 2765869240@qq.com
 */
#import "UMSocial.h"

#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaHandler.h"

#import "UMSocialTencentWeiboHandler.h"

#define UmengAppkey @"5423e48cfd98c58eed00664f"

//骑叭
#define SinaAppKey @"2470821654"
#define SinaAppSecret @"bea7d21c9647406a25960a617a8e40a8"

////fbauto
//#define SinaAppKey @"2437553400"
//#define SinaAppSecret @"7379cf0aa245ba45a66cc7c9ae9b1dba"

//bike
#define QQAPPID @"1103196390" //十六进制:41C170E6; 生成方法:echo 'ibase=10;obase=16;1103196390'|bc
#define QQAPPKEY @"zc8ykXXrvWjKpyuh"

//fbauto
#define WXAPPID @"wx10280ad0d507a8933b9d"
#define WXAPPSECRET @"SADSDAS"

#define RedirectUrl @"http://sns.whalecloud.com/sina2/callback"

//人人网
#define REN_APPID @"272107"
#define REN_APIKEY @"8399387c4fe34861b73585d5f99d93c4"
#define REN_SecretKey @"1762208535a047e18bd0799b7a21b7ab"

//腾讯微博

#define TENCENT_APPKEY @"801549982"
#define TENCENT_APPSECRET @"4305f299c4774e5c80d4582ef4128928"

//高德地图
#import <MAMapKit/MAMapKit.h>


//运动vc 开始vc
#import "GStartViewController.h"


@interface AppDelegate ()<CLLocationManagerDelegate,UITabBarControllerDelegate,UIAlertViewDelegate>
{
    //IOS8 定位
    UINavigationController *_navController;
    CLLocationManager      *_locationmanager;
    
    //开始按钮的tabbarItem
    NSString *_star_p_str;
    
    //定位开始画线点击返回 修改开始的按钮为停止
    UINavigationController * _navc3;
    //是否正在定位画线
    BOOL _isStart;//用于判断是否点击开始弹出alertview  开始定位后点击返回的时候值为yes 点击完成按钮后值为no
    
    //骑行完成后tabbar调到历史标签
    RootViewController * _tabbarVC;
    
    
    GStartViewController * mainVC;
    
     
}
@end


@implementation AppDelegate




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    mainVC = [[GStartViewController alloc] init];
    
//    HistoryViewController * microBBSVC = [[HistoryViewController alloc] init];//带网络数据的
    GhistoryViewController *microBBSVC = [[GhistoryViewController alloc]init];
    
    StartViewController * messageVC = [[StartViewController alloc] init];
    
    FindViewController * foundVC = [[FindViewController alloc] init];
    
    MineViewController * mineVC = [[MineViewController alloc] init];
    
    UINavigationController * navc1 = [[UINavigationController alloc] initWithRootViewController:mainVC];
    
    UINavigationController * navc2 = [[UINavigationController alloc] initWithRootViewController:microBBSVC];
    
    _navc3 = [[UINavigationController alloc] initWithRootViewController:messageVC];
    
    _star_p_str = [NSString stringWithFormat:@"%@",_navc3];
    
    NSLog(@"%@",_star_p_str);
    
    UINavigationController * navc4 = [[UINavigationController alloc] initWithRootViewController:foundVC];
    
    UINavigationController * navc5 = [[UINavigationController alloc] initWithRootViewController:mineVC];
    
    
    navc1.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"运动" image:[UIImage imageNamed:@"bike.png"] selectedImage:[UIImage imageNamed:@"bike.png"]];
    
    navc2.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"历史" image:[UIImage imageNamed:@"history.png"] selectedImage:[UIImage imageNamed:@"history.png"]];
    
    _navc3.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"开始" image:[UIImage imageNamed:@"start.png"] selectedImage:[UIImage imageNamed:@"start.png"]];
    
    navc4.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"发现" image:[UIImage imageNamed:@"find.png"] selectedImage:[UIImage imageNamed:@"find.png"]];
    
    navc5.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的" image:[UIImage imageNamed:@"mine.png"] selectedImage:[UIImage imageNamed:@"mine.png"]];
    
    
    _tabbarVC = [[RootViewController alloc] init];
    
    _tabbarVC.viewControllers = [NSArray arrayWithObjects:navc1,navc2,_navc3,navc4,navc5,nil];
    _tabbarVC.delegate = self;
    
    _tabbarVC.selectedIndex = 0;
    
      _tabbarVC.tabBar.tintColor=[UIColor redColor];
    
    
    _tabbarVC.tabBar.backgroundImage = [UIImage imageNamed:@""];
    
    
//    [MobClick startWithAppkey:@"5368ab4256240b6925029e29"];
    
    //微信
    
    //友盟第三方登录分享
    [self umengShare];
    
    
    
    //高德地图
    [self configureAPIKey];
    [UIApplication sharedApplication].idleTimerDisabled = TRUE;
    
    _locationmanager = [[CLLocationManager alloc] init];
    
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=8.0)) {
        [_locationmanager requestAlwaysAuthorization];        //NSLocationAlwaysUsageDescription
        [_locationmanager requestWhenInUseAuthorization];     //NSLocationWhenInUseDescription
    }
    
    
    _locationmanager.delegate = self;
    
    
    
//    UIDevice* device = [UIDevice currentDevice];
//    BOOL backgroundSupported = NO;
//    if ([device respondsToSelector:@selector(isMultitaskingSupported)]){
//        backgroundSupported = device.multitaskingSupported;
//    }
    
    
    
    self.window.rootViewController = _tabbarVC;
    
    
    
    
    //开始定位画线点击返回按钮 tabbar的开始按钮变成停止
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gKeepStart) name:@"gkeepstarting" object:nil];
    _isStart = NO;
    
    //停止并保存
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gStopAndSave) name:@"gstopandsave" object:nil];
    
    //停止不保存
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gStopAndNoSave) name:@"gstopandnosave" object:nil];
    
    
    return YES;
}



#pragma mark - 停止并保存
-(void)gStopAndSave{
    _isStart = NO;
    [_navc3.tabBarItem setImage:[UIImage imageNamed:@"start.png"]];
    [_navc3.tabBarItem setTitle:@"开始"];
    _tabbarVC.selectedIndex = 1;
    
}

#pragma mark - 停止不保存
-(void)gStopAndNoSave{
    _isStart = NO;
    [_navc3.tabBarItem setImage:[UIImage imageNamed:@"start.png"]];
    [_navc3.tabBarItem setTitle:@"开始"];
}


#pragma mark - 开始后点击返回按钮
-(void)gKeepStart{
    _isStart = YES;
    [_navc3.tabBarItem setImage:[UIImage imageNamed:@"gqixingzhong.png"]];
    [_navc3.tabBarItem setImageInsets:UIEdgeInsetsMake(-2, 0, 2, 0)];
    [_navc3.tabBarItem setTitle:@"骑行中"];
    
    
}

#pragma mark - tabar按钮即将点击的代理方法 返回no不会跳转vc
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    
    NSString *_vc_p_str = [NSString stringWithFormat:@"%@",viewController];
    if ([_vc_p_str isEqualToString:_star_p_str]) {
        tabBarController.selectedIndex = 0;
        if (!_isStart) {
            UIAlertView *al  = [[UIAlertView alloc]initWithTitle:@"是否开始运动" message:nil delegate:self cancelButtonTitle:@"撤销" otherButtonTitles:@"确定", nil];
            al.tag = 3;
            [al show];
        }else{
            [[NSNotificationCenter defaultCenter]postNotificationName:@"GToGstar" object:nil];
        }
        
        
        return NO;
    }
    
    
    return YES;
    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%d",buttonIndex);
    if (!_isStart) {//还没有开始运动
        if (alertView.tag == 3) {//开始按钮的alert
            if (buttonIndex == 1) {//点击的是确定
                _isStart = YES;
                [[NSNotificationCenter defaultCenter]postNotificationName:@"GToGstar" object:nil];
            }else if (buttonIndex == 0){//取消
                
            }
            
        }
    }
    
}



- (void)configureAPIKey
{
    
    
    if ([APIKey_MAP length] == 0)
    {
#define kMALogTitle @"提示"
#define kMALogContent @"0b92a81f23cc5905c30dcb4c39da609d"
        
        NSString *log = [NSString stringWithFormat:@"[MAMapKit] %@", kMALogContent];
        NSLog(@"%@", log);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kMALogTitle message:kMALogContent delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [alert show];
        });
    }
    
    [MAMapServices sharedServices].apiKey = (NSString *)APIKey_MAP;
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
//    [_locationmanager startUpdatingLocation];
    [self backgroundHandler];
    
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.fblife.OneTheBike" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"OneTheBike" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"OneTheBike.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


/**
 这里处理新浪微博SSO授权之后跳转回来，和微信分享完成之后跳转回来
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    return  [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
}

/**
 这里处理新浪微博SSO授权进入新浪微博客户端后进入后台，再返回原来应用
 */
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [UMSocialSnsService  applicationDidBecomeActive];
}


#pragma mark - 友盟分享

- (void)umengShare
{
    [UMSocialData setAppKey:UmengAppkey];
    
    //打开调试log的开关
    [UMSocialData openLog:YES];
    
    //打开新浪微博的SSO开关
    [UMSocialSinaHandler openSSOWithRedirectURL:RedirectUrl];
    
    //设置分享到QQ空间的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:QQAPPID appKey:QQAPPKEY url:@"http://www.umeng.com/social"];
    
    //设置支持没有客户端情况下使用SSO授权
    [UMSocialQQHandler setSupportWebView:YES];
    
    //设置微信AppId，设置分享url，默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:WXAPPID appSecret:WXAPPSECRET url:@"http://www.umeng.com/social"];
    
    [UMSocialTencentWeiboHandler openSSOWithRedirectUrl:@"http://sns.whalecloud.com/tencent2/callback"];

}




- (void)backgroundHandler {
    
//    self.loca.locationSpace = YES; //这个属性设置再后台定位的时间间隔 自己在定位类中加个定时器就行了
    
    UIApplication * app = [UIApplication sharedApplication];
    
    //声明一个任务标记 可在.h中声明为全局的  __block    UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid) {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
        
    }];
    
    // 开始执行长时间后台执行的任务 项目中启动后定位就开始了 这里不需要再去执行定位 可根据自己的项目做执行任务调整
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        while (1) {

            if (mainVC.mapView.showsUserLocation == YES) {
                mainVC.mapView.showsUserLocation = YES;
            }
            
            sleep(1);
        }
        
    });
}



@end
