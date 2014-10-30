//
//  HistoryViewController.m
//  OneTheBike
//
//  Created by szk on 14-9-24.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "HistoryViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "LoadingIndicatorView.h"

#import "GcustomHistoryTableViewCell.h"

#import "GHistoryDetailViewController.h"
#import "GyundongCanshuModel.h"
#import "GTimeSwitch.h"
#import "ShareView.h"

@interface HistoryViewController ()<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,UIScrollViewDelegate,ShareViewDelegate>
{
    UITableView *_tableView;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    int _currentPage;
    int _numOnePage;//每页几条数据
    
    //上提加载更多
    LoadingIndicatorView *_upMoreView;//上提加载更多
    BOOL _isUpMoreSuccess;//上提加载成功
    BOOL _isupMore;//是否为上提加载更多
    
    
    //请求轨迹数据 count为0 _currentPage不加
    int _guijiCount;

    
    
}
@end

@implementation HistoryViewController



-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //自定义导航栏
    //总公里数 运动次数 时长
    UIView *upGrayView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, 320, 44)];
    upGrayView.backgroundColor = RGBCOLOR(105, 105, 105);
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.backgroundColor = [UIColor orangeColor];
    [btn setFrame:CGRectMake(270, 5, 40, 40)];
    [btn addTarget:self action:@selector(fenxiangBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *titielLabel = [[UILabel alloc]initWithFrame:CGRectMake(140, 5, 40, 40)];
    titielLabel.textColor = [UIColor whiteColor];
    titielLabel.textAlignment = NSTextAlignmentCenter;
    titielLabel.text = @"历史";
    [upGrayView addSubview:titielLabel];
    
    [self.view addSubview:upGrayView];
    
    
    //展开的数组
    _fangkaiArray = [NSMutableArray arrayWithCapacity:1];
    
    
    
    _currentPage = 1;
    
    //给属性分配内存
    self.dataArray = [NSMutableArray arrayWithCapacity:1];
    self.netDataArray = [NSMutableArray arrayWithCapacity:1];
    self.localDataArray = [NSMutableArray arrayWithCapacity:1];
    
    //准备数据
//    [self prepareLocalDataAndNetData];
    [self netData];
    

    
    self.view.backgroundColor=[UIColor whiteColor];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, 320, iPhone5? 568-64 : 480-64) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    
    //下拉刷新
    
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc]initWithFrame:CGRectMake(0, 0-_tableView.bounds.size.height, 320, _tableView.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    [_tableView addSubview:_refreshHeaderView];
    _currentPage = 1;
    _isupMore = NO;//是否为上提加载
    _isUpMoreSuccess = NO;//上提加载是否成功
    
    
    
    UIView *topInfoView = [self customTableHeaderView];
    _tableView.tableHeaderView = topInfoView;
    
    
    //上提加载更多
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    _upMoreView = [[LoadingIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    _upMoreView.type = 1;
    _upMoreView.hidden = YES;
    [view addSubview:_upMoreView];
    
    _tableView.tableFooterView = view;
    
    
}



//分享
-(void)fenxiangBtnClicked{
    
    ShareView * share_view = [[ShareView alloc] initWithFrame:self.view.bounds];
    share_view.userInteractionEnabled = YES;
    share_view.delegate = self;
    share_view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [share_view showInView:[UIApplication sharedApplication].keyWindow WithAnimation:YES];
    
}


//tableheaderview
-(UIView *)customTableHeaderView{
    
    UIView *upHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 115)];
    upHeaderView.backgroundColor = [UIColor whiteColor];
    
    self.totalYongshiLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 20, 100, 25)];
    //        self.totalYongshiLabel.backgroundColor = [UIColor orangeColor];
    self.totalYongshiLabel.font = [UIFont systemFontOfSize:25];
    self.totalYongshiLabel.text = @"0";
    self.totalYongshiLabel.textAlignment = NSTextAlignmentRight;
    [upHeaderView addSubview:self.totalYongshiLabel];
    
    //用时单位 公里
    UILabel *danweiLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.totalYongshiLabel.frame)+5, self.totalYongshiLabel.frame.origin.y, 80, 25)];
    danweiLabel.font = [UIFont systemFontOfSize:25];
    danweiLabel.textAlignment = NSTextAlignmentLeft;
    //        danweiLabel.backgroundColor = [UIColor purpleColor];
    danweiLabel.text = @"公里";
    [upHeaderView addSubview:danweiLabel];
    
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


//准备本地数据和网络数据
-(void)prepareLocalDataAndNetData{
    
    [self prepareNetDataWithPage:1];//接口有问题
    //只从本地拿数据
//    [self OnlyPrepareLocalData];
    
    
    
}


