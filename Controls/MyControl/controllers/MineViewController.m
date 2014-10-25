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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *authKey = [LTools cacheForKey:USER_NAME];
    if (authKey.length > 0) {
        return;
    }
    
    [self login];
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
    
    [self.table reloadData];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeUser:) name:NOTIFICATION_CHANGE_USER object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark 三方登录

- (void)login
{
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"登录" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"QQ登录",@"新浪微博", nil];
    
    UIView *view = ((AppDelegate *)[UIApplication sharedApplication].delegate).window;
    [sheet showInView:view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    [actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex animated:YES];
    
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        [self loginToPlat:UMShareToQQ];
        
    }else if (buttonIndex == 1){
        
        [self loginToPlat:UMShareToSina];
    }
}

- (void)loginToPlat:(NSString *)snsPlatName
{
    //此处调用授权的方法,你可以把下面的platformName 替换成 UMShareToSina,UMShareToTencent等
    
    __weak typeof(self)weakSelf = self;
    
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:snsPlatName];
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        NSLog(@"login response is %@",response);
        
        //获取微博用户名、uid、token等
        if (response.responseCode == UMSResponseCodeSuccess) {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:snsPlatName];
            NSLog(@"username is %@, uid is %@, token is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken);
//            
            [LTools cache:snsAccount.iconURL ForKey:USER_HEAD_IMAGEURL];
            [LTools cache:snsAccount.userName ForKey:USER_NAME];
            [LTools cache:snsAccount.accessToken ForKey:USER_AUTHKEY_OHTER];
            
//            [weakSelf userInfoWithImage:snsAccount.iconURL name:snsAccount.userName];
            
            [weakSelf loginToServer:snsAccount.usid nickName:snsAccount.userName icon:snsAccount.iconURL];
            
            }
        
    });
}

#pragma mark - 事件处理

- (void)updateUserInfoIcon:(NSString *)icon name:(NSString *)nickName custID:(NSString *)custId gold:(NSString *)gold
{
    MineCellOne *cell = (MineCellOne *)[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    NSString *image = [LTools cacheForKey:USER_HEAD_IMAGEURL];
    
    [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:image] placeholderImage:[UIImage imageNamed:@""]];
    cell.nameLabel.text = nickName;
    
    cell.infoLabel.text = [NSString stringWithFormat:@"轨币:%@",gold];
    
}


//清空原先数据
- (void)changeUser:(NSNotification *)notification
{
    [self updateUserInfoIcon:nil name:nil custID:nil gold:nil];
}

#pragma mark - 数据解析

#pragma mark - 网络请求

- (void)loginToServer:(NSString *)otherUserId nickName:(NSString *)nickName icon:(NSString *)icon
{
    NSString *url = [NSString stringWithFormat:BIKE_LOGIN,otherUserId,nickName,icon];
    LTools *tool = [[LTools alloc]initWithUrl:url isPost:NO postData:nil];
    [tool requestSpecialCompletion:^(NSDictionary *result, NSError *erro) {
        
        NSLog(@"result %@ erro %@",result,erro);
        
        int status = [[result objectForKey:@"status"]integerValue];
        if (status == 1) {
            NSDictionary *dic = [result objectForKey:@"custJson"];
            loginUser = [[UserInfoClass alloc]initWithDictionary:dic];
            
            
            [LTools cache:loginUser.custId ForKey:USER_CUSTID];
            
//            [LTools cache:icon ForKey:USER_HEAD_IMAGEURL];
//            [LTools cache:loginUser.nickName ForKey:USER_NAME];
//            [LTools cache:loginUser ForKey:USER_AUTHKEY_OHTER];

            
            [self updateUserInfoIcon:loginUser.nickName name:loginUser.nickName custID:loginUser.custId gold:loginUser.gold];
            
        }
        
    } failBlock:^(NSDictionary *failDic, NSError *erro) {
        
        NSLog(@"failDic %@ erro %@",failDic,erro);
        
    }];
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
        userInfo.hidesBottomBarWhenPushed = YES;
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
        
        NSString *authKey = [LTools cacheForKey:USER_NAME];
        if (authKey.length > 0) {
            
            NSString *name = [LTools cacheForKey:USER_NAME];
            NSString *imageUrl = [LTools cacheForKey:USER_HEAD_IMAGEURL];
            
            cell.nameLabel.text = name;
            [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil];
        
            NSString *image = [LTools cacheForKey:USER_HEAD_IMAGEURL];
            
            [self updateUserInfoIcon:image name:name custID:@"" gold:loginUser.gold];
            
            
        }else
        {
//            [self login];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
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
