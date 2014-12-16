//
//  GhistoryViewController.m
//  OneTheBike
//
//  Created by gaomeng on 14/10/30.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "GhistoryViewController.h"
#import "GyundongCanshuModel.h"
#import "GcustomHistoryTableViewCell.h"
#import "GHistoryDetailViewController.h"

#import "GTimeSwitch.h"

#import "AFNetworking.h"

@interface GhistoryViewController ()

@end

@implementation GhistoryViewController


-(void)viewDidLoad{
    [super viewDidLoad];
    for (int i=0; i<2000; i++) {
        isOpen[i]=0;
    }
    
    
    self.navigationController.navigationBarHidden = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        self.navigationController.navigationBar.translucent = NO;
    }
    
    
    //给属性分配内存
    self.dataArray = [NSMutableArray arrayWithCapacity:1];
    self.netDataArray = [NSMutableArray arrayWithCapacity:1];
    //展开的数组
    _fangkaiArray = [NSMutableArray arrayWithCapacity:1];
    
    
    //自定义导航栏
    UIView *upGrayView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, 320, 44)];
    upGrayView.backgroundColor = RGBCOLOR(105, 105, 105);
    
    
    UILabel *titielLabel = [[UILabel alloc]initWithFrame:CGRectMake(140, 0, 44, 44)];
    titielLabel.textColor = [UIColor whiteColor];
    titielLabel.textAlignment = NSTextAlignmentCenter;
    titielLabel.text = @"历史";
    [upGrayView addSubview:titielLabel];
    
    [self.view addSubview:upGrayView];
    
    
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, 320, iPhone5? 568-44-64 : 480-44-64) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    
    UIView *topInfoView = [self customTableHeaderView];
    _tableView.tableHeaderView = topInfoView;
    
    NSLog(@"%@",NSStringFromCGRect(_tableView.tableHeaderView.frame));
    
    
    //给属性分配内存
    self.netDataArray = [NSMutableArray arrayWithCapacity:1];
    
    
    
    
    //判断网络是否可用
    //开启监控
    //[[AFNetworkActivityIndicatorManager sharedManager]setEnabled:YES];
    AFNetworkReachabilityManager *afnrm =[AFNetworkReachabilityManager sharedManager];
    [afnrm startMonitoring];
    //设置网络状况监控后的代码块
    [afnrm setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch ([[AFNetworkReachabilityManager sharedManager]networkReachabilityStatus]) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WiFi");
                [self upLoadDataToNet];
                [self netDataWithPage:1];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"WWAN");
                [self upLoadDataToNet];
                [self netDataWithPage:1];
                break;
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"Unknown");
                
                [self dataAarrayWithLocal];
                
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"NotReachable");
                [self dataAarrayWithLocal];
                break;
            default:
                break;
        }
    }];
        
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(netDataWithPage:) name:@"gstopandnosave" object:nil];
    
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewDidLoad];
  
    // Do any additional setup after loading the view.

    
    
}



