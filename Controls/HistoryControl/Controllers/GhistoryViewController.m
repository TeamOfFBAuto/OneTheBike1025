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

@interface GhistoryViewController ()

@end

@implementation GhistoryViewController


-(void)viewDidLoad{
    [super viewDidLoad];
    
//    //下拉刷新
//    
//    _refreshHeaderView = [[EGORefreshTableHeaderView alloc]initWithFrame:CGRectMake(0, 0-_tableView.bounds.size.height, 320, _tableView.bounds.size.height)];
//    _refreshHeaderView.delegate = self;
//    [_tableView addSubview:_refreshHeaderView];
//    _currentPage = 1;
//    _isupMore = NO;//是否为上提加载
//    _isUpMoreSuccess = NO;//上提加载是否成功
    
    
    
//    //上提加载更多
//    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
//    _upMoreView = [[LoadingIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
//    _upMoreView.type = 1;
//    _upMoreView.hidden = YES;
//    [view addSubview:_upMoreView];
//    
//    _tableView.tableFooterView = view;
    
    
    
    
}

-(void)viewWillAppear:(BOOL)animated {
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
    
    
    
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, 320, iPhone5? 568-64-44 : 480-64-44) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    
    UIView *topInfoView = [self customTableHeaderView];
    _tableView.tableHeaderView = topInfoView;
    
    
    //给属性分配内存
    self.netDataArray = [NSMutableArray arrayWithCapacity:1];
    
    [self.view addSubview:upGrayView];
    
    //请求网络数据
    [self netDataWithPage:1];
    
    
    //取本地数据
//    [self dataAarrayWithLocal];
    
    
    // Do any additional setup after loading the view.
}


//从本地取数据
-(void)dataAarrayWithLocal{
    
    
    NSArray *localGuijiArray = [GMAPI GgetGuiji];
    
    for (LRoadClass *model in localGuijiArray) {
        
        if (![model.serverRoadId isEqualToString:@"已上传"]) {
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
            
            
            [self.netDataArray addObject:gmodel];
            
        }
        
        
    }
    
    
    
    [self paixuWithDateWithArray:self.netDataArray];
    
}


-(void)netDataWithPage:(int)thePage{
    
    NSString *urlStr = [NSString stringWithFormat:BIKE_ROAD_LINE_GETGUIJILIST,[LTools cacheForKey:USER_CUSTID],thePage];
    
    NSLog(@"请求轨迹历史接口的url:%@",urlStr);
    
    
    LTools *tool = [[LTools alloc]initWithUrl:urlStr isPost:NO postData:nil];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"result = %@",result);
        
        self.totalCishuLabel.text = [NSString stringWithFormat:@"%@",[result objectForKey:@"Total"]];
        self.totalYongshiLabel.text = [result objectForKey:@"sumCostTime"];
        
        
        self.topTotalDistanceLabel.text = [NSString stringWithFormat:@"%@公里",[result objectForKey:@"sumCyclingKm"]];
        
        
        if ([result objectForKey:@"status"]) {
            
            NSArray *rows = [result objectForKey:@"Rows"];
            
            NSLog(@"rows.count = %d",rows.count);
            
            for (int i = 0; i<rows.count;i++) {
                NSArray *arr = rows[i];
                
                for (int j = 0;j<arr.count;j++) {
                    
                    NSDictionary *dic = arr[j];
                    
                    GyundongCanshuModel *model = [[GyundongCanshuModel alloc]init];
                    
                    
                    model.pingjunsudu = [[dic objectForKey:@"avgSpeed"]floatValue];
                    model.startCoorStr = [dic objectForKey:@"beginCoordinates"];
                    model.coorStr = [dic objectForKey:@"endCoordinates"];
                    
                    NSString *beginTime = [NSString stringWithFormat:@"%@",[dic objectForKey:@"beginTime"]];
                    model.startTime = [GMAPI timechange:[beginTime substringToIndex:beginTime.length - 3]];
                    
                    NSString *endTime = [NSString stringWithFormat:@"%@",[dic objectForKey:@"endTime"]];
                    model.endTime = [GMAPI timechange:[endTime substringToIndex:beginTime.length-3]];
                    
                    
                    
                    model.yongshi = [NSString stringWithFormat:@"%@",[dic objectForKey:@"costTime"]];
                    model.juli = [[dic objectForKey:@"cyclingKm"]floatValue];
                    model.jsonStr = [dic objectForKey:@"roadlines"];
                    model.haibaUp = (int)[dic objectForKey:@"upMetre"];
                    model.haibaDown = (int)[dic objectForKey:@"downMetre"];
                    model.maxSudu = [[NSString stringWithFormat:@"%@",[dic objectForKey:@"topSpeed"]] floatValue];
                    
                    
                    
                    
                    
                    NSLog(@" ,,,,, %@",model.jsonStr);
                    
                    //1414634471
                    //1414605769
                    
                    NSLog(@"--timeline %@",[LTools timechangeToDateline]);
                    
                    NSLog(@"轨迹字典 ----------- :%@",dic);
                    
                    [self.netDataArray addObject:model];
                }
            }
            
             NSLog(@"self.netDataArray.count = %d",self.netDataArray.count);
            
            
            
          
//            //判断有没有更多
//            if (self.netDataArray.count <100) {
//                [_upMoreView stopLoading:3];
//            }else{
//                [_upMoreView stopLoading:1];
//            }
//            
//            
//            //判断是否为上提加载更多
//            if (_isupMore) {//是加载更多的话把请求到的文章加到原来的数组中
//                [self.netDataArray addObjectsFromArray:(NSArray*)array];
//                
//                
//            }else{//不是上提加载更多
//                self.netDataArray = array;
//            }
//            
//            
//            _isUpMoreSuccess = YES;//上提加载更多的标志位
//            
//            
//            //有文章再显示上提加载更多
//            if (self.netDataArray.count>0) {
//                _upMoreView.hidden = NO;
//            }else{
//                _upMoreView.hidden = YES;
//            }
            
            
            
#pragma mark -取本地数据
//            NSArray *localGuijiArray = [GMAPI GgetGuiji];
//            for (LRoadClass *model in localGuijiArray) {
//                
//                if (![model.serverRoadId isEqualToString:@"已上传"]) {
//                    NSString *startNameStr = model.startName;
//                    NSString *endNameStr = model.endName;
//                    NSArray * startArr = [startNameStr componentsSeparatedByString:@","];
//                    NSArray *endArr = [endNameStr componentsSeparatedByString:@","];
//                    
//                    GyundongCanshuModel *gmodel = [[GyundongCanshuModel alloc]init];
//                    gmodel.jsonStr = model.lineString;
//                    gmodel.startTime = startArr[0];
//                    gmodel.endTime = startArr[1];
//                    gmodel.yongshi = startArr[2];
//                    gmodel.juli = [endArr[0]floatValue];
//                    gmodel.pingjunsudu = [endArr[1]floatValue];
//                    gmodel.maxSudu = [endArr[2]floatValue];
//                    gmodel.haibaUp = [endArr[3]floatValue];
//                    gmodel.haibaDown = [endArr[4]intValue];
//                    gmodel.bpm = [endArr[5]intValue];
//                    gmodel.xinlv = [endArr[6]intValue];
//                    gmodel.juli = [model.distance floatValue];
//                    gmodel.startCoorStr = [NSString stringWithFormat:@"%f,%f",model.startCoor.latitude,model.startCoor.longitude];
//                    gmodel.coorStr = [NSString stringWithFormat:@"%f,%f",model.endCoor.latitude,model.endCoor.longitude];
//                    
//                    
//                    [self.netDataArray addObject:gmodel];
//                }
//                
//               
//            }
            
            
            
            //按照时间排序
            [self paixuWithDateWithArray:self.netDataArray];
            
            
            
        }
        
        
        
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"获取用户轨迹失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [al show];
        
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
            
            NSString *date1 = [road1.startTime substringWithRange:NSMakeRange(0, 10)];
            NSString *date2 = [road2.startTime substringWithRange:NSMakeRange(0, 10)];
            
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
    UIImageView *showOrHiddenImv = [[UIImageView alloc]initWithFrame:CGRectMake(24, 10, 40, 20)];
    showOrHiddenImv.tag = section +1000;
    showOrHiddenImv.backgroundColor = [UIColor whiteColor];
    
    if ( !isOpen[section]) {
        [showOrHiddenImv setImage:[UIImage imageNamed:@"ghistorydown.png"]];
    }else{
        [showOrHiddenImv setImage:[UIImage imageNamed:@"ghistoryup.png"]];
    }
    [upHeaderView addSubview:showOrHiddenImv];
    
    //日期
    UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(showOrHiddenImv.frame)+5, 10, 100, 20)];
    dateLabel.font = [UIFont systemFontOfSize:15];
