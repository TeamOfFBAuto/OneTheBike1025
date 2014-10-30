//
//  GStartViewController.m
//  OneTheBike
//
//  Created by gaomeng on 14-10-13.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "GStartViewController.h"
#import "LoginViewController.h"


@interface GStartViewController ()<UIActionSheetDelegate>


@end

@implementation GStartViewController

- (void)dealloc
{
    [self returnAction];
    
}


-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    [super viewWillAppear:animated];
    
    BOOL state = [[NSUserDefaults standardUserDefaults]boolForKey:LOGIN_STATE];
    
    if (state == YES) {
        return;
    }
    
    [self loginView];
}

- (void)loginView
{
    LoginViewController *login = [[LoginViewController alloc]init];
    [self presentViewController:login animated:NO completion:^{
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.gYunDongCanShuModel = [[GyundongCanshuModel alloc]init];
#pragma mark - 接受通知隐藏tabbar
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(iWantToStart) name:@"GToGstar" object:nil];
    
#pragma mark - 从路书跳转过来的通知
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(newBilityXiaoPang:) name:NOTIFICATION_ROAD_LINES object:nil];
    
    _isTimeOutClicked = NO;
    _distance = 0.0f;
    _isFirstStartCanshu = NO;
    
    self.lines = [NSArray array];
    
    self.routeLineArray = [NSMutableArray arrayWithCapacity:1];
    
    
    [self initMap];//初始化地图
    [self initMapUpView];//初始化地图上面的view
    
    [self initTopWhiteAndGrayView];//状态栏和灰条g
    
    [self initFourBtn];//地图上4个btn
    
    [self initStartDownView];//初始化地图下面的view
    
    _points = [NSMutableArray arrayWithCapacity:10];
    
    
    
    //计时器
    timerMin = 0 ;
    timerSecond = 0;
    
    splitTimerMin = 0;
    splitTimerSecond = 0;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:(1)
                                             target:self
                                           selector:@selector(taktCounter)
                                           userInfo:nil
                                            repeats:TRUE];
    NSRunLoop *main = [NSRunLoop currentRunLoop];
    [main addTimer:timer forMode:NSRunLoopCommonModes];
    
    
    
    _localTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(localTimeModel) userInfo:nil repeats:TRUE];
    [main addTimer:_localTimer forMode:NSRunLoopCommonModes];
    
    
    
    
//    [self initHistoryMap];//显示路书
    
}

//给model对象赋值本地时间
-(void)localTimeModel{
    
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    
    NSString *localeDateStr = [[NSString stringWithFormat:@"%@",localeDate] substringWithRange:NSMakeRange(11, 8)];
    self.gYunDongCanShuModel.localTimeLabel.text = localeDateStr;
    
    _saveViewTag55View.contentLable.text = self.gYunDongCanShuModel.localTimeLabel.text;
    
}


//初始化上面灰条和状态栏白条
-(void)initTopWhiteAndGrayView{
    
    //白条
    UIView *baitiaoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 20)];
    baitiaoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:baitiaoView];
    
    
    //灰条
    UIView *shangGrayView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, 320, 44)];
    shangGrayView.backgroundColor = RGBCOLOR(105, 105, 105);
    //方向
    _fangxiangLabel = [[UILabel alloc]initWithFrame:CGRectMake(250, 5, 50, 30)];
    _fangxiangLabel.font = [UIFont systemFontOfSize:13];
    _fangxiangLabel.textColor = [UIColor whiteColor];
    _fangxiangLabel.textAlignment = NSTextAlignmentCenter;
    //标题
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 6, 50, 30)];
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"骑叭";
    
    [shangGrayView addSubview:titleLabel];
    [shangGrayView addSubview:_fangxiangLabel];
    [self.view addSubview:shangGrayView];
    shangGrayView.tag = 50;
}




///初始化地图上方view
-(void)initMapUpView{
    //地图上面的view
    _isUpViewShow = YES;
    _upview = [[UIView alloc]initWithFrame:FRAME_IPHONE5_UPVIEW_DOWN];
    _upview.backgroundColor = [UIColor whiteColor];
    //调试颜色
//    _upview.backgroundColor = [UIColor orangeColor];
    
    //上下按钮
    _upOrDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _upOrDownBtn.layer.cornerRadius = 15;
    _upOrDownBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_upOrDownBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_upOrDownBtn setTitle:@"up" forState:UIControlStateNormal];
    [_upOrDownBtn setFrame:CGRectMake(145, 210, 30, 30)];
    [_upOrDownBtn setImage:[UIImage imageNamed:@"gbtnup.png"] forState:UIControlStateNormal];
    [_upOrDownBtn addTarget:self action:@selector(gShou) forControlEvents:UIControlEventTouchUpInside];
    
    //创建上下左右四个自定义view 并加到数组里
    _dingView = [[GyundongCustomView alloc]initWithFrame:CGRectMake(0, 35, 320, 65)];
    _zuoshangView = [[GyundongCustomView alloc]initWithFrame:CGRectMake(0, 100, 160, 65)];
    _youshangView = [[GyundongCustomView alloc]initWithFrame:CGRectMake(160, 100, 160, 65)];
    _zuoxiaView = [[GyundongCustomView alloc]initWithFrame:CGRectMake(0, 165, 160, 65)];
    _youxiaView = [[GyundongCustomView alloc]initWithFrame:CGRectMake(160, 165, 160, 65)];
    
    //调试颜色