#pragma mark - 本地数据isUpload == no 上传服务器
-(void)upLoadDataToNet{
    NSArray *localArray = [GMAPI getRoadLinesForType:2];
    for (LRoadClass *model in localArray) {
        if (!model.isUpload) {
            NSString *custId =  [LTools cacheForKey:USER_CUSTID];
            NSString *startNameStr = model.startName;
            NSString *endNameStr = model.endName;
            NSArray * startArr = [startNameStr componentsSeparatedByString:@","];
            NSArray *endArr = [endNameStr componentsSeparatedByString:@","];
            
            GyundongCanshuModel *gmodel = [[GyundongCanshuModel alloc]init];
            gmodel.jsonStr = model.lineString;
            gmodel.startTime = startArr[0];
            gmodel.endTime = startArr[1];
            gmodel.yongshi = startArr[2];
            gmodel.juli = [endArr[0]floatValue];
            gmodel.pingjunsudu = [endArr[1]floatValue];
            gmodel.maxSudu = [endArr[2]floatValue];
            gmodel.haibaUp = [endArr[3]floatValue];
            gmodel.haibaDown = [endArr[4]intValue];
            gmodel.bpm = [endArr[5]intValue];
            gmodel.xinlv = [endArr[6]intValue];
            gmodel.juli = [model.distance floatValue];
            gmodel.startCoorStr = [NSString stringWithFormat:@"%f,%f",model.startCoor.latitude,model.startCoor.longitude];
            gmodel.coorStr = [NSString stringWithFormat:@"%f,%f",model.endCoor.latitude,model.endCoor.longitude];
            gmodel.serverRoadId = model.serverRoadId;
            NSInteger localeid = model.roadId;
            gmodel.localId = localeid;
            gmodel.isUpLoad = model.isUpload;
            
            
            
                //上传
                [self saveRoadlinesJsonString:gmodel.jsonStr
                                       custId:custId
                                    cyclingKm:gmodel.juli
                                      upMetre:gmodel.haibaUp
                                    downMetre:gmodel.haibaDown
                                 costCalories:gmodel.bpm
                                     avgSpeed:gmodel.pingjunsudu
                                     topSpeed:gmodel.maxSudu
                                    heartRate:gmodel.xinlv
                                    beginTime:gmodel.startTime
                                      endTime:gmodel.endTime
                                     costTime:gmodel.yongshi
                                    beginSite:@" "
                                      endSite:@" "
                             beginCoordinates:gmodel.startCoorStr
                               endCoordinates:gmodel.coorStr
                                    localflag:gmodel.serverRoadId];
            
            
            
            
            
            
        }
    }
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
                      localflag:(NSString *)locacustomflag

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
            
            NSString *fuwuqiid = [result objectForKey:@"cycId"];
            LRoadClass *needUpDataModel = [GMAPI getRoadLinesForDateLineId:locacustomflag];
            [GMAPI updateRoadId:needUpDataModel.roadId serverRoadId:fuwuqiid isUpload:YES];
        }
        
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        NSLog(@"failDic %@ erro %@",failDic,[failDic objectForKey:@"ERRO_INFO"]);
        
    }];
}


//从本地取数据
-(void)dataAarrayWithLocal{
    
    if (self.dataArray) {
        [self.dataArray removeAllObjects];
    }
    
    if (self.netDataArray) {
        [self.netDataArray removeAllObjects];
    }
    
    NSArray *localGuijiArray = [GMAPI getRoadLinesForType:2];
    for (LRoadClass *model in localGuijiArray) {
            NSString *startNameStr = model.startName;
            NSString *endNameStr = model.endName;
            NSArray * startArr = [startNameStr componentsSeparatedByString:@","];
            NSArray *endArr = [endNameStr componentsSeparatedByString:@","];
            
            GyundongCanshuModel *gmodel = [[GyundongCanshuModel alloc]init];
            gmodel.jsonStr = model.lineString;
            gmodel.startTime = startArr[0];
            gmodel.endTime = startArr[1];
            gmodel.yongshi = startArr[2];
            gmodel.juli = [endArr[0]floatValue];
            gmodel.pingjunsudu = [endArr[1]floatValue];
            gmodel.maxSudu = [endArr[2]floatValue];
            gmodel.haibaUp = [endArr[3]floatValue];
            gmodel.haibaDown = [endArr[4]intValue];
            gmodel.bpm = [endArr[5]intValue];
            gmodel.xinlv = [endArr[6]intValue];
        
            if (endArr.count>7) {
                gmodel.yongshiMiao = [endArr[7]intValue];
            }
        
            gmodel.juli = [model.distance floatValue];
            gmodel.startCoorStr = [NSString stringWithFormat:@"%f,%f",model.startCoor.latitude,model.startCoor.longitude];
            gmodel.coorStr = [NSString stringWithFormat:@"%f,%f",model.endCoor.latitude,model.endCoor.longitude];
            gmodel.serverRoadId = model.serverRoadId;
        
            NSInteger localeid = model.roadId;
            gmodel.localId = localeid;
            gmodel.isUpLoad = model.isUpload;
            [self.netDataArray addObject:gmodel];
        
        
        NSLog(@"localid %d",model.roadId);
        NSLog(@"serverid %@",model.serverRoadId);
        NSLog(@"isupload %d",model.isUpload);
        
        
    }
    
    
    
    [self paixuWithDateWithArray:self.netDataArray];
    
    
}

