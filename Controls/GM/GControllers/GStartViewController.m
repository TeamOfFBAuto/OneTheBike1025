//
//  GStartViewController.m
//  OneTheBike
//
//  Created by gaomeng on 14-10-13.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "GStartViewController.h"
#import "ReGeocodeAnnotation.h"
#import "GOffLineMapViewController.h"
#import "Gmap.h"

#import "GstarCanshuViewController.h"
#import "GyundongCustomView.h"
@class GyundongCustomView;

#define FRAME_IPHONE5_MAP_UP CGRectMake(0, 30, 320, 568-60-20)
#define FRAME_IPHONE5_MAP_DOWN CGRectMake(0, 230+20, 320, 568-230-20)
#define FRAME_IPHONE5_UPVIEW_UP CGRectMake(0, -115, 320, 230)
#define FRAME_IPHONE5_UPVIEW_DOWN CGRectMake(0, 20, 320, 230)




@interface GStartViewController ()<UIActionSheetDelegate>
{
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
    NSArray *_lines;//路书数组
}
@property (nonatomic,strong)NSMutableArray *cllocation2dsArray;
@property (nonatomic, strong) NSMutableArray *overlays;


@end

@implementation GStartViewController

- (void)dealloc
{
    [self returnAction];
    
}


-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    
    
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
    
    
    
    [self initMap];//初始化地图
    [self initMapUpView];//初始化地图上面的view
    
    [self initTopWhiteAndGrayView];//状态栏和灰条g
    
    [self initFourBtn];//地图上4个btn
    
    [self initStartDownView];//初始化地图下面的view
    
    
    
    
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
    
    
    
    
//    [self initHistoryMap];
    
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
    UIView *shangGrayView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, 320, 35)];
    shangGrayView.backgroundColor = RGBCOLOR(105, 105, 105);
    //方向
    _fangxiangLabel = [[UILabel alloc]initWithFrame:CGRectMake(250, 5, 50, 30)];
    _fangxiangLabel.font = [UIFont systemFontOfSize:13];
    _fangxiangLabel.textColor = [UIColor whiteColor];
    _fangxiangLabel.textAlignment = NSTextAlignmentCenter;
    //标题
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 50, 30)];
    titleLabel.font = [UIFont systemFontOfSize:13];
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
    
    self.fiveCustomView = @[_dingView,_zuoshangView,_youshangView,_zuoxiaView,_youshangView];
    
    
    
    
    
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
            _dingView.titleImv.frame = CGRectMake(70, 20, 30, 30);
            
            //内容label
            _dingView.contentLable.frame = CGRectMake(CGRectGetMaxX(_dingView.titleImv.frame)+5, _dingView.titleImv.frame.origin.y-5, 100, 35);
