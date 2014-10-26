//
//  RoadManagerController.m
//  OneTheBike
//
//  Created by lichaowei on 14-10-18.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "RoadManagerController.h"
#import "RoadProduceController.h"
#import "RoadCell.h"
#import "RoadProduceController.h"

#import "AppDelegate.h"

#import "LRoadClass.h"

#import "RoadInfoViewController.h"

#import "ServerRoadClass.h"

@interface RoadManagerController ()
{
    NSArray *titles_arr;
    NSArray *imagesArray;
    int road_count;
    
    NSArray *roads_arr;
    
    MBProgressHUD *loading;
}

@end

@implementation RoadManagerController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    NSString *road_ids = [LTools cacheForKey:ROAD_IDS];
//    road_count = [road_ids intValue];
    
    [self updateViewDataSource];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //适配ios7navigationbar高度
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self.navigationController.navigationBar setBackgroundImage:NAVIGATION_IMAGE forBarMetrics: UIBarMetricsDefault];
    
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"e3e3e3"];
    
    UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButton.width = -5;
    
    UIButton *_button_back=[[UIButton alloc]initWithFrame:CGRectMake(0,0,40,44)];
    [_button_back addTarget:self action:@selector(clickToBack:) forControlEvents:UIControlEventTouchUpInside];
    [_button_back setImage:BACK_IMAGE forState:UIControlStateNormal];
    _button_back.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem *back_item=[[UIBarButtonItem alloc]initWithCustomView:_button_back];
    self.navigationItem.leftBarButtonItems=@[spaceButton,back_item];
    
    UILabel *_titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 21)];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text = @"路书";
    
    self.navigationItem.titleView = _titleLabel;
    
    
    
    UIBarButtonItem *spaceButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButton1.width = IOS7_OR_LATER ? - 7 : 7;
    
    UIButton *settings=[[UIButton alloc]initWithFrame:CGRectMake(20,8,40,44)];
    [settings addTarget:self action:@selector(clickToAdd:) forControlEvents:UIControlEventTouchUpInside];
    [settings setImage:[UIImage imageNamed:@"+"] forState:UIControlStateNormal];
    [settings setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [settings setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    UIBarButtonItem *right =[[UIBarButtonItem alloc]initWithCustomView:settings];
    self.navigationItem.rightBarButtonItems = @[spaceButton1,right];
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 16)];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
    loading = [LTools MBProgressWithText:@"路书同步" addToView:self.view];
    
    NSString *custid = [LTools cacheForKey:USER_CUSTID];
    
    [self getRoadlistWithUserId:custid page:1];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickToBack:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 数据解析

#pragma mark - 网络请求


- (void)getRoadlistWithUserId:(NSString *)userId page:(int)page
{
    [loading show:YES];
    
    NSString *url = [NSString stringWithFormat:BIKE_ROAD_LIST,userId,page];
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    [tool requestSpecialCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"result %@ erro %@",result,erro);
        NSArray *rows = [result objectForKey:@"Rows"];
        
        if ([rows isKindOfClass:[NSArray class]] && (rows.count >= 1)) {
            
            NSArray *arr = [rows objectAtIndex:0];
            
            if ([arr isKindOfClass:[NSArray class]]) {
                
                for (NSDictionary *aDic in arr) {
                    
                    ServerRoadClass *aRoad = [[ServerRoadClass alloc]initWithDictionary:aDic];
                    
                    if (![GMAPI existForServerRoadId:aRoad.rdbkId]) {
                        
                        NSString *distace = [NSString stringWithFormat:@"%f",aRoad.distance];
                        
                        [GMAPI addRoadLinesJsonString:aRoad.roadlines startName:aRoad.beginSite endName:aRoad.endSite distance:distace type:Type_Road startCoorStr:aRoad.beginCoordinates endCoorStr:aRoad.endCoordinates serverRoadId:aRoad.rdbkId isUpload:YES];
                        
                    }else
                    {
                        NSLog(@"you");
                    }
                    
                    
                }
            }
            
        }
        
        [self updateViewDataSource];
        
        [loading hide:YES];
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        NSLog(@"failDic %@ erro %@",failDic,erro);
        
        [self updateViewDataSource];
        
        [loading hide:YES];
        
        [LTools showMBProgressWithText:@"路书同步失败" addToView:self.view];
        
    }];
}


#pragma mark - 视图创建

#pragma mark - 事件处理

//更新显示数据
- (void)updateViewDataSource
{
    roads_arr = [GMAPI getRoadLinesForType:Type_Road];
    
    [self.tableView reloadData];
}

- (void)clickToAdd:(UIButton *)sender
{
    RoadProduceController *produce = [[RoadProduceController alloc]init];
    produce.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:produce animated:YES];
}

#pragma mark - delegate


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        RoadInfoViewController *produce = [[RoadInfoViewController alloc]initWithStyle:UITableViewStylePlain];
        LRoadClass *road = [roads_arr objectAtIndex:indexPath.row];
        produce.aRoad = road;
        produce.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:produce animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return roads_arr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier1= @"RoadCell";
    
    RoadCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"RoadCell" owner:self options:nil]objectAtIndex:0];
    }
    
    cell.separatorInset = UIEdgeInsetsMake(7, 10, 10, 10);
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.iconImageView.image = [UIImage imageNamed:@"mine_road"];
    
    LRoadClass *road = [roads_arr objectAtIndex:indexPath.row];
    NSString *start = [NSString stringWithFormat:@"起:%@",road.startName];
    NSString *end = [NSString stringWithFormat:@"终:%@",road.endName];

    NSLog(@"--->%d",road.roadId);
    cell.startLabel.text = start;
    cell.endLabel.text = end;
    
    return cell;
    
}

@end