//取网络数据
-(void)netDataWithPage:(int)thePage{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *urlStr = [NSString stringWithFormat:BIKE_ROAD_LINE_GETGUIJILIST,[LTools cacheForKey:USER_CUSTID],1];
    NSLog(@"请求轨迹历史接口的url:%@",urlStr);
    LTools *tool = [[LTools alloc]initWithUrl:urlStr isPost:NO postData:nil];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"result = %@",result);
        self.totalCishuLabel.text = [NSString stringWithFormat:@"%@",[result objectForKey:@"Total"]];
        self.totalYongshiLabel.text = [result objectForKey:@"sumCostTime"];
        self.topTotalDistanceLabel.text = [NSString stringWithFormat:@"%@公里",[result objectForKey:@"sumCyclingKm"]];
        if ([result objectForKey:@"status"]) {
            NSArray *rows = [result objectForKey:@"Rows"];
            NSLog(@"rows.count = %d",rows.count);
            if (rows.count>0) {//网络请求下了数据
                NSArray *arr = [GMAPI getRoadLinesForType:2];//找出所有本地的数据
                for (LRoadClass *model in arr) {
                    if (model.isUpload) {//删除上传过的数据
                        [GMAPI deleteRoadId:model.roadId type:2];
                    }
                }
            }
            for (int i = 0; i<rows.count;i++) {
                NSArray *arr = rows[i];
                for (int j = 0;j<arr.count;j++) {
                    NSDictionary *dic = arr[j];
                    GyundongCanshuModel *model = [[GyundongCanshuModel alloc]init];
                    model.pingjunsudu = [[dic objectForKey:@"avgSpeed"]floatValue];
                    model.startCoorStr = [dic objectForKey:@"beginCoordinates"];
                    model.coorStr = [dic objectForKey:@"endCoordinates"];
                    NSString *beginTime = [NSString stringWithFormat:@"%@",[dic objectForKey:@"beginTime"]];
//                    model.startTime = [GMAPI timechange:[beginTime substringToIndex:beginTime.length - 3]];
                    model.startTime = beginTime;
                    NSString *endTime = [NSString stringWithFormat:@"%@",[dic objectForKey:@"endTime"]];
//                    model.endTime = [GMAPI timechange:[endTime substringToIndex:beginTime.length-3]];
                    model.endTime = endTime;
                    model.yongshi = [NSString stringWithFormat:@"%@",[dic objectForKey:@"costTimeBak"]];
                    model.juli = [[dic objectForKey:@"cyclingKm"]floatValue];
                    model.jsonStr = [dic objectForKey:@"roadlines"];
                    model.haibaUp = [[dic objectForKey:@"upMetre"]intValue];
                    model.haibaDown = [[dic objectForKey:@"downMetre"]intValue];
                    model.maxSudu = [[NSString stringWithFormat:@"%@",[dic objectForKey:@"topSpeed"]] floatValue];
                    model.serverRoadId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"cycId"]];
                    NSLog(@"%d",model.haibaUp);
                    NSLog(@"%d",model.haibaDown);
                    NSLog(@" ,,,,, %@",model.jsonStr);
                    NSLog(@"轨迹字典 ----------- :%@",dic);
                    NSInteger yongshiMiao = [[dic objectForKey:@"costTime"]integerValue];
                    model.yongshiMiao = yongshiMiao;
#pragma mark - 保存轨迹到本地数据库
                    NSString *gStartName = [NSString stringWithFormat:@"%@,%@,%@",model.startTime,model.endTime,model.yongshi];
                    
                    NSString *gEndName = [NSString stringWithFormat:@"%.1f,%.1f,%.1f,%d,%d,%d,%d,%d",model.juli,model.pingjunsudu,model.maxSudu,model.haibaUp,model.haibaDown,model.bpm,model.xinlv,yongshiMiao];
                    NSString *gDistance = [NSString stringWithFormat:@"%.1f",model.juli];
                    NSString *gStartCoorStr = model.startCoorStr;
                    NSString *gEndCoorStr = model.coorStr;
                    NSString *jsonStr = model.jsonStr;
                        //本地保存数据
                        //jsostr 轨迹数据
                        //startName 开始时间 结束时间 用时
                        //endName 距离 平均速度 最高速度 上升海拔 下降海拔 卡路里 心率
                        //distance 距离
                        //type 1为路书 2为轨迹
                        //startCoorStr 开始经纬度
                        //endCoorStr 结束经纬度
                        [GMAPI addRoadLinesJsonString:jsonStr startName:gStartName endName:gEndName distance:gDistance type:2 startCoorStr:gStartCoorStr endCoorStr:gEndCoorStr serverRoadId:model.serverRoadId isUpload:YES];
                }
            }
            
        }
        
        [self dataAarrayWithLocal];//取出所有本地数据并且按照时间排序
        [_tableView reloadData];//重载界面
   
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self dataAarrayWithLocal];//取出所有本地数据并且按照时间排序
        [_tableView reloadData];//重载界面
        
    }];
}