//    _zuoshangView.backgroundColor = [UIColor yellowColor];
//    _youshangView.backgroundColor = [UIColor lightGrayColor];
//    _zuoxiaView.backgroundColor = [UIColor greenColor];
//    _youxiaView.backgroundColor = [UIColor purpleColor];
    
    
    
    
    
    
    
    //图标数组
    NSArray *titleImageArr = @[[UIImage imageNamed:@"gspeed.png"],[UIImage imageNamed:@"gstartime.png"],[UIImage imageNamed:@"gongli.png"],[UIImage imageNamed:@"ghaiba.png"],[UIImage imageNamed:@"gbpm.png"]];
    
    for (int i = 0; i<6; i++) {
        
        //手势
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gChooseCanshu:)];
        
        //图标
        UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectZero];
        if (i>0) {
            [imv setImage:titleImageArr[i-1]];
        }
        
        //内容label
        
        if (i == 0) {//上面灰条
            
            
        }else if (i == 1){//公里/时 顶 tag 51
            
            
            
            _dingView.tag = 51;
            [_dingView addGestureRecognizer:tap];
            _dingView.line.frame = CGRectMake(0, 64, 320, 1);
            [_dingView.titleImv setImage:titleImageArr[i-1]];
            _dingView.titleImv.frame = CGRectMake(50, 20, 30, 30);
            
            //内容label
            _dingView.contentLable.frame = CGRectMake(CGRectGetMaxX(_dingView.titleImv.frame)+5, _dingView.titleImv.frame.origin.y-5, 92, 35);
//            _dingView.contentLable.backgroundColor = [UIColor redColor];
            
            _dingView.contentLable.text = @"0.0";
            _dingView.contentLable.textAlignment = NSTextAlignmentRight;//只有这里设置居中
            
            //计量单位
            _dingView.danweiLabel.frame = CGRectMake(CGRectGetMaxX(_dingView.contentLable.frame)+5, _dingView.contentLable.frame.origin.y+5, 70, 30);
            _dingView.danweiLabel.text = @"km/h";
            _dingView.viewTypeStr = @"速度";
            
            
            
            
        }else if (i == 2){//计时 左上 tag 52
            
            
            _zuoshangView.tag = 52;
            
            [_zuoshangView addGestureRecognizer:tap];
            _zuoshangView.line.frame = CGRectMake(0, 64, 160, 1);
            _zuoshangView.line1.frame = CGRectMake(159, 0, 1, 65);
            _zuoshangView.titleImv.frame = CGRectMake(7, 20, 30, 30);
            [_zuoshangView.titleImv setImage:titleImageArr[i-1]];
            
            //内容label
            _zuoshangView.contentLable.frame = CGRectMake(CGRectGetMaxX(_zuoshangView.titleImv.frame), _zuoshangView.titleImv.frame.origin.y-5, 100, 35);
            _zuoshangView.contentLable.text = @"00:00:00";
            
            
            _zuoshangView.viewTypeStr = @"计时";
            
            
            
        }else if (i == 3){//公里 右上
            
            
            _youshangView.tag = 53;
            
            [_youshangView addGestureRecognizer:tap];
            _youshangView.line.frame = CGRectMake(0, 64, 160, 1);
            _youshangView.titleImv.frame = CGRectMake(7, 20, 30, 30);
            
            //内容label
            _youshangView.contentLable.frame = CGRectMake(CGRectGetMaxX(_youshangView.titleImv.frame), _youshangView.titleImv.frame.origin.y-5, 70, 35);
            
            _youshangView.contentLable.text = @"0.0";
            
            //计量单位
            _youshangView.danweiLabel.frame = CGRectMake(CGRectGetMaxX(_youshangView.contentLable.frame)+4, _youshangView.titleImv.frame.origin.y, 50, 30);
            _youshangView.danweiLabel.text = @"km";
            
            [_youshangView.titleImv setImage:titleImageArr[i-1]];
            
            _youshangView.viewTypeStr = @"距离";
            
        }else if (i == 4){//海拔 左下
            
            
            _zuoxiaView.tag = 54;
            [_zuoxiaView addGestureRecognizer:tap];
            _zuoxiaView.line.frame = CGRectMake(0, 64, 160, 1);
            _zuoxiaView.line1.frame = CGRectMake(159, 0, 1, 65);
            _zuoxiaView.titleImv.frame = CGRectMake(7, 20, 30, 30);
            [_zuoxiaView.titleImv setImage:titleImageArr[i-1]];
            
            _zuoxiaView.contentLable.frame = CGRectMake(CGRectGetMaxX(_zuoxiaView.titleImv.frame), _zuoxiaView.titleImv.frame.origin.y-5, 70, 35);
            _zuoxiaView.contentLable.text = @"0";
            
            
            _zuoxiaView.danweiLabel.frame = CGRectMake(CGRectGetMaxX(_zuoxiaView.contentLable.frame)+4, _zuoxiaView.titleImv.frame.origin.y, 50, 30);
            _zuoxiaView.danweiLabel.text = @"米";
            [_zuoxiaView addSubview:_zuoxiaView.danweiLabel];
            
            _zuoxiaView.viewTypeStr = @"海拔";
            
        }else if (i == 5){//bpm 右下
            
            _youxiaView.tag = 55;
            [_youxiaView addGestureRecognizer:tap];
            _youxiaView.line.frame = CGRectMake(0, 64, 160, 1);
            _youxiaView.titleImv.frame = CGRectMake(7, 20, 30, 30);
            [_youxiaView.titleImv setImage:titleImageArr[i-1]];
            
            _youxiaView.contentLable.frame =CGRectMake(CGRectGetMaxX(_youxiaView.titleImv.frame), _youxiaView.titleImv.frame.origin.y-5, 70, 35);
            _youxiaView.contentLable.text = @"0";
            
            
            _youxiaView.danweiLabel.frame = CGRectMake(CGRectGetMaxX(_youxiaView.contentLable.frame)+4, _youxiaView.titleImv.frame.origin.y, 50, 30);
            _youxiaView.danweiLabel.text = @"bpm";
            
            _youxiaView.viewTypeStr = @"热量";
            
            
        }
        
        
        
        
        //隐藏view 位置在 左下 和 右下
        _saveViewTag54View = [[GyundongCustomView alloc]initWithFrame:CGRectMake(0, 165, 160, 65)];
        _saveViewTag54View.line.frame = CGRectMake(0, 64, 160, 1);
        _saveViewTag54View.line1.frame = CGRectMake(159, 0, 1, 65);
        _saveViewTag54View.titleImv.frame = CGRectMake(7, 20, 30, 30);
        [_saveViewTag54View.titleImv setImage:[UIImage imageNamed:@"gspeed.png"]];
        _saveViewTag54View.contentLable.frame = CGRectMake(CGRectGetMaxX(_saveViewTag54View.titleImv.frame)+5, _zuoxiaView.titleImv.frame.origin.y-5, 70, 35);
        _saveViewTag54View.contentLable.text = @"0";
        _saveViewTag54View.danweiLabel.frame = CGRectMake(CGRectGetMaxX(_saveViewTag54View.contentLable.frame)+5, _saveViewTag54View.titleImv.frame.origin.y, 50, 30);
        _saveViewTag54View.danweiLabel.text = @"km/h";
        _saveViewTag54View.viewTypeStr = @"km/时";
        _saveViewTag54View.hidden = YES;
        
        
        
        _saveViewTag55View = [[GyundongCustomView alloc]initWithFrame:CGRectMake(160, 165, 160, 65)];
        _saveViewTag55View.line.frame = CGRectMake(0, 64, 160, 1);
        _saveViewTag55View.titleImv.frame = CGRectMake(7, 20, 30, 30);
        [_saveViewTag55View.titleImv setImage:[UIImage imageNamed:@"gstartime.png"]];
        _saveViewTag55View.contentLable.frame =  CGRectMake(CGRectGetMaxX(_saveViewTag55View.titleImv.frame)+5, _saveViewTag55View.titleImv.frame.origin.y-5, 100, 35);
        _saveViewTag55View.contentLable.text = @"0";
        _saveViewTag55View.hidden = YES;
        
        
        
        self.fiveCustomView = @[_dingView,_zuoshangView,_youshangView,_zuoxiaView,_youxiaView,_saveViewTag54View];
        
        
        //添加到upview上
        [_upview addSubview:_dingView];
        [_upview addSubview:_zuoshangView];
        [_upview addSubview:_youshangView];
        [_upview addSubview:_zuoxiaView];
        [_upview addSubview:_youxiaView];
        [_upview addSubview:_saveViewTag54View];
        [_upview addSubview:_saveViewTag55View];
        [_upview addSubview:_upOrDownBtn];
        [self.view addSubview:_upview];
        
        
    }
}


