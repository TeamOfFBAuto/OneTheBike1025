//
//  GhistoryViewController.m
//  OneTheBike
//
//  Created by gaomeng on 14/10/28.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "GhistoryViewController.h"
#import "GcustomHistoryTableViewCell.h"
#import "GMAPI.h"
#import "ShareView.h"

@interface GhistoryViewController ()

@end

@implementation GhistoryViewController


-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
    
    
    [self initHeadView];
    
//    _dataArray = (NSMutableArray*)[GMAPI getRoadLinesForType:2];
    _dataArray = [NSMutableArray arrayWithArray:[GMAPI getRoadLinesForType:2]];
    
    _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 140+64, 320, iPhone5?568-140:480-140) style:UITableViewStylePlain];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    [self.view addSubview:_tableview];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
   
    
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = @"cell";
    GcustomHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell ) {
        cell = [[GcustomHistoryTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    [cell loadCustomCellWithMoedle:_dataArray[indexPath.row]];
    
    
    return cell;
}




-(void)initHeadView{
    //自定义导航栏
    //总公里数 运动次数 时长
    UIView *upGrayView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, 320, 44)];
    upGrayView.backgroundColor = RGBCOLOR(105, 105, 105);
    
    UILabel *titielLabel = [[UILabel alloc]initWithFrame:CGRectMake(140, 5, 40, 40)];
    titielLabel.textColor = [UIColor whiteColor];
    titielLabel.textAlignment = NSTextAlignmentCenter;
    titielLabel.text = @"历史";
    [upGrayView addSubview:titielLabel];
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"分享" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13];
    [btn setFrame:CGRectMake(270, 6, 40, 40)];
    [btn addTarget:self action:@selector(fenxiangClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [upGrayView addSubview:btn];
    [self.view addSubview:upGrayView];
    
    
    UIView *upHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, 320, 140)];
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
//            self.totalYongshiLabel.backgroundColor = [UIColor orangeColor];
    self.totalYongshiLabel.textColor = RGBCOLOR(105, 105, 105);
    self.totalYongshiLabel.text = @"00:00:00";
    [upHeaderView addSubview:self.totalYongshiLabel];
    
    UILabel *cccLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.totalYongshiLabel.frame.origin.x, CGRectGetMaxY(self.totalYongshiLabel.frame), 100, 12)];
    cccLabel.textColor = RGBCOLOR(105, 105, 105);
    cccLabel.textAlignment = NSTextAlignmentCenter;
    cccLabel.font = [UIFont systemFontOfSize:12];
    cccLabel.text = @"时长";
    [upHeaderView addSubview:cccLabel];
    
    [self.view addSubview:upHeaderView];
}


-(void)fenxiangClicked{
    ShareView * share_view = [[ShareView alloc] initWithFrame:self.view.bounds];
    share_view.userInteractionEnabled = YES;
    share_view.delegate = self;
    share_view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [share_view showInView:[UIApplication sharedApplication].keyWindow WithAnimation:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