//按日期排序
-(void)paixuWithDateWithArray:(NSMutableArray *)array{//array为融合数组
    
    
    NSLog(@"%s %d",__FUNCTION__,array.count);
    
//    for (GyundongCanshuModel *model in array) {
//        NSLog(@"model.startTime   %@",model.startTime);
//    }
    int count = array.count;
    
    //找出同一天的文章 放到一个数组里
    for (int i = 0; i < count; i++) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
        
        for (int j = i+1; j<count; j++) {
            GyundongCanshuModel *road1 = array[i];
            GyundongCanshuModel *road2 = array[j];
            //判断时间
            
            NSString *date1 = [road1.startTime substringWithRange:NSMakeRange(0, 7)];
            NSString *date2 = [road2.startTime substringWithRange:NSMakeRange(0, 7)];
            
            
            NSLog(@"%@",date1);
            NSLog(@"%@",date2);
            
            if ([date1  isEqualToString:date2]) {
                //如果相同并且日期 = NO 就加入数组里
                
                NSLog(@"road1.startTime 年 月 %@",road1.startTime);
                NSLog(@"日期截取判断 %@",date1);
                
                if (!road1.time) {
                    
                    [arr addObject:road1];
                    road1.time = YES;
                }
                
                if (!road2.time) {
                    
                    [arr addObject:road2];
                    road2.time = YES;
                }
            }
        }
        
        GyundongCanshuModel *road1 = array[i];
        if (arr.count == 0 && !road1.time) {//判断一天只有一个文章的情况
            [arr addObject:road1];
        }
        
        if (arr.count > 0) {
            
            [self.dataArray addObject:arr];
            
            NSLog(@"self.dataArray.count : %d",self.dataArray.count);
            
            NSLog(@"arr.count : %d",arr.count);
            
        }
    }
    
    
    
    double zongjuli = 0.0;
    NSInteger zongcishu = 0;
    NSInteger yongshiMiao = 0;
    
    for (NSArray *arr in self.dataArray) {
        zongcishu += arr.count;
        for (GyundongCanshuModel *model in arr) {
            zongjuli += model.juli;
            yongshiMiao += model.yongshiMiao;
        }
    }
    
    int hh = yongshiMiao/3600;
    int mm = (yongshiMiao%3600)/60;
    int ss = yongshiMiao%3600%60;
    NSString *yongshiStr = @"00:00:00";
    if (hh<100) {
        yongshiStr = [NSString stringWithFormat:@"%02d:%02d:%02d",hh,mm,ss];
    }else if (hh>100){
        yongshiStr = [NSString stringWithFormat:@"%d:%02d:%02d",hh,mm,ss];
    }
    
    self.topTotalDistanceLabel.text = [NSString stringWithFormat:@"%.1f公里",zongjuli];
    self.totalCishuLabel.text = [NSString stringWithFormat:@"%d",zongcishu];
    self.totalYongshiLabel.text = yongshiStr;
    [_tableView reloadData];
    
    
    
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return self.dataArray.count;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    int num = 0;
    
 
    
    if (self.dataArray.count>0) {
        
        
        NSArray *arr = self.dataArray[section];
        
        if (!isOpen[section]) {
            num=0;
        }else{
            
            num=arr.count;
        }
        
        
    }
    
    return num;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}