///初始化地图上面的4个按钮 路书显示 定位到地图中心点 gps强弱信号
-(void)initFourBtn{
    for (int i = 0; i<3; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(280, iPhone5 ? (380+i*45) : (300+i*45), 30, 30)];
        btn.tag = 40+i;
        [btn addTarget:self action:@selector(threeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i == 0) {//路书开关 tag 40
            [btn setImage:[UIImage imageNamed:@"gRoadLineOff"] forState:UIControlStateSelected];
            [btn setImage:[UIImage imageNamed:@"gRoadLineOn"] forState:UIControlStateNormal];
        }else if (i == 1){//地图跟随 tag 41
            [btn setImage:[UIImage imageNamed:@"gMapFllow.png"] forState:UIControlStateNormal];
        }else if (i == 2){//定位中心点 tag 42
            [btn setImage:[UIImage imageNamed:@"gMapCenterOff.png"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"gMapCenterOn.png"] forState:UIControlStateSelected];
            _dingweiCenterBtn = btn;
        }
        
        [self.view addSubview:btn];
        
        
        
    }
    
    
    
    
    //gps信号强弱
    
    _gpsQiangRuo = [[UIImageView alloc]initWithFrame:CGRectMake(15, iPhone5?470:390, 30, 30)];
    [_gpsQiangRuo setImage:[UIImage imageNamed:@"gps3.png"]];
    [self.view addSubview:_gpsQiangRuo];
    
    
}


//3个btn点击方法
-(void)threeBtnClicked:(UIButton *)sender{
    NSLog(@"fourBtn.tag = %d",sender.tag);
    
    if (self.mapView.showsUserLocation) {
        
        if (sender.tag == 41){//地图跟随
            
            sender.selected = !sender.selected;
            self.mapView.userTrackingMode = 2;
        }else if (sender.tag == 42){//定位中心点
            
            sender.selected = !sender.selected;
            self.mapView.userTrackingMode = 1;
        }
    }
    
    
    if (sender.tag == 40) {//路书开关
        
        sender.selected = !sender.selected;
        
        if (!sender.selected) {//路书为打开状态
            
            if (self.lines.count>0) {
                [self.mapView removeOverlays:self.lines];
                
//                MAPointAnnotation *startAnnotation;//起点
//                MAPointAnnotation *detinationAnnotation;//终点
//                NSMutableArray *middleAnntations;
                
                [self.mapView removeAnnotation:startAnnotation];
                [self.mapView removeAnnotation:detinationAnnotation];
            }
            
        }else{//路书为关闭状态
            RoadManagerController *cc = [[RoadManagerController alloc]init];
            cc.actionType = Action_SelectRoad;
            
            __weak typeof (self)bself = self;
            [cc selectRoadlineBlock:^(NSString *serverRoadId, NSString *roadlineJson) {
                
                if (bself.lines.count>0) {
                    [bself.mapView removeOverlays:self.lines];
                    [bself.mapView removeAnnotation:startAnnotation];
                    [bself.mapView removeAnnotation:detinationAnnotation];
                }
                
                NSArray *roadLineArray = [GMAPI getRoadLinesForType:1 isOpen:YES];
                if (roadLineArray && roadLineArray.count>0) {
                    LRoadClass *roadModelClass= roadLineArray[0];
                    [bself showRoadLineInMapViewWith:roadModelClass];
                    
                }
            }];
            cc.hidesBottomBarWhenPushed = YES;
            bself.navigationController.navigationBarHidden = NO;
            [bself.navigationController pushViewController:cc animated:YES];
        }
        
    }
    
    
}



///初始化地图
-(void)initMap{
    //地图相关初始化
//    [self initMapViewWithFrame:FRAME_IPHONE5_MAP_DOWN];
    
    self.mapView = [[MAMapView alloc]initWithFrame:FRAME_IPHONE5_MAP_DOWN];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    
    //    [self initObservers];
    [self initSearch];
    //    [self modeAction];
    self.mapView.showsUserLocation = NO;//关闭定位
//    self.mapView.showsUserLocation = _kaishiyundong;
    self.mapView.customizeUserLocationAccuracyCircleRepresentation = YES;//自定义定位样式
    self.mapView.userTrackingMode = MAUserTrackingModeNone;//定位模式
    
    self.mapView.showsCompass= NO;//开启指南针
    self.mapView.compassOrigin= CGPointMake(280, 10); //设置指南针位置
    
    self.mapView.showsScale= NO; //关闭比例尺
    self.mapView.scaleOrigin = CGPointMake(10, 70);
    
    //    [self initGestureRecognizer];//长按手势
    
}

///初始化地图下方view
-(void)initStartDownView{
    //开始运动时下方view
    _downView = [[UIView alloc]initWithFrame:CGRectMake(0, iPhone5?(568-50):(480-50), 320, 50)];
    _downView.backgroundColor = [UIColor whiteColor];
    _downView.hidden = YES;
    
    
    //返回按钮
    UIButton *returnBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [returnBackBtn setFrame:CGRectMake(0, 0, 80, 50)];
    [returnBackBtn setImage:[UIImage imageNamed:@"gback160x98.png"] forState:UIControlStateNormal];
    [returnBackBtn addTarget:self action:@selector(gGoBack) forControlEvents:UIControlEventTouchUpInside];
    [_downView addSubview:returnBackBtn];
    
    //完成按钮
    UIButton *redFinishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [redFinishBtn setFrame:CGRectMake(80, 0, 80, 50)];
    
    [redFinishBtn setImage:[UIImage imageNamed:@"gfinish.png"] forState:UIControlStateNormal];
    
    [redFinishBtn addTarget:self action:@selector(gFinish) forControlEvents:UIControlEventTouchUpInside];
    [_downView addSubview:redFinishBtn];
    
    //暂停按钮
    _greenTimeOutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_greenTimeOutBtn setFrame:CGRectMake(160, 0, 80, 50)];
    
    [_greenTimeOutBtn setImage:[UIImage imageNamed:@"gtimeout.png"] forState:UIControlStateNormal];
    [_greenTimeOutBtn addTarget:self action:@selector(gTimeOut) forControlEvents:UIControlEventTouchUpInside];
    [_downView addSubview:_greenTimeOutBtn];
    
    //拍照按钮
    UIButton *takePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [takePhotoBtn setFrame:CGRectMake(240, 0, 80, 50)];
    [takePhotoBtn setImage:[UIImage imageNamed:@"gtakephoto.png"] forState:UIControlStateNormal];
    [takePhotoBtn addTarget:self action:@selector(gTakePhotos) forControlEvents:UIControlEventTouchUpInside];
    
    
    [_downView addSubview:takePhotoBtn];
    
    [self.view addSubview:_downView];
}




