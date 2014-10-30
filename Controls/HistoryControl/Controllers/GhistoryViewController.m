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

@interface GhistoryViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation GhistoryViewController


-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
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
    
    [self netData];
    
    
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
        
        if ([result objectForKey:@"status"]) {
            
            NSArray *rows = [result objectForKey:@"Rows"];
            
            NSLog(@"rows.count = %d",rows.count);
            
            for (int i = 0; i<rows.count;i++) {
                NSArray *arr = rows[i];
                
                for (int j = 0;j<arr.count;j++) {
                    
                    NSDictionary *dic = arr[i];
                    
                    GyundongCanshuModel *model = [[GyundongCanshuModel alloc]init];
//                    model.pingjunsudu = [[dic objectForKey:@"avgSpeed"]floatValue];
//                    model.startCoorStr = [dic objectForKey:@"beginCoordinates"];
                    
                    
                    
//                    model.startTime = [GTimeSwitch testtime:[dic objectForKey:@"beginTime"]];
//                    model.endTime = [GTimeSwitch testtime:[dic objectForKey:@"endTime"]];
//                    
//                    
//                    model.yongshi = [NSString stringWithFormat:@"%@",[dic objectForKey:@"costTime"]];
//                    model.juli = [[dic objectForKey:@"cyclingKm"]floatValue];
//                    model.jsonStr = [dic objectForKey:@"roadlines"];
                    
                    
                    NSLog(@"轨迹字典 ----------- :%@",dic);
                    
                    [self.netDataArray addObject:model];
                }
            }
            
            
            NSLog(@"self.netDataArray.count = %d",self.netDataArray.count);
            
            [_tableView reloadData];
            
        }
        
        
        
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        NSLog(@"错误");
        
    }];
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    
    
    return self.netDataArray.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
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
    
    
    
    GyundongCanshuModel *model = self.netDataArray[indexPath.row];
    
    [cell loadCustomCellWithMoedle:model];
    
    return cell;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    GHistoryDetailViewController *cc = [[GHistoryDetailViewController alloc]init];
    GyundongCanshuModel *model = self.netDataArray[indexPath.row];
//    cc.passModel = model;
    cc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cc animated:YES];
}


@end
