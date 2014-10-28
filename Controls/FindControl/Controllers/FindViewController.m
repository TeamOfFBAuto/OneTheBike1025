//
//  FindViewController.m
//  OneTheBike
//
//  Created by szk on 14-9-24.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "FindViewController.h"
#import "CycleScrollView.h"
#import "FindActivityViewController.h"
#import "FindRankingViewController.h"
#import "CycleScrollModel.h"
#import "ShareView.h"
#import "AFHTTPRequestOperation.h"
#import "ActivityDetailViewController.h"
#import "UMSocial.h"



@interface FindViewController ()<ShareViewDelegate,UIAlertViewDelegate,UMSocialUIDelegate>
{
    UIScrollView * myScrollView;
    AFHTTPRequestOperation * request;
    
}

@property(nonatomic,strong)CycleScrollView * mainScorllView;
@property(nonatomic,strong)NSMutableArray * data_array;

@end

@implementation FindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _data_array = [NSMutableArray array];
//    
    //适配ios7navigationbar高度
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self.navigationController.navigationBar setBackgroundImage:NAVIGATION_IMAGE forBarMetrics: UIBarMetricsDefault];
    
    UILabel *_titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 21)];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text = @"发现";
    
    self.navigationItem.titleView = _titleLabel;
    
    self.view.backgroundColor=RGBCOLOR(227,227,227);
    
    myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,DEVICE_WIDTH,DEVICE_HEIGHT-64)];
    myScrollView.showsHorizontalScrollIndicator = NO;
    myScrollView.showsVerticalScrollIndicator = NO;
    myScrollView.contentSize = CGSizeMake(0,500);
    [self.view addSubview:myScrollView];
    
    
    NSArray * image_array = [NSArray arrayWithObjects:@"find_huodong_image.png",@"find_paihang_image",@"find_bike_qiandao_image",nil];
    NSArray * tArray = [NSArray arrayWithObjects:@"活动",@"排行",@"签到",nil];
 
    for (int i = 0;i < 3;i++)
    {
        CGRect frame = CGRectMake(0,180+68*i,320,60);
        [self setupViewWithFrame:frame With:[image_array objectAtIndex:i] Title:[tArray objectAtIndex:i] WithTag:100+i];
    }
    
    
    [self getData];
}

#pragma mark - 获取幻灯数据
-(void)getData
{
    request = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://182.254.242.58:8080/QiBa/QiBa/activityAction_imagesPlay.action"]]];
    __weak typeof(self) bself = self;
    
    [request setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        @try {
            NSDictionary * allDic = [operation.responseString objectFromJSONString];
            NSArray * array = [allDic objectForKey:@"Rows"];
            
            if ([array isKindOfClass:[NSArray class]] && array.count > 0)
            {
                NSArray * temp = [array objectAtIndex:0];
                for (NSDictionary * dic in temp)
                {
                    CycleScrollModel * model = [[CycleScrollModel alloc] init];
                    model.c_id = [dic objectForKey:@"activityId"];
                    model.c_image_url = [dic objectForKey:@"thumbnailUrl"];
                    model.c_title = [dic objectForKey:@"subtitle"];
                    [bself.data_array addObject:model];
                }
                [bself setup];
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    
    [request start];
}

#pragma mark - 加载幻灯数据
-(void)setup
{
    self.mainScorllView = [[CycleScrollView alloc] initWithFrame:CGRectMake(0,0,320,175) animationDuration:5.0f WithDataArray:_data_array];
    self.mainScorllView.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.1];
    __weak typeof(self)bself = self;
    self.mainScorllView.TapActionBlock = ^(NSInteger pageIndex){
        NSLog(@"点击了第%d个",pageIndex);
        
        CycleScrollModel * model = [bself.data_array objectAtIndex:pageIndex];
        ActivityDetailViewController * detail = [[ActivityDetailViewController alloc] init];
        detail.aId  =model.c_id;
        [bself.navigationController pushViewController:detail animated:YES];
    };
    [myScrollView addSubview:self.mainScorllView];
}

#pragma mark - 活动、排行视图布局

-(void)setupViewWithFrame:(CGRect)frame With:(NSString *)icon Title:(NSString *)aTitle WithTag:(int)tag
{
    UIView * aView = [[UIView alloc] initWithFrame:frame];
    aView.backgroundColor = [UIColor whiteColor];
    aView.tag = tag;
    [myScrollView addSubview:aView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTap:)];
    [aView addGestureRecognizer:tap];
    
    
    UIImageView * icon_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20,10,40,40)];
    icon_imageView.image = [UIImage imageNamed:icon];
    [aView addSubview:icon_imageView];
    
    UILabel * title_label = [[UILabel alloc] initWithFrame:CGRectMake(80,0,200,frame.size.height)];
    title_label.textAlignment = NSTextAlignmentLeft;
    title_label.text = aTitle;
    title_label.textColor = [UIColor blackColor];
    title_label.font = [UIFont systemFontOfSize:18];
    [aView addSubview:title_label];
    
    UIButton * access_button = [UIButton buttonWithType:UIButtonTypeCustom];
    access_button.frame = CGRectMake(280,10,40,frame.size.height-20);
    [access_button setImage:[UIImage imageNamed:@"right_jiantou_image"] forState:UIControlStateNormal];
    access_button.userInteractionEnabled = NO;
    [aView addSubview:access_button];
}



