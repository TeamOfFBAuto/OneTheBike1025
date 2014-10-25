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

@interface FindViewController ()<ShareViewDelegate>
{
    UIScrollView * myScrollView;
}

@property(nonatomic,strong)CycleScrollView * mainScorllView;


@end

@implementation FindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    
    NSMutableArray * colorArray = [NSMutableArray arrayWithObjects:@"1111.jpg",@"2222.jpg",@"1111.jpg",@"2222.jpg",@"1111.jpg", nil];
    NSMutableArray * titleArray = [NSMutableArray arrayWithObjects:@"低碳出行爱相随",@"一片蓝天在轮下", @"低碳出行爱相随",@"一片蓝天在轮下",@"低碳出行爱相随",nil];
    NSMutableArray * array = [NSMutableArray array];
    for (int i = 0;i < colorArray.count;i++) {
        CycleScrollModel * model = [[CycleScrollModel alloc] init];
        model.c_title = [titleArray objectAtIndex:i];
        model.c_image_url = [colorArray objectAtIndex:i];
        [array addObject:model];
    }
    
    
    
    myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,DEVICE_WIDTH,DEVICE_HEIGHT-64)];
    myScrollView.showsHorizontalScrollIndicator = NO;
    myScrollView.showsVerticalScrollIndicator = NO;
    myScrollView.contentSize = CGSizeMake(0,500);
    [self.view addSubview:myScrollView];
    
    
    
    self.mainScorllView = [[CycleScrollView alloc] initWithFrame:CGRectMake(0,0,320,175) animationDuration:5.0f WithDataArray:array];
    self.mainScorllView.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.1];
    
    self.mainScorllView.TapActionBlock = ^(NSInteger pageIndex){
        NSLog(@"点击了第%d个",pageIndex);
    };
    [myScrollView addSubview:self.mainScorllView];
    
    
    NSArray * image_array = [NSArray arrayWithObjects:@"find_huodong_image.png",@"find_paihang_image",@"find_bike_qiandao_image",nil];
    NSArray * tArray = [NSArray arrayWithObjects:@"活动",@"排行",@"签到",nil];
 
    
    for (int i = 0;i < 3;i++)
    {
        CGRect frame = CGRectMake(0,180+68*i,320,60);
        [self setupViewWithFrame:frame With:[image_array objectAtIndex:i] Title:[tArray objectAtIndex:i] WithTag:100+i];
    }
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
    ShareView * share_view = [[ShareView alloc] initWithFrame:self.view.bounds];
    share_view.userInteractionEnabled = YES;
    share_view.delegate = self;
    share_view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [share_view showInView:[UIApplication sharedApplication].keyWindow WithAnimation:YES];
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
