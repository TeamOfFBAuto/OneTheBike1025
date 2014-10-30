//
//  MineViewController.m
//  OneTheBike
//
//  Created by lichaowei on 14-9-28.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "MineViewController.h"
#import "UMSocial.h"

#import "MineCellOne.h"
#import "MineCellTwo.h"

#import "AppDelegate.h"

#import "UIColor+ConvertColor.h"

#import "UserInfoViewController.h"
#import "MoreViewController.h"
#import "RoadManagerController.h"
#import "UMSocialLoginViewController.h"

#import "GOffLineMapViewController.h"

#import "UserInfoClass.h"
#import "AppDelegate.h"

@interface MineViewController ()<UIActionSheetDelegate>
{
    NSArray *titleArray;
    NSArray *imagesArray;
    
    UserInfoClass *loginUser;
}

@end

@implementation MineViewController

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateUSerInfo];
    
    NSLog(@"--uid %@",[LTools cacheForKey:USER_CUSTID]);
    
    //http://182.254.242.58:8080/QiBa/QiBa/custAction_updateCust.action?custId=1414327474970&nickName=华丽毛毛&sex=1&cellphone=18612389982&personSign=theOne&height=176&weight=145&birthday=1989-5-21&city=linyi
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //适配ios7navigationbar高度
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self.navigationController.navigationBar setBackgroundImage:NAVIGATION_IMAGE forBarMetrics: UIBarMetricsDefault];
    
    UILabel *_titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 21)];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text = @"我的";
    
    self.navigationItem.titleView = _titleLabel;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    
    CGSize screenSize = [[UIScreen mainScreen]bounds].size;
    self.table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.table.backgroundColor = [UIColor colorWithHexString:@"e3e3e3"];
    
    
    imagesArray = @[@"mine_road",@"mine_map",@"mine_share",@"mine_more"];
    titleArray = @[@"路书管理",@"离线地图",@"分享好友",@"更多"];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeUser:) name:NOTIFICATION_CHANGE_USER object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 更新个人信息

- (void)updateUSerInfo
{
    NSString *icon = [LTools cacheForKey:USER_HEAD_IMAGEURL];
    NSString *name = [LTools cacheForKey:USER_NAME];
    NSString *custid = [LTools cacheForKey:USER_CUSTID];
    NSString *gold = [LTools cacheForKey:USER_GOLD];
    
    [self updateUserInfoIcon:icon name:name custID:custid gold:gold];
}

#pragma mark - 事件处理

- (void)updateUserInfoIcon:(NSString *)icon name:(NSString *)nickName custID:(NSString *)custId gold:(NSString *)gold
{
    
    MineCellOne *cell = (MineCellOne *)[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:icon] placeholderImage:[UIImage imageNamed:@""]];
    cell.nameLabel.text = nickName;
    
    cell.infoLabel.text = [NSString stringWithFormat:@"轨币:%@",gold];
    
    NSLog(@"icon %@ nickName %@ gold %@",icon,nickName,gold);
    
    
}


//清空原先数据
- (void)changeUser:(NSNotification *)notification
{
    [self updateUserInfoIcon:nil name:nil custID:nil gold:nil];
}


#pragma mark - 视图创建



#pragma mark - delegate


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 98;
    }
    return 68;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        UserInfoViewController *userInfo = [[UserInfoViewController alloc]init];
        userInfo.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:userInfo animated:YES];
        
    }else if (indexPath.row == 1)
    {
        RoadManagerController *userInfo = [[RoadManagerController alloc]init];
        userInfo.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:userInfo animated:YES];
        
    }else if (indexPath.row == 2)
    {
        NSLog(@"离线地图");
        
        GOffLineMapViewController *detailViewController = [[GOffLineMapViewController alloc] init];
//        detailViewController.mapView = self.mapView;
        
        detailViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:detailViewController];
        
        [self presentModalViewController:navi animated:YES];
        
        
        
    }else if (indexPath.row == 3)
    {
        NSLog(@"分享好友");
        UMSocialLoginViewController *userInfo = [[UMSocialLoginViewController alloc]init];
        userInfo.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:userInfo animated:YES];
        
    }else if (indexPath.row == 4)
    {
        MoreViewController *userInfo = [[MoreViewController alloc]init];
//        userInfo.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:userInfo animated:YES];

    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        static NSString * identifier1= @"MineCellOne";
        
        MineCellOne *cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"MineCellOne" owner:self options:nil]objectAtIndex:0];
        }
        cell.separatorInset = UIEdgeInsetsMake(7, 10, 10, 10);
        cell.backgroundColor = [UIColor clearColor];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
        NSString *icon = [LTools cacheForKey:USER_HEAD_IMAGEURL];
        NSString *name = [LTools cacheForKey:USER_NAME];
        NSString *gold = [LTools cacheForKey:USER_GOLD];
        
        [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:icon] placeholderImage:nil];
        cell.nameLabel.text = name;
        cell.infoLabel.text = [NSString stringWithFormat:@"金币:%@",gold];
        
        return cell;

    }
    
    static NSString * identifier1= @"MineCellTwo";
    
    MineCellTwo *cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"MineCellTwo" owner:self options:nil]objectAtIndex:0];
    }
    
    cell.iconImageView.image = [UIImage imageNamed:[imagesArray objectAtIndex:indexPath.row - 1]];
    cell.aTitleLabel.text = [titleArray objectAtIndex:indexPath.row - 1];
    
    cell.separatorInset = UIEdgeInsetsMake(7, 10, 10, 10);
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}




@end