-(void)doTap:(UITapGestureRecognizer *)sender
{
    if (sender.view.tag == 100)///活动
    {
        
        FindActivityViewController * activity = [[FindActivityViewController alloc] init];
        activity.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:activity animated:YES];
        
    }else if(sender.view.tag == 101)///排行
    {
        FindRankingViewController * activity = [[FindRankingViewController alloc] init];
        activity.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:activity animated:YES];
    }else if (sender.view.tag == 102)///每日一签
    {
        [self CheckIn];
    }
}

#pragma mark - 签到
-(void)CheckIn
{
    NSString * fullUrl = [NSString stringWithFormat:@"http://182.254.242.58:8080/QiBa/QiBa/custAction_mark.action?custId=%@",[LTools cacheForKey:USER_CUSTID]];
    AFHTTPRequestOperation * aRequest = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:fullUrl]]];
    [aRequest setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary * allDic = [operation.responseString objectFromJSONString];
        
        if ([[allDic objectForKey:@"status"] intValue] == 0) {
            [LTools showMBProgressWithText:@"您今天已经签到过了" addToView:self.view];
        }else if ([[allDic objectForKey:@"status"] intValue] == 1)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"签到成功,分享给朋友吧" message:@"" delegate:self cancelButtonTitle:@"去分享" otherButtonTitles:@"下次再说",nil];
            [alert show];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LTools showMBProgressWithText:@"签到失败，请重试" addToView:self.view];
    }];
    
    [aRequest start];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex ----  %d",buttonIndex);
    
    if (buttonIndex == 0)
    {
        [self performSelector:@selector(ShowShareView) withObject:nil afterDelay:0.8];
    }
}

-(void)ShowShareView
{
    ShareView * share_view = [[ShareView alloc] initWithFrame:self.view.bounds];
    share_view.userInteractionEnabled = YES;
    share_view.delegate = self;
    share_view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [share_view showInView:[UIApplication sharedApplication].keyWindow WithAnimation:YES];
}

-(void)shareTapWithType:(NSString *)type
{
    [[UMSocialControllerService defaultControllerService] setShareText:@"小手一抖，积分到手，每日一签，欢乐多多，兑换装备，分享抽奖。#骑行叭宝盒# @骑叭" shareImage:[UIImage imageNamed:@"icon120.png"] socialUIDelegate:self];        //设置分享内容和回调对象
    [UMSocialSnsPlatformManager getSocialPlatformWithName:type].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
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