-(void)netData{
    
    NSString *urlStr = [NSString stringWithFormat:BIKE_ROAD_LINE_GETGUIJILIST,[LTools cacheForKey:USER_CUSTID],1];
    
    NSLog(@"请求轨迹历史接口的url:%@",urlStr);
    
    
    LTools *tool = [[LTools alloc]initWithUrl:urlStr isPost:NO postData:nil];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"result = %@",result);
        
        if ([result objectForKey:@"status"]) {
            
            NSArray *rows = [result objectForKey:@"Rows"];
            NSLog(@"%d",rows.count);
            
            for (NSArray *arr in rows) {
                NSLog(@"arr.count %d",arr.count);
                for (NSDictionary *dic in arr) {
                    NSLog(@"dic %@",dic);
                    GyundongCanshuModel *model = [[GyundongCanshuModel alloc]init];
                    model.pingjunsudu = [[dic objectForKey:@"avgSpeed"]floatValue];
                    model.startCoorStr = [dic objectForKey:@"beginCoordinates"];
                    model.startTime = [dic objectForKey:@"beginTime"];
                    model.endTime = [dic objectForKey:@"endTime"];
                    model.yongshi = [dic objectForKey:@"costTime"];
                    model.juli = [[dic objectForKey:@"cyclingKm"]floatValue];
                    model.jsonStr = [dic objectForKey:@"roadlines"];
                    [self.dataArray addObject:model];
                }
            }
            
//            [self paixuWithDateWithArray:self.netDataArray];
            
            
            [_tableView reloadData];
            
        }
        
        
        
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        NSLog(@"错误");
        
    }];
}


//取本地数据 加到网络请求的数组中
-(void)prepareLocalData{
    self.localDataArray = [NSMutableArray arrayWithArray:[GMAPI GgetGuiji]];
    
    for (LRoadClass *model in self.localDataArray) {
        NSString *localIdStr= [NSString stringWithFormat:@"%d",model.roadId];
        
        if ([localIdStr isEqualToString:model.serverRoadId]) {//已上传
            
        }else{
            [self.netDataArray addObject:model];
        }
    }
    
}


//只从本地拿数据
-(void)OnlyPrepareLocalData{
    self.localDataArray = [NSMutableArray arrayWithArray:[GMAPI GgetGuiji]];
    
    [self paixuWithDateWithArray:self.localDataArray];
}



//按日期排序
-(void)paixuWithDateWithArray:(NSMutableArray *)array{//array为融合数组
    
    
    NSLog(@"%s %d",__FUNCTION__,array.count);
    
    for (GyundongCanshuModel *model in array) {
        NSLog(@"model.startTime   %@",model.startTime);
    }
    int count = array.count;
    
    //找出同一天的文章 放到一个数组里
    for (int i = 0; i < count; i++) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
        
        for (int j = i+1; j<count; j++) {
            GyundongCanshuModel *road1 = array[i];
            GyundongCanshuModel *road2 = array[j];
            //判断时间
            
            NSString *date1 = [GTimeSwitch testtime:road1.startTime];
            NSString *date2 = [GTimeSwitch testtime:road2.startTime];
            
            if ([date1  isEqualToString:date2]) {
                //如果相同并且日期 = NO 就加入数组里
                
                NSLog(@"%@",road1.startTime);
                
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
        
        LRoadClass *road1 = array[i];
        if (arr.count == 0 && !road1.time) {//判断一天只有一个文章的情况
            [arr addObject:road1];
        }
        
        if (arr.count > 0) {
            
            [self.dataArray addObject:arr];
            
            NSLog(@"self.dataArray.count : %d",self.dataArray.count);
            
            NSLog(@"arr.count : %d",arr.count);
            
        }
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    
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
    
    
    
    GyundongCanshuModel *model = self.dataArray[indexPath.row];
    
    [cell loadCustomCellWithMoedle:model];
    
    return cell;
}



-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *dayGuijiArray = _dataArray[indexPath.section];
        [dayGuijiArray removeObjectAtIndex:indexPath.row];
        [_tableView reloadData];
    }
}











-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    
//    int num = self.dataArray.count;
    
    
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    int num = 0;
    
//    for (NSString *str in _fangkaiArray) {
//        if ([str intValue] == section) {
//            if (self.dataArray.count>0) {
//                NSArray *arr = self.dataArray[section];
//                num = arr.count;
//            }
//        }
//    }
    
    num = self.dataArray.count;
    
    
    return num;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}