/// 根据传入的参数设置 _upview上的GyundongCustomView
-(void)setImage:(UIImage*)theImage andContent:(NSString *)theStr andDanwei:(NSString *)theDanwei withTag:(NSInteger)theTag    
   withType:(NSString *)theViewType{
    switch (theTag) {
        case 51://顶
        {
            _dingView.titleImv.image = theImage;
            _dingView.contentLable.text = theStr;
            _dingView.danweiLabel.text = theDanwei;
            _dingView.viewTypeStr = theViewType;
            
        }
            break;
        case 52://左上 //计时lable 无单位label
        {
            _zuoshangView.titleImv.image = theImage;
            _zuoshangView.contentLable.text = theStr;
            _zuoshangView.danweiLabel.text = theDanwei;
            _zuoshangView.viewTypeStr = theViewType;
            if (![theViewType isEqualToString:@"计时"]) {//不是计时的话 变窄contentlabel
                _zuoshangView.contentLable.frame = CGRectMake(CGRectGetMaxX(_zuoshangView.titleImv.frame), _zuoshangView.titleImv.frame.origin.y-5, 70, 35);
                _zuoshangView.danweiLabel.frame = CGRectMake(CGRectGetMaxX(_zuoshangView.contentLable.frame)+4, _zuoshangView.titleImv.frame.origin.y, 50, 30);
                _zuoshangView.danweiLabel.hidden = NO;
            }else{
                _zuoshangView.danweiLabel.frame = CGRectMake(CGRectGetMaxX(_zuoshangView.contentLable.frame)+4, _zuoshangView.titleImv.frame.origin.y, 100, 35);
                _zuoshangView.danweiLabel.hidden = YES;
            }
        }
            break;
        case 53://右上
        {
            _youshangView.titleImv.image = theImage;
            _youshangView.contentLable.text = theStr;
            _youshangView.danweiLabel.text = theDanwei;
            _youshangView.viewTypeStr = theViewType;
            if ([theViewType isEqualToString:@"计时"]) {//是计时的话 加宽contentLabel
                _youshangView.contentLable.frame = CGRectMake(CGRectGetMaxX(_youshangView.titleImv.frame), _youshangView.titleImv.frame.origin.y-5, 100, 35);
                _youshangView.danweiLabel.hidden = YES;
            }else{
                _youshangView.contentLable.frame = CGRectMake(CGRectGetMaxX(_youshangView.titleImv.frame), _youshangView.titleImv.frame.origin.y-5, 70, 35);
                _youshangView.danweiLabel.hidden = NO;
            }
        }
            break;
        case 54://左下
        {
            _zuoxiaView.titleImv.image = theImage;
            _zuoxiaView.contentLable.text = theStr;
            _zuoxiaView.danweiLabel.text = theDanwei;
            _zuoxiaView.viewTypeStr = theViewType;
            
            
            if ([theViewType isEqualToString:@"计时"]) {//是计时的话 加宽contentLabel
                _zuoxiaView.contentLable.frame = CGRectMake(CGRectGetMaxX(_zuoxiaView.titleImv.frame), _zuoxiaView.titleImv.frame.origin.y-5, 100, 35);
                _zuoxiaView.danweiLabel.hidden = YES;
            }else{
                _zuoxiaView.contentLable.frame = CGRectMake(CGRectGetMaxX(_zuoxiaView.titleImv.frame), _zuoxiaView.titleImv.frame.origin.y-5, 70, 35);
                _zuoxiaView.danweiLabel.frame = CGRectMake(CGRectGetMaxX(_zuoxiaView.contentLable.frame)+4, _zuoxiaView.titleImv.frame.origin.y, 50, 30);
                _zuoxiaView.danweiLabel.hidden = NO;
            }
            
        }
            break;
        case 55://右下
        {
            _youxiaView.titleImv.image = theImage;
            _youxiaView.contentLable.text = theStr;
            _youxiaView.danweiLabel.text = theDanwei;
            _youxiaView.viewTypeStr = theViewType;
            
            if ([theViewType isEqualToString:@"计时"]) {//是计时的话 加宽contentLabel
                _youxiaView.contentLable.frame = CGRectMake(CGRectGetMaxX(_youxiaView.titleImv.frame), _youxiaView.titleImv.frame.origin.y-5, 100, 35);
                _youxiaView.danweiLabel.hidden = YES;
            }else{
                _youxiaView.contentLable.frame = CGRectMake(CGRectGetMaxX(_youxiaView.titleImv.frame), _youxiaView.titleImv.frame.origin.y-5, 70, 35);
                _youxiaView.danweiLabel.frame = CGRectMake(CGRectGetMaxX(_youxiaView.contentLable.frame)+4, _youxiaView.titleImv.frame.origin.y, 50, 30);
                _youxiaView.danweiLabel.hidden = NO;
            }
            
            
            
        }
            break;
        default:
            break;
    }
}

#pragma mark - 上面5个自定义的手势点击方法
//手势
-(void)gChooseCanshu:(UITapGestureRecognizer*)sender{
    GstarCanshuViewController *cc = [[GstarCanshuViewController alloc]init];
    cc.passTag = sender.view.tag;
    
    cc.delegate = self;
    cc.yundongModel = self.gYunDongCanShuModel;
    cc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cc animated:YES];
}



//路书跳转过来的通知方法
-(void)newBilityXiaoPang:(NSNotification*)thenotification{
    NSDictionary *notiInfo = thenotification.userInfo;
    
    NSLog(@"%@",notiInfo);
    
     [self.mapView removeOverlays:_lines];
    [self.mapView removeAnnotation:startAnnotation];
    [self.mapView removeAnnotation:detinationAnnotation];
    
    [self initHistoryMapWithDic:notiInfo];
    
}

//计时器
- (void) taktCounter
{
    //    NSLog(@"taktCounter is called");
    
    if (started)
    {
        _totalTakt++;
        _lapTakt++;
        
        
        if(splitted)
        {
            _lapTakt = 0;
            [self.gYunDongCanShuModel.timeRunLabel setText:@"00:00:00"];
            splitted = NO;
        }
        
        
        timerSecond = _totalTakt;
        if (timerSecond==60) {//秒转分
            timerSecond = 0;
            _totalTakt = 0;
            timerMin++;
        }
        if (timerMin==60) {//分转时
            timerMin = 0;
            _timerHour++;
        }
        
        
        
        if (splitTimerSecond == 60) {
            splitTimerMin++;
            splitTimerSecond = 0;
            _lapTakt = 0;
        }
        
        if (splitTimerMin == 60) {
            _splitTimerHour++;
            splitTimerMin = 0;
            
        }
        
#pragma mark - 计时label=======
        self.gYunDongCanShuModel.timeRunLabel.text = [[NSString alloc]initWithFormat:@"%02d:%02d:%02d",_timerHour,timerMin,timerSecond];
        
#pragma mark - 用时=======
        self.gYunDongCanShuModel.yongshi = self.gYunDongCanShuModel.timeRunLabel.text;
    
        if (reset == YES) {
            [self.gYunDongCanShuModel.timeRunLabel setText:@"00:00:00"];
            started = NO;
            splitted = NO;
            _totalTakt = 0;
            _lapTakt = 0;
            splitTimes = 0;
            reset = NO;
        }
    }
    
    
    
#pragma 数据model赋值  计时时间--------
    for (GyundongCustomView *view in self.fiveCustomView) {
        if ([view.viewTypeStr isEqualToString:@"计时"]) {
            view.contentLable.text = self.gYunDongCanShuModel.timeRunLabel.text;
        }
    }
    
    
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - 暂停按钮
-(void)gTimeOut{
    
//    _kaishiyundong = NO;
    
    _isTimeOutClicked = !_isTimeOutClicked;
    if (_isTimeOutClicked) {
        self.mapView.showsUserLocation = NO;
        started = NO;
        [_greenTimeOutBtn setImage:[UIImage imageNamed:@"ghuifu.png"] forState:UIControlStateNormal];
    }else{
        self.mapView.showsUserLocation = YES;
        started = YES;
        [_greenTimeOutBtn setImage:[UIImage imageNamed:@"gtimeout.png"] forState:UIControlStateNormal];
        
    }
    
}


#pragma mark - 返回按钮
-(void)gGoBack{
    _downView.hidden = YES;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"gkeepstarting" object:nil];
    [self hideTabBar:NO];
}


#pragma mark - 跳转到离线地图下载
-(void)goToOffLineMapTable{
    
}

#pragma mark - 行走完成

