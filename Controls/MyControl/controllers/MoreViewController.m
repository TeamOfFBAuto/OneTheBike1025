//
//  MoreViewController.m
//  OneTheBike
//
//  Created by lichaowei on 14-10-18.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "MoreViewController.h"
#import "MineCellTwo.h"

#import "UMFeedbackViewController.h"

#import "AppDelegate.h"

@interface MoreViewController ()
{
    NSArray *titles_arr;
    NSArray *imagesArray;
}

@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //适配ios7navigationbar高度
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeBottom;
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
    _titleLabel.text = @"更多";
    
    self.navigationItem.titleView = _titleLabel;
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 16)];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
    titles_arr = @[@"给个好评",@"联系轨记",@"反馈意见",@"帮助说明",@"更换账号"];
    imagesArray = @[@"more_good",@"more_contact",@"more_recommend",@"more_help",@"more_update"];
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

#pragma mark - 视图创建

#pragma mark - 事件处理

//去app页面评价

- (void)gotoAppStorePageRaisal{
    
    NSString *str = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",APP_ID];
    
    str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/us/app/id%@?mt=8",APP_ID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

- (void)gotoTelephone
{
//    NSString *num = [[NSString alloc] initWithFormat:@"tel://%@",@"18612389982"];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];
    NSString *title = @"骑叭是一款专门为骑行爱好者量身打造的骑行软件,加入我们吧。";
    NSString *message = @"活动发布微博:新浪微博搜素\"骑叭\"\n叭友吐槽QQ群:284570442";
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    [alert show];
    
}

- (void)gotoCheckVersion
{
    //版本更新
    
    [[LTools shareInstance]versionForAppid:APP_ID Block:^(BOOL isNewVersion, NSString *updateUrl, NSString *updateContent) {
        
        NSLog(@"updateContent %@ %@",updateUrl,updateContent);
        
    }];
}

#pragma mark - delegate


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            [self gotoAppStorePageRaisal];
        }
            break;
        case 1:
        {
            [self gotoTelephone];
        }
            break;
        case 2:
        {
            NSLog(@"反馈意见");
            
            
            [self showNativeFeedbackWithAppkey:@"5440c181fd98c5a723000ea0"];

            
            
            
        }
            break;
        case 3:
        {
            NSLog(@"帮助说明");
        }
            break;
        case 4:
        {
//            [self gotoCheckVersion];
            
            NSLog(@"更换账号");
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"是否更换账号？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
        }
            break;
            
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
     
        NSLog(@"切换账号");
        
        [LTools cacheBool:NO ForKey:LOGIN_STATE];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_CHANGE_USER object:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
        
        UITabBarController *root = (UITabBarController *)((AppDelegate *)[UIApplication sharedApplication].delegate).window.rootViewController;
        
        root.selectedIndex = 0;
        
        [GMAPI deleteAllData];
    }
}
#pragma mark-意见反馈

- (void)showNativeFeedbackWithAppkey:(NSString *)appkey {
    
    UMFeedbackViewController *feedbackViewController = [[UMFeedbackViewController alloc] initWithNibName:@"UMFeedbackViewController" bundle:nil];
    feedbackViewController.appkey = appkey;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:feedbackViewController];
    //    navigationController.navigationBar.barStyle = UIBarStyleBlack;
    //    navigationController.navigationBar.translucent = NO;
     [self.navigationController pushViewController:feedbackViewController animated:YES];
    
//    [self presentViewController:navigationController animated:YES completion:^{
//        
//    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return titles_arr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier1= @"MineCellTwo";
    
    MineCellTwo *cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"MineCellTwo" owner:self options:nil]objectAtIndex:0];
    }
    
    cell.separatorInset = UIEdgeInsetsMake(7, 10, 10, 10);
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.aTitleLabel.text = [titles_arr objectAtIndex:indexPath.row];
    cell.iconImageView.image = [UIImage imageNamed:[imagesArray objectAtIndex:indexPath.row]];
    
    return cell;
    
}

@end