//    dateLabel.backgroundColor = [UIColor redColor];
    dateLabel.textColor = RGBCOLOR(105, 105, 105);
    [upHeaderView addSubview:dateLabel];

    
    //距离
    UILabel *juliLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(dateLabel.frame)+75, 10, 75, 20)];
    juliLabel.font = [UIFont systemFontOfSize:15];
//    juliLabel.backgroundColor = [UIColor redColor];
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
    GyundongCanshuModel *model = arr[indexPath.section];
    [cell loadCustomCellWithMoedle:model];
    
    return cell;
}





-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        NSMutableArray *dayGuijiArray = self.dataArray[indexPath.section];
//        [dayGuijiArray removeObjectAtIndex:indexPath.row];
//        [_tableView reloadData];
//    }
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
    GHistoryDetailViewController *cc = [[GHistoryDetailViewController alloc]init];
    NSArray *arr = self.dataArray[indexPath.section];
    GyundongCanshuModel *model = arr[indexPath.row];
    cc.passModel = model;
    cc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cc animated:YES];
}






//#pragma mark - 下拉上提 相关代理
//
//-(void)reloadTableViewDataSource{
//    _reloading = YES;
//}
//
//-(void)doneLoadingTableViewData{
//    _reloading = NO;
//    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
//    
//}
//
//
//#pragma mark - EGORefreshTableHeaderDelegate
//
//-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view{
//    _currentPage = 1;
//    _isupMore = NO;
//    [self reloadTableViewDataSource];
//    [self netDataWithPage:_currentPage];
//    
//    
//}
//
//-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view{
//    return _reloading;
//}
//
//- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
//    
//    return [NSDate date];
//}
//
//
//#pragma mark - UIScrollViewDelegate
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    
//    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
//}
//
//-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
//    
//    
//    if(_tableView.contentOffset.y > (_tableView.contentSize.height - _tableView.frame.size.height+40)&&_isUpMoreSuccess==YES&&[self.dataArray count]>0)
//    {
//        [_upMoreView startLoading];
//        _isupMore = YES;
//        if (_guijiCount) {
//            _currentPage++;
//        }
//        
//        _isUpMoreSuccess = NO;
//        [self netDataWithPage:_currentPage];
//    }
//}





@end