-(void)gFinish{
//    _kaishiyundong = NO;
    started = NO;
    
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    
    self.gYunDongCanShuModel.endTime = [NSString stringWithFormat:@"%@",localeDate];
    
    
    UIActionSheet *actionsheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"放弃记录" otherButtonTitles:@"保存分享", nil];
    actionsheet.tag = 101;
    [actionsheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 101) {
        if (buttonIndex == 1) {//保存记录
//            _kaishiyundong = NO;
            self.mapView.showsUserLocation = NO;
            _distance = 0.0f;
            reset = YES;//停止计时器
            _downView.hidden = YES;
            [self hideTabBar:NO];
            
            
//            [GMAPI zhengliPointArrayWithArray:self.routeLineArray];
            
            NSArray *dic_arr = [LMapTools saveMaplines:self.routeLineArray];
            
            int dic_arr_count = dic_arr.count;
            NSLog(@"dic_arr.count %d",dic_arr.count);
            
            if (dic_arr_count<1) {
                UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"轨迹太短无法保存" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [al show];
            }else{
                 NSString *jsonStr = [dic_arr JSONString];
                
                NSLog(@" jsonStr = %@",jsonStr);
                
                
#pragma mark - 上传轨迹到服务器
                
                NSString *custIdStr = [LTools cacheForKey:USER_CUSTID];
                CGFloat juli = self.gYunDongCanShuModel.juli;
                int upMetre = (self.gYunDongCanShuModel.maxHaiba - self.gYunDongCanShuModel.minHaiba);
                int downMetre = (self.gYunDongCanShuModel.haiba  - self.gYunDongCanShuModel.minHaiba);
                int costCalories = 30;
                
                CGFloat avgSpeed = self.gYunDongCanShuModel.pingjunsudu;
                CGFloat topSpeed = self.gYunDongCanShuModel.maxSudu;
                int heartRate = 70;
                NSString *beginTimeStr = [self.gYunDongCanShuModel.startTime substringToIndex:19];
                NSString *endTimeStr = [self.gYunDongCanShuModel.endTime substringToIndex:19];
                NSString *costTimeStr = self.gYunDongCanShuModel.yongshi;
                NSString *beginCoordinatesStr = self.gYunDongCanShuModel.startCoorStr;
                NSString *endCoordinatesStr = self.gYunDongCanShuModel.coorStr;
                
                NSLog(@"终点经纬度 %@",endCoordinatesStr);
                
                
                if (jsonStr) {
                    [self saveRoadlinesJsonString:jsonStr custId:custIdStr cyclingKm:juli upMetre:upMetre downMetre:downMetre costCalories:costCalories avgSpeed:avgSpeed topSpeed:topSpeed heartRate:heartRate beginTime:beginTimeStr endTime:endTimeStr costTime:costTimeStr beginSite:@" " endSite:@" " beginCoordinates:beginCoordinatesStr endCoordinates:endCoordinatesStr];
                }else{
                    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"没有轨迹" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [al show];
                }
                
                
                
            }
            
           
            
            
#pragma mark - 保存轨迹到本地数据库
            
//            if (jsonStr) {//有轨迹再往本地存
//                if (jsonStr && startNameStr && endNameStr && self.gYunDongCanShuModel.juli && self.gYunDongCanShuModel.startCoorStr && self.gYunDongCanShuModel.coorStr) {
//                    
//                    [GMAPI addRoadLinesJsonString:jsonStr startName:startNameStr endName:endNameStr distance:self.gYunDongCanShuModel.juli type:2 startCoorStr:self.gYunDongCanShuModel.startCoorStr endCoorStr:self.gYunDongCanShuModel.coorStr];
            
                    

            
            
            
            
            
            
            
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"起点和终点" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
//            
//            alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
//            
//            [alert show];
//            
//            first = [alert textFieldAtIndex:0];
//            first.text = startName;
//            
//            second = [alert textFieldAtIndex:1];
//            second.text = endName;
//            second.secureTextEntry = NO;
            
            
//            [[NSNotificationCenter defaultCenter]postNotificationName:@"gstopandsave" object:nil];
            
            
            
            for (GyundongCustomView *view in self.fiveCustomView) {
                
                [self.gYunDongCanShuModel cleanAllData];
                
                if ([view.viewTypeStr isEqualToString:@"计时"]) {
                    view.contentLable.text = @"00:00:00";
                }else{
                    view.contentLable.text = @"0.0";
                }
            }
            
            _distance = 0.0f;
            
            self.mapView.showsUserLocation = NO;
            [self.mapView removeOverlays:self.routeLineArray];
            
            [_points removeAllObjects];
            [self.routeLineArray removeAllObjects];
            
            reset = YES;//停止计时器
            _downView.hidden = YES;
            [self.gYunDongCanShuModel cleanAllData];
            [self hideTabBar:NO];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"gstopandnosave" object:nil];
            
            
            
            
            
        }else if (buttonIndex == 0){//放弃保存
            
            for (GyundongCustomView *view in self.fiveCustomView) {
                
                [self.gYunDongCanShuModel cleanAllData];
                
                if ([view.viewTypeStr isEqualToString:@"计时"]) {
                    view.contentLable.text = @"00:00:00";
                }else{
                    view.contentLable.text = @"0.0";
                }
            }
            
            _distance = 0.0f;

            self.mapView.showsUserLocation = NO;
            [self.mapView removeOverlays:self.routeLineArray];
            [_points removeAllObjects];
            [self.routeLineArray removeAllObjects];
            
            reset = YES;//停止计时器
            _downView.hidden = YES;
            [self.gYunDongCanShuModel cleanAllData];
            [self hideTabBar:NO];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"gstopandnosave" object:nil];
        }else if (buttonIndex == 2){//取消按钮
            if (_isTimeOutClicked) {
                started = NO;

            }else{
                started = YES;

            }
            
        }
    }
    
}



#pragma mark - 地图变大 upview上移动
-(void)gShou{
    
    if (_isUpViewShow) {//上移上面的view
        _isUpViewShow = NO;
        [_upOrDownBtn setImage:[UIImage imageNamed:@"gbtndown.png"] forState:UIControlStateNormal];
        [UIView animateWithDuration:0.2 animations:^{
            _upview.frame = FRAME_IPHONE5_UPVIEW_UP;
            [self.mapView setFrame:FRAME_IPHONE5_MAP_UP];
            
            
        } completion:^(BOOL finished) {
            
            _saveViewTag54View.hidden = NO;
            _saveViewTag55View.hidden = NO;
            
        }];
    }else{//下移上面的view
        _isUpViewShow = YES;
        [_upOrDownBtn setImage:[UIImage imageNamed:@"gbtnup.png"] forState:UIControlStateNormal];
        [UIView animateWithDuration:0.2 animations:^{
            _upview.frame = FRAME_IPHONE5_UPVIEW_DOWN;
            
            [self.mapView setFrame:FRAME_IPHONE5_MAP_DOWN];
        } completion:^(BOOL finished) {
            _saveViewTag54View.hidden = YES;
            _saveViewTag55View.hidden = YES;
            
        }];
    }
    
    
    
}



#pragma mark - 地图相关内存管理 点击返回按钮vc释放的时候走
- (void)returnAction
{
    [self clearMapView];
    
    [self clearSearch];
    
    self.mapView.userTrackingMode  = MAUserTrackingModeNone;
    
    [self.mapView removeObserver:self forKeyPath:@"showsUserLocation"];
    
}
- (void)clearMapView
{
    self.mapView.showsUserLocation = NO;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView removeOverlays:self.mapView.overlays];
    
    self.mapView.delegate = nil;
}