//            _dingView.contentLable.backgroundColor = [UIColor redColor];
            
            _dingView.contentLable.text = @"0.0";
            _dingView.contentLable.textAlignment = NSTextAlignmentCenter;//只有这里设置居中
            
            //计量单位
            _dingView.danweiLabel.frame = CGRectMake(CGRectGetMaxX(_dingView.contentLable.frame)+5, _dingView.contentLable.frame.origin.y+5, 70, 30);
            _dingView.danweiLabel.text = @"公里/时";
            _dingView.viewTypeStr = @"速度";
            
            
            
            
        }else if (i == 2){//计时 左上 tag 52
            
            
            _zuoshangView.tag = 52;
            
            [_zuoshangView addGestureRecognizer:tap];
            _zuoshangView.line.frame = CGRectMake(0, 64, 160, 1);
            _zuoshangView.line1.frame = CGRectMake(159, 0, 1, 65);
            _zuoshangView.titleImv.frame = CGRectMake(10, 20, 30, 30);
            [_zuoshangView.titleImv setImage:titleImageArr[i-1]];
            
            //内容label
            _zuoshangView.contentLable.frame = CGRectMake(CGRectGetMaxX(_zuoshangView.titleImv.frame)+5, _zuoshangView.titleImv.frame.origin.y-5, 100, 35);
            _zuoshangView.contentLable.text = @"00:00:00";
            
            
            _zuoshangView.viewTypeStr = @"计时";
            
            
            
        }else if (i == 3){//公里 右上
            
            
            _youshangView.tag = 53;
            
            [_youshangView addGestureRecognizer:tap];
            _youshangView.line.frame = CGRectMake(0, 64, 160, 1);
            _youshangView.titleImv.frame = CGRectMake(10, 20, 30, 30);
            
            //内容label
            _youshangView.contentLable.frame = CGRectMake(CGRectGetMaxX(_youshangView.titleImv.frame)+5, _youshangView.titleImv.frame.origin.y-5, 70, 35);
            
            _youshangView.contentLable.text = @"0.0";
            
            //计量单位
            _youshangView.danweiLabel.frame = CGRectMake(CGRectGetMaxX(_youshangView.contentLable.frame)+5, _youshangView.titleImv.frame.origin.y, 40, 30);
            _youshangView.danweiLabel.text = @"公里";
            
            [_youshangView.titleImv setImage:titleImageArr[i-1]];
            
            _youshangView.viewTypeStr = @"距离";
            
        }else if (i == 4){//海拔 左下
            
            
            _zuoxiaView.tag = 54;
            [_zuoxiaView addGestureRecognizer:tap];
            _zuoxiaView.line.frame = CGRectMake(0, 64, 160, 1);
            _zuoxiaView.line1.frame = CGRectMake(159, 0, 1, 65);
            _zuoxiaView.titleImv.frame = CGRectMake(10, 20, 30, 30);
            [_zuoxiaView.titleImv setImage:titleImageArr[i-1]];
            
            _zuoxiaView.contentLable.frame = CGRectMake(CGRectGetMaxX(_zuoxiaView.titleImv.frame)+5, _zuoxiaView.titleImv.frame.origin.y-5, 70, 35);
            _zuoxiaView.contentLable.text = @"0";
            
            
            _zuoxiaView.danweiLabel.frame = CGRectMake(CGRectGetMaxX(_zuoxiaView.contentLable.frame)+5, _zuoxiaView.titleImv.frame.origin.y, 40, 30);
            _zuoxiaView.danweiLabel.text = @"米";
            [_zuoxiaView addSubview:_zuoxiaView.danweiLabel];
            
            _zuoxiaView.viewTypeStr = @"海拔";
            
        }else if (i == 5){//bpm 右下
            
            _youxiaView.tag = 55;
            [_youxiaView addGestureRecognizer:tap];
            _youxiaView.line.frame = CGRectMake(0, 64, 160, 1);
            _youxiaView.titleImv.frame = CGRectMake(10, 20, 30, 30);
            [_youxiaView.titleImv setImage:titleImageArr[i-1]];
            
            _youxiaView.contentLable.frame =CGRectMake(CGRectGetMaxX(_youxiaView.titleImv.frame)+5, _youxiaView.titleImv.frame.origin.y-5, 70, 35);
            _youxiaView.contentLable.text = @"0";
            
            
            _youxiaView.danweiLabel.frame = CGRectMake(CGRectGetMaxX(_youxiaView.contentLable.frame)+5, _youxiaView.titleImv.frame.origin.y, 40, 30);
            _youxiaView.danweiLabel.text = @"bpm";
            
            _youshangView.viewTypeStr = @"热量";
            
            
        }
        
        
        
        
        //隐藏view 位置在 左下 和 右下
        _saveViewTag54View = [[GyundongCustomView alloc]initWithFrame:CGRectMake(0, 165, 160, 65)];
        _saveViewTag54View.line.frame = CGRectMake(0, 64, 160, 1);
        _saveViewTag54View.line1.frame = CGRectMake(159, 0, 1, 65);
        _saveViewTag54View.titleImv.frame = CGRectMake(10, 20, 30, 30);
        [_saveViewTag54View.titleImv setImage:[UIImage imageNamed:@"gspeed.png"]];
        _saveViewTag54View.contentLable.frame = CGRectMake(CGRectGetMaxX(_saveViewTag54View.titleImv.frame)+5, _zuoxiaView.titleImv.frame.origin.y-5, 70, 35);
        _saveViewTag54View.contentLable.text = @"0";
        _saveViewTag54View.danweiLabel.frame = CGRectMake(CGRectGetMaxX(_saveViewTag54View.contentLable.frame)+5, _saveViewTag54View.titleImv.frame.origin.y, 40, 30);
        _saveViewTag54View.danweiLabel.text = @"km/时";
        _saveViewTag54View.hidden = YES;
        
        
        
        _saveViewTag55View = [[GyundongCustomView alloc]initWithFrame:CGRectMake(160, 165, 160, 65)];
        _saveViewTag55View.line.frame = CGRectMake(0, 64, 160, 1);
        _saveViewTag55View.titleImv.frame = CGRectMake(10, 20, 30, 30);
        [_saveViewTag55View.titleImv setImage:[UIImage imageNamed:@"gstartime.png"]];
        _saveViewTag55View.contentLable.frame =  CGRectMake(CGRectGetMaxX(_saveViewTag55View.titleImv.frame)+5, _saveViewTag55View.titleImv.frame.origin.y-5, 100, 35);
        _saveViewTag55View.contentLable.text = @"0";
        _saveViewTag55View.hidden = YES;
        
        
        
        
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
        [btn setFrame:CGRectMake(280, 380+i*45, 30, 30)];
        btn.tag = 40+i;
        [btn addTarget:self action:@selector(threeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i == 0) {//路书开关 tag 40
            [btn setImage:[UIImage imageNamed:@"gRoadLineOff"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"gRoadLineOn"] forState:UIControlStateSelected];
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
    
    _gpsQiangRuo = [[UIImageView alloc]initWithFrame:CGRectMake(15, 470, 30, 30)];
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
    
    [self.mapView addOverlays:self.overlays];//把线条添加到地图上
    
    [self configureRoutes];//划线
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
    [takePhotoBtn addTarget:self action:@selector(goToOffLineMapTable) forControlEvents:UIControlEventTouchUpInside];
    
    
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
                _zuoshangView.contentLable.frame = CGRectMake(CGRectGetMaxX(_zuoshangView.titleImv.frame)+5, _zuoshangView.titleImv.frame.origin.y-5, 70, 35);
                _zuoshangView.danweiLabel.frame = CGRectMake(CGRectGetMaxX(_zuoshangView.contentLable.frame)+5, _zuoshangView.titleImv.frame.origin.y, 40, 30);
                _zuoshangView.danweiLabel.hidden = NO;
            }else{
                _zuoshangView.danweiLabel.frame = CGRectMake(CGRectGetMaxX(_zuoshangView.contentLable.frame)+5, _zuoshangView.titleImv.frame.origin.y, 100, 35);
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
                _youshangView.contentLable.frame = CGRectMake(CGRectGetMaxX(_youshangView.titleImv.frame)+5, _youshangView.titleImv.frame.origin.y-5, 100, 35);
                _youshangView.danweiLabel.hidden = YES;
            }else{
                _youshangView.contentLable.frame = CGRectMake(CGRectGetMaxX(_youshangView.titleImv.frame)+5, _youshangView.titleImv.frame.origin.y-5, 70, 35);
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
                _zuoxiaView.contentLable.frame = CGRectMake(CGRectGetMaxX(_zuoxiaView.titleImv.frame)+5, _zuoxiaView.titleImv.frame.origin.y-5, 100, 35);
                _zuoxiaView.danweiLabel.hidden = YES;
            }else{
                _zuoxiaView.contentLable.frame = CGRectMake(CGRectGetMaxX(_zuoxiaView.titleImv.frame)+5, _zuoxiaView.titleImv.frame.origin.y-5, 70, 35);
                _zuoxiaView.danweiLabel.frame = CGRectMake(CGRectGetMaxX(_zuoxiaView.contentLable.frame)+5, _zuoxiaView.titleImv.frame.origin.y, 40, 30);
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
                _youxiaView.contentLable.frame = CGRectMake(CGRectGetMaxX(_youxiaView.titleImv.frame)+5, _youxiaView.titleImv.frame.origin.y-5, 100, 35);
                _youxiaView.danweiLabel.hidden = YES;
            }else{
                _youxiaView.contentLable.frame = CGRectMake(CGRectGetMaxX(_youxiaView.titleImv.frame)+5, _youxiaView.titleImv.frame.origin.y-5, 70, 35);
                _youxiaView.danweiLabel.frame = CGRectMake(CGRectGetMaxX(_youxiaView.contentLable.frame)+5, _youxiaView.titleImv.frame.origin.y, 40, 30);
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
//    cc.hidesBottomBarWhenPushed = YES;
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
            
            
            NSString *jsonStr = [self.routeLineArray JSONString];
            
            //历史展示界面需要的参数
            //时间  平均速度 用时 距离
            NSString *startNameStr = [NSString stringWithFormat:@"%@,%@,%@",self.gYunDongCanShuModel.startTime,self.gYunDongCanShuModel.endTime,self.gYunDongCanShuModel.yongshi];
            
            NSString *endNameStr = @"0";
            
            if (self.gYunDongCanShuModel.pingjunsudu.length >0) {
                endNameStr = [NSString stringWithFormat:@"%@",self.gYunDongCanShuModel.pingjunsudu];
            }
            
            //保存轨迹到本地数据库
            [GMAPI addRoadLinesJsonString:jsonStr startName:startNameStr endName:endNameStr distance:self.gYunDongCanShuModel.juli type:2 startCoorStr:self.gYunDongCanShuModel.startCoorStr endCoorStr:self.gYunDongCanShuModel.coorStr];
            
            
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
            
            
            
#pragma mark - 上传轨迹===============================
            
            int upMetre = [self.gYunDongCanShuModel.maxHaiba intValue] - [self.gYunDongCanShuModel.startHaiba intValue];
            int downMetre = [self.gYunDongCanShuModel.startHaiba intValue] - [self.gYunDongCanShuModel.minHaiba intValue];
            
            NSString *upMetreStr = [NSString stringWithFormat:@"%d",upMetre];//上升海拔
            NSString *downMetreStr = [NSString stringWithFormat:@"%d",downMetre];//下降海拔
            NSString *startTimeStr = [self.gYunDongCanShuModel.startTime substringToIndex:19];//开始时间
            NSString *endTimeStr = [self.gYunDongCanShuModel.startTime substringToIndex:19];//结束时间
            self.gYunDongCanShuModel.startTime = startTimeStr;
            self.gYunDongCanShuModel.endTime = endTimeStr;
            
            [self saveRoadlinesJsonString:jsonStr//轨迹大字符串
                                startName:nil
                                  endName:nil
                                cyclingKm:self.gYunDongCanShuModel.juli//总距离
                                  upMetre:upMetreStr//上升海拔
                                downMetre:downMetreStr//下降海拔
                             costCalories:nil//卡路里
                                 avgSpeed:self.gYunDongCanShuModel.pingjunsudu//平均速度
                                 topSpeed:self.gYunDongCanShuModel.maxSudu//最高速度
                                heartRate:nil//心率
                                beginTime:startTimeStr//开始时间
                                  endTime:endTimeStr//结束时间
                                 costTime:@"30"//用时
                                beginSite:nil
                                  endSite:nil
                         beginCoordinates:self.gYunDongCanShuModel.startCoorStr//起点的经纬度
                           endCoordinates:self.gYunDongCanShuModel.coorStr];//终点的经纬度
            
            
            
            
            
        }else if (buttonIndex == 0){//放弃保存
            
            for (GyundongCustomView *view in self.fiveCustomView) {
                if ([view.viewTypeStr isEqualToString:@"计时"]) {
                    view.contentLable.text = @"00:00:00";
                }else{
                    view.contentLable.text = @"0.0";
                }
            }
            
            _distance = 0.0f;
//            _kaishiyundong = NO;
            self.mapView.showsUserLocation = NO;
            reset = YES;//停止计时器
            _downView.hidden = YES;
            [self.gYunDongCanShuModel cleanAllData];
            [self hideTabBar:NO];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"gstopandnosave" object:nil];
        }else if (buttonIndex == 2){//取消按钮
            if (_isTimeOutClicked) {
                started = NO;
//                _kaishiyundong = NO;
            }else{
                started = YES;
//                _kaishiyundong = YES;
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
    
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"定位失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [al show];
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
    
    
    
    
    NSLog(@"lat ====== %f",userLocation.location.coordinate.latitude);
    NSLog(@"lon ====== %f",userLocation.location.coordinate.longitude);
    
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
                self.gYunDongCanShuModel.startHaiba = [NSString stringWithFormat:@"%d",alti];//开始海拔
                self.gYunDongCanShuModel.maxHaiba = [NSString stringWithFormat:@"%d",alti];
                self.gYunDongCanShuModel.minHaiba = [NSString stringWithFormat:@"%d",alti];
            }
            //开始时的经纬度
            self.gYunDongCanShuModel.startCoorStr = [NSString stringWithFormat:@"%f,%f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude];
#pragma makr - 第一次的各个参数
            _isFirstStartCanshu = NO;
        }
        
        if (alti > [self.gYunDongCanShuModel.maxHaiba intValue]) {
            self.gYunDongCanShuModel.maxHaiba = [NSString stringWithFormat:@"%d",alti];//最高海拔
        }
        
        if (alti <[self.gYunDongCanShuModel.minHaiba integerValue] && alti !=0 ) {
            self.gYunDongCanShuModel.minHaiba = [NSString stringWithFormat:@"%d",alti];//最低海拔
        }
        
        
        self.gYunDongCanShuModel.haiba = [NSString stringWithFormat:@"%d",alti];//实时海拔
        self.gYunDongCanShuModel.coorStr = [NSString stringWithFormat:@"%f,%f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude];//实时经纬度 定位结束后为终点经纬度
        
        

        
        for (GyundongCustomView *view in self.fiveCustomView) {
            if ([view.viewTypeStr isEqualToString:@"海拔"]) {
                
                view.contentLable.text = self.gYunDongCanShuModel.haiba;
                
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
    
    
    
    
    
    
    
    
#pragma mark -  划线=======================
    
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
    if (_points.count > 0) {
        CLLocationDistance distance = [location distanceFromLocation:_currentLocation];
        if (distance < 5 || distance > 10){
            return;
        }
        _distance += distance;
        NSLog(@"距离---- %.2f 米",_distance);
#pragma mark - 数据model赋值--------------- 距离
        self.gYunDongCanShuModel.juli = [NSString stringWithFormat:@"%.2f",_distance/1000];
        
        for (GyundongCustomView *view in self.fiveCustomView) {
            if ([view.viewTypeStr isEqualToString:@"距离"]) {
                view.contentLable.text = self.gYunDongCanShuModel.juli;//给距离label赋值 单位是公里
            }
        }
        
    }
    
    
#pragma mark - 数据model赋值 ------------- 当前 实时速度
    
//    double sudu = userLocation.location.speed;//单位米每秒
//    if (sudu<0) {
//        sudu = 0;
//    }
//    double suduOfGongli = sudu *3.6;
//    self.gYunDongCanShuModel.dangqiansudu = [NSString stringWithFormat:@"%.1f",suduOfGongli];//单位 公里每小时
    
    
    
    
    
#pragma mark - 数据model赋值 ------------ 最高速度 
    
    if ([self.gYunDongCanShuModel.maxSudu intValue] < [self.gYunDongCanShuModel.dangqiansudu intValue]) {
        self.gYunDongCanShuModel.maxSudu = self.gYunDongCanShuModel.dangqiansudu;
    }
    
    
#pragma mark - 数据model赋值 ------------ 平均速度
    
    
    double zjuli = _distance/1000;//单位：公里
    if (self.gYunDongCanShuModel.yongshi.length>1) {
        int hh = [[self.gYunDongCanShuModel.yongshi substringWithRange:NSMakeRange(0, 2)]intValue];
        int mm = [[self.gYunDongCanShuModel.yongshi substringWithRange:NSMakeRange(3, 2)]intValue];
        int ss = [[self.gYunDongCanShuModel.yongshi substringWithRange:NSMakeRange(6, 2)]intValue];
        double yongshi = hh+mm/60.0+ss/3600.0;//单位小时
        double pjsd = zjuli/yongshi;
        if (pjsd<0) {
            pjsd = 0;
        }
        self.gYunDongCanShuModel.pingjunsudu = [NSString stringWithFormat:@"%.1f",pjsd];
    }
    
    for (GyundongCustomView *view in self.fiveCustomView) {
        if ([view.viewTypeStr isEqualToString:@"速度"]) {
            view.contentLable.text = self.gYunDongCanShuModel.pingjunsudu;
        }
    }
    
    
    if (_points == nil) {
        _points = [[NSMutableArray alloc] init];
    }
    
    [_points addObject:location];
    _currentLocation = location;
    
    NSLog(@"points: %@", _points);
    
    [self configureRoutes];
    
//    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
//    [self.mapView setCenterCoordinate:coordinate animated:YES];
    
    
    
    
    
    
}

#pragma mark - 画线
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
//        MAMapPoint point = MAMapPointMake(coordinate.latitude, coordinate.longitude);
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
    if (nil != self.routeLine) {
        [self.mapView addOverlay:self.routeLine];
#pragma mark - 划线保存的line数组？？？？？？？？？？？？？？？？？？？
        //这个数组保存的时候转为json串存入数据库中
        [self.routeLineArray addObject:self.routeLine];
    }
    
    // clear the memory allocated earlier for the points
    free(pointArray);
    
    
}

#pragma 点击tabbar上开始按钮开始的操作   开始骑行============
-(void)iWantToStart{
//    _kaishiyundong = YES;
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








//上传接口
//#define BIKE_ROAD_LINE_GUIJI  @"http://182.254.242.58:8080/QiBa/QiBa/cyclingAction_saveCycling.action?custId=%@&cyclingKm=%.2f&upMetre=%d&downMetre=%d&costCalories=%d&avgSpeed=%.2f&topSpeed=%.2f&heartRate=%d&beginTime=%@&endTime=%@&costTime=%d&beginSite=%@&endSite=%@&beginCoordinates=%@&endCoordinates=%@"

#define BIKE_ROAD_LINE_GUIJI  @"http://182.254.242.58:8080/QiBa/QiBa/cyclingAction_saveCycling.action?custId=%@&cyclingKm=%@&upMetre=%@&downMetre=%@&costCalories=%@&avgSpeed=%@&topSpeed=%@&heartRate=%@&beginTime=%@&endTime=%@&costTime=%@&beginSite=%@&endSite=%@&beginCoordinates=%@&endCoordinates=%@"



- (void)saveRoadlinesJsonString:(NSString *)jsonStr
                      startName:(NSString *)startNameL
                        endName:(NSString *)endNameL
                      cyclingKm:(NSString *)cyclingKmStr
                        upMetre:(NSString *)upMetreStr
                      downMetre:(NSString *)downMetreStr
                   costCalories:(NSString *)costCaloriesStr
                       avgSpeed:(NSString *)avgSpeedStr
                       topSpeed:(NSString *)topSpeedStr
                      heartRate:(NSString *)heartRateStr
                      beginTime:(NSString *)beginTimeStr
                        endTime:(NSString *)endTimeStr
                       costTime:(NSString *)costTimeStr
                      beginSite:(NSString *)beginSiteStr
                        endSite:(NSString *)endSiteStr
               beginCoordinates:(NSString *)beginCoordinatesStr
                 endCoordinates:(NSString *)endCoordinatesStr

{
    NSString *custId = [LTools timechangeToDateline];
    
    NSString *post = [NSString stringWithFormat:@"&roadlines=%@",jsonStr];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *url = [NSString stringWithFormat:BIKE_ROAD_LINE_GUIJI,custId,cyclingKmStr,upMetreStr,downMetreStr,costCaloriesStr,avgSpeedStr,topSpeedStr,heartRateStr,beginTimeStr,endTimeStr,costTimeStr,beginSiteStr,endSiteStr,beginCoordinatesStr,endCoordinatesStr];
    
    NSLog(@"请求的url : %@",url);
    
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:YES postData:postData];
    [tool requestSpecialCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"result %@ erro %@",result,erro);
        
        int status = [[result objectForKey:@"status"]integerValue];
        
        if (status == 1) {
            
//            [loading hide:YES];
            
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
        
//        [loading hide:YES];
        
    }];
}






@end
