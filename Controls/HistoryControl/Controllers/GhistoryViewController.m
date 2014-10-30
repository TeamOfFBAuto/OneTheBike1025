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


-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    
    
    //给属性分配内存
    self.dataArray = [NSMutableArray arrayWithCapacity:1];
    self.netDataArray = [NSMutableArray arrayWithCapacity:1];
    //展开的数组
    _fangkaiArray = [NSMutableArray arrayWithCapacity:1];
    
    
    //自定义导航栏
    //总公里数 运动次数 时长
    UIView *upGrayView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, 320, 44)];
    upGrayView.backgroundColor = RGBCOLOR(105, 105, 105);
    
    
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    //    btn.backgroundColor = [UIColor orangeColor];
//    [btn setFrame:CGRectMake(270, 5, 40, 40)];
//    [btn addTarget:self action:@selector(fenxiangBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *titielLabel = [[UILabel alloc]initWithFrame:CGRectMake(140, 5, 40, 40)];
    titielLabel.textColor = [UIColor whiteColor];
    titielLabel.textAlignment = NSTextAlignmentCenter;
    titielLabel.text = @"历史";
    [upGrayView addSubview:titielLabel];
    
    
    
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, 320, iPhone5? 568-64 : 480-64) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    
    UIView *topInfoView = [self customTableHeaderView];
    _tableView.tableHeaderView = topInfoView;
    
    
    //给属性分配内存
    self.netDataArray = [NSMutableArray arrayWithCapacity:1];
    
    [self.view addSubview:upGrayView];
    
    //请求网络数据
    [self netData];
    
    //下拉刷新
    
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc]initWithFrame:CGRectMake(0, 0-_tableView.bounds.size.height, 320, _tableView.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    [_tableView addSubview:_refreshHeaderView];
    _currentPage = 1;
    _isupMore = NO;//是否为上提加载
    _isUpMoreSuccess = NO;//上提加载是否成功
    
    
    
    //上提加载更多
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    _upMoreView = [[LoadingIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    _upMoreView.type = 1;
    _upMoreView.hidden = YES;
    [view addSubview:_upMoreView];
    
    _tableView.tableFooterView = view;
    
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



-(void)netData{
    
    NSString *urlStr = [NSString stringWithFormat:BIKE_ROAD_LINE_GETGUIJILIST,[LTools cacheForKey:USER_CUSTID],1];
    
    NSLog(@"请求轨迹历史接口的url:%@",urlStr);
    
    
    LTools *tool = [[LTools alloc]initWithUrl:urlStr isPost:NO postData:nil];
    [tool requestCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"result = %@",result);
        
        self.totalCishuLabel.text = [NSString stringWithFormat:@"%@",[result objectForKey:@"Total"]];
        self.totalYongshiLabel.text = [result objectForKey:@"sumCostTime"];
        
        
        self.topTotalDistanceLabel.text = [NSString stringWithFormat:@"%@",[result objectForKey:@"sumCyclingKm"]];
        
        
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
                    model.startTime = [GTimeSwitch testtime:[beginTime substringToIndex:beginTime.length - 3]];
                    
                    NSString *endTime = [NSString stringWithFormat:@"%@",[dic objectForKey:@"endTime"]];
                    
                    model.endTime = [GTimeSwitch testtime:[endTime substringToIndex:beginTime.length - 3]];
                    
                    
                    model.yongshi = [NSString stringWithFormat:@"%@",[dic objectForKey:@"costTime"]];
                    model.juli = [[dic objectForKey:@"cyclingKm"]floatValue];
                    model.jsonStr = [dic objectForKey:@"roadlines"];
                    
                    NSLog(@" ,,,,, %@",model.jsonStr);
                    
                    //1414634471
                    //1414605769
                    
                    NSLog(@"--timeline %@",[LTools timechangeToDateline]);
                    
                    NSLog(@"轨迹字典 ----------- :%@",dic);
                    
                    [self.netDataArray addObject:model];
                }
            }
            
             NSLog(@"self.netDataArray.count = %d",self.netDataArray.count);
            
            [self paixuWithDateWithArray:self.netDataArray];
            
            
            
        }
        
        
        
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        NSLog(@"错误");
        
    }];
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
            
            NSString *date1 = road1.startTime;
            NSString *date2 = road2.startTime;
            
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
    
    for (NSString *str in _fangkaiArray) {
        
        if ([str intValue] == section) {
            
            if (self.dataArray.count>0) {
                
                
                NSArray *arr = self.dataArray[section];
                
                num = arr.count;
                
            }
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


    UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 100, 20)];
    dateLabel.font = [UIFont systemFontOfSize:15];

    [upHeaderView addSubview:dateLabel];



    NSMutableArray *arr = self.dataArray[section];
    GyundongCanshuModel *model = arr[0];
    dateLabel.text = model.startTime;


    return upHeaderView;
}


-(void)ggShouFang:(UIGestureRecognizer*)ges{
    
    NSString *sectionStr = [NSString stringWithFormat:@"%d",(ges.view.tag-10)];
    
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


//tableheaderview
-(UIView *)customTableHeaderView{
    
    UIView *upHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 115)];
    upHeaderView.backgroundColor = [UIColor whiteColor];
    
    self.topTotalDistanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 20, 100, 25)];
    //        self.totalYongshiLabel.backgroundColor = [UIColor orangeColor];
    self.topTotalDistanceLabel.font = [UIFont systemFontOfSize:25];
    self.topTotalDistanceLabel.text = @"0";
    self.topTotalDistanceLabel.textAlignment = NSTextAlignmentRight;
    [upHeaderView addSubview:self.topTotalDistanceLabel];
    
    //用时单位 公里
    UILabel *danweiLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.topTotalDistanceLabel.frame)+5, self.topTotalDistanceLabel.frame.origin.y, 80, 25)];
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


@end