- (void)clearSearch
{
    self.search.delegate = nil;
}



#pragma mark - AMapSearchDelegate

- (void)searchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"%s: searchRequest = %@, errInfo= %@", __func__, [request class], error);
}



#pragma mark - Initialization 初始化Methode start=========

//初始化地图
- (void)initMapViewWithFrame:(CGRect)theFrame
{
    
    self.mapView = [Gmap sharedMap];
    [self.mapView setFrame:theFrame];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    self.mapView.visibleMapRect = MAMapRectMake(220880104, 101476980, 272496, 466656);
}

//初始化搜索服务
- (void)initSearch
{
    self.search = [[AMapSearchAPI alloc] initWithSearchKey:[MAMapServices sharedServices].apiKey Delegate:nil];
    self.search.delegate = self;
}



#pragma mark - Initialization 初始化Method  end=========



#pragma mark - ==============长按手势start=============
- (void)initGestureRecognizer//初始化长按手势
{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.5;
    
    [self.view addGestureRecognizer:longPress];
}

#pragma mark - Handle Gesture

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress//长按弹出大头针=========
{
    
    if (longPress.state == UIGestureRecognizerStateBegan)
    {
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:[longPress locationInView:self.view]
                                                  toCoordinateFromView:self.mapView];
        
        [self searchReGeocodeWithCoordinate:coordinate];
    }
    
    
    
}

- (void)searchReGeocodeWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    
    regeo.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeo.requireExtension = YES;
    
    [self.search AMapReGoecodeSearch:regeo];
}


#pragma mark - AMapSearchDelegate

/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode != nil)
    {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(request.location.latitude, request.location.longitude);
        ReGeocodeAnnotation *reGeocodeAnnotation = [[ReGeocodeAnnotation alloc] initWithCoordinate:coordinate
                                                                                         reGeocode:response.regeocode];
        
        [self.mapView addAnnotation:reGeocodeAnnotation];
        [self.mapView selectAnnotation:reGeocodeAnnotation animated:YES];

    }
}



#pragma mark - //==============长按手势end=============






#pragma mark - 定位=============================
#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated{
    
    
    if (mode != 1) {
        _dingweiCenterBtn.selected = NO;
    }
    
    
}


-(void)mapView:(MAMapView*)mapView didFailToLocateUserWithError:(NSError*)error{
    
//    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"定位失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//    [al show];
    NSLog(@"定位失败");
}





- (void)modeAction {
    [self.mapView setUserTrackingMode: MAUserTrackingModeFollow animated:YES]; //设置 为地图跟着位置移动
}





#pragma mark - 自定义定位样式
#pragma mark - MAMapViewDelegate

- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id <MAOverlay>)overlay
{
    
    
    
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    
    MAOverlayPathView* overlayView = nil;
    
    
//    if (overlay == mapView.userLocationAccuracyCircle)// 自定义定位精度对应的MACircleView
//    {
//        MACircleView *accuracyCircleView = [[MACircleView alloc] initWithCircle:overlay];
//        
//        accuracyCircleView.lineWidth    = 2.f;
//        accuracyCircleView.strokeColor  = [UIColor lightGrayColor];
//        accuracyCircleView.fillColor    = [UIColor colorWithRed:1 green:0 blue:0 alpha:.3];
//        
//        return accuracyCircleView;
//        
//    }
    if (overlay == self.routeLine){
        
        //if we have not yet created an overlay view for this overlay, create it now.
        if (self.routeLineView) {
            [self.routeLineView removeFromSuperview];
        }
        
        self.routeLineView = [[MAPolylineView alloc] initWithPolyline:self.routeLine];
        self.routeLineView.fillColor = [UIColor redColor];
        self.routeLineView.strokeColor = [UIColor redColor];
        self.routeLineView.lineWidth = 10;
        
        overlayView = self.routeLineView;
    }
    
    
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
    
    if ([annotation isKindOfClass:[MAUserLocation class]])/* 自定义userLocation对应的annotationView. */
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
        
    }
    
    
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





#pragma mark - 定位的回调方法===========================================
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    
    
    NSLog(@"点的数组 ------------------ %d",_points.count);
    
    
    //方向
    NSString *headingStr = @"";
    if (userLocation) {
        NSLog(@"userLocation ---- %@",userLocation);
        NSLog(@"userLocation.heading----%@",userLocation.heading);
        //地磁场方向
        double heading = userLocation.heading.magneticHeading;
        if (heading > 0) {
            headingStr = [GMAPI switchMagneticHeadingWithDoubel:heading];
        }
        NSLog(@"%@",headingStr);
        _fangxiangLabel.text = headingStr;
    }
    