//-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView *upHeaderView = [[UIView alloc]initWithFrame:CGRectZero];
//    upHeaderView.tag = section +10;
//    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gShouFangZiRu:)];
//    [upHeaderView addGestureRecognizer:tap];
//    
//    upHeaderView.frame = CGRectMake(0, 0, 320, 30);
//    upHeaderView.backgroundColor = RGBCOLOR(190, 190, 190);
//    
//    
//    UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 200, 20)];
//    dateLabel.font = [UIFont systemFontOfSize:15];
//    
////    LRoadClass *model = self.localDataArray[section][0];
//    [upHeaderView addSubview:dateLabel];
//    
//    
//    
//    NSMutableArray *arr = self.dataArray[section];
//    GyundongCanshuModel *model = arr[0];
//    dateLabel.text = [GTimeSwitch testtime:model.startTime];
//    
//    
//    return upHeaderView;
//}






//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    CGFloat height = 0;
//    height = 30;
//    return height;
//}

//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    return 5;
//}



-(void)gShouFangZiRu:(UIGestureRecognizer*)ges{
    
    
        
    NSString *sectionStr = [NSString stringWithFormat:@"%d",(ges.view.tag-10)];
    
    NSLog(@" section %@",sectionStr);
    
    int arrCount = _fangkaiArray.count;
    BOOL ishave = NO;
    
    for (int i = 0; i<arrCount; i++) {
        NSString *str = _fangkaiArray[i];
        if ([str isEqualToString:sectionStr]) {
            ishave = YES;
            [_fangkaiArray removeObject:str];
        }
    }
    
    if (!ishave || arrCount==0) {
        [_fangkaiArray addObject:sectionStr];
    }
    
    [_tableView reloadData];
        
    
}



#pragma mark - 请求网络数据
-(void)prepareNetDataWithPage:(int)page{
    
    NSString *urlStr = [NSString stringWithFormat:BIKE_ROAD_LINE_GETGUIJILIST,[LTools cacheForKey:USER_CUSTID],page];
    
    
    NSLog(@"请求轨迹历史接口的url:%@",urlStr);
    
    
    LTools *tool = [[LTools alloc]initWithUrl:urlStr isPost:NO postData:nil];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        NSLog(@"请求轨迹历史接口返回的dic ： %@",result);
        
        
        
        
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];//网络获取到得数组
        
        _guijiCount = array.count;
        
        
        //判断有没有更多
        if (array.count <_numOnePage) {
            [_upMoreView stopLoading:3];
        }else{
            [_upMoreView stopLoading:1];
        }
        
        
        //判断是否为上提加载更多
        if (_isupMore) {//是加载更多的话把请求到的文章加到原来的数组中
            [self.netDataArray addObjectsFromArray:(NSArray*)array];
            
            
        }else{//不是上提加载更多
            self.netDataArray = array;
        }
        
        
        _isUpMoreSuccess = YES;//上提加载更多的标志位
        
        
        //有文章再显示上提加载更多
        if (self.netDataArray.count>0) {
            _upMoreView.hidden = NO;
        }else{
            _upMoreView.hidden = YES;
        }
        
        
        
        //取本地数据
        [self prepareLocalData];
        
        //按照天数排出二维数组
        [self paixuWithDateWithArray:self.netDataArray];
        
        
        //刷新tableview
        [self doneLoadingTableViewData];
        
        
        
        
        
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"网络连接失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [al show];
        
        self.dataArray = [NSMutableArray arrayWithArray:[GMAPI GgetGuiji]];
        
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];//网络获取到得数组
        
        _guijiCount = array.count;
        
        _isUpMoreSuccess = YES;//上提加载更多的标志位
        _upMoreView.hidden = YES;
        
        //取本地数据
        [self prepareLocalData];
        
        //按照天数排出二维数组
        [self paixuWithDateWithArray:self.netDataArray];
        
        
        //刷新tableview
        [self doneLoadingTableViewData];
        
    }];
    
    
    
    
    
    
    
    
}






#pragma mark - 下拉上提 相关代理

-(void)reloadTableViewDataSource{
    _reloading = YES;
}

-(void)doneLoadingTableViewData{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
    
}


#pragma mark - EGORefreshTableHeaderDelegate

-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view{
    _currentPage = 1;
    _isupMore = NO;
    [self reloadTableViewDataSource];
    [self prepareNetDataWithPage:_currentPage];
    
    
}

-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view{
    return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date];
}


#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
    
    if(_tableView.contentOffset.y > (_tableView.contentSize.height - _tableView.frame.size.height+40)&&_isUpMoreSuccess==YES&&[self.dataArray count]>0)
    {
        [_upMoreView startLoading];
        _isupMore = YES;
        if (_guijiCount) {
            _currentPage++;
        }
        
        _isUpMoreSuccess = NO;
        [self prepareNetDataWithPage:_currentPage];
    }
}





-(void)gGoBackVc{
    [self.navigationController popViewControllerAnimated:YES];
}





-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    GHistoryDetailViewController *cc = [[GHistoryDetailViewController alloc]init];
    NSArray *arr = self.dataArray[indexPath.section];
    LRoadClass *model = arr[indexPath.row];
    cc.passModel = model;
    cc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cc animated:YES];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