-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *upHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    upHeaderView.userInteractionEnabled = YES;
    upHeaderView.tag = section +10;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ggShouFang:)];
    
    [upHeaderView addGestureRecognizer:tap];

    upHeaderView.frame = CGRectMake(0, 0, 320, 30);
    upHeaderView.backgroundColor = RGBCOLOR(190, 190, 190);

    //箭头
    UIImageView *showOrHiddenImv = [[UIImageView alloc]initWithFrame:CGRectMake(14, 10, 20, 20)];
    
    
    if ( !isOpen[section]) {
        [showOrHiddenImv setImage:[UIImage imageNamed:@"ghistorydown.png"]];
    }else{
        [showOrHiddenImv setImage:[UIImage imageNamed:@"ghistoryup.png"]];
    }
    [upHeaderView addSubview:showOrHiddenImv];
    
    //日期
    UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(showOrHiddenImv.frame)+10, 10, 100, 20)];
    dateLabel.font = [UIFont systemFontOfSize:15];

    dateLabel.textColor = RGBCOLOR(105, 105, 105);
    [upHeaderView addSubview:dateLabel];

    
    //距离
    UILabel *juliLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(dateLabel.frame)+75, 10, 75, 20)];
    juliLabel.font = [UIFont systemFontOfSize:15];

    juliLabel.textColor = RGBCOLOR(105, 105, 105);
    [upHeaderView addSubview:juliLabel];
    
    CGFloat juli  = 0;
    
    if (self.dataArray.count>0) {
        
        for (NSArray *arr in self.dataArray) {
            
            for (GyundongCanshuModel *model in arr) {
                juli +=model.juli;
            }
        }
    }
    
    juliLabel.text = [NSString stringWithFormat:@"%.1fkm",juli];

    NSMutableArray *arr = self.dataArray[section];
    GyundongCanshuModel *model = arr[0];
    dateLabel.text = model.startTime;
    if (model.startTime.length >9) {
        NSString *month = [model.startTime substringWithRange:NSMakeRange(5, 2)];
        NSString *year = [model.startTime substringWithRange:NSMakeRange(0, 4)];
        dateLabel.text = [NSString stringWithFormat:@"%@月%@年",month,year];
    }

    return upHeaderView;
}


-(void)ggShouFang:(UIGestureRecognizer*)ges{
    
    
    isOpen[ges.view.tag-10]=!isOpen[ges.view.tag-10];
    [_tableView reloadData];
    
    
}




-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    GcustomHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GcustomHistoryTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    
    NSArray *arr = self.dataArray[indexPath.section];
    GyundongCanshuModel *model = arr[indexPath.row];
    
    
    
    [cell loadCustomCellWithMoedle:model];
    
    return cell;
}



#pragma mark - 删除数据 (本地和网络)

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *dayGuijiArray = self.dataArray[indexPath.section];
        GyundongCanshuModel *model = dayGuijiArray[indexPath.row];
        
        NSLog(@"%d",model.localId);
        
        if (model.isUpLoad) {//已经上传过
            if (model.serverRoadId ) {
                NSString *urlStr = [NSString stringWithFormat:BIKE_GUIJI_DELETE,model.serverRoadId];
                
                NSLog(@"请求删除轨迹历史接口的url:%@",urlStr);
                
                LTools *tool = [[LTools alloc]initWithUrl:urlStr isPost:NO postData:nil];
                
                [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
                    
                    if (model.localId !=0) {
                        [GMAPI deleteRoadId:model.localId type:2];
                        [self netDataWithPage:1];
                    }
                    
                } failBlock:^(NSDictionary *failDic, NSError *erro) {
                    UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"删除失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [al show];
                    
                }];
            }
            
        }else{
            if (model.localId !=0) {
                [GMAPI deleteRoadId:model.localId type:2];
                [self dataAarrayWithLocal];
                
            }
            
        }
        
        
        
    }
}