#pragma mark - 给数据model赋值=========== 海拔(最高 最低 实时) 经纬度(开始，实时)
    //海拔
    CLLocation *currentLocation = userLocation.location;
    if (currentLocation) {
        NSLog(@"海拔---%f",currentLocation.altitude);
        int alti = (int)currentLocation.altitude;
        
        if (_isFirstStartCanshu) {
            if (alti != 0) {
                self.gYunDongCanShuModel.startHaiba = alti;//开始海拔
                self.gYunDongCanShuModel.maxHaiba = alti;
                self.gYunDongCanShuModel.minHaiba = alti;
            }
            //开始时的经纬度
            self.gYunDongCanShuModel.startCoorStr = [NSString stringWithFormat:@"%f,%f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude];
#pragma makr - 第一次的各个参数
            _isFirstStartCanshu = NO;
        }
        
        if (alti > self.gYunDongCanShuModel.maxHaiba) {
            self.gYunDongCanShuModel.maxHaiba = alti;//最高海拔
        }
        
        if ( (alti <self.gYunDongCanShuModel.minHaiba) && alti !=0 ) {
            self.gYunDongCanShuModel.minHaiba = alti;//最低海拔
        }
        
        
        self.gYunDongCanShuModel.haiba = alti;//实时海拔
        self.gYunDongCanShuModel.coorStr = [NSString stringWithFormat:@"%f,%f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude];//实时经纬度 定位结束后为终点经纬度
        
        

        
        for (GyundongCustomView *view in self.fiveCustomView) {
            if ([view.viewTypeStr isEqualToString:@"海拔"]) {
                
                view.contentLable.text = [NSString stringWithFormat:@"%d",self.gYunDongCanShuModel.haiba];
                
            }
        }
    }
    

    
    //自定义定位箭头方向
    if (!updatingLocation && self.userLocationAnnotationView != nil)
    {
        [UIView animateWithDuration:0.1 animations:^{
            
            double degree = userLocation.heading.trueHeading - self.mapView.rotationDegree;
            self.userLocationAnnotationView.transform = CGAffineTransformMakeRotation(degree * M_PI / 180.f );
            
        }];
    }
    
    
    
    
    
    
    
    
#pragma mark -  划线- start
    NSLog(@"lat ====== %f",userLocation.location.coordinate.latitude);
    NSLog(@"lon ====== %f",userLocation.location.coordinate.longitude);
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude
                                                      longitude:userLocation.coordinate.longitude];
    // check the zero point
    if  (userLocation.coordinate.latitude == 0.0f ||
         userLocation.coordinate.longitude == 0.0f)
        return;
    
    // check the move distance
    
//        CLLocationDistance distance = [self addNewLocationToPath:userLocation.location];
    
     CLLocationDistance distance = [location distanceFromLocation:_currentLocation];
    _currentLocation = location;
        NSLog(@"?????? distance = %f",distance);
        
        if (distance < 5 ||distance>10){
            return;
        }
    
        [_points addObject:location];
    
    
        CLLocationDistance julishangyigedian = [location distanceFromLocation:_currentLocation];
    
    
        [self configureRoutes];
#pragma mark --  划线- end
        
        
        
 #pragma mark - 数据model赋值 -- 距离
        _distance += distance;
        NSLog(@"距离---- %f 米",_distance);
        self.gYunDongCanShuModel.juli = _distance/1000.0;
        for (GyundongCustomView *view in self.fiveCustomView) {
            
            if ([view.viewTypeStr isEqualToString:@"距离"]) {
                view.contentLable.text = [NSString stringWithFormat:@"%.2f",self.gYunDongCanShuModel.juli];//给距离label赋值 单位是公里
            }
        }
        
//    }
    
   
    
#pragma mark - 数据model赋值 -- 最高速度
    self.gYunDongCanShuModel.dangqiansudu = userLocation.location.speed;
    if (self.gYunDongCanShuModel.maxSudu  < self.gYunDongCanShuModel.dangqiansudu) {
        self.gYunDongCanShuModel.maxSudu = self.gYunDongCanShuModel.dangqiansudu;
    }
#pragma mark - 数据model赋值 -- 平均速度/ 实时速度
    double zjuli = _distance/1000;//单位：公里
    
    if (self.gYunDongCanShuModel.yongshi.length>1) {
        
        NSString *hhStr = [self.gYunDongCanShuModel.yongshi substringWithRange:NSMakeRange(0, 2)];
        NSString *mmStr = [self.gYunDongCanShuModel.yongshi substringWithRange:NSMakeRange(3, 2)];
        NSString *ssStr = [self.gYunDongCanShuModel.yongshi substringWithRange:NSMakeRange(6, 2)];
        
        
        int hh;
        int mm;
        int ss;
        
        if ([hhStr intValue]) {
            hh = [hhStr intValue];
        }else{
            hh = 0;
        }
        
        if ([mmStr intValue]) {
            mm = [mmStr intValue];
        }else{
            mm = 0;
        }
        
        if ([ssStr intValue]) {
            ss = [ssStr intValue];
        }else{
            ss = 0;
        }
        
        
        
        double yongshi = hh+mm/60.0+ss/3600.0;//单位小时
        
        
        double pjsd = zjuli/yongshi;
        if (pjsd<0) {
            pjsd = 0.0;
        }
        
        self.gYunDongCanShuModel.pingjunsudu = pjsd;
        
    }
    
    
    self.gYunDongCanShuModel.dangqiansudu = userLocation.location.speed * 3.6;
    if (self.gYunDongCanShuModel.dangqiansudu<0 || self.gYunDongCanShuModel.dangqiansudu >50) {
        self.gYunDongCanShuModel.dangqiansudu = 0.0;
    }
    for (GyundongCustomView *view in self.fiveCustomView) {
        
        if ([view.viewTypeStr isEqualToString:@"速度"] || [view.viewTypeStr isEqualToString:@"km/时"]) {
            
            
            view.contentLable.text = [NSString stringWithFormat:@"%.1f",self.gYunDongCanShuModel.dangqiansudu];
            
        }
        
    }
    
    
    
}




// 添加原始位置点到数据，去除一些异常点后，返回走过的距离
-(CLLocationDistance)addNewLocationToPath:(CLLocation *)cLocation
{
    
    CLLocationDistance dist = 0.0f;

    [_points addObject:cLocation];
    
    // 优化数据集合
    for (int i = [_points count] - 3; i >= 0; i--) {
        CLLocationDistance distItem1 = [[_points objectAtIndex:i ] distanceFromLocation:[_points objectAtIndex:(i + 1)]];
        CLLocationDistance distItem2 = [[_points objectAtIndex:i + 1 ] distanceFromLocation:[_points objectAtIndex:(i + 2)]];
        CLLocationDistance distItem13 = [[_points objectAtIndex:i ] distanceFromLocation:[_points objectAtIndex:(i + 2)]];
        // 减少描点个数，5米一个间距
        if (distItem1 + distItem2 < 15.0f) {
            [_points removeObjectAtIndex:i + 1];
        }
        NSLog(@"%lf,%lf", distItem1, distItem2);
        if (distItem1 > 20.0f ) {
            if (i < 10) {
                // 前几个点的特殊处理
                [_points removeObjectAtIndex:i];
            }
            else
            {
                // 急速变动情况特殊处理，取中心点坐标
                CLLocationDegrees newLatitude = (((CLLocation *)[_points objectAtIndex:i ]).coordinate.latitude + ((CLLocation *)[_points objectAtIndex:i + 1]).coordinate.latitude + ((CLLocation *)[_points objectAtIndex:i + 2]).coordinate.latitude) / 3.0f;
                CLLocationDegrees newLongitude = (((CLLocation *)[_points objectAtIndex:i ]).coordinate.longitude + ((CLLocation *)[_points objectAtIndex:i + 1]).coordinate.longitude + ((CLLocation *)[_points objectAtIndex:i + 2]).coordinate.longitude) / 3.0f;
                CLLocation *clocationNew = [[CLLocation alloc] initWithLatitude:newLatitude longitude:newLongitude] ;
                // 替换三角形中间的坐标
                if (distItem2 > distItem13) {
                    [_points replaceObjectAtIndex:i withObject:clocationNew];
                }
                else {
                    [_points replaceObjectAtIndex:i+1 withObject:clocationNew];
                }
            }
            NSLog(@"修正坐标");
        }
    }
    
    
    
    
    // 增加上传前过滤操作
    // 判断连续三个点之间的夹角，当大于某个给定临界值(此处选170度)时，可以认为三点一线，去掉中间点
    if (_points.count >5) {
        float fArcThreshold = 170.0f;       //临界值
        BOOL bFind = YES;
        while (bFind) {
            
            bFind = NO;
            
            for (int i = 0; i < [_points count] - 2; i++) {
                
                CLLocationDistance distItem1 = [[_points objectAtIndex:i ] distanceFromLocation:[_points objectAtIndex:(i + 1)]];
                
                CLLocationDistance distItem2 = [[_points objectAtIndex:i + 1 ] distanceFromLocation:[_points objectAtIndex:(i + 2)]];
                
                CLLocationDistance distItem13 = [[_points objectAtIndex:i ] distanceFromLocation:[_points objectAtIndex:(i + 2)]];
                
                // 余弦定理求出ABC夹角
                double fRate = (distItem1 * distItem1 + distItem2 * distItem2 - distItem13 * distItem13) / (2.0f * distItem1 * distItem2);
                
                float fArc = (180.0f / M_PI) *  acosf((float)fRate);        // 转化成度数
                
                if (isnan(fArc)) {
                    
                    [_points removeObjectAtIndex:i + 1];
                    bFind = YES;
                }
                else if (fArc > fArcThreshold){
                    
                    bFind = YES;
                    [_points removeObjectAtIndex:i + 1];
                }
                else if (distItem1 + distItem2 > 50.0f && (distItem1 + distItem2 - distItem13 < distItem13 * 0.005)) {
                    
                    bFind = YES;
                    [_points removeObjectAtIndex:i + 1];
                }
            }
        }
        
    }

    
    for (int j = 1; j < [_points count]; j++) {
        CLLocationDistance distItems = [[_points objectAtIndex:j ] distanceFromLocation:[_points objectAtIndex:(j - 1)]];
        dist = distItems;
    }

    
    return dist;
}