//tableheaderview
-(UIView *)customTableHeaderView{
    
    UIView *upHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 115)];
    upHeaderView.backgroundColor = [UIColor whiteColor];
    
    self.topTotalDistanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 320, 25)];
    //        self.totalYongshiLabel.backgroundColor = [UIColor orangeColor];
    self.topTotalDistanceLabel.font = [UIFont systemFontOfSize:25];
    self.topTotalDistanceLabel.text = @"0公里";
    self.topTotalDistanceLabel.textAlignment = NSTextAlignmentCenter;
    [upHeaderView addSubview:self.topTotalDistanceLabel];
    
    //用时单位 公里
    UILabel *danweiLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.topTotalDistanceLabel.frame)+5, self.topTotalDistanceLabel.frame.origin.y, 80, 25)];
    danweiLabel.font = [UIFont systemFontOfSize:25];
    danweiLabel.textAlignment = NSTextAlignmentLeft;
    //        danweiLabel.backgroundColor = [UIColor purpleColor];
    danweiLabel.text = @"公里";
//    [upHeaderView addSubview:danweiLabel];
    
    
    
    //运动次数
    self.totalCishuLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(danweiLabel.frame)+ 30, 100, 12)];
    self.totalCishuLabel.font = [UIFont systemFontOfSize:12];
    self.totalCishuLabel.textAlignment = NSTextAlignmentCenter;
    self.totalCishuLabel.textColor = RGBCOLOR(105, 105, 105);
    //        self.totalCishuLabel.backgroundColor = [UIColor orangeColor];
    self.totalCishuLabel.text = @"0";
    [upHeaderView addSubview:self.totalCishuLabel];
    
    UILabel *cclabel1 = [[UILabel alloc]initWithFrame:CGRectMake(self.totalCishuLabel.frame.origin.x, CGRectGetMaxY(self.totalCishuLabel.frame), 100, 12)];
    cclabel1.font = [UIFont systemFontOfSize:12];
    cclabel1.textColor = RGBCOLOR(105, 105, 105);
    cclabel1.textAlignment = NSTextAlignmentCenter;
    cclabel1.text = @"运动次数";
    [upHeaderView addSubview:cclabel1];
    
    
    //总时长
    self.totalYongshiLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.totalCishuLabel.frame)+60, self.totalCishuLabel.frame.origin.y, 100, 12)];
    self.totalYongshiLabel.font = [UIFont systemFontOfSize:12];
    self.totalYongshiLabel.textAlignment = NSTextAlignmentCenter;
    //        self.totalYongshiLabel.backgroundColor = [UIColor orangeColor];
    self.totalYongshiLabel.textColor = RGBCOLOR(105, 105, 105);
    self.totalYongshiLabel.text = @"00:00:00";
    [upHeaderView addSubview:self.totalYongshiLabel];
    
    UILabel *cccLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.totalYongshiLabel.frame.origin.x, CGRectGetMaxY(self.totalYongshiLabel.frame), 100, 12)];
    cccLabel.textColor = RGBCOLOR(105, 105, 105);
    cccLabel.textAlignment = NSTextAlignmentCenter;
    cccLabel.font = [UIFont systemFontOfSize:12];
    cccLabel.text = @"时长";
    [upHeaderView addSubview:cccLabel];
    
    
    
    return upHeaderView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GHistoryDetailViewController *cc = [[GHistoryDetailViewController alloc]init];
    NSArray *arr = self.dataArray[indexPath.section];
    
    
    GyundongCanshuModel *model = arr[indexPath.row];
    cc.passModel = model;
    cc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cc animated:YES];
}







@end