#pragma mark - 画线方法
- (void)configureRoutes
{
    
    
    MAMapPoint northEastPoint = MAMapPointMake(0.0f, 0.0f);
    MAMapPoint southWestPoint = MAMapPointMake(0.0f, 0.0f);
    
    MAMapPoint* pointArray = malloc(sizeof(CLLocationCoordinate2D) * _points.count);
    
    for(int idx = 0; idx < _points.count; idx++)
    {
        CLLocation *location = [_points objectAtIndex:idx];
        CLLocationDegrees latitude  = location.coordinate.latitude;
        CLLocationDegrees longitude = location.coordinate.longitude;

        // create our coordinate and add it to the correct spot in the array
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        MAMapPoint point = MAMapPointForCoordinate(coordinate);

        // if it is the first point, just use them, since we have nothing to compare to yet.
        if (idx == 0) {
            northEastPoint = point;
            southWestPoint = point;
        } else {
            if (point.x > northEastPoint.x)
                northEastPoint.x = point.x;
            if(point.y > northEastPoint.y)
                northEastPoint.y = point.y;
            if (point.x < southWestPoint.x)
                southWestPoint.x = point.x;
            if (point.y < southWestPoint.y)
                southWestPoint.y = point.y;
        }
        
        pointArray[idx] = point;
    }
    

    
    if (self.routeLine) {
        [self.mapView removeOverlay:self.routeLine];
    }
    
    
    self.routeLine = [MAPolyline polylineWithPoints:pointArray count:_points.count];
    
    // add the overlay to the map
    if (self.routeLine != nil) {
        [self.mapView addOverlay:self.routeLine];
//#pragma mark - 划线时把MAPolyline折线对象保存到self.routeLineArray数组中
//        //这个数组保存的时候转为json串存入数据库中
        [self.routeLineArray removeAllObjects];
        [self.routeLineArray addObject:self.routeLine];
    }
    // clear the memory allocated earlier for the points
    free(pointArray);
    
    
    
    
}

#pragma 点击tabbar上开始按钮开始的操作   开始骑行
-(void)iWantToStart{

    [self hideTabBar:YES];
    _isFirstStartCanshu = YES;
    _downView.hidden = NO;
    self.mapView.showsUserLocation = YES;//开启定位
    
    //接收到appdelegate通知 开始骑行 下面这个是判断 是否为暂停后点击返回然后再点击开始骑行进入的
    if (_isTimeOutClicked) {
        
    }else{
        started = YES;
        NSDate *date = [NSDate date];
        NSTimeZone *zone = [NSTimeZone systemTimeZone];
        NSInteger interval = [zone secondsFromGMTForDate: date];
        NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
        
        self.gYunDongCanShuModel.startTime = [NSString stringWithFormat:@"%@",localeDate];
        
        
    }
    
}



#pragma mark - 隐藏或显示tabbar
- (void)hideTabBar:(BOOL) hidden{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0];
    
    for(UIView *view in self.tabBarController.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            if (hidden) {
                [view setFrame:CGRectMake(view.frame.origin.x, iPhone5 ? 568 : 480 , view.frame.size.width, view.frame.size.height)];
            } else {
                [view setFrame:CGRectMake(view.frame.origin.x, iPhone5 ? (568-49):(480-49), view.frame.size.width, view.frame.size.height)];
            }
        }
        else
        {
            if (hidden) {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 320)];
            } else {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 320-49)];
            }
        }
    }
    
    [UIView commitAnimations];
}




#pragma mark - 把路书添加到地图上

-(void)showRoadLineInMapViewWith:(LRoadClass*)model{

    NSArray *arr = [model.lineString objectFromJSONString];
    CLLocationCoordinate2D start;
    start = CLLocationCoordinate2DMake(model.startCoor.latitude, model.startCoor.longitude);
    CLLocationCoordinate2D end;
    end = CLLocationCoordinate2DMake(model.endCoor.latitude, model.endCoor.longitude);
    
    NSDictionary *history_dic = [LMapTools parseMapHistoryMap:arr];
    
    self.lines = [history_dic objectForKey:L_POLINES];
    
    self.startCoordinate = start;
    [self addStartAnnotation];
    
    self.destinationCoordinate = end;
    [self addDestinationAnnotation];
    
    [self.mapView addOverlays:self.lines];
    
    [self.mapView setCenterCoordinate:self.startCoordinate animated:YES];
    
    
    
}




//牛逼的小胖===============
- (void)initHistoryMapWithDic:(NSDictionary*)dic
{
    
    NSString *index = [dic objectForKey:@"road_index"];
    int indexx = [index intValue];
    NSDictionary *dic1 = [GMAPI getRoadLinesForRoadId:indexx];
    NSString *jsonString = [dic1 objectForKey:LINE_JSONSTRING];
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



#pragma mark 添加\取消 标志

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







#pragma mark - 上传轨迹
- (void)saveRoadlinesJsonString:(NSString *)jsonStr
                         custId:(NSString *)userId
                      cyclingKm:(CGFloat)juli
                        upMetre:(int)haibashangsheng
                      downMetre:(int)haibaxiajiang
                   costCalories:(int)kaluli
                       avgSpeed:(CGFloat)pingjunsudu
                       topSpeed:(CGFloat)zuigaosudu
                      heartRate:(int)xinlv
                      beginTime:(NSString *)kaishishijian
                        endTime:(NSString *)jiesushijian
                       costTime:(NSString *)yongshi
                      beginSite:(NSString *)kaishididian
                        endSite:(NSString *)jiesudidian
               beginCoordinates:(NSString *)kaishijingweidu
                 endCoordinates:(NSString *)jiesujingweidu

{
    NSString *custId =  [LTools cacheForKey:USER_CUSTID];
    
    
    NSString *post = [NSString stringWithFormat:@"&roadlines=%@",jsonStr];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *url = [NSString stringWithFormat:BIKE_ROAD_LINE_GUIJI,custId,juli,haibashangsheng,haibaxiajiang,kaluli,pingjunsudu,zuigaosudu,xinlv,kaishishijian,jiesushijian,yongshi,kaishididian,jiesudidian,kaishijingweidu,jiesujingweidu];
    
    NSLog(@"上传轨迹请求的url : %@",url);
    
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:YES postData:postData];
    [tool requestSpecialCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"result %@ erro %@",result,erro);
        
        int status = [[result objectForKey:@"status"]integerValue];
        
        if (status == 1) {
            
            NSLog(@"上传返回的dic ： %@",result);
            
            [LTools showMBProgressWithText:@"路书上传成功" addToView:self.view];
        }else
        {
            NSLog(@"上传返回的dic ： %@",result);
            UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"上传失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [al show];
            
        }
        
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        NSLog(@"failDic %@ erro %@",failDic,[failDic objectForKey:@"ERRO_INFO"]);
        
        
    }];
}




-(void)gTakePhotos{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController * pickerC = [[UIImagePickerController alloc] init];
        pickerC.delegate = self;
        pickerC.allowsEditing = NO;
        pickerC.sourceType = sourceType;
        [self presentViewController:pickerC animated:YES completion:nil];
    }
    else
    {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"相机不可用" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [al show];
    }
}





@end
